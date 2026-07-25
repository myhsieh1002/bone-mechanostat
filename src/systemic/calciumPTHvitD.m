function [d, alg] = calciumPTHvitD(Ca_s, P, V_D, I_Ca, vForm, vRes, p)
%CALCIUMPTHVITD M8 -- systemic calcium / PTH / 1,25(OH)2D homeostasis.
%
%   [D, ALG] = CALCIUMPTHVITD(CA_S, P, V_D, I_CA, VFORM, VRES, P) returns
%   the systemic derivatives and absorption / renal diagnostics.
%
%       Abs      = a_p I_Ca + [a_a I_Ca/(K_I + I_Ca)] [V_D/(K_VD + V_D)]
%       Renal    = Renal_0 (Ca_s/Ca_s_0)^n_renal [1 - lambda_P(P - 1)]
%       dCa_s/dt = kappa_Ca [ Abs + phi_res vRes - phi_form vForm - Renal ]
%       dP/dt    = delta_P  [ Pset(Ca_s) - P ]
%       dV_D/dt  = delta_VD [ VDset(P)   - V_D ]
%
%   *** THIS MODULE ANSWERS THE ORIGINAL QUESTION ***
%   Calcium intake reaches bone only along the physiological route: intake
%   -> serum Ca -> PTH -> resorption / sclerostin, with nothing added on
%   the formation side.  V7 (a small, non-progressive BMD response to
%   calcium) should EMERGE, not be fitted.
%
%   *** SERUM CALCIUM IS TIGHTLY HOMEOSTATIC (the fix in v1.8) ***
%   Physiologically serum Ca varies by <2% across wide intake ranges.  The
%   first draft let it drift 55% and BMD ran away with no plateau.  Two
%   things enforce homeostasis here:
%     - Renal excretion is STEEP in serum Ca (n_renal ~ 8): the filtered
%       load rises with Ca_s and tubular reabsorption saturates, so a
%       few-percent rise in Ca_s clears a large calcium excess.
%     - The parathyroid Hill is steep (n_P ~ 4): small Ca_s changes move
%       PTH a lot, and PTH defends Ca_s through renal reabsorption.
%   kappa_Ca makes the serum pool fast relative to remodelling, so it sits
%   at quasi-steady-state and the bone sees an almost-constant Ca_s -- the
%   permissive-not-instructive picture.
%
%   *** BASELINE-RELATIVE, like M4-M6 (appendix C7.3) ***
%   P and V_D are 1 at baseline; Ca_s keeps mmol/L.  Set-point maps are
%   normalised so (Ca_s_0, 1, 1) is a fixed point, and Renal_0 is derived
%   to close the calcium balance there.
%
%   Inputs
%     Ca_s   (1,1) double  serum ionised calcium                 [mmol/L]
%     P      (1,1) double  PTH, baseline 1                            [-]
%     V_D    (1,1) double  1,25(OH)2D, baseline 1                     [-]
%     I_Ca   (1,1) double  calcium intake                        [mg/day]
%     vForm  (1,1) double  formation velocity / baseline (B)          [-]
%     vRes   (1,1) double  resorption velocity / baseline (C)         [-]
%     p      (1,1) struct  parameters
%
%   Outputs
%     d    (1,1) struct  .Ca_s [mmol/L/day] .P .V_D [1/day]
%     alg  (1,1) struct  .Abs .Renal .Pset .VDset
%
%   See also OSTEOCYTESIGNAL, RHSFULL.

%   Project: bone-mechanostat (PROJECT_PLAN v1.8)

arguments
    Ca_s (1,1) double
    P (1,1) double
    V_D (1,1) double
    I_Ca (1,1) double {mustBeNonnegative}
    vForm (1,1) double
    vRes (1,1) double
    p (1,1) struct
end

% --- intestinal absorption ----------------------------------------------
absFcn = @(ica, vd) p.a_p_abs * ica ...
    + (p.a_a_abs * ica / (p.K_I_abs + ica)) * (vd / (p.K_VD + vd));
Abs   = absFcn(I_Ca, V_D);
Abs_0 = absFcn(p.I_Ca_0, p.V_D_0);

% --- PTH set point: falls as serum calcium rises (steep) -----------------
gP    = @(ca) 1 / (1 + (ca / p.Ca_50)^p.n_P);
Pset  = gP(Ca_s) / gP(p.Ca_s_0);

% --- 1,25D set point: rises with PTH -------------------------------------
hV    = @(x) x / (p.K_VP + x);
VDset = hV(P) / hV(1);

% --- renal clearance, steep in Ca_s, derived to balance at baseline ------
% Baseline (vForm = vRes = 1, P = 1, Ca_s = Ca_s_0):
%   Abs_0 + phi_res - phi_form - Renal_0 = 0.
Renal_0 = Abs_0 + p.phi_res - p.phi_form;
reabs   = max(1 - p.renal_lambda_P * (P - 1), 0);
Renal   = Renal_0 * (Ca_s / p.Ca_s_0)^p.n_renal * reabs;

% --- derivatives ---------------------------------------------------------
% Normalise the flux imbalance by the baseline flux so kappa_Ca has clean
% units [1/day] and the near-equilibrium relaxation rate is kappa_Ca *
% n_renal (~ hours), not the ~40000/day the raw fluxes would give.
imbalance = (Abs + p.phi_res * vRes - p.phi_form * vForm - Renal) / Abs_0;
d.Ca_s = p.kappa_Ca * p.Ca_s_0 * imbalance;
d.P    = p.delta_P  * (Pset  - P);
d.V_D  = p.delta_VD * (VDset - V_D);

alg = struct(Abs = Abs, Renal = Renal, Pset = Pset, VDset = VDset, ...
             Abs_0 = Abs_0, Renal_0 = Renal_0);
end
