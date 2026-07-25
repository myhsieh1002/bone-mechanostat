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
%       B, C, I_Ca       -> calciumPTHvitD   -> Ca_s, P, V_D
%                            \--> P feeds back into osteocyteSignal (SOST,
%                                 RANKL), closing the systemic loop.
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
s = struct( ...
    Ca_i = y(ix.Ca_i), Y = y(ix.Y), S = y(ix.S), T = y(ix.T), ...
    n_ot = y(ix.n_ot), beta = y(ix.beta), R = y(ix.R), B = y(ix.B), ...
    C = y(ix.C), r_p = y(ix.r_p), r_e = y(ix.r_e), f_bm = y(ix.f_bm), ...
    m1 = y(ix.m1), m2 = y(ix.m2));
P_pth = y(ix.P);

u_romo = localDrugOn(t, ctx.scenario.drug.romosozumab);
E2     = ctx.scenario.E2;

% --- M1-M7 for the single site ------------------------------------------
siteCtx = struct(peakBout = ctx.peakBout, ...
                 doseSurrogate = ctx.doseSurrogate, D_eff_0 = ctx.D_eff_0);
[dLoc, flux, aux] = siteRHS(s, siteCtx, P_pth, E2, u_romo, p);

% --- M8: systemic calcium / PTH / 1,25D ---------------------------------
Ca_s = y(ix.Ca_s);   V_D = y(ix.V_D);
[dSys, algSys] = calciumPTHvitD(Ca_s, P_pth, V_D, ctx.scenario.I_Ca, ...
                                flux.vForm, flux.vRes, p);

% --- assemble ------------------------------------------------------------
dydt = zeros(numel(y), 1);
dydt(ix.Ca_i) = dLoc.Ca_i;
dydt(ix.Y)    = dLoc.Y;
dydt(ix.S)    = dLoc.S;
dydt(ix.T)    = dLoc.T;
dydt(ix.n_ot) = dLoc.n_ot;
dydt(ix.beta) = dLoc.beta;
dydt(ix.R)    = dLoc.R;
dydt(ix.B)    = dLoc.B;
dydt(ix.C)    = dLoc.C;
dydt(ix.r_p)  = dLoc.r_p;
dydt(ix.r_e)  = dLoc.r_e;
dydt(ix.f_bm) = dLoc.f_bm;
dydt(ix.m1)   = dLoc.m1;
dydt(ix.m2)   = dLoc.m2;
dydt(ix.Ca_s) = dSys.Ca_s;
dydt(ix.P)    = dSys.P;
dydt(ix.V_D)  = dSys.V_D;

if nargout > 1
    aux.v_form = flux.vForm;
    aux.v_res  = flux.vRes;
    aux.Abs    = algSys.Abs;
    aux.Renal  = algSys.Renal;
    aux.Pset   = algSys.Pset;
    aux.VDset  = algSys.VDset;
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
