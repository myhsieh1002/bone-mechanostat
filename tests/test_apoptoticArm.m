function tests = test_apoptoticArm()
%TEST_APOPTOTICARM P5n'/P5n'' -- the osteocyte-apoptosis route to RANKL.
%
%   Run with:  runtests("tests/test_apoptoticArm.m")
%
%   Two mechanisms were built and measured in appendix C33 and then SHIPPED
%   INERT, both at zero:
%
%     lambda_apop      apoptotic osteocytes raise RANKL directly, bypassing
%                      sclerostin (OSTEOCYTESIGNAL)
%     lambda_ot_mech   unloading induces osteocyte apoptosis
%                      (OSTEOCYTEDENSITY)
%
%   They were built to let the model adopt the MEASURED cortical specific-
%   surface exponent s2_Sv = 0.5 (Lerebours 2015) instead of the assumed 3,
%   by supplying the disuse loss that the exaggerated exponent had been
%   carrying.  They can do that -- and appendix C33 records what it costs.
%
%   This file exists for two reasons, and the second is the important one.
%
%   1.  It pins the BASELINE-NEUTRALITY that made the experiment readable at
%       all.  Both terms are written on a DEFICIT, so both are exactly 1 at
%       the reference state whatever their coefficients.  That is why V1, V8
%       and V14 came back bit-for-bit unchanged, and why the measured cost
%       can be attributed to the mechanism rather than to a shifted baseline.
%       If someone rewrites either term and breaks that property, every
%       number in C33 silently stops meaning what it says.
%
%   2.  It makes the inert state DELIBERATE rather than accidental.  This
%       project's worst defect (appendix C24) was four validation targets
%       that sat in the CSV for months with their mechanisms built and
%       nothing evaluating them.  A mechanism shipped at zero is the same
%       hazard in a different shape.  The last test therefore fails the
%       moment either coefficient leaves zero, and says what to read first.
%
%   Project: bone-mechanostat (PROJECT_PLAN v2.23, appendix C33)

tests = functiontests(localfunctions);
end

% -------------------------------------------------------------------------
function setupOnce(tc)
tc.TestData.p = getDefaultParams(reload = true);
tc.TestData.s = struct(Ca_i = 1, Y = 1, S = 1, T = 0, beta = 1);
end

function testApoptoticTermIsExactlyNeutralAtBaseline(tc)
% gA(n_ot_0) = 1 by construction, so RANKL at the reference state must be
% INDEPENDENT of lambda_apop -- and not approximately: exactly.  Approximate
% neutrality would leave a baseline drift that the calibration would then
% absorb into k_res, which is precisely the confound this design avoids.
p = tc.TestData.p;  s = tc.TestData.s;

[~, a0] = osteocyteSignal(s, 1, 1, 1, p.n_ot_0, 0, 0, p);
for lam = [0.5 3 10]
    q = p;  q.lambda_apop = lam;
    [~, a] = osteocyteSignal(s, 1, 1, 1, q.n_ot_0, 0, 0, q);
    verifyEqual(tc, a.L_RANKL, a0.L_RANKL, ...
        "RANKL at baseline moved with lambda_apop = " + lam + ...
        "; gA is not normalised to 1 at n_ot_0.");
    verifyEqual(tc, a.pi_L, a0.pi_L, ...
        "Osteoclast activation at baseline moved with lambda_apop = " + lam + ".");
end
end

function testApoptoticTermRaisesRanklOnlyWhenOsteocytesAreLost(tc)
% One-sided by design: a DEFICIT raises RANKL, a SURPLUS does nothing.  The
% literature supports dying osteocytes releasing RANKL; it says nothing
% about extra osteocytes suppressing it, and a symmetric term would be a
% free parameter acting in both directions on no evidence.
p = tc.TestData.p;  p.lambda_apop = 4;  s = tc.TestData.s;

[~, aBase] = osteocyteSignal(s, 1, 1, 1, p.n_ot_0,       0, 0, p);
[~, aLoss] = osteocyteSignal(s, 1, 1, 1, 0.8 * p.n_ot_0, 0, 0, p);
[~, aGain] = osteocyteSignal(s, 1, 1, 1, 1.2 * p.n_ot_0, 0, 0, p);

