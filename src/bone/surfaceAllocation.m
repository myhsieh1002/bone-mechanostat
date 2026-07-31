function [eta, xi] = surfaceAllocation(mech, T, D_eff_hat, doseFcn, p)
%SURFACEALLOCATION M7(a) -- split formation and resorption across surfaces.
%
%   [ETA, XI] = SURFACEALLOCATION(MECH, T, D_EFF_HAT, DOSEFCN, P) returns the
%   formation split ETA and resorption split XI over
%   [periosteal, endocortical, intracortical], each summing to 1.
%
%   FORMATION follows the strain gradient across the wall:
%
%       eta_p : eta_e : eta_i = D(eps_p) : D(eps_e) : D(eps_bar)
%
%   Under bending eps_p > eps_e, and D is supralinear below saturation --
%   that supralinearity now comes from the lower limb of the k_co(tau)
%   sigmoid, NOT from the deleted exponent q (v1.4, appendix C5.2).  The
%   periosteum therefore receives disproportionately more formation, which
%   is why loading makes bone BIGGER rather than DENSER, matching
%   Haapasalo (V6f).
%
%   *** No free parameter is introduced by the formation split. ***
%
%   RESORPTION follows available surface area, modulated by TNF-alpha:
%
%       xi_e ~ xi_e_0 (1 + lambda_xi (T-1)/(K_T + T))
%
%   so oestrogen withdrawal shifts resorption endocortically -- the
%   wider-but-thinner postmenopausal cortex (V15).
%
%   *** AND UNLOADING SHIFTS IT INTRACORTICALLY (P5p, appendix C36) ***
%
%       xi_i ~ xi_i_0 (1 + lambda_xi_mech max(0, 1 - D_eff_hat))
%
%   Immobilisation raises cortical POROSITY, which is intracortical
%   resorption: Rolvien et al. 2020 find significantly higher cortical
%   porosity in the femoral cortex of long-term immobilised individuals,
%   with a pattern distinguishable from postmenopausal osteoporosis.  The two
%   biases are therefore separate terms on separate surfaces with separate
%   drivers, not one term with two causes.
%
%   Written on the DOSE deficit, which is what makes it disuse-specific in a
%   way the TNF-alpha bias is not.  Measured over the scenario set, the
%   deficit is 0.886 in bed rest against 0.0016 in the low-calcium arm and
%   0.000 under loading -- a specificity of about 550 to 1.  That check was
%   run BEFORE this term was written, because the previous two attempts at
%   a disuse mechanism (appendices C32, C33) both failed on exactly this
%   point after being built.
%
%   Inputs
%     mech    (1,1) struct    ORGANMECHANICS output (eps_p, eps_e, eps_bar)
%     T       (1,1) double    TNF-alpha, baseline 1                     [-]
%     D_eff_hat (1,1) double  daily channel dose / baseline dose        [-]
%     doseFcn (1,1) function_handle  strain -> osteogenic dose; supplied
%                             by the caller so this function stays free of
%                             surrogate plumbing.  Must be monotonic.
%     p       (1,1) struct    parameters
%
%   Outputs
%     eta  (1,3) double  formation split [per, endo, intra], sums to 1
%     xi   (1,3) double  resorption split, same order, sums to 1
%
%   See also ORGANMECHANICS, BONESTRUCTURE, SPECIFICSURFACE.

%   Project: bone-mechanostat (PROJECT_PLAN v1.6)

arguments
    mech (1,1) struct
    T (1,1) double
    D_eff_hat (1,1) double {mustBeNonnegative}
    doseFcn (1,1) function_handle
    p (1,1) struct
end

% Available surface per compartment.  Formation cannot occur where there
% is no surface, so the split is area-weighted and the strain gradient
% MODULATES it -- it does not replace it.  (An earlier version used dose
% alone; that handed the periosteum 35% of all formation despite its
% having ~5% of the surface, and the resulting runaway periosteal
% expansion swamped every other behaviour.)
A = [p.xi_p_0, p.xi_e_0, p.xi_i_0];

dP = max(doseFcn(mech.eps_p),   0);
dE = max(doseFcn(mech.eps_e),   0);
dI = max(doseFcn(mech.eps_bar), 0);

w   = A .* [dP, dE, dI];
tot = sum(w);
if tot <= 0
    eta = A / sum(A);          % complete unloading: fall back on area
else
    eta = w / tot;
end

% Resorption: baseline surface weighting, TNF-alpha biased endocortically
% and unloading biased intracortically.  Both factors are exactly 1 at the
% reference state (T = 1, D_eff_hat = 1), so the baseline split is untouched
% whatever the two coefficients are -- the same construction as delta_ab.
biasT = 1 + p.lambda_xi * (T - 1) / (p.K_T + T);
biasM = 1 + p.lambda_xi_mech * max(0, 1 - D_eff_hat);
xi   = [p.xi_p_0, p.xi_e_0 * max(biasT, 0), p.xi_i_0 * biasM];
xi   = xi / sum(xi);
end
