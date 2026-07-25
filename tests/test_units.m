function tests = test_units()
%TEST_UNITS Parameter table integrity and dimensional sanity.
%
%   Run with:  runtests("tests/test_units.m")
%
%   Covers PROJECT_PLAN §7.1: SI units, days internally, every parameter
%   annotated, no hard-coded constants, values inside their stated bounds.
%
%   Project: bone-mechanostat (PROJECT_PLAN v1.4)

tests = functiontests(localfunctions);
end

% -------------------------------------------------------------------------
function setupOnce(tc)
tc.TestData.p = getDefaultParams(reload = true);
tc.TestData.t = tc.TestData.p.meta;
end

% --- CSV schema ----------------------------------------------------------
function testSchemaComplete(tc)
t = tc.TestData.t;
required = ["name" "symbol" "value" "unit" "lower" "upper" ...
            "module" "source" "confidence" "description"];
verifyTrue(tc, all(ismember(required, string(t.Properties.VariableNames))), ...
    "parameters_literature.csv is missing required columns.");
end

function testNoMissingValues(tc)
t = tc.TestData.t;
verifyFalse(tc, any(isnan(t.value)), "Some parameters have NaN value.");
verifyFalse(tc, any(ismissing(t.unit)), "Some parameters have no unit.");
verifyFalse(tc, any(ismissing(t.source)), "Some parameters have no source.");
end

function testNamesUnique(tc)
t = tc.TestData.t;
verifyEqual(tc, numel(unique(t.name)), height(t), ...
    "Duplicate parameter names would silently shadow each other.");
end

function testValuesWithinBounds(tc)
t = tc.TestData.t;
bad = t.value < t.lower | t.value > t.upper;
verifyFalse(tc, any(bad), sprintf( ...
    "Parameter(s) outside their own [lower, upper]: %s", ...
    strjoin(t.name(bad), ", ")));
end

function testBoundsOrdered(tc)
t = tc.TestData.t;
verifyTrue(tc, all(t.lower <= t.upper), "Some parameters have lower > upper.");
end

function testConfidenceVocabulary(tc)
t = tc.TestData.t;
allowed = ["low" "medium" "high"];
verifyTrue(tc, all(ismember(t.confidence, allowed)), ...
    "confidence must be one of low/medium/high.");
end

function testModuleVocabulary(tc)
t = tc.TestData.t;
allowed = ["M1" "M2" "M3" "M4" "M5" "M6" "M7" "M8" "IN"];
verifyTrue(tc, all(ismember(t.module, allowed)), ...
    "module tag must be M1..M8 or IN (model input).");
end

% --- provenance discipline ----------------------------------------------
function testAssumedParametersAreFlaggedLowOrMedium(tc)
% An "assumed" value must never claim high confidence -- that is how a
% placeholder quietly becomes a citation.
t = tc.TestData.t;
bad = t.source == "assumed" & t.confidence == "high";
verifyFalse(tc, any(bad), sprintf( ...
    "source=assumed but confidence=high: %s", strjoin(t.name(bad), ", ")));
end

% --- dimensional sanity of the M1 chain ---------------------------------
function testCrossSectionUnits(tc)
p = tc.TestData.p;
g = crossSection(p.r_p_0, p.r_e_0, p.f_bm_0, p.rho_min_0, p);

verifyGreaterThan(tc, g.A_g, 0);
verifyGreaterThan(tc, g.I_g, 0);
verifyGreaterThan(tc, g.t_c, 0);

% Human humeral shaft: cortical area of order 100-400 mm^2 = 1e-4..4e-4 m^2
verifyGreaterThan(tc, g.A_g, 0.5e-4);
verifyLessThan(tc, g.A_g, 6.0e-4);

% Apparent cortical modulus of order 10-25 GPa
verifyGreaterThan(tc, g.E_app, 5e9);
verifyLessThan(tc, g.E_app, 3e10);
end

function testBaselineStrainIsPhysiological(tc)
% PROJECT_PLAN §1.2 / §2: everyday activity produces roughly 400-1500
% microstrain; the physiological ceiling is about 3000.  If the baseline
% load parameters put us outside that window, M_L_0 / F_L_0 are wrong and
% every downstream shear stress will be wrong too.
p = tc.TestData.p;
s = scenarioLibrary("sedentary");
st = struct(r_p = p.r_p_0, r_e = p.r_e_0, ...
            f_bm = p.f_bm_0, rho_min = p.rho_min_0);
m = organMechanics(s.bouts(1), st, p);

microstrain = m.eps_p * 1e6;
verifyGreaterThan(tc, microstrain, 200, ...
    "Baseline peak strain is implausibly low; check M_L_0 / F_L_0 / E_ref.");
verifyLessThan(tc, microstrain, 3000, ...
    "Baseline peak strain exceeds the physiological ceiling.");
end

function testStrainGradientAcrossWall(tc)
% Under bending the periosteal surface must strain more than the
% endocortical one.  SURFACEALLOCATION relies on this ordering to bias
% formation towards the periosteum (V6f).
p = tc.TestData.p;
s = scenarioLibrary("sedentary");
st = struct(r_p = p.r_p_0, r_e = p.r_e_0, ...
            f_bm = p.f_bm_0, rho_min = p.rho_min_0);
m = organMechanics(s.bouts(1), st, p);

verifyGreaterThan(tc, m.eps_p, m.eps_e, ...
    "Periosteal strain must exceed endocortical strain under bending.");
end

function testDensitometryUnits(tc)
p = tc.TestData.p;
d = densitometry(p.r_p_0, p.r_e_0, p.f_bm_0, p.rho_min_0, p);

% aBMD of order 1 g/cm^2 = 10 kg/m^2
verifyGreaterThan(tc, d.aBMD, 3);
verifyLessThan(tc, d.aBMD, 20);

% Cortical vBMD of order 1000-1300 kg/m^3
verifyGreaterThan(tc, d.vBMD, 800);
verifyLessThan(tc, d.vBMD, 1500);

% Geometric identity: total = cortical + marrow
verifyEqual(tc, d.Tot_Ar, d.Co_Ar + d.MCav_Ar, RelTol = 1e-12);
end

function testStateVectorConsistency(tc)
single = stateVector("single");
two    = stateVector("two");
verifyEqual(tc, single.n, 16, "Single-compartment model should have 16 states (13 local + 3 systemic; v2.3).");
verifyEqual(tc, two.n, 29, "Two-compartment model should have 29 states (13x2 + 3; v2.3).");
verifyEqual(tc, numel(single.units), single.n, "Every state needs a unit.");
verifyEqual(tc, numel(two.units), two.n, "Every state needs a unit.");
end
