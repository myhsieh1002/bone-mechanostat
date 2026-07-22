function d = mineralization(m1, m2, v_form, v_res, f_bm, p)
%MINERALIZATION M7(c) -- two-compartment primary/secondary mineralisation.
%
%     dm1/dt = v_form m_prim - kappa_m m1
%     dm2/dt = kappa_m m1 - v_res mbar
%     rho_min = (m1 + m2)/f_bm                                    [kg/m^3]
%
%   Inputs
%     m1, m2  (1,1) double  mineral pools                          [kg/m^3]
%     v_form  (1,1) double  formation velocity                     [m/day]
%     v_res   (1,1) double  resorption velocity                    [m/day]
%     f_bm    (1,1) double  bone volume fraction                   [-]
%     p       (1,1) struct  parameters
%   Output
%     d  (1,1) struct  .m1 .m2 derivatives              [kg/(m^3 day)]
%
%   *** NOT IMPLEMENTED -- scheduled for phase P3 (M7) ***
%
%   Project: bone-mechanostat (PROJECT_PLAN v1.4)

error("boneMechanostat:notImplemented", ...
      "mineralization is a phase-P3 deliverable (M7) and is not implemented yet.");
end
