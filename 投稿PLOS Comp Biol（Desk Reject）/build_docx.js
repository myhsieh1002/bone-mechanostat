// Build the PLOS Computational Biology manuscript as .docx from manuscript.md
const fs = require('fs');
const {
  Document, Packer, Paragraph, TextRun, HeadingLevel, AlignmentType,
  PageOrientation, LineRuleType, Footer, PageNumber, LineNumberRestartFormat,
} = require('docx');

const SRC = process.argv[2];
const OUT = process.argv[3];
const md = fs.readFileSync(SRC, 'utf8').split('\n');

// --- inline markdown -> TextRun[] -------------------------------------------
// Handles **bold**, *italic*, `code`, and <sup>n</sup>. Deliberately small:
// the manuscript uses nothing else.
function runs(text, base = {}) {
  text = text.replace(/\\([*_\[\]#`\\])/g, '$1');   // drop markdown escapes
  const out = [];
  const re = /(\*\*[^*]+\*\*|\*[^*]+\*|`[^`]+`|<sup>[^<]+<\/sup>|<\/?[a-z]+>)/g;
  let last = 0, m;
  const push = (t, opts) => { if (t) out.push(new TextRun({ text: t, ...base, ...opts })); };
  while ((m = re.exec(text)) !== null) {
    push(text.slice(last, m.index), {});
    const tok = m[0];
    if (tok.startsWith('**')) push(tok.slice(2, -2), { bold: true });
    else if (tok.startsWith('`')) push(tok.slice(1, -1), { font: 'Courier New' });
    else if (tok.startsWith('<sup>')) push(tok.slice(5, -6), { superScript: true });
    else if (tok.startsWith('<')) { /* stray tag: drop */ }
    else push(tok.slice(1, -1), { italics: true });
    last = re.lastIndex;
  }
  push(text.slice(last), {});
  return out.length ? out : [new TextRun({ text: '', ...base })];
}

const FONT = process.argv[4] || 'Times New Roman';
const BODY = { font: FONT, size: 24 };   // 12 pt
const SPACING = { line: 480, lineRule: LineRuleType.AUTO, after: 120 }; // double

const children = [];
const para = (text, opts = {}) => children.push(new Paragraph({
  children: runs(text, opts.base || BODY),
  spacing: opts.spacing || SPACING,
  alignment: opts.alignment,
  heading: opts.heading,
  pageBreakBefore: opts.pageBreakBefore,
}));

let i = 0;
// Title
while (i < md.length && !md[i].startsWith('# ')) i++;
children.push(new Paragraph({
  children: runs(md[i].slice(2), { font: FONT, size: 32, bold: true }),
  spacing: { line: 360, lineRule: LineRuleType.AUTO, after: 240 },
  alignment: AlignmentType.LEFT,
}));
i++;

let inRefs = false;
for (; i < md.length; i++) {
  const line = md[i];
  const t = line.trim();

  if (t === '' || t === '---') continue;

  if (t.startsWith('## ')) {
    inRefs = t.slice(3).trim() === 'References';
    children.push(new Paragraph({
      children: runs(t.slice(3), { font: FONT, size: 28, bold: true }),
      spacing: { before: 360, after: 160, line: 360, lineRule: LineRuleType.AUTO },
      heading: HeadingLevel.HEADING_1,
    }));
    continue;
  }
  if (t.startsWith('### ')) {
    children.push(new Paragraph({
      children: runs(t.slice(4), { font: FONT, size: 24, bold: true, italics: true }),
      spacing: { before: 240, after: 120, line: 360, lineRule: LineRuleType.AUTO },
      heading: HeadingLevel.HEADING_2,
    }));
    continue;
  }

  // Blockquote: render as an indented note, not a literal '>'
  if (t.startsWith('> ') || t === '>') {
    children.push(new Paragraph({
      children: runs(t.replace(/^>\s?/, ''), BODY),
      spacing: { line: 360, lineRule: LineRuleType.AUTO, after: 100 },
      indent: { left: 400 },
    }));
    continue;
  }

  // Reference list: single-spaced, hanging feel via smaller spacing
  if (inRefs && /^\d+\./.test(t)) {
    children.push(new Paragraph({
      children: runs(t, BODY),
      spacing: { line: 300, lineRule: LineRuleType.AUTO, after: 80 },
    }));
    continue;
  }

  para(t);
}

const doc = new Document({
  creator: 'Ming-Yu Hsieh',
  title: 'From fluid shear to sclerostin',
  styles: { default: { document: { run: BODY } } },
  sections: [{
    properties: {
      page: {
        size: { width: 12240, height: 15840, orientation: PageOrientation.PORTRAIT },
        margin: { top: 1440, right: 1440, bottom: 1440, left: 1440 },
      },
      // PLOS reviewers work from line and page numbers.
      lineNumbers: { countBy: 1, restart: LineNumberRestartFormat.CONTINUOUS, distance: 360 },
    },
    footers: {
      default: new Footer({
        children: [new Paragraph({
          alignment: AlignmentType.CENTER,
          children: [new TextRun({ children: [PageNumber.CURRENT], font: FONT, size: 20 })],
        })],
      }),
    },
    children,
  }],
});

Packer.toBuffer(doc).then(buf => {
  fs.writeFileSync(OUT, buf);
  console.log('written:', OUT, (buf.length / 1024).toFixed(0) + ' KB');
});
