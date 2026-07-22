function [O, I, C_h] = msicGating(tau_t, tvec, p)
%MSICGATING M3 -- mechanosensitive ion channel, three-state gating.  THE only channel model.
%
%     k_co(tau) = k_co_max [1 + exp(-(tau - tau_50)/k_tau)]^-1
%     dO/dt = k_co(tau) C_h - (k_oc + k_oi) O
%     dI/dt = k_oi O - k_ic I
%     C_h   = 1 - O - I
%
%   *** This is the model's single representation of channel opening. ***
%   v1.3 also carried a phenomenological P_o(tau) sigmoid in M4 and
%   phenomenological saturation terms (Phi_rest, N^p) in M3 -- four-fold
%   double counting.  v1.4 removed all of them; tau_50 and k_tau migrated
%   here.  Do not reintroduce a separate open-probability expression
%   anywhere (test_noPhenomParams.m guards the parameter side of this).
%
%   Cycle-number saturation (V4) emerges from I accumulating within a bout;
%   rest-insertion gain (V5) emerges from I -> C_h during the gaps.  Neither
%   has a fitted parameter any more.
%
%   Inputs
%     tau_t (1,:) double  wall shear stress time course           [Pa]
%     tvec  (1,:) double  time grid, seconds resolution           [s]
%     p     (1,1) struct  parameters (tau_50, k_tau_sig, k_co_max,
%                         k_oc, k_oi, k_ic)
%   Outputs
%     O, I, C_h (1,:) double  state occupancies                   [-]
%
%   *** NOT IMPLEMENTED -- scheduled for phase P2 (M3) ***
%
%   Project: bone-mechanostat (PROJECT_PLAN v1.4)

error("boneMechanostat:notImplemented", ...
      "msicGating is a phase-P2 deliverable (M3) and is not implemented yet.");
end
