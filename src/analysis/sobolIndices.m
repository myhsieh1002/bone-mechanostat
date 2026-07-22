function res = sobolIndices(scenario, opts)
%SOBOLINDICES Global variance-based sensitivity (first-order and total indices).
%
%   N = 10,000 per PROJECT_PLAN §5 E6.  Same parallel-pool cap and rng seed
%   as SENSITIVITYLHS.
%
%   Expected key parameters: tau_50, k_tau_sig, K_S, lambda_S, zeta, kappa_E.
%
%   Inputs
%     scenario (1,1) struct
%     opts     .nSamples, .paramSubset, .outputs
%   Output
%     res  (1,1) struct  S1, ST, confidence intervals
%
%   *** NOT IMPLEMENTED -- scheduled for phase P6 (analysis) ***
%
%   Project: bone-mechanostat (PROJECT_PLAN v1.4)

error("boneMechanostat:notImplemented", ...
      "sobolIndices is a phase-P6 deliverable (analysis) and is not implemented yet.");
end
