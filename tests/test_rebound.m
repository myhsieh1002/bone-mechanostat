function tests = test_rebound()
%TEST_REBOUND P5h -- the anti-sclerostin withdrawal rebound.
%
%   Run with:  runtests("tests/test_rebound.m")
%
%   A_reb carries the compensatory up-regulation of SOST transcription that
%   builds up under sustained antibody exposure and then decays on its own
%   clock, not the antibody's.  That lag is the mechanism: on withdrawal the
%   clearance term vanishes while the raised production does not, sclerostin
%   overshoots, and resorption surges.
%
%   The assertions here are mostly about CONTAINMENT.  A rebound term is
%   exactly the kind of addition that can quietly contaminate everything
%   else, so what is tested first is that it cannot: A_reb is identically
%   zero in every run that never sees the drug.
%
%   Project: bone-mechanostat (PROJECT_PLAN v2.10, appendix C21)

tests = functiontests(localfunctions);
end

% -------------------------------------------------------------------------
function setupOnce(tc)
tc.TestData.p = getDefaultParams(reload = true);
end

function testDormantWithoutTheDrug(tc)
% THE containment guarantee.  If A_reb ever left zero in a drug-free run it
% would perturb V1, V2, V7, V6 and V14 -- all of which are either
% calibration targets or hold-outs.
p = tc.TestData.p;
for nm = ["sedentary" "resistance" "bedrest" "lowCalcium" "highCalcium"]
    o = simulate(scenarioLibrary(nm, durationDays = 730), p = p);
    verifyEqual(tc, max(abs(o.get.A_reb)), 0, sprintf( ...
        "A_reb must stay identically zero in the drug-free scenario '%s'.", nm));
end
end

function testBuildsUnderDrugAndDecaysAfter(tc)
% Shape of the adaptation itself: rises towards sost_reb while dosing, falls
% back once the drug stops.
p = tc.TestData.p;
o = simulate(scenarioLibrary("romosozumab", durationDays = 730), p = p);
[~, k12] = min(abs(o.t - 365));
A = o.get.A_reb;

verifyGreaterThan(tc, A(k12), 0.5 * p.sost_reb, ...
    "A_reb should approach its plateau over a 12-month course.");
verifyLessThan(tc, A(k12), p.sost_reb * 1.001, ...
    "A_reb must not exceed its plateau.");
verifyLessThan(tc, A(end), 0.2 * A(k12), ...
    "A_reb must decay after withdrawal.");
end

function testSclerostinIsSuppressedEarlyThenEscapes(tc)
% The adaptation catches up with the antibody DURING treatment: sclerostin
% is suppressed early, then climbs back towards baseline while still dosing.
% That escape is the mechanism behind V9's self-limitation, and it is why
% the strong form of V9 (formation peaking inside the course) appears at
% all -- so it is worth pinning, not just the withdrawal step.
p = tc.TestData.p;
o = simulate(scenarioLibrary("romosozumab", durationDays = 730), p = trabecularParams(p));
S = o.get.S;
[~, kEarly] = min(abs(o.t - 30));
[~, kLate]  = min(abs(o.t - 330));      % still on drug: it stops at day 365

verifyLessThan(tc, S(kEarly), 0.75 * S(1), ...
    "Sclerostin must be clearly suppressed in the first month of dosing.");
verifyGreaterThan(tc, S(kLate), S(kEarly), ...
    "Sclerostin must climb back while still dosing -- this is the V9 escape.");
end

function testSclerostinOvershootsAfterWithdrawal(tc)
% The step the whole mechanism turns on: once clearance stops but the raised
% production has not yet decayed, free sclerostin goes ABOVE baseline rather
% than merely returning to it.
%
% Note the magnitude of that transient is exaggerated by the drug being a
% STEP -- a real antibody clears over weeks (appendix C21.5).  The
% calibrated quantity is the downstream resorption overshoot (V16), not
% this spike.
p = tc.TestData.p;
o = simulate(scenarioLibrary("romosozumab", durationDays = 730), p = trabecularParams(p));
[~, k12] = min(abs(o.t - 365));
S = o.get.S;

verifyGreaterThan(tc, max(S(k12:end)), 1.5 * S(1), ...
    "Sclerostin must overshoot baseline after withdrawal, not just return to it.");
verifyLessThan(tc, S(end), 1.3 * S(1), ...
    "The overshoot must resolve by the end of the washout.");
end

function testResorptionSurgeDrivesTheBoneLoss(tc)
% The overshoot has to actually reach bone: resorption above baseline, and
% BMD falling as a consequence.
p = tc.TestData.p;
o = simulate(scenarioLibrary("romosozumab", durationDays = 730), p = trabecularParams(p));
[~, k12] = min(abs(o.t - 365));

verifyGreaterThan(tc, max(o.get.C(k12:end)) / o.get.C(1), 1.1, ...
    "Resorption must surge above baseline after withdrawal.");
verifyLessThan(tc, o.dens.aBMD(end), o.dens.aBMD(k12), ...
    "BMD must fall over the washout window.");
verifyTrue(tc, o.validity.ok, "Withdrawal run left the elastic domain.");
end

function testTheReboundIsWhatCausesTheLoss(tc)
% Attribution.  Switching sost_reb off must make the washout loss markedly
% shallower, otherwise V10 is passing for some other reason and the new
% mechanism is decoration.
%
% Note it does not have to reverse the sign: delta_ab was refitted upward
% alongside sost_reb (P5h), and at that larger antibody effect the
% mechanostat alone already claws some bone back.  What must be true is
% that the rebound accounts for most of the loss.
p = tc.TestData.p;
q = p; q.sost_reb = 0;

washout = @(pp) localWashout(pp);
withReb = washout(trabecularParams(p));
without = washout(trabecularParams(q));

verifyLessThan(tc, withReb, 0, "With the rebound on, BMD must fall over the washout.");
verifyLessThan(tc, withReb, 0.5 * without, sprintf( ...
    "The rebound must account for most of the washout loss (%.2f %% with, %.2f %% without).", ...
    withReb, without));
end

% -------------------------------------------------------------------------
function w = localWashout(pp)
%LOCALWASHOUT Percent aBMD change over the 12-month washout.
o = simulate(scenarioLibrary("romosozumab", durationDays = 730), p = pp);
[~, k12] = min(abs(o.t - 365));
w = 100 * (o.dens.aBMD(end) / o.dens.aBMD(k12) - 1);
end
