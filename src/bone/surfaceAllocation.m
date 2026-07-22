function [eta, xi] = surfaceAllocation(mech, T, p)
%SURFACEALLOCATION M7(a) -- distribute formation and resorption across the three surfaces.
%
%   Formation is allocated by the strain gradient across the wall:
%
%     eta_p : eta_e : eta_i = D(eps_p) : D(eps_e) : D(eps_bar)
%
%   Under bending eps_p > eps_e, and D is supralinear below saturation (the
%   lower limb of the k_co(tau) sigmoid -- NOT the deleted exponent q), so
%   the periosteum receives disproportionately more formation.  That is why
%   loading makes bone bigger rather than denser, matching Haapasalo (V6f).
%
%   Resorption is allocated by available surface area, modulated by TNF-alpha:
%
%     xi_e ~ xi_e_0 (1 + lambda_xi T/(K_T + T))
%
%   so oestrogen withdrawal shifts resorption endocortically (V15).
%
%   *** No free parameters are introduced by the formation split. ***
%
%   Inputs
%     mech  (1,1) struct  ORGANMECHANICS output (eps_p, eps_e, eps_bar)
%     T     (1,1) double  TNF-alpha                                [-]
%     p     (1,1) struct  parameters
%   Outputs
%     eta   (1,3) double  formation split [periosteal endocortical intracortical], sums to 1
%     xi    (1,3) double  resorption split, same order, sums to 1
%
%   *** NOT IMPLEMENTED -- scheduled for phase P3 (M7) ***
%
%   Project: bone-mechanostat (PROJECT_PLAN v1.4)

error("boneMechanostat:notImplemented", ...
      "surfaceAllocation is a phase-P3 deliverable (M7) and is not implemented yet.");
end
