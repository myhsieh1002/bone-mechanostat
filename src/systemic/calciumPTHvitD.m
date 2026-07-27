function [d, alg] = calciumPTHvitD(Ca_s, P, V_D, I_Ca, vForm, vRes, p)
%CALCIUMPTHVITD M8 -- systemic calcium / PTH / 1,25(OH)2D homeostasis.
%
%   [D, ALG] = CALCIUMPTHVITD(CA_S, P, V_D, I_CA, VFORM, VRES, P) returns
%   the systemic derivatives and absorption / renal diagnostics.  Every
%   flux below is a real calcium flux in mg/day, not a normalised ratio.
%
%       Abs      = a_p I_Ca                            (paracellular)
%                + A_act [I_Ca/(K_I + I_Ca)] [V_D/(K_VD + V_D)]  (active)
%       Ca_th    = renal_Ca_th [1 + lambda_P (P - 1)]
%       Renal    = renal_k max(Ca_s - Ca_th, 0)
%       Bone     = phi_res vRes - phi_form vForm
%       dCa_s/dt = (kappa_Ca / renal_k) [ Abs + Bone - Renal ]
%       dP/dt    = delta_P  [ Pset(Ca_s) - P ]
%       dV_D/dt  = delta_VD [ VDset(P)   - V_D ]
%
%   *** THIS MODULE ANSWERS THE ORIGINAL QUESTION ***
%   Calcium intake reaches bone only along the physiological route: intake
%   -> serum Ca -> PTH -> resorption / sclerostin, with nothing added on
%   the formation side.  V7 (a small, non-progressive BMD response to
%   calcium) should EMERGE, not be fitted.
%
%   *** P5k (v2.14) REBUILT BOTH HALVES OF THIS MODULE ***
%   The v1.8 form was audited in appendices C24 and C26 and failed in two
%   opposite directions at once.
%
%   (1) FORWARD, it was too loose.  Serum calcium swung 15 % across 400 to
%   1500 mg/day of intake, where physiology holds about 2 %.  Two causes:
%   the paracellular term was linear and unsaturating while the active
%   term had been written as a FRACTION rather than a flux and so
%   contributed 0.08 % of absorption -- meaning the calcitriol-gated,
%   PTH-regulated arm, which is what actually buffers dietary calcium, was
%   effectively absent; and renal excretion was a bare power law
%   (Ca_s/Ca_s_0)^n_renal rather than the saturable tubular reabsorption
%   that renal_k and renal_Ca_th were declared for and never used in.
%
%   (2) BACKWARD, it was far too weak.  phi_res and phi_form were 0.10
%   while the flux imbalance was normalised by a baseline absorption over
%   a thousand times larger, so bone could not move serum calcium at all:
%   180 days of unloading moved PTH by 0.01 % where bed-rest subjects show
%   17-24 % suppression (Spatz 2012, PMID 22767636).  The note justifying
%   0.10 reasoned from the ratio of the skeletal calcium POOL to daily
%   turnover; the quantity that belongs here is the ratio of skeletal
%   calcium FLUX to daily flux, and those are the same order.
%
%   The rebuilt module fixes both: absorption has a saturating,
%   calcitriol-gated active arm that carries most of the baseline flux and
%   supplies the negative feedback that buffers intake; excretion is the
%   classic threshold form, steep because the renal threshold sits just
%   below normal serum calcium so excretion is a small difference of two
%   large numbers; and bone exchanges calcium at a real skeletal flux.
%
%   *** RENAL GAIN IS DERIVED, NOT FITTED ***
%   renal_k follows from closing the baseline balance,
%
%       renal_k = (Abs_0 + phi_res - phi_form) / (Ca_s_0 - renal_Ca_th),
%
%   so the one free physiological choice is where the threshold sits.
%   Putting it about 2 % below Ca_s_0 is what makes excretion steep, and
%   it is the same statement as "98 % of filtered calcium is reabsorbed".
%
%   *** BASELINE-RELATIVE, like M4-M6 (appendix C7.3) ***
%   P and V_D are 1 at baseline; Ca_s keeps mmol/L.  Set-point maps are
%   normalised so (Ca_s_0, 1, 1) is a fixed point.
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
%     alg  (1,1) struct  .Abs .Renal .Bone .Pset .VDset .renal_k .Ca_th
%
%   See also OSTEOCYTESIGNAL, RHSFULL.

%   Project: bone-mechanostat (PROJECT_PLAN v2.14, appendix C27)

arguments
    Ca_s (1,1) double
    P (1,1) double
    V_D (1,1) double
    I_Ca (1,1) double {mustBeNonnegative}
    vForm (1,1) double
    vRes (1,1) double
    p (1,1) struct
end

% --- intestinal absorption [mg/day] --------------------------------------
% Paracellular: a fixed fraction of intake, unsaturating and unregulated.
% Transcellular: saturable in intake and gated by calcitriol.  a_a_abs is
% the maximum active flux expressed as a fraction of BASELINE intake, so
% it stays a dimensionless parameter while the flux it produces is mg/day.
A_act  = p.a_a_abs * p.I_Ca_0;
absFcn = @(ica, vd) p.a_p_abs * ica ...
    + A_act * (ica / (p.K_I_abs + ica)) * (vd / (p.K_VD + vd));
Abs   = absFcn(I_Ca, V_D);
Abs_0 = absFcn(p.I_Ca_0, p.V_D_0);

% --- skeletal exchange [mg/day] ------------------------------------------
% vForm and vRes are baseline-relative, so this vanishes at baseline and
% carries the true skeletal flux under perturbation.
Bone = p.phi_res * vRes - p.phi_form * vForm;

% --- PTH set point: falls as serum calcium rises (steep) -----------------
gP    = @(ca) 1 / (1 + (ca / p.Ca_50)^p.n_P);
Pset  = gP(Ca_s) / gP(p.Ca_s_0);

% --- 1,25D set point: rises with PTH -------------------------------------
hV    = @(x) x / (p.K_VP + x);
VDset = hV(P) / hV(1);

% --- renal clearance: saturable tubular reabsorption ---------------------
% Excretion is what the tubule fails to reclaim, so it is the excess of
% serum calcium over a threshold, and PTH raises that threshold.  The gain
% closes the baseline balance, which puts the whole steepness of the
% defence in one physiological quantity: how far the threshold sits below
% normal serum calcium.
% The PTH shift is scaled by the SAME gap, not by Ca_th itself: the gap is
% only ~2 % of Ca_th, so shifting the threshold by a percentage of its own
% value would swamp the whole defence with a few percent of PTH movement.
gap     = p.Ca_s_0 - p.renal_Ca_th;
renal_k = (Abs_0 + p.phi_res - p.phi_form) / gap;
Ca_th   = p.renal_Ca_th + p.renal_lambda_P * gap * (P - 1);
Renal   = renal_k * max(Ca_s - Ca_th, 0);

% --- derivatives ---------------------------------------------------------
% Dividing by renal_k turns the flux imbalance into mmol/L directly, so
% kappa_Ca keeps clean units [1/day] and is the relaxation rate of the
% serum pool -- fast (hours) relative to remodelling (days to months).
d.Ca_s = p.kappa_Ca * (Abs + Bone - Renal) / renal_k;
d.P    = p.delta_P  * (Pset  - P);
d.V_D  = p.delta_VD * (VDset - V_D);

alg = struct(Abs = Abs, Renal = Renal, Bone = Bone, Pset = Pset, ...
             VDset = VDset, Abs_0 = Abs_0, renal_k = renal_k, Ca_th = Ca_th);
end
