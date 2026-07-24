function tests = test_noPhenomParams()
%TEST_NOPHENOMPARAMS Guards the v1.4 M3/M4 interface decision.
%
%   Run with:  runtests("tests/test_noPhenomParams.m")
%
%   v1.3 and earlier described channel gating three times over: a
%   phenomenological dose expression in M3, a three-state MSIC model also
%   in M3, and a P_o(tau) sigmoid in M4.  Rest insertion, cycle saturation,
%   threshold and supralinearity each had two representations, and the
%   scalar that was supposed to cross the fast/slow boundary, D_mech, had
%   no consumer at all (appendix C5.1).
%
%   v1.4 deleted five phenomenological free parameters and moved tau_50 /
%   k_tau into k_co(tau).  Those parameters are easy to reintroduce by
%   reflex when a validation target proves stubborn -- which is exactly
%   when doing so would be most harmful, because it buys the fit with an
%   unidentifiable degree of freedom (§9 risk 1).  Hence this test.
%
%   Project: bone-mechanostat (PROJECT_PLAN v1.4)

tests = functiontests(localfunctions);
end

% -------------------------------------------------------------------------
function setupOnce(tc)
tc.TestData.p = getDefaultParams();

% Distinctive names of constructs deleted in v1.4.  Kept as a blacklist
% because these could reappear under any module tag.
%
% NOTE: speculative entries "N_p" and "q_exp" were removed from this list.
% "N_p" lower-cases onto n_P, the PTH secretion Hill coefficient in M8 --
% a legitimate parameter with no relation to the deleted cycle-count
% exponent.  A guard that cries wolf gets deleted by the next person to
% hit it, so the cycle/dose exponents are policed by the M3 whitelist
% below instead of by guessing at their names.
tc.TestData.bannedNames = ["a_r" "tau_r" "tau_th" "Phi_rest" "phi_rest"];

% M3 may contain ONLY the mechanistic MSIC parameters.  This is a
% whitelist, so any new M3 parameter -- whatever it is called -- fails
% until someone justifies it.  Stronger than enumerating what we banned.
tc.TestData.allowedM3 = ["tau_50" "k_tau_sig" "k_co_max" ...
                         "k_oc" "k_oi" "k_ic" "T_day"];
% Distinctive source tokens.  Deliberately excludes the bare "p" and "q"
% exponents: "p" is the parameter struct everywhere in this code base, so
% grepping it would be pure noise.
tc.TestData.bannedTokens = ["Phi_rest" "tau_th" "P_o(" "phiRest" "tauTh"];
end

function testCsvHasNoDeletedParameters(tc)
t = tc.TestData.p.meta;
found = intersect(lower(tc.TestData.bannedNames), lower(t.name));
% Concatenate with +, not [..].  ["a" "b"] is a string ARRAY and sprintf
% rejects it as an invalid format -- which made this very test error out
% unconditionally on its first run, passing no judgement at all.
msg = "parameters_literature.csv reintroduces phenomenological " + ...
      "parameter(s) deleted in v1.4: %s." + newline + ...
      "Cycle saturation (V4) must emerge from k_oi, rest insertion (V5) " + ...
      "from k_ic, threshold and supralinearity from tau_50 / k_tau_sig.";
verifyEmpty(tc, found, sprintf(msg, strjoin(found, ", ")));
end

function testM3ContainsOnlyMsicParameters(tc)
% Whitelist: the daily dose is int_day O(t) dt and nothing else.  Any extra
% M3 parameter means a phenomenological term has crept back in beside the
% three-state model -- the exact four-fold double counting v1.4 removed
% (appendix C5.1).
t = tc.TestData.p.meta;
m3 = t.name(t.module == "M3");
extra = setdiff(m3, tc.TestData.allowedM3);
msg = "Module M3 contains unexpected parameter(s): %s." + newline + ...
      "M3 is the three-state MSIC model only.  Cycle saturation and " + ...
      "rest insertion must emerge from k_oi / k_ic, not from new terms.";
verifyEmpty(tc, extra, sprintf(msg, strjoin(extra, ", ")));
end

function testMsicRateConstantsArePresent(tc)
% The mechanistic replacements must actually exist.
p = tc.TestData.p;
required = ["tau_50" "k_tau_sig" "k_co_max" "k_oc" "k_oi" "k_ic"];
for name = required
    verifyTrue(tc, isfield(p, name), sprintf( ...
        "MSIC parameter '%s' is missing from the CSV.", name));
end
end

function testNoPoSigmoidInSource(tc)
% M4 must not define its own open-probability sigmoid.
root = projectRoot();
files = dir(fullfile(root, "src", "**", "*.m"));
offenders = string.empty;

for k = 1:numel(files)
    f = fullfile(files(k).folder, files(k).name);
    txt = string(fileread(f));
    code = localStripComments(txt);
    for token = tc.TestData.bannedTokens
        if contains(code, token)
            offenders(end+1) = files(k).name + " (" + token + ")"; %#ok<AGROW>
        end
    end
end

msg = "Source reintroduces a deleted construct: %s." + newline + ...
      "Channel gating lives only in msicGating.m (v1.4, appendix C5.2).";
verifyEmpty(tc, offenders, sprintf(msg, strjoin(offenders, "; ")));
end

function testSingleFastSlowInterface(tc)
% loadingDose.m is the sole producer of the scalar crossing the fast/slow
% boundary, and osteocyteSignal.m its sole consumer.  Both must exist.
root = projectRoot();
verifyTrue(tc, isfile(fullfile(root, "src", "mech", "loadingDose.m")), ...
    "loadingDose.m (D_eff producer) is missing.");
verifyTrue(tc, isfile(fullfile(root, "src", "mech", "msicGating.m")), ...
    "msicGating.m (the single channel model) is missing.");
verifyTrue(tc, isfile(fullfile(root, "src", "signal", "osteocyteSignal.m")), ...
    "osteocyteSignal.m (D_eff consumer) is missing.");
end

% -------------------------------------------------------------------------
function code = localStripComments(txt)
%LOCALSTRIPCOMMENTS Remove whole-line and trailing % comments.
%   Crude but sufficient: the banned tokens appear in docstrings on purpose
%   (they document what was removed), so comments must not count as hits.
lines = splitlines(txt);
for k = 1:numel(lines)
    idx = strfind(lines(k), "%");
    if ~isempty(idx)
        lines(k) = extractBefore(lines(k) + "%", idx(1));
    end
end
code = join(lines, newline);
end
