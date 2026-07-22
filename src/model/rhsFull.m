function [dydt, aux] = rhsFull(t, y, scenario, p)
%RHSFULL Right-hand side of the single-compartment model.  *** P1 STUB ***
%
%   [DYDT, AUX] = RHSFULL(T, Y, SCENARIO, P) returns the time derivative of
%   the 17-state vector defined by STATEVECTOR("single").
%
%   *** IMPLEMENTATION STATUS: P1 STUB ***
%   Modules M2-M8 are NOT implemented.  What is wired up and real:
%     - the state vector layout (STATEVECTOR)
%     - the force-controlled M1 mechanics (ORGANMECHANICS), evaluated from
%       the CURRENT geometry, so the closed-loop plumbing is exercised
%   What is fake: every biological derivative is replaced by first-order
%   relaxation towards the baseline state.  The system is therefore stable
%   and flat by construction, which is exactly what P1's end-to-end test
%   needs ("空模型可跑完 24 個月") and nothing more.  Do not read anything
%   physiological into a P1 trajectory.
%
%   Order of implementation (PROJECT_PLAN §8): P2 replaces the mechanics
%   half (M2 poroelasticity, M3 MSIC dose), P3 the biology (M4-M7), P4 the
%   systemic calcium coupling (M8).
%
%   Inputs
%     t         (1,1) double  time                                    [day]
%     y         (:,1) double  state vector, see STATEVECTOR("single")
%     scenario  (1,1) struct  from SCENARIOLIBRARY
%     p         (1,1) struct  from GETDEFAULTPARAMS
%
%   Outputs
%     dydt  (:,1) double  time derivative                       [state/day]
%     aux   (1,1) struct  diagnostics for the current state:
%                         .eps_p, .eps_e [-], .geom (CROSSSECTION output)
%
%   See also SIMULATE, STATEVECTOR, ORGANMECHANICS, RHSTWOSITE.

%   Project: bone-mechanostat (PROJECT_PLAN v1.4)

arguments
    t (1,1) double %#ok<INUSA>
    y (:,1) double
    scenario (1,1) struct
    p (1,1) struct
end

info = stateVector("single");
if numel(y) ~= info.n
    error("boneMechanostat:stateSizeMismatch", ...
          "Expected %d states, got %d.", info.n, numel(y));
end

ix = info.idx;

% --- M1: real, force-controlled mechanics from the current geometry ------
% Uses the largest-amplitude bout of the day as a representative load.  P2
% replaces this with the full within-day tau(t) time course feeding M3.
state = struct(r_p = y(ix.r_p), r_e = y(ix.r_e), ...
               f_bm = y(ix.f_bm), rho_min = localMeanMineral(y, ix, p));
[~, iPeak] = max([scenario.bouts.momentScale]);
m = organMechanics(scenario.bouts(iPeak), state, p);

aux = struct(eps_p = m.eps_p, eps_e = m.eps_e, ...
             eps_bar = m.eps_bar, geom = m.geom);

% --- M2-M8: NOT IMPLEMENTED.  Relaxation towards baseline. ---------------
% Deliberately NOT cached in a persistent: E6 sweeps call this with varying
% p, and a stale baseline would silently pin every sample to the first
% parameter set it ever saw.
y0 = baselineState("single", p);
kRelax = 0.01;                       % [1/day], slow but unconditionally stable
dydt = kRelax * (y0 - y);
end

% -------------------------------------------------------------------------
function rho = localMeanMineral(y, ix, p)
%LOCALMEANMINERAL Mean mineral density from the two mineralisation pools.
%   rho_min = (m1 + m2) / f_bm   [kg/m^3];  falls back to baseline when the
%   pools are still at their initial values (P1).
f = max(y(ix.f_bm), p.f_bm_min);
rho = (y(ix.m1) + y(ix.m2)) / f;
if ~isfinite(rho) || rho <= 0
    rho = p.rho_min_0;
end
end
