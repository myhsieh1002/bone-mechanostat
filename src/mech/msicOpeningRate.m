function kco = msicOpeningRate(tau, p)
%MSICOPENINGRATE M3 -- shear-dependent closed->open rate of the MSIC.
%
%   KCO = MSICOPENINGRATE(TAU, P) evaluates
%
%       k_co(tau) = k_co_max [1 + exp(-(tau - tau_50)/k_tau)]^-1   [1/s]
%
%   This sigmoid is where ALL shear dependence of the model enters.  It
%   also carries two roles that v1.3 assigned to separate phenomenological
%   parameters (appendix C5.2):
%     - the soft threshold, previously tau_th
%     - the supralinearity of dose in strain, previously the exponent q
%   Its steepness k_tau_sig therefore matters well beyond channel kinetics:
%   SURFACEALLOCATION relies on the supralinearity to bias formation
%   towards the periosteum.
%
%   Note k_co(0) = k_co_max/(1 + exp(tau_50/k_tau)) > 0, so there is a
%   non-zero resting open probability.  That is deliberate -- complete
%   unloading should attenuate the signal, not abolish it -- but the size
%   of that floor is set by tau_50/k_tau_sig and is currently a
%   placeholder awaiting Fu et al. 2025 (B1 #5).  MSICRESTINGSTATE reports
%   what it implies.
%
%   Inputs
%     tau  (:,:) double  wall shear stress                            [Pa]
%     p    (1,1) struct  parameters (k_co_max, tau_50, k_tau_sig)
%
%   Output
%     kco  (:,:) double  opening rate                                 [1/s]
%
%   See also MSICGATING, MSICRESTINGSTATE.

%   Project: bone-mechanostat (PROJECT_PLAN v1.5)

arguments
    tau double
    p (1,1) struct
end

kco = p.k_co_max ./ (1 + exp(-(tau - p.tau_50) ./ p.k_tau_sig));
end
