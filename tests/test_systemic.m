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
% Serum Ca must stay within a few percent across a near-doubling of intake.
%
% *** THE BAR IS NOW 3%, AND IT MEANS IT (P5k, v2.14) ***  From v1.8 to
% v2.13 this test's bar was 15% while its name and comment claimed "a few
% percent" -- it had been written as a runaway guard and was read ever
% after as a homeostasis check, and the model duly drifted 15% without
% anyone noticing (appendix C24.5).  P5k rebuilt M8 so the claim and the
% assertion agree: measured across 400 to 1500 mg/day the spread is now
% 1.6%.  Do NOT loosen this bar again to make a change pass.
p = tc.TestData.p;

Ca = zeros(1, 2);
names = ["lowCalcium" "highCalcium"];
for k = 1:2
    o = simulate(scenarioLibrary(names(k), durationDays = 900), p = p);
    Ca(k) = o.get.Ca_s(end);
end

for k = 1:2
    dev = abs(Ca(k) / p.Ca_s_0 - 1);
    verifyLessThan(tc, dev, 0.03, ...
        "Serum Ca must stay within 3% of baseline under intake change.");
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

function testAbsorptionIsMostlyTheRegulatedArm(tc)
% The calcitriol-gated transcellular arm must carry a substantial share of
% baseline absorption.  It is the only part of intake handling that PTH can
% act on, so if the unregulated paracellular term dominates, dietary
% calcium has no negative feedback and serum calcium drifts with intake --
% which is exactly how the v1.8 module failed (appendix C24.5).
p = tc.TestData.p;

[~, alg] = calciumPTHvitD(p.Ca_s_0, 1, p.V_D_0, p.I_Ca_0, 1, 1, p);
passive  = p.a_p_abs * p.I_Ca_0;
active   = alg.Abs - passive;

verifyGreaterThan(tc, active / alg.Abs, 0.35, ...
    "The regulated (transcellular) arm must carry over a third of baseline absorption.");
end

function testRenalGainClosesTheBaselineBalance(tc)
% renal_k is derived, not free: it must be exactly what closes the balance
% at baseline, so the steepness of the renal defence follows from where the
% threshold sits rather than from a fitted exponent.
p = tc.TestData.p;

[~, alg] = calciumPTHvitD(p.Ca_s_0, 1, p.V_D_0, p.I_Ca_0, 1, 1, p);
expected = (alg.Abs_0 + p.phi_res - p.phi_form) / (p.Ca_s_0 - p.renal_Ca_th);

verifyEqual(tc, alg.renal_k, expected, ...
    "renal_k must close the baseline calcium balance.", RelTol = 1e-12);
verifyGreaterThan(tc, p.Ca_s_0, p.renal_Ca_th, ...
    "The tubular threshold must sit below baseline serum calcium.");
end

function testUnloadingSuppressesPTH(tc)
% Immobilisation releases skeletal calcium, which suppresses the
% parathyroid: bed-rest subjects show PTH down 17% at day 28 and 24% at day
% 60, with urinary calcium elevated throughout (Spatz 2012, PMID 22767636).
% Until P5k the model produced -0.01% here, because phi_res and phi_form
% were three orders of magnitude below the flux they were normalised
% against -- the bone-to-blood arm existed in the equations and did nothing
% (appendix C26.5).  This is the test that would have caught it.
p = tc.TestData.p;

o = simulate(scenarioLibrary("bedrest", durationDays = 180), p = p);
verifyTrue(tc, o.validity.ok, "Disuse reference run left the elastic domain.");

[~, k60] = min(abs(o.t - 60));
dP = 100 * (o.get.P(k60) / o.get.P(1) - 1);

verifyLessThan(tc, dP, -10, ...
    "Unloading must suppress PTH by at least 10% by day 60.");
verifyGreaterThan(tc, dP, -35, ...
    "PTH suppression under unloading must stay physiological (> -35%).");

% ... and it must come from calcium released by bone, not from nowhere.
verifyGreaterThan(tc, o.get.Ca_s(k60), o.get.Ca_s(1), ...
    "Serum calcium must rise when unloaded bone releases calcium.");
end
