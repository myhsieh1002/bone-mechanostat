function d = densitometry(r_p, r_e, f_bm, rho_min, p)
%DENSITOMETRY M7(d) -- convert structural state to DXA and pQCT observables.
%
%   D = DENSITOMETRY(R_P, R_E, F_BM, RHO_MIN, P) returns areal and
%   volumetric densities (PROJECT_PLAN v1.3 §4.2 M7(d)).
%
%     BMC/L = A_g f_bm rho_min                              [kg/m]
%     aBMD  = A_g f_bm rho_min / (2 r_p)                     [kg/m^2]
%     vBMD  = f_bm rho_min                                   [kg/m^3]
%
%   *** BOTH OUTPUTS ARE REQUIRED, AND THE aBMD SIZE ARTEFACT IS INTENDED ***
%   Dividing by the projected width 2*r_p reproduces DXA's well-known
%   confounding of bone size with bone density: periosteal expansion raises
%   aBMD even when volumetric density is unchanged.  That is not a bug to be
%   corrected -- it is what lets one model be compared against BOTH the
%   pQCT literature (V6a-V6f, reported as vBMD and areas) and the DXA
%   literature (V7 calcium, V8 romosozumab, reported as aBMD).  Suppressing
%   it would make V6f unreachable.
%
%   Inputs
%     r_p      (:,1) double  periosteal radius                    [m]
%     r_e      (:,1) double  endocortical radius                  [m]
%     f_bm     (:,1) double  intracortical bone volume fraction   [-]
%     rho_min  (:,1) double  mean mineral density                 [kg/m^3]
%     p        (1,1) struct  parameters from getDefaultParams
%
%   Output
%     d  (1,1) struct with column-vector fields
%       aBMD    [kg/m^2]  areal BMD (DXA-like)
%       vBMD    [kg/m^3]  volumetric BMD (pQCT Co.Dn-like)
%       BMC_L   [kg/m]    bone mineral content per unit length
%       Tot_Ar  [m^2]     total cross-sectional area,  pi r_p^2
%       Co_Ar   [m^2]     cortical area,               pi (r_p^2 - r_e^2)
%       MCav_Ar [m^2]     marrow cavity area,          pi r_e^2
%       I_max   [m^4]     second moment of area
%
%   See also CROSSSECTION, BONESTRUCTURE.

%   Project: bone-mechanostat (PROJECT_PLAN v1.4)

arguments
    r_p (:,1) double
    r_e (:,1) double
    f_bm (:,1) double
    rho_min (:,1) double
    p (1,1) struct %#ok<INUSA>  % kept for interface symmetry / future use
end

A_g = pi * (r_p.^2 - r_e.^2);

d = struct();
d.Tot_Ar  = pi * r_p.^2;
d.MCav_Ar = pi * r_e.^2;
d.Co_Ar   = A_g;
d.I_max   = (pi / 4) * (r_p.^4 - r_e.^4);
d.BMC_L   = A_g .* f_bm .* rho_min;
d.aBMD    = d.BMC_L ./ (2 * r_p);
d.vBMD    = f_bm .* rho_min;
end
