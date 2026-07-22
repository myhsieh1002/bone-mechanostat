function [y_ss, J, eig_J] = steadyState(scenario, p, opts)
%STEADYSTATE Fixed point via FSOLVE, plus the Jacobian and its eigenvalues.
%
%   Used by E0 for baseline calibration and by E6 as the predictor step of
%   pseudo-arclength continuation.  Eigenvalues classify stability and locate
%   the saddle-node.
%
%   Inputs
%     scenario (1,1) struct
%     p        (1,1) struct
%     opts     .y_guess, .tolerance, .display
%   Outputs
%     y_ss   (:,1) double  fixed point
%     J      (:,:) double  Jacobian at y_ss                      [1/day]
%     eig_J  (:,1) double  eigenvalues
%
%   *** NOT IMPLEMENTED -- scheduled for phase P3 (model) ***
%
%   Project: bone-mechanostat (PROJECT_PLAN v1.4)

error("boneMechanostat:notImplemented", ...
      "steadyState is a phase-P3 deliverable (model) and is not implemented yet.");
end
