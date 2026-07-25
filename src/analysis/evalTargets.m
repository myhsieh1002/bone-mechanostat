function r = evalTargets(p, opts)
%EVALTARGETS Evaluate the model against the calibration validation targets.
%
%   R = EVALTARGETS(P) runs the scenarios needed for the non-hold-out
%   targets and returns a struct of computed values plus per-target
%   pass/fail against data/validation_targets.csv.
%
%   R = EVALTARGETS(P, holdout=true) ALSO evaluates the hold-out targets
%   (V6 tennis via two-site is skipped until rhsTwoSite exists; V10
%   post-withdrawal; V14 emergent epsilon*).  Hold-out values are for
%   BLIND assessment AFTER calibration and must never enter the objective.
%
%   Targets evaluated:
%     V1  adult turnover            5-10 %/yr        (sedentary steady state)
%     V2  disuse bone loss          1.0-1.5 %/month  (bedrest)
%     V7  calcium BMD effect        +0.7-1.8 %       (highCa vs lowCa)
%     V7-plateau  non-progressive   slope -> 0       (lowCa 30mo slope)
%     V8  romosozumab @12mo         +11-14 %         (romosozumab)
%   Hold-out (opts.holdout):
%     V10 post-withdrawal loss      < 0 within 12mo  (romosozumab washout)
%     V14 emergent epsilon*         100-1500 ue      (baseline peak strain)
%
%   Inputs
%     p            (1,1) struct  parameters
%     opts.holdout (1,1) logical evaluate hold-out targets too.  Default false
%     opts.years   (1,1) double  calcium/turnover horizon.  Default 2.5
%
%   Output
%     r  (1,1) struct  computed values (.V1 .V2 .V7 .V7slope .V8 ...),
%                      .pass (struct of logicals), .resid (normalised)
%
%   See also CALIBRATE, SIMULATE.

%   Project: bone-mechanostat (PROJECT_PLAN v1.9)

arguments
    p (1,1) struct
    opts.holdout (1,1) logical = false
    opts.years (1,1) double = 2.5
end

r = struct();

% --- V1: adult turnover, sedentary steady state -------------------------
% Turnover = annual gross resorbed bone fraction. At baseline B=C=1, the
% intracortical resorption flux is (S_v/w) k_res xi_i; annualise vs f_bm.
[~, S_v_hat] = specificSurface(p.f_bm_0, p);
grossRes = (S_v_hat / p.w_wall) * (p.k_res * 1) * p.xi_i_0;   % [1/day] of f_bm
r.V1 = 100 * 365 * grossRes / p.f_bm_0;                       % %/yr

% --- V2: disuse loss, bedrest -------------------------------------------
oB = simulate(scenarioLibrary("bedrest", durationDays = 180), p = p);
r.V2 = -100 * (oB.dens.BMC_L(end) / oB.dens.BMC_L(1) - 1) / 6;  % %/month loss

% --- V7: calcium effect + plateau ---------------------------------------
d = round(opts.years * 365);
oL = simulate(scenarioLibrary("lowCalcium",  durationDays = d), p = p);
oH = simulate(scenarioLibrary("highCalcium", durationDays = d), p = p);
r.V7 = 100 * (oH.dens.aBMD(end)/oH.dens.aBMD(1) ...
            - oL.dens.aBMD(end)/oL.dens.aBMD(1));   % highCa - lowCa, %

% plateau: |slope| over last 6 months of the low-calcium run
tL = oL.t / 365;
[~, k1] = min(abs(tL - (opts.years - 0.5)));
aL = 100 * (oL.dens.aBMD / oL.dens.aBMD(1) - 1);
r.V7slope = (aL(end) - aL(k1)) / 0.5;               % %/yr, want ~0

% --- V8: romosozumab @ 12 months ----------------------------------------
oR = simulate(scenarioLibrary("romosozumab", durationDays = 365), p = p);
r.V8 = 100 * (oR.dens.aBMD(end) / oR.dens.aBMD(1) - 1);

% --- pass/fail ----------------------------------------------------------
r.pass = struct( ...
    V1 = r.V1 >= 5 && r.V1 <= 10, ...
    V2 = r.V2 >= 0.5 && r.V2 <= 2.0, ...
    V7 = r.V7 >= 0.7 && r.V7 <= 1.8, ...
    V7slope = abs(r.V7slope) < 0.3, ...
    V8 = r.V8 >= 11 && r.V8 <= 14);

% --- normalised residuals for the objective -----------------------------
r.resid = struct( ...
    V1 = localBandResid(r.V1, 5, 10), ...
    V2 = localBandResid(r.V2, 1.0, 1.5), ...
    V7 = localBandResid(r.V7, 0.7, 1.8), ...
    V7slope = max(0, abs(r.V7slope) - 0.3) / 0.3, ...
    V8 = localBandResid(r.V8, 11, 14));

% --- smooth chi-square-like metric, for PROFILE LIKELIHOOD ---------------
% Standardised squared deviation from each band MIDPOINT.  Unlike the
% banded residual (flat inside the band), this is smooth with a clear
% minimum, so identifiability.m can trace a real profile.  half = half the
% band width serves as the "1 sigma" scale.
r.chi2 = localMidChi2(r.V1, 5, 10) ...
       + localMidChi2(r.V2, 1.0, 1.5) ...
       + localMidChi2(r.V7, 0.7, 1.8) ...
       + (r.V7slope / 0.3)^2 ...
       + localMidChi2(r.V8, 11, 14);

if opts.holdout
    % V10: continue romosozumab run through 12 months washout.
    sW = scenarioLibrary("romosozumab", durationDays = 730);
    oW = simulate(sW, p = p);
    tW = oW.t;
    [~, kStop] = min(abs(tW - 365));
    r.V10 = 100 * (oW.dens.aBMD(end) / oW.dens.aBMD(kStop) - 1);  % want < 0

    % V14: emergent set point = baseline peak strain [microstrain].
    st = struct(r_p = p.r_p_0, r_e = p.r_e_0, ...
                f_bm = p.f_bm_0, rho_min = p.rho_min_0);
    b = scenarioLibrary("sedentary").bouts(1);
    r.V14 = organMechanics(b, st, p).eps_p * 1e6;

    r.passHoldout = struct( ...
        V10 = r.V10 < 0, ...
        V14 = r.V14 >= 100 && r.V14 <= 1500);
end
end

% -------------------------------------------------------------------------
function e = localBandResid(x, lo, hi)
%LOCALBANDRESID 0 inside [lo,hi], else normalised distance to the band.
mid = 0.5 * (lo + hi);
half = 0.5 * (hi - lo);
if x < lo
    e = (lo - x) / half;
elseif x > hi
    e = (x - hi) / half;
else
    e = 0;
end
% small pull toward the midpoint keeps the optimiser from stalling on a
% flat interior; negligible vs out-of-band penalty.
e = e + 0.01 * abs(x - mid) / max(half, eps);
end

% -------------------------------------------------------------------------
function c = localMidChi2(x, lo, hi)
%LOCALMIDCHI2 Standardised squared deviation from the band midpoint.
mid  = 0.5 * (lo + hi);
half = 0.5 * (hi - lo);
c = ((x - mid) / max(half, eps))^2;
end
