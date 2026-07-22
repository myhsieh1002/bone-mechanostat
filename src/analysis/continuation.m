function branch = continuation(scenario, paramName, range, opts)
%CONTINUATION Pseudo-arclength continuation; detects saddle-node bifurcations.
%
%   *** Continuation parameters are tau_50, beta_S and E2 -- NOT epsilon*. ***
%   Once the loop is closed the mechanostat set point is an OUTPUT of the
%   system, not an input (PROJECT_PLAN v1.3 §5 note, V14).  Treating
%   epsilon* as an adjustable parameter would cut the feedback line again.
%
%   Inputs
%     scenario  (1,1) struct
%     paramName (1,1) string  "tau_50" | "beta_S" | "E2_0" | "zeta"
%     range     (1,2) double  [lo hi]
%     opts      .ds, .maxSteps, .detectFold
%   Output
%     branch  (1,1) struct  parameter values, fixed points, stability, folds
%
%   *** NOT IMPLEMENTED -- scheduled for phase P6 (analysis) ***
%
%   Project: bone-mechanostat (PROJECT_PLAN v1.4)

error("boneMechanostat:notImplemented", ...
      "continuation is a phase-P6 deliverable (analysis) and is not implemented yet.");
end
