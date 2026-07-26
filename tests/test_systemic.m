function tests = test_systemic()
%TEST_SYSTEMIC P4 -- M8 calcium / PTH / 1,25(OH)2D homeostasis.
%
%   Run with:  runtests("tests/test_systemic.m")
%
%   These assert only what is STRUCTURALLY guaranteed at P4: the baseline
%   is a fixed point, serum calcium is bounded by homeostasis, and the
%   feedback signs are correct.  The MAGNITUDE and SIGN of the bone
%   response to calcium (V7) are calibration-blocked on Pivonka 2008 and
%   Peterson & Riggs 2010, and are deliberately NOT asserted here -- see
%   PROJECT_PLAN appendix C8.
%
%   Project: bone-mechanostat (PROJECT_PLAN v1.8)

tests = functiontests(localfunctions);
end

% -------------------------------------------------------------------------
function setupOnce(tc)
tc.TestData.p = getDefaultParams(reload = true);
end

function testBaselineIsFixedPoint(tc)
% (Ca_s_0, 1, 1) must be a fixed point of the systemic block.
p = tc.TestData.p;
[d, alg] = calciumPTHvitD(p.Ca_s_0, 1, p.V_D_0, p.I_Ca_0, 1, 1, p);

verifyEqual(tc, d.Ca_s, 0, "Serum Ca must be balanced at baseline.", AbsTol = 1e-9);
verifyEqual(tc, d.P,    0, "PTH must be at its set point.", AbsTol = 1e-12);
verifyEqual(tc, d.V_D,  0, "1,25D must be at its set point.", AbsTol = 1e-12);
verifyEqual(tc, alg.Abs, alg.Renal, "Baseline absorption must equal baseline renal clearance.", ...
    RelTol = 1e-9);
end

function testFeedbackSigns(tc)
% The four regulatory couplings must have the physiological sign.
p = tc.TestData.p;

% Ca_s up  -> PTH set point down
hi = calciumPTHvitD(p.Ca_s_0 * 1.02, 1, 1, p.I_Ca_0, 1, 1, p);
lo = calciumPTHvitD(p.Ca_s_0 * 0.98, 1, 1, p.I_Ca_0, 1, 1, p);
verifyLessThan(tc, hi.P, lo.P, "Higher serum Ca must lower the PTH set point.");

% PTH up -> 1,25D set point up
[~, aHi] = calciumPTHvitD(p.Ca_s_0, 1.2, 1, p.I_Ca_0, 1, 1, p);
[~, aLo] = calciumPTHvitD(p.Ca_s_0, 0.8, 1, p.I_Ca_0, 1, 1, p);
verifyGreaterThan(tc, aHi.VDset, aLo.VDset, "Higher PTH must raise the 1,25D set point.");

% 1,25D up -> absorption up
[~, avd1] = calciumPTHvitD(p.Ca_s_0, 1, 1.5, p.I_Ca_0, 1, 1, p);
[~, avd0] = calciumPTHvitD(p.Ca_s_0, 1, 0.5, p.I_Ca_0, 1, 1, p);
verifyGreaterThan(tc, avd1.Abs, avd0.Abs, "Higher 1,25D must raise absorption.");

% intake up -> absorption up
[~, aI1] = calciumPTHvitD(p.Ca_s_0, 1, 1, 1500, 1, 1, p);
[~, aI0] = calciumPTHvitD(p.Ca_s_0, 1, 1,  400, 1, 1, p);
verifyGreaterThan(tc, aI1.Abs, aI0.Abs, "Higher intake must raise absorption.");
end

function testSerumCalciumIsTightlyRegulated(tc)
% Serum Ca must not run away under a near-doubling of intake.  The v1.8
% rewrite exists because the first draft let it drift 55%.
%
% *** READ THE TOLERANCE, NOT THE NAME (appendix C24, v2.13) ***  This
% test's bar is 15%, which is NOT tight regulation.  Measured at 400 vs
% 1500 mg/day the model gives 1.107 -> 1.291 mmol/L, a 15% spread, where
% real serum ionised calcium is defended within about 2%.  The test passes
% because it was written as a runaway guard and then read ever after as a
% homeostasis check -- exactly the false assurance it looks like.  The
% cause is in the model, not here: passive intestinal absorption is linear
% and unsaturating in intake, so it swamps the saturating active term, and
% the saturable tubular reabsorption that renal_k and renal_Ca_th were
% declared for is never implemented.  Tightening this bar is a model fix
% (P5k), not a test fix, so the threshold is deliberately left at 15%.
p = tc.TestData.p;

Ca = zeros(1, 2);
names = ["lowCalcium" "highCalcium"];
for k = 1:2
    o = simulate(scenarioLibrary(names(k), durationDays = 900), p = p);
    Ca(k) = o.get.Ca_s(end);
end

for k = 1:2
    dev = abs(Ca(k) / p.Ca_s_0 - 1);
    verifyLessThan(tc, dev, 0.15, ...
        "Serum Ca must not run away (< 15%) under intake change. " + ...
        "This is a runaway guard, NOT a homeostasis check -- see C24.");
end
% Direction: more intake -> higher serum Ca.
verifyGreaterThan(tc, Ca(2), Ca(1), "More calcium intake must raise serum Ca.");
end

function testSerumSubsystemReachesSteadyState(tc)
% Fast subsystem: serum Ca and PTH must SETTLE (the plateau of V7 depends
% on this even though the bone magnitude does not yet).
p = tc.TestData.p;
o = simulate(scenarioLibrary("lowCalcium", durationDays = 1825), p = p);
g = o.get;

t = o.t / 365;
[~, kEarly] = min(abs(t - 0.5));
verifyEqual(tc, g.Ca_s(end), g.Ca_s(kEarly), "Serum Ca must reach steady state well before 5 years.", ...
    RelTol = 1e-3);
verifyEqual(tc, g.P(end), g.P(kEarly), "PTH must reach steady state well before 5 years.", ...
    RelTol = 1e-3);
end

function testFullModelStillRuns(tc)
% M1-M8 all live: 24 months must integrate cleanly.
o = simulate(scenarioLibrary("sedentary", durationDays = 730), p = tc.TestData.p);
verifyTrue(tc, all(isfinite(o.y), "all"), "Non-finite state.");
verifyTrue(tc, all(o.y(:) >= -1e-9), "Negative state.");
end
