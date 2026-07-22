function [p_fit, diagnostics] = calibrate(targets, opts)
%CALIBRATE Fit the few free parameters to the validation targets.
%
%   *** Discipline (PROJECT_PLAN §9) ***
%   At least 80% of parameters stay fixed from the literature; at most 4-6 are
%   opened.  Hold-out targets must NOT enter the objective: V6a-V6f (tennis),
%   V10 (post-withdrawal loss) and V14 (emergent epsilon*) are blind tests.
%   Check the holdout column of data/validation_targets.csv.
%
%   Inputs
%     targets (:,:) table   from data/validation_targets.csv
%     opts    .freeParams, .solver, .weights
%   Outputs
%     p_fit        (1,1) struct  calibrated parameters
%     diagnostics  (1,1) struct  residuals, target-by-target pass/fail
%
%   *** NOT IMPLEMENTED -- scheduled for phase P4 (analysis) ***
%
%   Project: bone-mechanostat (PROJECT_PLAN v1.4)

error("boneMechanostat:notImplemented", ...
      "calibrate is a phase-P4 deliverable (analysis) and is not implemented yet.");
end
