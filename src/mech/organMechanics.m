function m = organMechanics(bout, state, p)
%ORGANMECHANICS M1 -- force-controlled organ mechanics (closed loop).
%
%   M = ORGANMECHANICS(BOUT, STATE, P) converts an applied LOAD into the
%   peak strains at the periosteal and endocortical surfaces, given the
%   bone's current geometry and material state.
%
%   *** THIS FUNCTION IS THE MECHANOSTAT ***
%   The input is force; strain is the output.  Because E_app and I_g depend
%   on the structural state, bone that has gained mass sees LESS strain for
%   the same load -- the negative feedback that gives the system a set
%   point.  In PROJECT_PLAN v1.2 strain was an exogenous input, which cut
%   this line and made f_bm a pure integrator (see appendix C1).
%
%     eps_p = M_L r_p / (E_app I_g) + F_L / (E_app A_g)        [-]
%     eps_e = M_L r_e / (E_app I_g) + F_L / (E_app A_g)        [-]
%
%   The strain gradient across the wall (eps_p > eps_e under bending) is
%   what SURFACEALLOCATION later uses to bias formation towards the
%   periosteum -- so this function also supplies the mechanism behind the
%   "bone gets bigger, not denser" response.
%
%   Inputs
%     bout   (1,1) struct  one element of scenario.bouts; uses
%                          .momentScale and .axialScale                [-]
%     state  (1,1) struct  current structural state with fields
%                          r_p [m], r_e [m], f_bm [-], rho_min [kg/m^3]
%     p      (1,1) struct  parameters from getDefaultParams
%
%   Output
%     m  (1,1) struct with fields
%       eps_p    [-]    peak periosteal strain
%       eps_e    [-]    peak endocortical strain
%       eps_bar  [-]    wall-average strain (used for the intracortical
%                       surface)
%       M_L      [N*m]  applied peak bending moment
%       F_L      [N]    applied peak axial force
%       Psi      [Pa]   peak strain energy density, 0.5 E_app eps_p^2
%       geom     struct output of CROSSSECTION
%
%   Example
%     p  = getDefaultParams();
%     st = struct(r_p = p.r_p_0, r_e = p.r_e_0, ...
%                 f_bm = p.f_bm_0, rho_min = p.rho_min_0);
%     s  = scenarioLibrary("sedentary");
%     m  = organMechanics(s.bouts(1), st, p);
%     m.eps_p * 1e6      % peak strain in microstrain
%
%   See also CROSSSECTION, SHEARSURROGATE, SURFACEALLOCATION.

%   Project: bone-mechanostat (PROJECT_PLAN v1.4)

arguments
    bout (1,1) struct
    state (1,1) struct
    p (1,1) struct
end

geom = crossSection(state.r_p, state.r_e, state.f_bm, state.rho_min, p);

M_L = bout.momentScale * p.M_L_0;    % [N*m]
F_L = bout.axialScale  * p.F_L_0;    % [N]

axial = F_L / (geom.E_app * geom.A_g);

m = struct();
m.M_L     = M_L;
m.F_L     = F_L;
m.eps_p   = M_L * state.r_p / (geom.E_app * geom.I_g) + axial;
m.eps_e   = M_L * state.r_e / (geom.E_app * geom.I_g) + axial;
m.eps_bar = 0.5 * (m.eps_p + m.eps_e);
m.Psi     = 0.5 * geom.E_app * m.eps_p^2;
m.geom    = geom;
end
