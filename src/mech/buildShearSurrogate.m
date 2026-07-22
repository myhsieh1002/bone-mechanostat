function surrogate = buildShearSurrogate(p, opts)
%BUILDSHEARSURROGATE M2 -- offline sweep of POROELASTIC1D, fitted to a fast surrogate.
%
%   Sweeps (eps_peak, f) over POROELASTIC1D and fits
%
%     tauhat_max(eps,f) = K_tau eps (f/f_0)^alpha / (1 + (f/f_c)^alpha)
%
%   Saves the fitted coefficients under GETRESULTSDIR("surrogates").
%   Required fit quality: R^2 > 0.98 (P2 definition of done).
%
%   *** alpha and f_c are standardised HERE and must NOT be re-fitted
%   downstream. *** Frequency enters the model twice -- through M2 fluid
%   mechanics and through M3 channel kinetics -- and the two are hard to
%   separate during calibration (PROJECT_PLAN v1.4 §4.2 M3, C5.3).
%
%   Inputs
%     p    (1,1) struct  parameters
%     opts .epsGrid [-], .freqGrid [Hz], .save (logical)
%   Output
%     surrogate (1,1) struct  fitted coefficients + fit diagnostics
%
%   *** NOT IMPLEMENTED -- scheduled for phase P2 (M2) ***
%
%   Project: bone-mechanostat (PROJECT_PLAN v1.4)

error("boneMechanostat:notImplemented", ...
      "buildShearSurrogate is a phase-P2 deliverable (M2) and is not implemented yet.");
end
