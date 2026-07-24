function [d, rho_min] = mineralization(m1, m2, v_form, v_res, f_bm, p)
%MINERALIZATION M7(c) -- two-compartment primary/secondary mineralisation.
%
%   [D, RHO_MIN] = MINERALIZATION(M1, M2, V_FORM, V_RES, F_BM, P) evaluates
%
%       dm1/dt  = v_form_hat m_prim rho_ref - kappa_m m1
%       dm2/dt  = kappa_m m1 - v_res_hat mbar
%       rho_min = (m1 + m2) / f_bm                             [kg/m^3]
%
%   V_FORM and V_RES are surface velocities NORMALISED to baseline, so the
%   pools stay in kg/m^3 and are unaffected by the placeholder k_form /
%   k_res magnitudes.  Deposition and removal are scaled so that the
%   baseline partition (m_prim, 1 - m_prim) x f_bm_0 rho_min_0 is a fixed
%   point.
%
%   Secondary mineralisation is slow (kappa_m ~ 0.004 /day, i.e. months to
%   years).  That lag is why BMD keeps drifting after remodelling activity
%   has already changed -- relevant to V9/V10 (romosozumab self-limitation
%   and post-withdrawal loss).
%
%   Inputs
%     m1, m2  (1,1) double  mineral pools                        [kg/m^3]
%     v_form  (1,1) double  formation velocity / baseline              [-]
%     v_res   (1,1) double  resorption velocity / baseline             [-]
%     f_bm    (1,1) double  bone volume fraction                       [-]
%     p       (1,1) struct  parameters
%
%   Outputs
%     d        (1,1) struct  .m1 .m2                      [kg/(m^3 day)]
%     rho_min  (1,1) double  mean mineral density                [kg/m^3]
%
%   See also BONESTRUCTURE, DENSITOMETRY.

%   Project: bone-mechanostat (PROJECT_PLAN v1.6)

arguments
    m1 (1,1) double
    m2 (1,1) double
    v_form (1,1) double
    v_res (1,1) double
    f_bm (1,1) double
    p (1,1) struct
end

m1_0 = p.m_prim * p.f_bm_0 * p.rho_min_0;
m2_0 = (1 - p.m_prim) * p.f_bm_0 * p.rho_min_0;

% Baseline balance: deposition = kappa_m m1_0 = removal, so both pools sit
% still when v_form_hat = v_res_hat = 1.
dep = p.kappa_m * m1_0;

d.m1 = dep * v_form - p.kappa_m * m1;
d.m2 = p.kappa_m * m1 - (p.kappa_m * m1_0) * v_res * (m2 / m2_0);

rho_min = (m1 + m2) / max(f_bm, p.f_bm_min);
end
