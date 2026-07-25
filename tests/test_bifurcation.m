function tests = test_bifurcation()
%TEST_BIFURCATION P6 -- steady state and the P3 bistability question.
%
%   Run with:  runtests("tests/test_bifurcation.m")
%
%   Guards the P6 finding (appendix C15): the baseline is a STABLE fixed
%   point, and the porosity dynamics are MONOSTABLE across the bifurcation
%   parameters -- so P3 (osteoporosis as a saddle-node alternative stable
%   state) is NOT supported at physiological parameters.  These assertions
%   pin the negative result so a future change that (re)introduces spurious
%   bistability is caught.
%
%   Project: bone-mechanostat (PROJECT_PLAN v2.3)

tests = functiontests(localfunctions);
end

function setupOnce(tc)
tc.TestData.p = getDefaultParams(reload = true);
end

function testBaselineIsStable(tc)
% E0: the healthy baseline must be a stable equilibrium (all eigenvalues in
% the left half plane) of the frozen-geometry system.
[~, ~, ev] = steadyState(tc.TestData.p, days = 2000);
verifyLessThan(tc, max(real(ev)), 0, ...
    "Baseline must be a stable fixed point (max Re(eig) < 0).");
end

function testEstrogenBranchIsMonostable(tc)
% P3 answer: sweeping oestrogen, the porosity equilibrium must stay a
% SINGLE attractor (no saddle-node / bistability).  A steep but continuous
% shift is expected; two simultaneous stable states would be P3.
br = continuation("E2", 0.7:0.1:1.0, nFbm = 24, days = 700);
verifyLessThanOrEqual(tc, max(br.nStable), 1, ...
    "Oestrogen branch must be monostable; >1 stable state would be P3 bistability.");
verifyTrue(tc, contains(br.class, "MONOSTABLE"), br.class);
end

function testEstrogenLossLowersEquilibrium(tc)
% Direction: less oestrogen must lower the bone-volume equilibrium (the
% steep continuous osteoporotic shift), even though it is not bistable.
br = continuation("E2", [0.75 1.0], nFbm = 24, days = 700);
fLow  = br.fps{1}(1);
fHigh = br.fps{2}(1);
verifyLessThan(tc, fLow, fHigh, ...
    "Lower oestrogen must give a lower bone-volume equilibrium.");
end
