function [tau_max, Phi] = shearSurrogate(eps_peak, freqHz, p)
%SHEARSURROGATE M2 -- peak fluid shear stress, closed form.
%
%   TAU_MAX = SHEARSURROGATE(EPS_PEAK, FREQHZ, P) returns the peak wall
%   shear stress for sinusoidal loading, from the exact steady-periodic
%   solution of the Biot problem in POROELASTIC1D:
%
%       tau_max = K_tau * eps_peak * Phi(f)
%       Phi(f)  = |k tanh(kL)| / |k0 tanh(k0 L)|,   k = sqrt(i 2 pi f / c_p)
%
%   Phi is normalised to 1 at f_0 = 1 Hz, so K_tau is exactly "peak shear
%   per unit peak strain at 1 Hz" [Pa per unit strain].
%
%   *** WHY THE PLAN'S SURROGATE FORM WAS REPLACED (v1.5) ***
%   PROJECT_PLAN v1.4 §4.2 M2 proposed
%       tauhat = K_tau eps (f/f_0)^alpha / (1 + (f/f_c)^alpha)
%   on the reasoning that pore pressure "cannot dissipate fast enough" at
%   high frequency, so shear saturates.  Solving the Biot problem shows the
%   opposite.  Writing eps(t) = Re{eps_hat e^{i omega t}} and p = Re{P e^{i
%   omega t}} with P'(0) = 0, P(L) = 0:
%
%       P(z) = (eps_hat/S) [cosh(kz)/cosh(kL) - 1]
%       |dP/dz|_max = |eps_hat/S| |k tanh(kL)|
%
%   Asymptotically:
%       kL << 1  ->  |k tanh kL| -> |k^2| L = (omega/c_p) L    ->  tau ~ f
%       kL >> 1  ->  |k tanh kL| -> |k| = sqrt(omega/c_p)      ->  tau ~ sqrt(f)
%
%   At high frequency the pressure does approach its undrained value, but
%   it does so everywhere EXCEPT in a boundary layer of thickness
%   delta = sqrt(c_p/omega) at the drained face.  As delta shrinks the
%   gradient there GROWS.  Shear therefore rises as sqrt(f) forever; it
%   never saturates.  The exponent softens from 1 to 1/2 across the
%   crossover at f_poro = c_p/(2 pi L^2) -- a compressive, log-like
%   dependence that is what V5b (mechanostat ~ ln f over 1-10 Hz) actually
%   needs.  A saturating form would have flattened V5b out entirely.
%
%   The closed form is exact for the linear problem, so no fitting is
%   involved and there is no residual R^2 to report -- BUILDSHEARSURROGATE
%   verifies it against the finite-difference solver instead.
%
%   Inputs
%     eps_peak (:,:) double  peak tissue strain                       [-]
%     freqHz   (:,:) double  loading frequency (scalar-expanded)      [Hz]
%     p        (1,1) struct  parameters (K_tau, k_perm, mu_fluid,
%                            S_stor, L_poro, f_0)
%
%   Outputs
%     tau_max  (:,:) double  peak wall shear stress                   [Pa]
%     Phi      (:,:) double  frequency factor, 1 at f_0               [-]
%
%   See also POROELASTIC1D, BUILDSHEARSURROGATE, LOADINGDOSE.

%   Project: bone-mechanostat (PROJECT_PLAN v1.5)

arguments
    eps_peak double
    freqHz double
    p (1,1) struct
end

Phi     = localPhi(freqHz, p) ./ localPhi(p.f_0, p);
tau_max = p.K_tau .* eps_peak .* Phi;
end

% -------------------------------------------------------------------------
function g = localPhi(f, p)
%LOCALPHI Unnormalised |k tanh(kL)|  [1/m].
c_p = p.k_perm / (p.mu_fluid * p.S_stor);
k   = sqrt(1i * 2 * pi * f / c_p);
g   = abs(k .* tanh(k * p.L_poro));
end
