function tests = test_conservation()
%TEST_CONSERVATION Calcium mass balance across M6/M7/M8.
%
%   Calcium mass balance across M6/M7/M8.
%
%   Total calcium (skeletal + serum + cumulative intake - cumulative
%   excretion) must be conserved to within solver tolerance.  Also checks
%   that the f_bm_min floor introduced for numerical safety does not
%   quietly create or destroy calcium (PROJECT_PLAN v1.3 §4.2 M7(b)).
%
%   *** NOT IMPLEMENTED -- scheduled for phase P4 ***
%
%   Project: bone-mechanostat (PROJECT_PLAN v1.4)

tests = functiontests(localfunctions);
end

function testPlaceholder(tc)
assumeFail(tc, "test_conservation is a phase-P4 deliverable and is not implemented yet.");
end
