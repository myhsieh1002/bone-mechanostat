function tests = test_twosite()
%TEST_TWOSITE P5 -- two-compartment site-specificity (innovation N3, P2).
%
%   Run with:  runtests("tests/test_twosite.m")
%
%   Asserts the DISCRIMINATING prediction P2 (PROJECT_PLAN §0, §4.3): local
%   loading creates a side-to-side bone difference, while a systemic
%   intervention cannot.  These are the robust qualitative claims of the
%   two-compartment model.
%
%   V6 now EMERGES as a held-out blind test (v2.3, appendix C14): the Frost
%   modelling term + intensive mineralisation give Haapasalo's pattern --
%   geometric gain with volumetric density essentially unchanged.  V6 was
%   never in the calibration objective, so these assertions are genuine
%   predictions of the improved structure.
%
%   Project: bone-mechanostat (PROJECT_PLAN v2.3)

tests = functiontests(localfunctions);
end

% -------------------------------------------------------------------------
function setupOnce(tc)
tc.TestData.p = getDefaultParams(reload = true);
end

function testTwoSiteIntegrates(tc)
% 30-state two-compartment model must integrate cleanly.
o = simulate(scenarioLibrary("tennis"), p = tc.TestData.p);
verifyEqual(tc, numel(o.names), 30, "Two-site model should have 30 states (v2.10: A_reb added).");
verifyTrue(tc, all(isfinite(o.y), "all"), "Non-finite state.");
verifyTrue(tc, all(o.y(:) >= -1e-9), "Negative state.");
verifyTrue(tc, isfield(o.dens, "aBMD_A") && isfield(o.dens, "aBMD_B"), ...
    "Densitometry must report both sites.");
end

function testLocalLoadingCreatesAsymmetry(tc)
% P2, part 1: the loaded arm (site A) must gain bone over the contralateral
% arm (site B).  This is the tennis-player result (Haapasalo, V6a).
p = tc.TestData.p;
o = simulate(scenarioLibrary("tennis"), p = p);
dBMC = 100 * (o.dens.BMC_L_A(end) / o.dens.BMC_L_B(end) - 1);

verifyGreaterThan(tc, dBMC, 3, ...
    "Loaded side must gain clearly more bone than contralateral.");
verifyLessThan(tc, dBMC, 40, ...
    "Side difference should be physiological, not runaway.");
end

function testSystemicInterventionCreatesNoAsymmetry(tc)
% P2, part 2 -- THE discriminating claim.  With BOTH sites under identical
% loading, a whole-body change (low calcium) shifts the shared PTH equally
% for both, so it cannot manufacture a side-to-side difference.  A systemic
% pill can never reproduce the tennis asymmetry.
p = tc.TestData.p;
s = scenarioLibrary("tennis");
s.boutsA = s.boutsB;      % both arms contralateral loading -> symmetric
s.I_Ca   = 400;           % systemic low calcium
o = simulate(s, p = p);
dBMC = 100 * (o.dens.BMC_L_A(end) / o.dens.BMC_L_B(end) - 1);

verifyLessThan(tc, abs(dBMC), 0.05, ...
    "A systemic intervention must not create a side-to-side difference.");
end

function testV6_geometricGain_notDensity(tc)
% V6f (HARD, hold-out): the loaded arm's gain is GEOMETRIC, with volumetric
% density essentially unchanged.  This is the discriminating Haapasalo
% result and it emerges here without being fitted.
p = tc.TestData.p;
o = simulate(scenarioLibrary("tennis"), p = p);

dVBMD = 100 * (o.dens.vBMD_A(end)  / o.dens.vBMD_B(end)  - 1);
dTot  = 100 * (o.dens.Tot_Ar_A(end)/ o.dens.Tot_Ar_B(end)- 1);
dImax = 100 * (o.dens.I_max_A(end) / o.dens.I_max_B(end) - 1);

verifyLessThan(tc, abs(dVBMD), 2.0, ...
    "V6f: loaded-side volumetric density must be ~unchanged (|Delta vBMD| < 2%).");
verifyGreaterThan(tc, dTot, 5, ...
    "V6b: loaded side must expand its total cross-section (geometric gain).");
verifyGreaterThan(tc, dImax, dTot, ...
    "V6: second moment of area must gain more than area (periosteal expansion).");
end

function testSharedSystemicPool(tc)
% Both sites must see the SAME systemic PTH / calcium (one shared M8).
info = stateVector("two");
% There is exactly one Ca_s, one P, one V_D (shared), not per-site.
verifyTrue(tc, any(info.names == "Ca_s") && ~any(info.names == "Ca_s_A"), ...
    "Systemic calcium must be shared, not duplicated per site.");
verifyTrue(tc, any(info.names == "P"), "Shared PTH state must exist.");
end
