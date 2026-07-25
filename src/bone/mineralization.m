function [d, rho_min] = mineralization(rho, vForm, vRes, p)
%MINERALIZATION M7(c) -- mean matrix mineralisation (turnover-dilution model).
%
%   [D, RHO_MIN] = MINERALIZATION(RHO, VFORM, VRES, P) evolves the mean
%   mineral density of the bone matrix as an intensive state:
%
%       d rho_min/dt = mu_turn_0 vForm (rho_prim - rho_min)   (dilution)
%                    + kappa_m          (rho_ref  - rho_min)   (maturation)
%
%   *** WHY THIS REPLACES THE TWO-POOL AREAL MODEL (v2.3, appendix C13) ***
%   The previous model tracked areal mineral pools m1, m2 and divided by
%   f_bm.  Under net formation those pools grew, so rho_min ROSE with
%   turnover -- backwards.  New bone is deposited at primary mineralisation
%   (~60% of mature) and only slowly matures, so faster turnover means MORE
%   young, less-mineralised bone and a LOWER mean density.  That is why the
%   tennis player's loaded arm gains bone geometrically with volumetric
%   density UNCHANGED (Haapasalo, V6f): the extra formation is diluted by
%   young bone, cancelling any density rise.
%
%   rho_ref (fully-mature density) is DERIVED so rho_min = rho_min_0 is a
%   fixed point at vForm = 1 -- baseline-relative, like M4-M8.  Two rates set
%   the balance: mu_turn_0 (baseline turnover, tied to V1) and kappa_m
%   (secondary-mineralisation rate, years).  kappa_m also carries the slow
%   post-treatment BMD drift relevant to V9/V10.
%
%   VRES is accepted for interface symmetry but does not enter: resorption
%   removes bone at the current mean density and so does not change the mean
%   of what remains (to first order).
%
%   Inputs
%     rho     (1,1) double  current mean mineral density          [kg/m^3]
%     vForm   (1,1) double  formation velocity / baseline (B)          [-]
%     vRes    (1,1) double  resorption velocity / baseline (C)         [-]
%     p       (1,1) struct  parameters (rho_min_0, m_prim, kappa_m,
%                           mu_turn_0)
%
%   Outputs
%     d        (1,1) struct  .rho_min derivative           [kg/(m^3 day)]
%     rho_min  (1,1) double  the input, echoed for convenience    [kg/m^3]
%
%   See also BONESTRUCTURE, DENSITOMETRY.

%   Project: bone-mechanostat (PROJECT_PLAN v2.3)

arguments
    rho (1,1) double
    vForm (1,1) double
    vRes (1,1) double %#ok<INUSA>  interface symmetry; see docstring
    p (1,1) struct
end

% rho_ref (mature) and rho_prim = m_prim*rho_ref (deposition), derived
% together so baseline rho_min_0 is a fixed point:
%   0 = mu*(m_prim*rho_ref - rho0) + kappa*(rho_ref - rho0)
rho_ref  = p.rho_min_0 * (p.mu_turn_0 + p.kappa_m) ...
         / (p.mu_turn_0 * p.m_prim + p.kappa_m);
rho_prim = p.m_prim * rho_ref;

d.rho_min = p.mu_turn_0 * vForm * (rho_prim - rho) ...
          + p.kappa_m * (rho_ref - rho);

rho_min = rho;
end