verifyGreaterThan(tc, aLoss.L_RANKL, aBase.L_RANKL, ...
    "Losing osteocytes must raise RANKL when lambda_apop > 0.");
verifyEqual(tc, aGain.L_RANKL, aBase.L_RANKL, ...
    "An osteocyte SURPLUS must not change RANKL: the term is one-sided.");

% 20 % deficit at lambda_apop = 4 is a 1.8-fold RANKL rise, exactly.
verifyEqual(tc, aLoss.L_RANKL / aBase.L_RANKL, 1.8, ...
    "gA is not 1 + lambda_apop*(1 - n_ot/n_ot_0).", AbsTol = 1e-12);
end

function testMechanicalApoptosisIsNeutralAtBaselineAndRisesWithUnloading(tc)
% Same construction on the dose deficit: exactly 1 at D_eff_hat = 1, so no
% mechanically-loaded scenario is perturbed, and monotone as load is removed.
p = tc.TestData.p;  p.lambda_ot_mech = 50;

dBase = osteocyteDensity(p.n_ot_0, 1, 1, p.E2_0, 1.0, p);
verifyEqual(tc, dBase, 0, ...
    "Baseline is no longer a fixed point of n_ot once lambda_ot_mech > 0.", ...
    AbsTol = 1e-14);

dHalf = osteocyteDensity(p.n_ot_0, 1, 1, p.E2_0, 0.5, p);
dZero = osteocyteDensity(p.n_ot_0, 1, 1, p.E2_0, 0.0, p);
verifyLessThan(tc, dHalf, 0, "Unloading must push dn_ot/dt negative.");
verifyLessThan(tc, dZero, dHalf, ...
    "Osteocyte apoptosis must rise monotonically as the dose falls.");

% Overloading must not run the term backwards into an osteocyte bonus.
dOver = osteocyteDensity(p.n_ot_0, 1, 1, p.E2_0, 2.0, p);
verifyEqual(tc, dOver, 0, ...
    "The mechanical apoptosis term is one-sided and must be silent above baseline dose.", ...
    AbsTol = 1e-14);
end

function testApoptosisIsAOnePercentArmOfOsteocyteTurnover(tc)
% The scale that decided appendix C33: basal apoptosis is 1 % of osteocyte
% removal, burial and resorption the other 99 %.  That is why a literature-
% scale fold-induction of apoptosis moves n_ot almost not at all, and why
% lambda_ot_mech had to reach ~100 to matter.  Both numbers rest on ASSUMED
% parameters (delta_ot_0, k_ot), so if either is ever sourced, C33's
% conclusion has to be re-derived rather than inherited.
p = tc.TestData.p;
lossBase = p.k_ot * (p.n_ot_max - p.n_ot_0) / p.n_ot_0;
verifyLessThan(tc, p.delta_ot_0 / lossBase, 0.05, ...
    "Basal apoptosis is no longer a small arm of osteocyte turnover; " + ...
    "appendix C33's arithmetic assumed it was, and must be redone.");
end

function testBothArmsAreShippedInert(tc)
% Deliberate, not accidental.  Appendix C33 measured what happens when
% these leave zero: the disuse loss does come back, and V7's PLATEAU -- a
% stated hard requirement, and the content of P1 sub-clause 1 -- goes with
% it.  Anyone turning either coefficient up is making that trade, so this
% test's job is to make sure they know they are making it.
p = tc.TestData.p;
verifyEqual(tc, p.lambda_apop, 0, ...
    "lambda_apop is no longer zero.  Read appendix C33 before proceeding: " + ...
    "at the value V2 needs, the low-calcium arm stops plateauing.");
verifyEqual(tc, p.lambda_ot_mech, 0, ...
    "lambda_ot_mech is no longer zero.  Read appendix C33: making the " + ...
    "osteocyte deficit disuse-specific did NOT rescue the trade-off.");
end
