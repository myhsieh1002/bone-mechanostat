function S_v = specificSurface(f_bm, p)
%SPECIFICSURFACE M7(b) -- specific surface as a function of bone volume fraction.
%
%   Remodelling can only happen on an existing bone surface.  S_v peaks at
%   intermediate porosity and vanishes at both ends:
%
%     S_v(0) = 0   -- trabeculae perforated: nothing left to build on
%     S_v(1) = 0   -- solid: no surface
%
%   S_v(0) = 0 makes f_bm = 0 a DEGENERATE fixed point (an absorbing state).
%   That is the mechanism behind V11's loss/recovery asymmetry -- it needs no
%   phenomenological asymmetry parameter (PROJECT_PLAN v1.3 §4.2 M7(b)).
%
%   *** Placeholder form in use ***
%     S_v = S_v_max * norm * f^s1 (1-f)^s2,   peak at f = s1/(s1+s2)
%   with s1=1, s2=3 giving a peak near f_bm = 0.25.  This has the right
%   qualitative shape but is NOT Martin's function; replace with the
%   five-term polynomial from B1 #6b (Martin 1984) before P4.
%
%   Numerical note: near f_bm -> 0 both formation and resorption vanish, so
%   ODE15S crawls.  BONESTRUCTURE must impose f_bm_min and an event.
%
%   Inputs
%     f_bm  (:,1) double  bone volume fraction                     [-]
%     p     (1,1) struct  parameters (S_v_max, s1_Sv, s2_Sv)
%   Output
%     S_v   (:,1) double  specific surface, normalised             [-]
%
%   *** NOT IMPLEMENTED -- scheduled for phase P3 (M7) ***
%
%   Project: bone-mechanostat (PROJECT_PLAN v1.4)

error("boneMechanostat:notImplemented", ...
      "specificSurface is a phase-P3 deliverable (M7) and is not implemented yet.");
end
