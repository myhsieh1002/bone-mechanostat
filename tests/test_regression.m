function tests = test_regression()
%TEST_REGRESSION Golden-trajectory comparison against stored reference runs.
%
%   Golden-trajectory comparison against stored reference runs.
%
%   References live under getResultsDir("golden") -- local disk, not
%   iCloud, so that sync eviction cannot silently corrupt them.
%
%   *** NOT IMPLEMENTED -- scheduled for phase P5 ***
%
%   Project: bone-mechanostat (PROJECT_PLAN v1.4)

tests = functiontests(localfunctions);
end

function testPlaceholder(tc)
assumeFail(tc, "test_regression is a phase-P5 deliverable and is not implemented yet.");
end
