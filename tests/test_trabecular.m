function tests = test_trabecular()
%TEST_TRABECULAR P5d -- the vertebral trabecular compartment.
%
%   Run with:  runtests("tests/test_trabecular.m")
%
%   Asserts the compartment is a usable baseline (stable, valid, literature
%   turnover) and that it delivers the AMPLIFICATION it exists for: the same
%   drug produces a much larger BMD gain in a low-f_bm, fast-turnover
%   compartment than in cortex.
%
%   What is deliberately NOT asserted: V8's +11-14 % magnitude.  The
%   compartment gets ~3.6x amplification but stops around +4.5 %, and
%   appendix C19 traces the remaining gap to delta_ab -- whose current value
%   was fitted in P4 against a V8 that C14 later showed was contaminated by
%   the mineralisation artefact.  Asserting the magnitude before that refit
%   would be asserting a number we know is provisional.
%
%   Project: bone-mechanostat (PROJECT_PLAN v2.8, appendix C19)

tests = functiontests(localfunctions);
end

% -------------------------------------------------------------------------
function setupOnce(tc)
tc.TestData.p = getDefaultParams(reload = true);
tc.TestData.q = trabecularParams(tc.TestData.p);
end

function testStructureIsTrabecular(tc)
q = tc.TestData.q;
verifyLessThan(tc, q.f_bm_0, 0.2, "Trabecular BV/TV must be low.");
verifyGreaterThan(tc, q.f_bm_0, 0.05, "BV/TV below 0.05 is outside the vertebral range.");
verifyLessThan(tc, q.w_wall, tc.TestData.p.w_wall, ...
    "Trabecular thickness must be below the cortical wall thickness.");

% The apparent modulus has to land in the measured vertebral trabecular
% range without anyone tuning it -- E_ref and kappa_E are shared with
% cortex, so this is a consistency check on the whole elastic law.
g = crossSection(q.r_p_0, q.r_e_0, q.f_bm_0, q.rho_min_0, q);
verifyGreaterThan(tc, g.E_app / 1e6, 30, "E_app below the vertebral trabecular range.");
verifyLessThan(tc,    g.E_app / 1e6, 400, "E_app above the vertebral trabecular range.");
end

function testSharedShearSetPoint(tc)
% The signalling chain is shared, so both compartments must see the same
% baseline osteocyte shear or the trabecular site cannot be at rest.
p = tc.TestData.p; q = tc.TestData.q;
ref = scenarioLibrary("sedentary");
[~, i] = max([ref.bouts.momentScale]);
b = ref.bouts(i);

stC = struct(r_p = p.r_p_0, r_e = p.r_e_0, f_bm = p.f_bm_0, ...
             rho_min = p.rho_min_0, n_ot = p.n_ot_0);
stT = struct(r_p = q.r_p_0, r_e = q.r_e_0, f_bm = q.f_bm_0, ...
             rho_min = q.rho_min_0, n_ot = q.n_ot_0);
tauC = shearSurrogate(organMechanics(b, stC, p).eps_p, b.freqHz, p);
tauT = shearSurrogate(organMechanics(b, stT, q).eps_p, b.freqHz, q);

verifyEqual(tc, tauT, tauC, "Baseline shear must match the cortical set point.", ...
    RelTol = 1e-6);
end

function testTurnoverIsTrabecular(tc)
% Literature: trabecular 15-30 %/yr against cortical 5-10.
v1 = evalTargets(tc.TestData.q).V1;
verifyGreaterThan(tc, v1, 15, "Trabecular turnover must exceed the cortical range.");
verifyLessThan(tc,    v1, 30, "Trabecular turnover above the literature range.");
end

function testBaselineIsStableAndValid(tc)
o = simulate(scenarioLibrary("sedentary", durationDays = 730), p = tc.TestData.q);
drift = 100 * (o.dens.aBMD(end) / o.dens.aBMD(1) - 1);
verifyLessThan(tc, abs(drift), 0.5, sprintf( ...
    "Trabecular baseline drifted %.3f %% over 24 months.", drift));
verifyTrue(tc, o.validity.ok, sprintf( ...
    "Trabecular baseline left the elastic domain (max %.0f ue).", ...
    o.validity.maxStrain * 1e6));
end

function testAmplifiesTheDrugOverCortex(tc)
% THE reason the compartment exists.  Same drug, same biology, same
% delta_ab -- only the structure differs.
p = tc.TestData.p; q = tc.TestData.q;
s = scenarioLibrary("romosozumab", durationDays = 730);
pct = @(o) 100 * (o.dens.aBMD ./ o.dens.aBMD(1) - 1);

oC = simulate(s, p = p);  oT = simulate(s, p = q);
[~, k12] = min(abs(oC.t - 365));
gainC = pct(oC); gainT = pct(oT);

verifyGreaterThan(tc, gainT(k12), 2 * gainC(k12), sprintf( ...
    "Trabecular compartment must amplify the drug (got %.2f %% vs cortical %.2f %%).", ...
    gainT(k12), gainC(k12)));
verifyTrue(tc, oT.validity.ok, "Drug run left the elastic domain.");
end
