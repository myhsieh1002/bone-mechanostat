function tests = test_closedloop()
%TEST_CLOSEDLOOP Guards the mechanostat feedback loop (PROJECT_PLAN v1.3).
%
%   Run with:  runtests("tests/test_closedloop.m")
%
%   The v1.2 plan prescribed strain as an exogenous input, which cut the
%   negative feedback that gives the mechanostat a set point.  The
%   consequences were silent and severe: f_bm became a pure integrator, so
%   V7's calcium plateau was unreachable, and with no set point E6's
%   saddle-node analysis had nothing to find (appendix C1).
%
%   Nothing about a running simulation makes that failure visible, so it is
%   asserted here instead:
%     1. the scenario interface may not carry strain
%     2. every scenario must carry force
%     3. the feedback SIGN must be negative through both channels
%        (geometry and material)
%     4. the model integrates end to end
%
%   Note: the "perturb and recover" assertion is a P2 deliverable -- it
%   needs the real M2/M3 modules.  RHSFULL is still a stub here.
%
%   Project: bone-mechanostat (PROJECT_PLAN v1.4)

tests = functiontests(localfunctions);
end

% -------------------------------------------------------------------------
function setupOnce(tc)
tc.TestData.p = getDefaultParams();
tc.TestData.scenarioNames = ["sedentary" "resistance" "bedrest" ...
                             "spaceflight" "tennis" "romosozumab" ...
                             "lowCalcium" "highCalcium"];
end

% --- 1. interface contract: no strain may be prescribed ------------------
function testScenariosRejectStrainFields(tc)
% Exercises the REAL guard (assertForceControlled), not a copy.  The first
% draft of this test called a private duplicate of the validation logic
% defined inside this file; it passed while the shipped guard was throwing
% MATLAB:badformat_mx instead of its own error ID.  A test that reimplements
% what it is testing verifies nothing.
s = scenarioLibrary("sedentary");
s.epsilon = 1200e-6;                       % someone "helpfully" adds this
verifyError(tc, @() assertForceControlled(s), ...
    "boneMechanostat:strainControlledInput", ...
    "Scenario validation must reject strain-like fields.");
end

function testGuardMessageIsFormattable(tc)
% The guard's message must survive being formatted -- see the note in
% assertForceControlled about ["a" "b"] silently becoming a string array.
% Caught by try/catch rather than verifyError because we need the
% exception object itself, which verifyError does not return.
s = scenarioLibrary("sedentary");
s.strain = 1e-3;

caught = MException.empty;
try
    assertForceControlled(s);
catch err
    caught = err;
end

verifyNotEmpty(tc, caught, "Guard did not throw on a strain field.");
% string() the identifier: MException.identifier is char, and verifyEqual
% compares class as well as value.
verifyEqual(tc, string(caught.identifier), "boneMechanostat:strainControlledInput", ...
    "Wrong error ID -- a bad format string can mask it as MATLAB:badformat_mx.");
verifyGreaterThan(tc, strlength(caught.message), 50, ...
    "Guard message did not render; check for a string-array format.");
verifyTrue(tc, contains(caught.message, "strain"), ...
    "Guard message should name the offending field.");
end

function testNoScenarioCarriesStrain(tc)
forbidden = ["strain" "eps" "epsilon" "microstrain" "sed" ...
             "strainenergy" "epspeak" "eps_peak"];
for name = tc.TestData.scenarioNames
    s = scenarioLibrary(name);
    fn = lower(string(fieldnames(s)));
    verifyEmpty(tc, intersect(fn, forbidden), ...
        sprintf("Scenario '%s' prescribes strain.", name));
end
end

% --- 2. every scenario must specify force --------------------------------
function testAllScenariosSpecifyForce(tc)
for name = tc.TestData.scenarioNames
    s = scenarioLibrary(name);
    verifyTrue(tc, isfield(s, "bouts"), ...
        sprintf("Scenario '%s' has no bouts.", name));
    for k = 1:numel(s.bouts)
        verifyTrue(tc, isfield(s.bouts(k), "momentScale") && ...
                       isfield(s.bouts(k), "axialScale"), ...
            sprintf("Scenario '%s' bout %d lacks force fields.", name, k));
    end
end
end

