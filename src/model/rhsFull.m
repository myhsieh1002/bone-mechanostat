function [dydt, aux] = rhsFull(t, y, ctx)
%RHSFULL Right-hand side of the single-compartment model (M1-M7 live).
%
%   [DYDT, AUX] = RHSFULL(T, Y, CTX) returns the derivative of the 17-state
%   vector defined by STATEVECTOR("single").
%
%   CTX is built once by MAKECONTEXT and carries the parameters, scenario,
%   dose surrogate and baseline references, so that nothing expensive
%   happens inside the ODE right-hand side.
%
%   Signal flow, one pass, no branches:
%
%       geometry + load  -> organMechanics   -> eps_p, eps_e
%       eps_p            -> shearSurrogate   -> tau_max
%       tau_max, n_ot    -> loadingDose      -> D_eff   (the ONE scalar
%                                               crossing fast/slow)
%       D_eff            -> osteocyteSignal  -> Ca, Y, S, beta, RANKL, OPG
%                        -> boneCellPopulation -> R, B, C
%       B, C             -> boneStructure    -> r_p, r_e, f_bm
%                        -> mineralization   -> m1, m2
%
%   *** M8 IS NOT IMPLEMENTED (P4) ***
%   Ca_s, P and V_D are held at baseline.  Every M4 term that reads PTH
%   therefore sees P = 1.  Anything about calcium intake (V7, V7b, P1) is
%   meaningless until P4 lands.
%
%   Inputs
%     t    (1,1) double  time                                      [day]
%     y    (:,1) double  state, see STATEVECTOR("single")
%     ctx  (1,1) struct  from MAKECONTEXT
%
%   Outputs
%     dydt  (:,1) double  derivative                          [state/day]
%     aux   (1,1) struct  diagnostics: eps_p, eps_e, tau_max, D_eff,
%                         D_eff_hat, v_form, v_res, eta, xi, rho_min, geom
%
%   See also MAKECONTEXT, SIMULATE, STATEVECTOR.

%   Project: bone-mechanostat (PROJECT_PLAN v1.6)

arguments
    t (1,1) double
    y (:,1) double
    ctx (1,1) struct
end

p  = ctx.p;
ix = ctx.idx;

% --- unpack -------------------------------------------------------------
Ca   = y(ix.Ca_i);   Y  = y(ix.Y);    S    = y(ix.S);
T    = y(ix.T);      n_ot = y(ix.n_ot);
beta = y(ix.beta);
R    = y(ix.R);      B  = y(ix.B);    C    = y(ix.C);
r_p  = y(ix.r_p);    r_e = y(ix.r_e); f_bm = y(ix.f_bm);
m1   = y(ix.m1);     m2  = y(ix.m2);
P_pth = y(ix.P);

[~, rho_min] = mineralization(m1, m2, 1, 1, f_bm, p);

% --- M1/M2/M3: mechanics -> the single fast/slow scalar ------------------
st = struct(r_p = r_p, r_e = r_e, f_bm = f_bm, rho_min = rho_min);
mech = organMechanics(ctx.peakBout, st, p);

tau_max = shearSurrogate(mech.eps_p, ctx.peakBout.freqHz, p);
D_eff   = loadingDose(tau_max, ctx.doseSurrogate, n_ot, p);
D_hat   = D_eff / ctx.D_eff_0;

% --- M4/M5: osteocyte signalling ----------------------------------------
u_romo = localDrugOn(t, ctx.scenario.drug.romosozumab);
E2     = ctx.scenario.E2;

sig = struct(Ca_i = Ca, Y = Y, S = S, T = T, beta = beta);
[dSig, alg] = osteocyteSignal(sig, D_hat, P_pth, E2, u_romo, p);
alg.beta = beta;

dT = estrogenTNF(T, E2, p);

% --- M6: cell populations ------------------------------------------------
dCell = boneCellPopulation(R, B, C, alg, p);

% --- M7: structure and mineral ------------------------------------------
% Surface velocities, expressed relative to baseline (B = C = 1).
vForm = B;
vRes  = C;

doseFcn = @(e) ctx.doseSurrogate.F(shearSurrogate(e, ctx.peakBout.freqHz, p));
[eta, xi] = surfaceAllocation(mech, T, doseFcn, p);

dStruct = boneStructure(st, eta, xi, ...
                        p.k_form * vForm, p.k_res * vRes, p);
dMin    = mineralization(m1, m2, vForm, vRes, f_bm, p);
dn_ot   = osteocyteDensity(n_ot, vForm, vRes, E2, p);

% --- assemble ------------------------------------------------------------
dydt = zeros(numel(y), 1);
dydt(ix.Ca_i) = dSig.Ca_i;
dydt(ix.Y)    = dSig.Y;
dydt(ix.S)    = dSig.S;
dydt(ix.T)    = dT;
dydt(ix.n_ot) = dn_ot;
dydt(ix.beta) = dSig.beta;
dydt(ix.R)    = dCell.R;
dydt(ix.B)    = dCell.B;
dydt(ix.C)    = dCell.C;
dydt(ix.r_p)  = dStruct.r_p;
dydt(ix.r_e)  = dStruct.r_e;
dydt(ix.f_bm) = dStruct.f_bm;
dydt(ix.m1)   = dMin.m1;
dydt(ix.m2)   = dMin.m2;
% M8 not implemented (P4): systemic states held.
dydt(ix.Ca_s) = 0;
dydt(ix.P)    = 0;
dydt(ix.V_D)  = 0;

if nargout > 1
    aux = struct(eps_p = mech.eps_p, eps_e = mech.eps_e, ...
                 tau_max = tau_max, D_eff = D_eff, D_eff_hat = D_hat, ...
                 v_form = vForm, v_res = vRes, eta = eta, xi = xi, ...
                 rho_min = rho_min, geom = mech.geom, ...
                 L_RANKL = alg.L_RANKL, O_OPG = alg.O_OPG, pi_L = alg.pi_L);
end
end

% -------------------------------------------------------------------------
function u = localDrugOn(t, win)
%LOCALDRUGON 1 while t is inside [startDay, stopDay), else 0.
u = 0;
if ~isnan(win.startDay) && t >= win.startDay
    if isnan(win.stopDay) || t < win.stopDay
        u = 1;
    end
end
end
