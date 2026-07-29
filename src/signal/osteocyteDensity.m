function dn_ot = osteocyteDensity(n_ot, v_form, v_res, E2, D_eff_hat, p)
%OSTEOCYTEDENSITY M4(a) -- osteocyte density.  P3 positive feedback #1.
%
%   DN_OT = OSTEOCYTEDENSITY(N_OT, V_FORM, V_RES, E2, D_EFF_HAT, P) evaluates
%
%       dn_ot/dt = k_ot v_form_hat (n_ot_max - n_ot)
%                  - [gamma_eff v_res_hat + delta_ot(E2, D_eff_hat)] n_ot
%
%   where V_FORM and V_RES are surface velocities NORMALISED to baseline,
%   so the expression stays dimensionally clean in [1/day] regardless of
%   the placeholder k_form / k_res.
%
%   Osteocytes are buried by formation and removed by resorption;
%   oestrogen withdrawal accelerates their apoptosis, and so does UNLOADING
%   (LAMBDA_OT_MECH, added at v2.23 for P5n''; before that the apoptosis
%   term saw oestrogen only, so n_ot fell in disuse purely because
%   resorption carried osteocytes away -- appendix C31.1).  With the sensing
%   exponent zeta in LOADINGDOSE this closes the loop
%
%       bone loss -> fewer sensors -> weaker signal -> more loss
%
%   which is what makes bistability (P3) possible.  A purely mechanical
%   closed loop is negative feedback and is monostable.
%
%   *** gamma_eff is derived, not read from the CSV, so that n_ot = n_ot_0
%   is a fixed point at baseline. ***  Otherwise the placeholder rates
%   would drag n_ot off 1 on day one and every downstream signal with it.
%
%   Inputs
%     n_ot   (1,1) double  osteocyte density, baseline n_ot_0          [-]
%     v_form (1,1) double  formation velocity / baseline               [-]
%     v_res  (1,1) double  resorption velocity / baseline              [-]
%     E2     (1,1) double  oestrogen                                   [-]
%     D_eff_hat (1,1) double  daily channel dose / baseline dose        [-]
%     p      (1,1) struct  parameters
%
%   Output
%     dn_ot  (1,1) double  derivative                             [1/day]
%
%   See also LOADINGDOSE, ESTROGENTNF.

%   Project: bone-mechanostat (PROJECT_PLAN v1.6)

arguments
    n_ot (1,1) double {mustBeNonnegative}
    v_form (1,1) double
    v_res (1,1) double
    E2 (1,1) double {mustBeNonnegative}
    D_eff_hat (1,1) double {mustBeNonnegative}
    p (1,1) struct
end

% Oestrogen-sensitive apoptosis: rises as E2 falls below baseline.
%
% Unloading induction (P5n''): the mechanical factor is 1 at baseline
% (D_eff_hat = 1) and rises towards 1 + lambda_ot_mech as the channel dose
% goes to zero, so it perturbs no baseline and no scenario that is not
% MECHANICALLY unloaded.  That specificity is the whole point: gA in
% OSTEOCYTESIGNAL is driven by the osteocyte deficit, and without this term
% the only thing that produces a deficit is resorption itself -- which makes
% gA a resorption amplifier in every scenario rather than a disuse term.
apop = p.delta_ot_0 * (p.E2_0 / max(E2, 1e-6)) ...
       * (1 + p.lambda_ot_mech * max(0, 1 - D_eff_hat));

% Baseline balance k_ot (n_max - n_0) = (gamma_eff + delta_ot_0) n_0
% pins gamma_eff, making n_ot_0 a fixed point by construction.
lossBase = p.k_ot * (p.n_ot_max - p.n_ot_0) / p.n_ot_0;   % [1/day]
gammaEff = max(lossBase - p.delta_ot_0, 0);

dn_ot = p.k_ot * v_form * (p.n_ot_max - n_ot) ...
        - (gammaEff * v_res + apop) * n_ot;
end