% --- 3. the feedback sign must be negative -------------------------------
function testGeometricFeedbackIsNegative(tc)
% Periosteal expansion must REDUCE strain for the same load.  If this ever
% comes out positive the loop is wired backwards and bone would run away.
p = tc.TestData.p;
s = scenarioLibrary("sedentary");

st1 = struct(r_p = p.r_p_0,        r_e = p.r_e_0, ...
             f_bm = p.f_bm_0, rho_min = p.rho_min_0);
st2 = st1;
st2.r_p = p.r_p_0 * 1.10;                  % +10% periosteal radius

eps1 = organMechanics(s.bouts(1), st1, p).eps_p;
eps2 = organMechanics(s.bouts(1), st2, p).eps_p;

verifyLessThan(tc, eps2, eps1, ...
    "Periosteal expansion must reduce peak strain (negative feedback).");
end

function testMaterialFeedbackIsNegative(tc)
% Densification must also reduce strain, via E_app ~ f_bm^kappa.
p = tc.TestData.p;
s = scenarioLibrary("sedentary");

st1 = struct(r_p = p.r_p_0, r_e = p.r_e_0, ...
             f_bm = 0.85, rho_min = p.rho_min_0);
st2 = st1;
st2.f_bm = 0.95;

eps1 = organMechanics(s.bouts(1), st1, p).eps_p;
eps2 = organMechanics(s.bouts(1), st2, p).eps_p;

verifyLessThan(tc, eps2, eps1, ...
    "Higher bone volume fraction must reduce peak strain.");
end

% NOTE -- a "geometry beats density" assertion was drafted here and
% deliberately removed.  Comparing a 5% radius change against a 5% f_bm
% change gives 13.0% vs 11.5% strain reduction at kappa_E = 2.5, but the
% ordering REVERSES at kappa_E = 3.0 -- a value inside the CSV's own
% [2.0, 3.0] bounds.  A test that fails on a legitimate parameter value
% tests the placeholder, not the model.
%
% The real claim (Haapasalo: gain is geometric, vBMD unchanged) is V6f,
% and it is a statement about where the CELLS put new bone, not about the
% strain sensitivity of a hypothetical uniform change.  It belongs to E5
% at phase P5, once SURFACEALLOCATION exists.

function testUnloadingRaisesNothingAndLoadingRaisesStrain(tc)
p = tc.TestData.p;
st = struct(r_p = p.r_p_0, r_e = p.r_e_0, ...
            f_bm = p.f_bm_0, rho_min = p.rho_min_0);

epsSed  = organMechanics(scenarioLibrary("sedentary").bouts(1), st, p).eps_p;
epsRest = organMechanics(scenarioLibrary("bedrest").bouts(1), st, p).eps_p;
resBouts = scenarioLibrary("resistance").bouts;
[~, iPeak] = max([resBouts.momentScale]);
epsRes  = organMechanics(resBouts(iPeak), st, p).eps_p;

verifyLessThan(tc, epsRest, epsSed, "Bed rest must lower peak strain.");
verifyGreaterThan(tc, epsRes, epsSed, "Resistance training must raise peak strain.");
end

% --- 4. end-to-end integration -------------------------------------------
function testTwentyFourMonthRunCompletes(tc)
% PROJECT_PLAN §8, P1 definition of done: "空模型可跑完 24 個月".
s = scenarioLibrary("sedentary", durationDays = 730);
out = simulate(s);

verifyEqual(tc, numel(out.t), 731);
verifyEqual(tc, out.t(end), 730);
verifyFalse(tc, any(~isfinite(out.y), "all"), "Non-finite states in trajectory.");
verifyTrue(tc, all(out.y >= -1e-9, "all"), "NonNegative constraint violated.");
verifyTrue(tc, isfield(out.dens, "aBMD"), "SIMULATE must report aBMD.");
verifyTrue(tc, isfield(out.dens, "vBMD"), "SIMULATE must report vBMD.");
end

function testStubModelIsFlat(tc)
% The P1 stub relaxes towards baseline, so aBMD must not drift.  This is a
% plumbing check, not a physiological result.
s = scenarioLibrary("sedentary", durationDays = 730);
out = simulate(s);

drift = abs(out.dens.aBMD(end) - out.dens.aBMD(1)) / out.dens.aBMD(1);
verifyLessThan(tc, drift, 1e-6, ...
    "P1 stub should hold baseline; drift indicates a plumbing error.");
end

