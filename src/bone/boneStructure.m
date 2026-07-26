function d = boneStructure(st, eta, xi, v_form, v_res, p, mech)
%BONESTRUCTURE M7 -- three-surface structural evolution.
%
%   D = BONESTRUCTURE(ST, ETA, XI, V_FORM, V_RES, P) evaluates
%
%       dr_p/dt  = v_form eta_p - v_res xi_p                     [m/day]
%       dr_e/dt  = v_res  xi_e  - v_form eta_e                   [m/day]
%       df_bm/dt = (S_v_hat/w) (v_form eta_i - v_res xi_i)       [1/day]
%
%   r_e INCREASING means endocortical resorption, i.e. a thinning cortex.
%   Tracking r_p and r_e separately is what lets the model reproduce
%   Haapasalo's finding that the playing arm's marrow cavity ALSO enlarged
%   (+19%): periosteal apposition outpacing endocortical change.
%
%   The S_v_hat factor carries P3 positive feedback #2 -- as f_bm falls
%   there is progressively less surface to rebuild on, and f_bm = 0 becomes
%   an absorbing state (SPECIFICSURFACE).
%
%   Inputs
%     st      (1,1) struct  r_p [m], r_e [m], f_bm [-]
%     eta     (1,3) double  formation split [per, endo, intra]          [-]
%     xi      (1,3) double  resorption split, same order                [-]
%     v_form  (1,1) double  k_form * B                              [m/day]
%     v_res   (1,1) double  k_res  * C                              [m/day]
%     p       (1,1) struct  parameters
%
%   Output
%     d  (1,1) struct  .r_p .r_e [m/day], .f_bm [1/day]
%
%   See also SURFACEALLOCATION, SPECIFICSURFACE, DENSITOMETRY.

%   Project: bone-mechanostat (PROJECT_PLAN v1.6)

arguments
    st (1,1) struct
    eta (1,3) double
    xi (1,3) double
    v_form (1,1) double
    v_res (1,1) double
    p (1,1) struct
    mech (1,1) struct = struct(eps_p = 0)
end

[~, S_v_hat] = specificSurface(st.f_bm, p);

% --- Frost MODELING term (v2.3, appendix C13/C14; SATURATED v2.6, C17) ---
% Vigorous loading drives direct periosteal apposition (bone MODELING),
% distinct from the dose/remodelling pathway.  It has a strain threshold
% (Frost's minimum effective strain for modelling, MES_m ~ 1000-1500 ue):
% ZERO at normal daily activity (~760 ue), active only above the threshold.
% This is what produces Haapasalo's geometric gain (V6a-e) without touching
% any calibration scenario (all below threshold), and it self-limits -- as
% r_p grows, I_g rises, peak strain falls back below MES_m.
% Gated by the osteocyte-sensing gain so a thinned network responds less.
%
% P5e: the strain excess SATURATES.  The v2.3 form was linear in the excess
% and therefore unbounded, which is only harmless while strain stays
% physiological.  At pathological f_bm the apparent modulus E_app = E_ref
% f_bm^kappa_E collapses, strain runs to ~1.2e4 ue *per cent*, and the
% linear term demanded 1513 mm/yr of periosteal apposition -- the 99 mm
% cortex artefact that nearly produced a false-positive P3 (appendix C15.4).
% Saturating at EPS_MODEL_SAT caps the rate at k_model*eps_model_sat =
% 1.93 um/day, the documented ceiling for rapid/woven mineral apposition,
% and puts half-maximal response at the yield strain of cortical bone,
% beyond which tissue damages rather than adapts.
sensing  = (st.n_ot / p.n_ot_0) ^ p.zeta;
excess   = max(0, mech.eps_p - p.eps_model_star);
modeling = p.k_model * excess / (1 + excess / p.eps_model_sat) * sensing;

% --- MODELLING DRIFT (v2.11, P5i, appendix C22) --------------------------
% A Frost modelling drift MOVES a cortex; it does not simply inflate it.
% Periosteal apposition is accompanied by endocortical resorption, so the
% whole wall translates outward.  Until v2.10 only the periosteal half was
% implemented, and the consequence was visible: the loaded arm's marrow
% cavity CONTRACTED (-2.9 %) where Haapasalo measured it enlarging (+19 %,
% V6e).  CHI_DRIFT = 1 is a pure translation, which conserves wall
% thickness; 0 recovers the v2.10 inflate-only behaviour.
%
% Note this rides on MODELING, so it inherits both of that term's gates: it
% is silent below the strain threshold (no calibration scenario is touched)
% and it is bounded by the same saturation (P5e).
d.r_p = v_form * eta(1) - v_res * xi(1) + modeling;
d.r_e = v_res  * xi(2)  - v_form * eta(2) + p.chi_drift * modeling;

df = (S_v_hat / p.w_wall) * (v_form * eta(3) - v_res * xi(3));

% Floor guard: E_app ~ f_bm^kappa, so f_bm -> 0 sends strain to infinity.
% Clamp the derivative rather than the state, so ODE15S sees a continuous
% right-hand side instead of a discontinuity it would keep rejecting.
if st.f_bm <= p.f_bm_min && df < 0
    df = 0;
end
d.f_bm = df;
end
