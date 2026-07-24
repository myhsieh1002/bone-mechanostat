function [y, info] = msicRestingState(p, tau)
%MSICRESTINGSTATE M3 -- steady-state channel occupancies at constant shear.
%
%   [Y, INFO] = MSICRESTINGSTATE(P) returns [O; I] at tau = 0.
%   [Y, INFO] = MSICRESTINGSTATE(P, TAU) uses the given constant shear.
%
%   Setting dO/dt = dI/dt = 0 with C_h = 1 - O - I:
%
%       I = (k_oi/k_ic) O
%       O = k_co / [k_co (1 + k_oi/k_ic) + k_oc + k_oi]
%
%   Used as the default initial condition for MSICGATING so that a
%   simulation does not begin with a spurious transient, and as a
%   diagnostic: INFO.O_rest is the model's baseline open probability under
%   complete unloading, which sets the floor of the daily dose and hence
%   how much signal survives in E3 (bed rest / microgravity).
%
%   Inputs
%     p    (1,1) struct  parameters
%     tau  (1,1) double  constant shear stress.  Default 0            [Pa]
%
%   Outputs
%     y     (2,1) double  [O; I]                                      [-]
%     info  (1,1) struct  .O_rest .I_rest .C_rest .k_co .tau
%
%   See also MSICGATING, MSICOPENINGRATE.

%   Project: bone-mechanostat (PROJECT_PLAN v1.5)

arguments
    p (1,1) struct
    tau (1,1) double = 0
end

kco = msicOpeningRate(tau, p);
r   = p.k_oi / p.k_ic;

O = kco / (kco * (1 + r) + p.k_oc + p.k_oi);
I = r * O;

y = [O; I];

info = struct();
info.O_rest = O;
info.I_rest = I;
info.C_rest = 1 - O - I;
info.k_co   = kco;
info.tau    = tau;
end
