function tests = test_steadystate()
%TEST_STEADYSTATE Baseline stability: with no perturbation, aBMD drift must stay below
%
%   Baseline stability: with no perturbation, aBMD drift must stay below
%   0.1 %/yr, and the Jacobian at the fixed point must have all
%   eigenvalues in the left half plane.
%
%   Also asserts V14: the emergent mechanostat set point epsilon* must land
%   inside Frost's 100-1500 microstrain window.  epsilon* is an OUTPUT of
%   the closed loop, never an input.
%
%   *** NOT IMPLEMENTED -- scheduled for phase P3 ***
%
%   Project: bone-mechanostat (PROJECT_PLAN v1.4)

tests = functiontests(localfunctions);
end

function testPlaceholder(tc)
assumeFail(tc, "test_steadystate is a phase-P3 deliverable and is not implemented yet.");
end
