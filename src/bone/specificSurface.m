function [S_v, S_v_hat] = specificSurface(f_bm, p)
%SPECIFICSURFACE M7(b) -- specific surface vs bone volume fraction.
%
%   [S_V, S_V_HAT] = SPECIFICSURFACE(F_BM, P) returns the specific surface
%   and its value normalised to the baseline f_bm_0.
%
%   Remodelling can only happen on an existing bone surface, so S_v must
%   vanish at both ends:
%       S_v(0) = 0   trabeculae perforated -- nothing left to build on
%       S_v(1) = 0   solid -- no surface
%
%   S_v(0) = 0 makes f_bm = 0 a DEGENERATE fixed point (an absorbing
%   state).  That is the mechanism behind V11's loss/recovery asymmetry,
%   and it needs no phenomenological asymmetry parameter (PROJECT_PLAN
%   v1.3 4.2 M7(b)).  It is also P3 positive feedback #2.
%
%   *** PLACEHOLDER FORM ***
%       S_v = S_v_max * norm * f^s1 (1-f)^s2,  peak at f = s1/(s1+s2)
%   with s1 = 1, s2 = 3 putting the peak near f_bm = 0.25.  Right shape,
%   but NOT Martin's function -- replace with the five-term polynomial
%   from B1 #6b (Martin 1984) before P4.
%
%   Numerical note: as f_bm -> 0 both formation and resorption vanish, so
%   ODE15S crawls.  BONESTRUCTURE imposes f_bm_min.
%
%   Inputs
%     f_bm  (:,:) double  bone volume fraction                         [-]
%     p     (1,1) struct  parameters (S_v_max, s1_Sv, s2_Sv, f_bm_0)
%
%   Outputs
%     S_v      (:,:) double  specific surface                          [-]
%     S_v_hat  (:,:) double  S_v / S_v(f_bm_0)                         [-]
%
%   See also BONESTRUCTURE, SURFACEALLOCATION.

%   Project: bone-mechanostat (PROJECT_PLAN v1.6)

arguments
    f_bm double
    p (1,1) struct
end

s1 = p.s1_Sv;
s2 = p.s2_Sv;

% Normalise so the polynomial peaks at S_v_max.
fPk  = s1 / (s1 + s2);
peak = fPk^s1 * (1 - fPk)^s2;

f   = min(max(f_bm, 0), 1);
S_v = p.S_v_max * (f.^s1 .* (1 - f).^s2) / peak;

f0      = min(max(p.f_bm_0, 0), 1);
S_v0    = p.S_v_max * (f0^s1 * (1 - f0)^s2) / peak;
S_v_hat = S_v / S_v0;
end
