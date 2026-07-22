function res = sensitivityLHS(scenario, opts)
%SENSITIVITYLHS Latin hypercube sampling with PRCC.
%
%   *** Cap the parallel pool: parpool('Processes', 3). ***
%   Other Claude Code sessions on this machine drive their own MATLAB
%   processes and this is a 10-core box; the default pool size oversubscribes
%   it and slows everyone down (PROJECT_PLAN v1.3 §7.3).
%
%   Set rng(20260722,'twister') before sampling (§7.1).
%
%   Inputs
%     scenario (1,1) struct
%     opts     .nSamples, .paramSubset, .outputs
%   Output
%     res  (1,1) struct  samples, outputs, PRCC, significance
%
%   *** NOT IMPLEMENTED -- scheduled for phase P6 (analysis) ***
%
%   Project: bone-mechanostat (PROJECT_PLAN v1.4)

error("boneMechanostat:notImplemented", ...
      "sensitivityLHS is a phase-P6 deliverable (analysis) and is not implemented yet.");
end
