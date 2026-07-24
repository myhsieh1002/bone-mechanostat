function [O, I, C_h, D_mech] = msicGating(tau_t, tvec, p, opts)
%MSICGATING M3 -- mechanosensitive ion channel gating.  THE only channel model.
%
%   [O, I, C_H, D_MECH] = MSICGATING(TAU_T, TVEC, P) integrates the
%   three-state scheme
%
%       k_co(tau) = k_co_max [1 + exp(-(tau - tau_50)/k_tau)]^-1
%       dO/dt = k_co(tau) C_h - (k_oc + k_oi) O
%       dI/dt = k_oi O - k_ic I
%       C_h   = 1 - O - I
%
%   and returns the osteogenic dose D_MECH = int O dt over TVEC.
%
%   *** THIS IS THE MODEL'S SINGLE REPRESENTATION OF CHANNEL OPENING ***
%   v1.3 and earlier also carried a phenomenological dose expression here
%   and a P_o(tau) sigmoid in M4 -- four-fold double counting of rest
%   insertion, cycle saturation, threshold and supralinearity (appendix
%   C5.1).  Do not reintroduce an open-probability expression elsewhere.
%
%   Emergent behaviour, with no fitted parameter behind either:
%     V4 cycle saturation    -- I accumulates within a bout, depleting C_h
%     V5 rest-insertion gain -- I relaxes back to C_h during gaps (k_ic)
%
%   The system is linear in (O, I) with a time-varying coefficient, so each
%   step is advanced by the exact solution of the frozen-coefficient
%   problem (augmented 3x3 matrix exponential at the midpoint tau).  This
%   is unconditionally stable and, wherever tau is genuinely constant,
%   exact -- so one enormous step across the quiescent part of a day costs
%   a single EXPM and introduces no error.
%
%   Inputs
%     tau_t     (1,:) double  wall shear stress time course           [Pa]
%     tvec      (1,:) double  time grid, strictly increasing          [s]
%     p         (1,1) struct  parameters (tau_50, k_tau_sig, k_co_max,
%                             k_oc, k_oi, k_ic)
%     opts.y0   (2,1) double  initial [O; I].  Default: resting state
%
%   Outputs
%     O, I, C_h (1,:) double  state occupancies                       [-]
%     D_mech    (1,1) double  int O dt                                [s]
%
%   Example
%     p = getDefaultParams();
%     t = 0:0.01:60;  tau = 2 * max(0, sin(2*pi*0.5*t));
%     [O, ~, ~, D] = msicGating(tau, t, p);
%
%   See also MSICRESTINGSTATE, BUILDDOSESURROGATE, LOADINGDOSE.

%   Project: bone-mechanostat (PROJECT_PLAN v1.5)

arguments
    tau_t (1,:) double
    tvec (1,:) double
    p (1,1) struct
    opts.y0 (:,1) double = double.empty(0,1)
end

if numel(tau_t) ~= numel(tvec)
    error("boneMechanostat:sizeMismatch", ...
          "tau_t (%d) and tvec (%d) must be the same length.", ...
          numel(tau_t), numel(tvec));
end
if any(diff(tvec) <= 0)
    error("boneMechanostat:nonMonotonicTime", "tvec must increase strictly.");
end

if isempty(opts.y0)
    y = msicRestingState(p);
else
    y = opts.y0(1:2);
end

nt = numel(tvec);
O  = zeros(1, nt);
I  = zeros(1, nt);
O(1) = y(1);
I(1) = y(2);

koc = p.k_oc;
koi = p.k_oi;
kic = p.k_ic;

for n = 2:nt
    dt  = tvec(n) - tvec(n-1);
    kco = msicOpeningRate(0.5 * (tau_t(n) + tau_t(n-1)), p);

    % d/dt [O; I] = M [O; I] + b, after substituting C_h = 1 - O - I.
    M = [-(kco + koc + koi), -kco; ...
          koi,               -kic];
    b = [kco; 0];

    E = expm([M, b; zeros(1, 3)] * dt);
    y = E(1:2, 1:2) * y + E(1:2, 3);

    O(n) = y(1);
    I(n) = y(2);
end

C_h    = 1 - O - I;
D_mech = trapz(tvec, O);
end
