function [dLoc, flux, aux] = siteRHS(s, siteCtx, P_pth, E2, u_romo, p)
%SITERHS Per-site M1-M7 derivatives (one skeletal site).
%
%   [DLOC, FLUX, AUX] = SITERHS(S, SITECTX, P_PTH, E2, U_ROMO, P) computes
%   the mechanics -> signalling -> cells -> structure -> mineral cascade for
%   ONE site, given the SHARED systemic PTH.  It is the single source of
%   truth for the per-site biology: RHSFULL calls it once, RHSTWOSITE calls
%   it once per compartment.  M8 (calcium) is deliberately NOT here -- it is
%   systemic and shared, so the callers own it.
%
%   Inputs
%     s        (1,1) struct  local state: Ca_i, Y, S, T, n_ot, beta,
%                            R, B, C, r_p, r_e, f_bm, rho_min
%     siteCtx  (1,1) struct  .peakBout, .doseSurrogate, .D_eff_0
%     P_pth    (1,1) double  shared PTH, baseline 1                     [-]
%     E2       (1,1) double  oestrogen, baseline 1                      [-]
%     u_romo   (1,1) double  romosozumab on/off                        [-]
%     p        (1,1) struct  parameters
%
%   Outputs
%     dLoc  (1,1) struct  derivatives, same field names as S       [state/day]
%     flux  (1,1) struct  .vForm .vRes -- baseline-relative bone cell
%                         activity, for the caller's M8 coupling        [-]
%     aux   (1,1) struct  per-site diagnostics
%
%   See also RHSFULL, RHSTWOSITE, MAKECONTEXT.

%   Project: bone-mechanostat (PROJECT_PLAN v2.1)

arguments
    s (1,1) struct
    siteCtx (1,1) struct
    P_pth (1,1) double
    E2 (1,1) double
    u_romo (1,1) double
    p (1,1) struct
end

% --- M1/M2/M3: mechanics -> the single fast/slow scalar -----------------
st = struct(r_p = s.r_p, r_e = s.r_e, f_bm = s.f_bm, ...
            rho_min = s.rho_min, n_ot = s.n_ot);
mech = organMechanics(siteCtx.peakBout, st, p);

tau_max = shearSurrogate(mech.eps_p, siteCtx.peakBout.freqHz, p);
D_eff   = loadingDose(tau_max, siteCtx.doseSurrogate, s.n_ot, p);
D_hat   = D_eff / siteCtx.D_eff_0;

% --- M4/M5: osteocyte signalling ----------------------------------------
sig = struct(Ca_i = s.Ca_i, Y = s.Y, S = s.S, T = s.T, beta = s.beta);
[dSig, alg] = osteocyteSignal(sig, D_hat, P_pth, E2, u_romo, p);
alg.beta = s.beta;

dT = estrogenTNF(s.T, E2, p);

% --- M6: cell populations ------------------------------------------------
dCell = boneCellPopulation(s.R, s.B, s.C, alg, p);

% --- M7: structure + mineral --------------------------------------------
vForm = s.B;
vRes  = s.C;

doseFcn = @(e) siteCtx.doseSurrogate.F( ...
              shearSurrogate(e, siteCtx.peakBout.freqHz, p));
[eta, xi] = surfaceAllocation(mech, s.T, doseFcn, p);

dStruct = boneStructure(st, eta, xi, p.k_form * vForm, p.k_res * vRes, p, mech);
dMin    = mineralization(s.rho_min, vForm, vRes, p);
dn_ot   = osteocyteDensity(s.n_ot, vForm, vRes, E2, p);

% --- pack ----------------------------------------------------------------
dLoc = struct( ...
    Ca_i = dSig.Ca_i, Y = dSig.Y, S = dSig.S, T = dT, n_ot = dn_ot, ...
    beta = dSig.beta, R = dCell.R, B = dCell.B, C = dCell.C, ...
    r_p = dStruct.r_p, r_e = dStruct.r_e, f_bm = dStruct.f_bm, ...
    rho_min = dMin.rho_min);

flux = struct(vForm = vForm, vRes = vRes);

if nargout > 2
    aux = struct(eps_p = mech.eps_p, eps_e = mech.eps_e, ...
                 tau_max = tau_max, D_eff = D_eff, D_eff_hat = D_hat, ...
                 eta = eta, xi = xi, rho_min = s.rho_min, geom = mech.geom, ...
                 L_RANKL = alg.L_RANKL, O_OPG = alg.O_OPG, pi_L = alg.pi_L);
end
end
