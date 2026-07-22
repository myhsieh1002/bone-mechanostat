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
% Names and symbols removed in v1.4.
tc.TestData.bannedNames = ["a_r" "tau_r" "p_cycle" "tau_th" "q_dose" ...
                           "Phi_rest" "N_p" "q_exp"];
% Distinctive source tokens.  Deliberately excludes the bare "p" and "q"
% exponents: "p" is the parameter struct everywhere in this code base, so
% grepping it would be pure noise.
tc.TestData.bannedTokens = ["Phi_rest" "tau_th" "P_o(" "phiRest" "tauTh"];
end

function testCsvHasNoDeletedParameters(tc)
t = tc.TestData.p.meta;
found = intersect(lower(tc.TestData.bannedNames), lower(t.name));
verifyEmpty(tc, found, sprintf( ...
    ["parameters_literature.csv reintroduces phenomenological " ...
     "parameter(s) deleted in v1.4: %s.\n" ...
     "Cycle saturation (V4) must emerge from k_oi, rest insertion (V5) " ...
     "from k_ic, threshold and supralinearity from tau_50 / k_tau_sig."], ...
    strjoin(found, ", ")));
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

verifyEmpty(tc, offenders, sprintf( ...
    ["Source reintroduces a deleted construct: %s.\n" ...
     "Channel gating lives only in msicGating.m (v1.4, appendix C5.2)."], ...
    strjoin(offenders, "; ")));
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
