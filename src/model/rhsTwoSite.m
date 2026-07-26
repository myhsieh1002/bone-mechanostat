function [dydt, aux] = rhsTwoSite(t, y, ctx)
%RHSTWOSITE Two-compartment right-hand side (site A loaded, site B contralateral).
%
%   [DYDT, AUX] = RHSTWOSITE(T, Y, CTX) evolves the 31-state vector of
%   STATEVECTOR("two"): 14 local states per site plus 3 shared systemic
%   states.  Each site runs its own M1-M7 via SITERHS; both share ONE M8
%   calcium/PTH pool.
%
%   *** THIS IS INNOVATION N3 (PROJECT_PLAN §4.3) ***
%   Site specificity becomes a testable mathematical claim.  The two sites
%   see IDENTICAL systemic PTH (from the shared M8), so:
%     - LOCAL loading (different boutsA vs boutsB) produces different local
%       strain -> different local dose -> different local bone: ASYMMETRY.
%     - a SYSTEMIC intervention (calcium intake, an anti-sclerostin drug)
%       shifts the shared PTH / clearance equally for both sites, so it
%       cannot create a side-to-side difference.
%   This is exactly the tennis-player result (Haapasalo 2000, V6): the
%   playing arm gains bone, and no pill could reproduce that asymmetry.
%
%   The shared systemic pool is driven by the AVERAGE of the two sites'
%   bone-cell activity.  Physiologically a single humerus is a negligible
%   fraction of whole-body calcium turnover, so this keeps M8 near baseline
%   regardless of local loading -- which is the point: the arms are probes
%   of the shared pool, not drivers of it.
%
%   Inputs / outputs mirror RHSFULL, with the 31-state layout.
%
%   See also SITERHS, MAKECONTEXTTWOSITE, RHSFULL, STATEVECTOR.

%   Project: bone-mechanostat (PROJECT_PLAN v2.1)

arguments
    t (1,1) double
    y (:,1) double
    ctx (1,1) struct
end

ix = ctx.idx;
p  = ctx.p;

P_pth  = y(ix.P);
V_D    = y(ix.V_D);
Ca_s   = y(ix.Ca_s);
u_romo = localDrugOn(t, ctx.scenario.drug.romosozumab);
E2     = ctx.scenario.E2;

% --- per-site M1-M7 (shared PTH) ----------------------------------------
sA = localUnpack(y, ix, "_A");
sB = localUnpack(y, ix, "_B");
A_reb = y(ix.A_reb);
[dA, fluxA] = siteRHS(sA, ctx.A, P_pth, E2, u_romo, A_reb, p);
[dB, fluxB] = siteRHS(sB, ctx.B, P_pth, E2, u_romo, A_reb, p);

% --- shared M8: driven by the mean of the two sites ---------------------
vForm = 0.5 * (fluxA.vForm + fluxB.vForm);
vRes  = 0.5 * (fluxA.vRes  + fluxB.vRes);
[dSys, algSys] = calciumPTHvitD(Ca_s, P_pth, V_D, ctx.scenario.I_Ca, ...
                                vForm, vRes, p);

% --- assemble ------------------------------------------------------------
dydt = zeros(numel(y), 1);
dydt = localPack(dydt, ix, "_A", dA);
dydt = localPack(dydt, ix, "_B", dB);
dydt(ix.Ca_s) = dSys.Ca_s;
dydt(ix.P)    = dSys.P;
dydt(ix.V_D)  = dSys.V_D;
dydt(ix.A_reb) = (p.sost_reb * u_romo - A_reb) / p.tau_reb;

if nargout > 1
    aux = struct(vForm = vForm, vRes = vRes, ...
                 fluxA = fluxA, fluxB = fluxB, algSys = algSys);
end
end

% -------------------------------------------------------------------------
function s = localUnpack(y, ix, suf)
g = @(nm) y(ix.(matlab.lang.makeValidName(nm + suf)));
s = struct(Ca_i = g("Ca_i"), Y = g("Y"), S = g("S"), T = g("T"), ...
           n_ot = g("n_ot"), beta = g("beta"), R = g("R"), B = g("B"), ...
           C = g("C"), r_p = g("r_p"), r_e = g("r_e"), f_bm = g("f_bm"), ...
           rho_min = g("rho_min"));
end

% -------------------------------------------------------------------------
function dydt = localPack(dydt, ix, suf, d)
fn = string(fieldnames(d));
for k = 1:numel(fn)
    dydt(ix.(matlab.lang.makeValidName(fn(k) + suf))) = d.(fn(k));
end
end

% -------------------------------------------------------------------------
function u = localDrugOn(t, win)
u = 0;
if ~isnan(win.startDay) && t >= win.startDay
    if isnan(win.stopDay) || t < win.stopDay
        u = 1;
    end
end
end
