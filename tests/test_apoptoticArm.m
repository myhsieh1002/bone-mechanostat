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

function testApoptosisIsAMinorityArmOfOsteocyteTurnover(tc)
% Appendix C33 turned on this split being small: basal apoptosis was 1 % of
% osteocyte removal, which is why a literature-scale fold-induction moved
% n_ot almost not at all and lambda_ot_mech had to reach ~100 to matter.
%
% At v2.24 the split is 10 % BY CHOICE rather than 1 % by accident.  It
% corresponds to a steady-state lacunar occupancy of 90 % under
% occupancy = gamma/(gamma+delta), which is inside the 12.4-99.2 % Power
% et al. 2001 measured in elderly femoral neck cortex.  C33's conclusion
% survives the change, and appendix C34.4 shows why: sweeping the split
% across 1 %, 10 % and 25 % moves V7 by 0.012 and V2 not at all, because
% n_ot is now a slow variable that barely leaves baseline in any scenario.
%
% The bound here is loose on purpose.  What C33 needs is that resorption,
% not apoptosis, dominates osteocyte removal; it does not need a precise
% split, and no source pins one.
p = tc.TestData.p;
lossBase = p.k_ot * (p.n_ot_max - p.n_ot_0) / p.n_ot_0;
verifyLessThan(tc, p.delta_ot_0 / lossBase, 0.3, ...
    "Apoptosis is no longer a minority arm of osteocyte removal.  " + ...
    "Appendix C33 assumed resorption dominates; if that has changed, " + ...
    "C33's exclusion of the apoptotic RANKL route must be re-derived.");
end

function testOsteocyteRemovalMatchesBoneTurnover(tc)
% Osteocytes leave the tissue when the bone they sit in is resorbed, so the
% fractional removal rate of the osteocyte population MUST equal the
% fractional turnover rate of the bone.
%
% Until v2.23 it did not, by a factor of 514: the model resorbed bone at
% 1.93e-4 /day (V1 = 7.03 %/yr) and removed osteocytes at 9.90e-2 /day, a
% mean osteocyte residence of 10 days.  P5o fixed it by DERIVING k_ot from
% the turnover instead of fitting it (OSTEOCYTEBURIALRATE, appendix C34),
% which makes the contradiction impossible rather than merely absent -- so
% this test now guards the derivation, not a recorded defect.
%
% Between v2.23 and v2.24 this test asserted the ratio was 514 and said in
% its own message that it was expected to fail the day someone corrected
% k_ot.  It did.  Kept, inverted, as the standing invariant.
p = tc.TestData.p;
boneRate = turnoverRate(p) / 100 / 365;                        % [1/day]
gammaEff = p.k_ot * (p.n_ot_max - p.n_ot_0) / p.n_ot_0 - p.delta_ot_0;

verifyEqual(tc, gammaEff / boneRate, 1, ...
    "Osteocyte removal no longer tracks bone turnover.  The usual cause is " + ...
    "a changed k_res with a stale k_ot in the CSV: k_ot is DERIVED " + ...
    "(osteocyteBurialRate) and must be rewritten alongside k_form, exactly " + ...
    "as pitfall C27.7 describes for k_form.", RelTol = 1e-5);

% And the derived value must still agree with the independent measurement.
% Buenzli & Sims 2015: 42e9 osteocytes, 9.1e6 replenished daily = 2.167e-4
% /day.  Ours comes from our own turnover and shares no inputs with theirs,
% so this is a real check; theirs is a whole-skeleton average including
% fast trabecular bone, hence the loose tolerance and the one-sided reading
% that ours should if anything be lower.
verifyEqual(tc, gammaEff + p.delta_ot_0, 2.167e-4, ...
    "Derived osteocyte turnover has drifted away from the Buenzli & Sims " + ...
    "estimate of 2.167e-4 /day.  Check V1 first: this quantity now follows " + ...
    "bone turnover by construction, so a drift here means turnover moved.", ...
    RelTol = 0.25);
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
