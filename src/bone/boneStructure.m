function d = boneStructure(st, eta, xi, v_form, v_res, p)
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
end

[~, S_v_hat] = specificSurface(st.f_bm, p);

d.r_p = v_form * eta(1) - v_res * xi(1);
d.r_e = v_res  * xi(2)  - v_form * eta(2);

df = (S_v_hat / p.w_wall) * (v_form * eta(3) - v_res * xi(3));

% Floor guard: E_app ~ f_bm^kappa, so f_bm -> 0 sends strain to infinity.
% Clamp the derivative rather than the state, so ODE15S sees a continuous
% right-hand side instead of a discontinuity it would keep rejecting.
if st.f_bm <= p.f_bm_min && df < 0
    df = 0;
end
d.f_bm = df;
end
