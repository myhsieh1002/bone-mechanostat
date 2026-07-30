#!/usr/bin/env python3
"""Align manuscript.tex paragraphs to manuscript.md and diff the numbers.

Run from the submission folder (which is gitignored, so it is not in this
repository -- keep it beside the repo or pass the paths in):

    cd "<submission folder>" && python3 <repo>/tools/reconcile_manuscript_numbers.py

*** WHY THIS EXISTS (P5o, appendix C35.7) ***
The manuscript is maintained in three formats and they drift.  It has now
happened twice.  At v2.13 the .md carried 3 citations where the .tex carried
18, and the .docx -- which is generated from the .md and is the file actually
submitted -- was the one missing them.  At v2.24 the same thing had happened
to the NUMBERS: the romosozumab response read +12.459 in the .md, +12.461 in
the .tex and +12.179 in the zh-TW copy, three different parameter vintages in
three files describing one model.  Several values in all three were older than
the model itself.

A global multiset diff of numbers cannot find this, because it cannot say
WHICH claim disagrees.  This aligns paragraph by paragraph first (difflib on
normalised text), then compares the ordered numbers inside each aligned pair,
so the output names the sentence.

Remaining reported mismatches are expected to be markup artefacts only:
exponent notation (1 x 10^-13 splits differently in the two formats), chi^2
superscripts, and the ORCID line, which has no counterpart in the .tex.
Anything else is a real divergence.

*** THE AUTHORITATIVE SOURCE IS NEITHER FILE ***
It is the current experiment output.  Reconciling the formats against each
other is not enough; at v2.24 both were wrong about the rest-insertion gain.
Re-run E0-E7 and check against those numbers, then bring the formats to it.
"""

import re, sys, difflib, unicodedata

MD  = 'manuscript.md'
TEX = 'manuscript.tex'


def norm_md(s):
    s = s[:s.index('## References')] if '## References' in s else s
    s = re.sub(r'^\s*#.*$', '', s, flags=re.M)          # headings
    s = s.replace('**', '').replace('*', '')
    s = re.sub(r'`([^`]*)`', r'\1', s)
    s = re.sub(r'\[(\d+(?:\s*,\s*\d+)*)\]', ' ', s)      # citation markers
    s = re.sub(r'<[^>]+>', ' ', s)
    return s


def norm_tex(s):
    i = s.find(r'\begin{thebibliography}')
    if i > 0:
        s = s[:i]
    i = s.find(r'\bibitem')
    if i > 0:
        s = s[:i]
    s = re.sub(r'(?<!\\)%.*$', '', s, flags=re.M)        # comments
    s = re.sub(r'\\(section|subsection|subsubsection|title|author)\*?\{[^}]*\}', ' ', s)
    s = re.sub(r'\\cite\{[^}]*\}', ' ', s)
    s = re.sub(r'\\label\{[^}]*\}', ' ', s)
    s = re.sub(r'\\(textbf|textit|emph|texttt|mathrm|text)\{', '{', s)
    s = s.replace(r'\,', '').replace(r'\%', '%').replace(r'\times', 'x')
    s = re.sub(r'\^\{?-?(\d+)\}?', r'e\1', s)            # 10^{-4} -> 10e4
    s = re.sub(r'\\[a-zA-Z]+\*?', ' ', s)                # remaining commands
    s = s.replace('{', ' ').replace('}', ' ').replace('$', ' ')
    s = s.replace('--', '-')
    return s


def paras(s):
    out = []
    for p in re.split(r'\n\s*\n', s):
        p = unicodedata.normalize('NFKC', p)
        p = re.sub(r'\s+', ' ', p).strip()
        if len(p) > 60:
            out.append(p)
    return out


NUM = re.compile(r'(?<![\w.])[-+\u2212]?\d+(?:\.\d+)?')


def nums(p):
    """Numbers, excluding pure section/figure references and years."""
    out = []
    for m in NUM.finditer(p):
        tok = m.group().replace('\u2212', '-')
        ctx = p[max(0, m.start() - 22):m.start()].lower()
        if re.search(r'(fig|table|text|s1|s2)\s*$', ctx):
            continue
        out.append(tok)
    return out


def key(p):
    return re.sub(r'[^a-z ]', '', p.lower())[:400]


md = paras(norm_md(open(MD, encoding='utf-8').read()))
tx = paras(norm_tex(open(TEX, encoding='utf-8').read()))

sm = difflib.SequenceMatcher(None, [key(p) for p in md], [key(p) for p in tx], autojunk=False)

# Greedy best-match alignment: for each md paragraph find the most similar tex one.
used, pairs, unmatched = set(), [], []
for i, p in enumerate(md):
    best, bj = 0.0, None
    for j, q in enumerate(tx):
        if j in used:
            continue
        r = difflib.SequenceMatcher(None, key(p), key(q)).ratio()
        if r > best:
            best, bj = r, j
    if bj is not None and best > 0.55:
        used.add(bj)
        pairs.append((i, bj, best))
    else:
        unmatched.append((i, best))

bad = 0
for i, j, r in pairs:
    a, b = nums(md[i]), nums(tx[j])
    if a != b:
        bad += 1
        print(f'\n=== md para {i}  <->  tex para {j}   (similarity {r:.2f}) ===')
        print('  md :', a)
        print('  tex:', b)
        sa, sb = set(a), set(b)
        print('  only in md :', sorted(sa - sb))
        print('  only in tex:', sorted(sb - sa))
        print('  md text : ', md[i][:230])
        print('  tex text: ', tx[j][:230])

print(f'\n\naligned {len(pairs)} / {len(md)} md paragraphs; {bad} with number mismatches')
if unmatched:
    print(f'\nUNALIGNED md paragraphs ({len(unmatched)}):')
    for i, r in unmatched:
        print(f'  [{i}] best={r:.2f} :: {md[i][:150]}')
leftover = [j for j in range(len(tx)) if j not in used]
if leftover:
    print(f'\nUNALIGNED tex paragraphs ({len(leftover)}):')
    for j in leftover:
        print(f'  [{j}] :: {tx[j][:150]}')
