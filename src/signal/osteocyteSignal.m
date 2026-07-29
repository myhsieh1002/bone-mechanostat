function [d, alg] = osteocyteSignal(s, D_eff_hat, P_pth, E2, n_ot, u_romo, A_reb, p)
%OSTEOCYTESIGNAL M4-M5 -- Piezo1/Ca -> YAP/TAZ -> SOST -> Wnt, plus RANKL/OPG.
%
%   [D, ALG] = OSTEOCYTESIGNAL(S, D_EFF_HAT, P_PTH, E2, N_OT, U_ROMO, A_REB, P)
%   returns the signalling derivatives and the algebraic outputs consumed by M6.
%
%   Written in BASELINE-RELATIVE form: every variable is 1 at the reference
%   state, and each equation carries a single rate constant.  The shape
%   functions (Hill terms) are exactly those in PROJECT_PLAN 4.2; only the
%   normalisation differs.  This makes the reference state a fixed point by
%   construction, which matters because most M4/M5 constants are still
%   placeholders -- without it, E0 would diverge on day one for reasons
%   that have nothing to do with the biology.
%
%       dCa/dt   = k_C   [ (1 - J_alt) D_eff_hat + J_alt - Ca ]
%       dY/dt    = k_Y   [ h_Y(Ca)/h_Y(1) - Y ]
%       dS/dt    = k_S   [ Sset(Y, P, T) - S ]
%       dbeta/dt = k_b   [ W(S)/W(1) - beta ]
%
%   with
%       h_Y(Ca) = Ca^n / (K_Y^n + Ca^n)
%       Sset    = [f_mech(Y) f_pth(P) f_tnf(T)] / [same at baseline]
%       W(S)    = K_W^m / (K_W^m + S^m)
%
%   Romosozumab acts as an extra clearance term on S, so U_ROMO shortens
%   the sclerostin time constant rather than shifting its set point.
%
%   *** THE MECHANICAL SIGNAL ENTERS HERE AND ONLY HERE ***
%   D_EFF_HAT is the daily mean open probability relative to baseline --
%   the single scalar crossing the fast/slow boundary (LOADINGDOSE).  The
%   P_o(tau) sigmoid that v1.3 had in this module was deleted in v1.4; it
%   duplicated MSICGATING.
%
%   Sclerostin's dual action -- blocking Wnt AND raising RANKL through
%   lambda_S -- is innovation N2 and the mechanism behind V13.
%
%   *** THE APOPTOTIC ARM, AND WHY IT BYPASSES SCLEROSTIN (P5n', C32) ***
%   Dying osteocytes release RANKL directly, and that targeted resorption is
%   the one disuse route that does NOT pass through S.  It has to bypass S,
%   because the mechanical arm of sclerostin is already saturated: fMech
%   runs 0.6216 -> 0.9997 of its absolute ceiling of 1 over 180 days of
%   bed rest (appendix C31.4), so nothing routed through sensing can supply
%   further loss.  LAMBDA_APOP therefore multiplies RANKL by the osteocyte
%   DEFICIT, 1 - n_ot/n_ot_0, which is identically zero at baseline.
%
%   Inputs
%     s          (1,1) struct  fields Ca_i, Y, S, T, beta               [-]
%     D_eff_hat  (1,1) double  daily dose / baseline dose              [-]
%     P_pth      (1,1) double  PTH, baseline 1                          [-]
%     E2         (1,1) double  oestrogen, baseline 1                    [-]
%     n_ot       (1,1) double  osteocyte density, baseline n_ot_0        [-]
%     u_romo     (1,1) double  romosozumab on/off                       [-]
%     A_reb      (1,1) double  compensatory SOST up-regulation built up
%                              under sustained antibody exposure; 0 in any
%                              drug-free run (P5h, appendix C21)         [-]
%     p          (1,1) struct  parameters
%
%   Outputs
%     d    (1,1) struct  .Ca_i .Y .S .beta derivatives            [1/day]
%     alg  (1,1) struct  .L_RANKL .O_OPG .W_eff .pi_L             [-]
%
%   See also LOADINGDOSE, ESTROGENTNF, BONECELLPOPULATION.

%   Project: bone-mechanostat (PROJECT_PLAN v1.6)

arguments
    s (1,1) struct
    D_eff_hat (1,1) double {mustBeNonnegative}
    P_pth (1,1) double {mustBeNonnegative}
    E2 (1,1) double {mustBeNonnegative}
    n_ot (1,1) double {mustBeNonnegative}
    u_romo (1,1) double {mustBeNonnegative}
    A_reb (1,1) double {mustBeNonnegative}
    p (1,1) struct
end

Ca = s.Ca_i;  Y = s.Y;  S = s.S;  T = s.T;  b = s.beta;

% --- M4: Ca2+ influx -----------------------------------------------------
% J_alt is the baseline FRACTION carried by integrin / primary cilium /
% Cx43, i.e. the part that survives complete unloading.
fAlt = min(max(p.J_alt, 0), 1);
d.Ca_i = p.k_C * ((1 - fAlt) * D_eff_hat + fAlt - Ca);

% --- M4: YAP/TAZ nuclear fraction ---------------------------------------
hY   = @(c) c^p.n_Y / (p.K_Y^p.n_Y + c^p.n_Y);
d.Y  = p.k_Y * (hY(Ca) / hY(1) - Y);

% --- M4: sclerostin ------------------------------------------------------
fMech = @(y) 1 / (1 + (y / p.K_S)^p.h_S);
fPth  = @(x) 1 / (1 + x / p.K_P_sost);
fTnf  = @(t) 1 + p.lambda_T * t / (p.K_T + t);

Sset = (fMech(Y) * fPth(P_pth) * fTnf(T)) / ...
       (fMech(1) * fPth(1)     * fTnf(1));

% Romosozumab adds CLEARANCE, so the sclerostin set point falls to
% delta_S*Sset*(1+A_reb)/clr and its time constant shortens.
%
% *** WITHDRAWAL REBOUND (v2.10, P5h, appendix C21) ***
% Sustained antibody exposure also up-regulates SOST TRANSCRIPTION -- the
% osteocyte compensates for the loss of sclerostin signalling.  A_REB
% carries that compensation, and it decays on its own slow clock rather
% than with the antibody.  So on withdrawal the clearance term vanishes
% while the raised production does not, and free sclerostin overshoots
% baseline before settling back.  That overshoot is what drives the
% clinically observed post-withdrawal resorption surge.
%
% A_reb is 0 in any run that never sees the drug, so this term cannot
% perturb a single drug-free target.
clr  = p.delta_S + p.delta_ab * u_romo;
d.S  = p.delta_S * Sset * (1 + A_reb) - clr * S;

% --- M5: Wnt / beta-catenin ---------------------------------------------
W    = @(x) p.K_W^p.m_W / (p.K_W^p.m_W + x^p.m_W);
Weff = W(S) / W(1);
d.beta = p.k_beta * (Weff - b);

% --- algebraic outputs for M6 -------------------------------------------
gS = @(x) 1 + p.lambda_S * x / (p.K_L + x);
gP = @(x) 1 + p.lambda_P * x / (p.K_PL + x);
gE = @(x) 1 - p.lambda_E * x;
gB = @(x) 1 + p.lambda_beta * x / (p.K_beta + x);

% Apoptotic osteocytes release RANKL directly (P5n', appendix C32).  Written
% on the DEFICIT so that gA(n_ot_0) = 1 exactly: the term is silent at
% baseline and in every scenario that does not lose osteocytes, which is what
% keeps V1/V7/V8/V14 untouched -- the same construction as delta_ab and A_reb.
% max(0, .) means osteocyte GAIN does not suppress RANKL; there is no
% literature for a protective arm and inventing one would be a free fit.
gA = @(n) 1 + p.lambda_apop * max(0, 1 - n / p.n_ot_0);

alg.L_RANKL = (gS(S) * gP(P_pth) * gE(E2) * gA(n_ot)) / ...
              (gS(1) * gP(1) * gE(p.E2_0) * gA(p.n_ot_0));
alg.O_OPG   = gB(b) / gB(1);
alg.W_eff   = Weff;

% pi_L, normalised to 1 at baseline (L = O = 1).
piL = @(L, O) L / (p.K_L3 + L + p.kappa_OPG * O);
alg.pi_L = piL(alg.L_RANKL, alg.O_OPG) / piL(1, 1);
end
