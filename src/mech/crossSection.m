function g = crossSection(r_p, r_e, f_bm, rho_min, p)
%CROSSSECTION Geometry and apparent stiffness of the idealised cortical tube.
%
%   G = CROSSSECTION(R_P, R_E, F_BM, RHO_MIN, P) evaluates the structural
%   quantities that close the mechanostat feedback loop (PROJECT_PLAN v1.3
%   §4.2 M1).
%
%   Geometry (hollow circular section):
%     A_g = pi (r_p^2 - r_e^2)                                       [m^2]
%     I_g = (pi/4) (r_p^4 - r_e^4)                                   [m^4]
%
%   Material (Currey / Gibson-Ashby power law; separates how MUCH matrix
%   there is from how MINERALISED that matrix is):
%     E_app = E_ref * f_bm^kappa * (rho_min / rho_min_0)^nu           [Pa]
%
%   Note the strong lever arms: I_g ~ r^4 and, for a thin wall,
%   I_g ~ pi r^3 t.  Periosteal expansion is therefore a far more
%   effective way to reduce strain than densification -- which is why
%   Haapasalo et al. (2000) found the tennis players' gain to be entirely
%   geometric (I_max +27-67%) with volumetric density unchanged.
%
%   Inputs
%     r_p      (1,1) double  periosteal radius                        [m]
%     r_e      (1,1) double  endocortical radius                      [m]
%     f_bm     (1,1) double  intracortical bone volume fraction       [-]
%     rho_min  (1,1) double  mean mineral density                     [kg/m^3]
%     p        (1,1) struct  parameters from getDefaultParams
%
%   Output
%     g  (1,1) struct with fields
%       A_g    [m^2]   bone cross-sectional area
%       I_g    [m^4]   second moment of area
%       E_app  [Pa]    apparent elastic modulus
%       t_c    [m]     cortical wall thickness (r_p - r_e)
%
%   See also ORGANMECHANICS, DENSITOMETRY.

%   Project: bone-mechanostat (PROJECT_PLAN v1.4)

arguments
    r_p (1,1) double
    r_e (1,1) double
    f_bm (1,1) double
    rho_min (1,1) double
    p (1,1) struct
end

if r_e >= r_p
    error("boneMechanostat:invalidGeometry", ...
          "Endocortical radius (%g m) must be smaller than periosteal (%g m).", ...
          r_e, r_p);
end

% Floor on f_bm: E_app ~ f_bm^kappa, so f_bm -> 0 sends strain to infinity.
% The floor is a numerical guard, not a physiological claim -- see
% PROJECT_PLAN v1.3 §4.2 M1 "數值注意".
f_eff = max(f_bm, p.f_bm_min);

g = struct();
g.A_g   = pi * (r_p^2 - r_e^2);
g.I_g   = (pi / 4) * (r_p^4 - r_e^4);
g.t_c   = r_p - r_e;
g.E_app = p.E_ref * f_eff^p.kappa_E * (rho_min / p.rho_min_0)^p.nu_E;
end
