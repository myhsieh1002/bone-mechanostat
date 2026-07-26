function tests = test_modeling()
%TEST_MODELING P5e -- the Frost modelling term is bounded, and runs that
%leave the linear-elastic domain say so.
%
%   Run with:  runtests("tests/test_modeling.m")
%
%   Guards the appendix C15.4 artefact.  The v2.3 modelling term was linear
%   in the strain excess and therefore unbounded: at pathological f_bm it
%   demanded 1513 mm/yr of periosteal apposition and grew a 99 mm cortex,
%   which nearly registered as a positive P3 (bistability) result.
%
%   Two separate defences are asserted here, because the first alone is not
%   enough:
%     1. SATURATION bounds the modelling RATE at a physiological ceiling.
%        It does NOT move the runaway's fixed point.
%     2. A VALIDITY FLAG reports when a trajectory left the linear-elastic
%        domain, so the residual slow drift cannot be read as a result.
%
%   Project: bone-mechanostat (PROJECT_PLAN v2.6, appendix C17)

tests = functiontests(localfunctions);
end

% -------------------------------------------------------------------------
function setupOnce(tc)
tc.TestData.p = getDefaultParams(reload = true);
end

function m = localModeling(epsP, p)
%LOCALMODELING Isolate the modelling term: zero cell activity, so the only
% contribution to dr_p/dt is the modelling term itself.
st = struct(r_p = p.r_p_0, r_e = p.r_e_0, f_bm = p.f_bm_0, ...
            rho_min = p.rho_min_0, n_ot = p.n_ot_0);
d  = boneStructure(st, zeros(1,3), zeros(1,3), 0, 0, p, struct(eps_p = epsP));
m  = d.r_p;
end

% -------------------------------------------------------------------------
function testSilentBelowThreshold(tc)
% Normal daily activity (~762 ue) is below Frost's MES_m, so modelling must
% contribute exactly nothing -- this is why saturating it cannot disturb any
% calibration scenario.
p = tc.TestData.p;
verifyEqual(tc, localModeling(762e-6, p), 0, ...
    "Modelling must be silent at normal daily strain.");
verifyEqual(tc, localModeling(p.eps_model_star, p), 0, ...
    "Modelling must be zero exactly at the threshold.");
end

function testAgreesWithLinearFormInPhysiologicalRange(tc)
% Tennis peak strain (~2851 ue) is the largest strain any validated scenario
% reaches.  There the saturated form must still be close to the v2.3 linear
% form, otherwise saturation would silently rewrite the V6 hold-out rather
% than merely bounding pathology.
p     = tc.TestData.p;
epsP  = 2851e-6;
lin   = p.k_model * (epsP - p.eps_model_star);
ratio = localModeling(epsP, p) / lin;
verifyGreaterThan(tc, ratio, 0.75, ...
    "Saturation must not gut the modelling term inside the physiological range.");
verifyLessThan(tc, ratio, 1.0, ...
    "Saturated form must lie strictly below the linear form above threshold.");
end

function testRateIsBoundedAtPathologicalStrain(tc)
% THE regression guard.  At the collapsed-porosity strains seen in C15.4
% (~1.2e7 ue) the linear form asked for 1513 mm/yr.  The saturated form must
% stay under the ceiling k_model * eps_model_sat for ANY strain.
p       = tc.TestData.p;
ceiling = p.k_model * p.eps_model_sat;                       % [m/day]

for epsP = [1e-2 1e-1 1 10 1e3]
    m = localModeling(epsP, p);
    verifyLessThan(tc, m, ceiling, sprintf( ...
        "Modelling rate must stay below the ceiling at strain %.3g.", epsP));
end

verifyLessThan(tc, ceiling * 365 * 1e3, 1.0, ...
    "Ceiling must be under 1 mm/yr of periosteal apposition.");
verifyGreaterThan(tc, ceiling * 1e6, 0.5, ...
    "Ceiling must not be so tight it forbids rapid modelling (>0.5 um/day).");
end

function testMonotoneInStrain(tc)
% Saturating must not make the response non-monotone -- more strain may give
% diminishing returns but never less bone.
p = tc.TestData.p;
e = p.eps_model_star + logspace(-5, 1, 60);
m = arrayfun(@(x) localModeling(x, p), e);
verifyTrue(tc, all(diff(m) > 0), "Modelling must increase monotonically with strain.");
end

function testValidScenariosStayInsideElasticDomain(tc)
% Every scenario the model is actually validated on must stay well inside
% the linear-elastic assumption that the whole mechanics stack rests on.
p = tc.TestData.p;
for nm = ["sedentary" "resistance" "tennis"]
    o = simulate(scenarioLibrary(nm, durationDays = 730), p = p);
    verifyTrue(tc, o.validity.ok, sprintf( ...
        "%s left the elastic domain (max %.0f ue > %.0f ue).", ...
        nm, o.validity.maxStrain * 1e6, p.eps_elastic_max * 1e6));
end

% The V2 calibration window specifically -- disuse is only claimed over the
% 180 days it is evaluated on (it collapses to the porosity floor if pushed
% much past that; see appendix C17.4).
o = simulate(scenarioLibrary("bedrest", durationDays = 180), p = p);
verifyTrue(tc, o.validity.ok, "The V2 disuse window must be a valid run.");
end

function testPathologicalRunIsFlaggedInvalid(tc)
% The flag has to actually fire, or it is decoration.  Severe oestrogen
% withdrawal drives f_bm to the floor, strain past yield, and the geometry
% into nonsense -- the run must announce that rather than return a number.
p = tc.TestData.p;
s = scenarioLibrary("sedentary", durationDays = 730);
s.E2 = 0.1;
o = simulate(s, p = p);

verifyFalse(tc, o.validity.ok, ...
    "A collapsed-porosity run must be flagged as outside the elastic domain.");
verifyGreaterThan(tc, o.validity.maxStrain, p.eps_elastic_max, ...
    "Flagged run must actually exceed the limit.");
verifyTrue(tc, isfinite(o.validity.firstExceededDay), ...
    "Flag must report when validity was first lost.");
end
