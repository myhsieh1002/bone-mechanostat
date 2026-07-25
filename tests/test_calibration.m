function tests = test_calibration()
%TEST_CALIBRATION P4 -- the calibrated model must hit its validation targets.
%
%   Run with:  runtests("tests/test_calibration.m")
%
%   Regression guard for the P4 calibration (PROJECT_PLAN appendix C10).
%   The parameters in data/parameters_literature.csv were fitted to V1,
%   V2, V7 and V8 with surrogateopt; V6/V10/V14 were held out.  This test
%   asserts the shipped CSV still reproduces those targets -- so an
%   innocent parameter edit that breaks the fit fails loudly.
%
%   The HOLD-OUT assertions (V10, V14) are the ones that matter most: they
%   were never in the objective, so their passing is evidence of predictive
%   validity rather than curve-fitting.
%
%   Project: bone-mechanostat (PROJECT_PLAN v2.0)

tests = functiontests(localfunctions);
end

% -------------------------------------------------------------------------
function setupOnce(tc)
tc.TestData.p = getDefaultParams(reload = true);
tc.TestData.r = evalTargets(tc.TestData.p, holdout = true);
end

% --- fitted targets ------------------------------------------------------
function testTurnover_V1(tc)
verifyTrue(tc, tc.TestData.r.pass.V1, sprintf( ...
    "V1 turnover %.2f %%/yr outside 5-10.", tc.TestData.r.V1));
end

function testDisuse_V2(tc)
verifyTrue(tc, tc.TestData.r.pass.V2, sprintf( ...
    "V2 disuse loss %.2f %%/mo outside 1.0-1.5.", tc.TestData.r.V2));
end

function testCalciumEffect_V7(tc)
% The calcium question itself: small POSITIVE BMD effect of supplementation.
verifyTrue(tc, tc.TestData.r.pass.V7, sprintf( ...
    "V7 calcium effect %+.2f %% outside 0.7-1.8.", tc.TestData.r.V7));
verifyGreaterThan(tc, tc.TestData.r.V7, 0, ...
    "Calcium supplementation must raise BMD, not lower it (sign).");
end

function testCalciumPlateau_V7(tc)
% Non-progressive: the plateau is the discriminating feature (Tai 2015).
verifyTrue(tc, tc.TestData.r.pass.V7slope, sprintf( ...
    "V7 plateau slope %+.3f %%/yr not flat.", tc.TestData.r.V7slope));
end

function testRomosozumab_V8(tc)
verifyTrue(tc, tc.TestData.r.pass.V8, sprintf( ...
    "V8 romosozumab %+.2f %% outside 11-14.", tc.TestData.r.V8));
end

% --- hold-out targets (blind) -------------------------------------------
function testHoldout_V10_postWithdrawal(tc)
verifyTrue(tc, tc.TestData.r.passHoldout.V10, sprintf( ...
    "HOLD-OUT V10 washout %+.2f %% should be < 0.", tc.TestData.r.V10));
end

function testHoldout_V14_emergentSetPoint(tc)
% epsilon* is an OUTPUT of the closed loop; it should land in Frost's band
% without ever being fitted.
verifyTrue(tc, tc.TestData.r.passHoldout.V14, sprintf( ...
    "HOLD-OUT V14 emergent epsilon* %.0f ue outside 100-1500.", ...
    tc.TestData.r.V14));
end

% --- balance invariant ---------------------------------------------------
function testFormationIsBoneMassBalanced(tc)
% k_form in the CSV must equal balanceBoneFormation(p): the calibration
% only opens k_res, and k_form follows from adult bone-mass balance.
p = tc.TestData.p;
verifyEqual(tc, p.k_form, balanceBoneFormation(p), "CSV k_form must match the bone-mass-balanced value.", ...
    RelTol = 1e-3);
end
