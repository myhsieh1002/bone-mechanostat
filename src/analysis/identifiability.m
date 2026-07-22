function profiles = identifiability(p_fit, freeParams, opts)
%IDENTIFIABILITY Profile likelihood for the fitted parameters.
%
%   Mandatory before publication (PROJECT_PLAN §9 risk 1), and specifically
%   required for the pairs known to compensate:
%     lambda_E vs lambda_T  (E2 reaches RANKL by two routes)
%     kappa_E  vs K_tau     (mechanical loop gain vs shear gain)
%
%   Inputs
%     p_fit      (1,1) struct
%     freeParams (1,:) string
%     opts       .nPoints, .range
%   Output
%     profiles  (1,:) struct  per parameter: grid, chi2, CI, flat/identifiable
%
%   *** NOT IMPLEMENTED -- scheduled for phase P6 (analysis) ***
%
%   Project: bone-mechanostat (PROJECT_PLAN v1.4)

error("boneMechanostat:notImplemented", ...
      "identifiability is a phase-P6 deliverable (analysis) and is not implemented yet.");
end
