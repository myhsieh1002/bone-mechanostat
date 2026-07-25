function [fbm, y_ss] = probeSteadyFbm(p, fld, val, f0_frac, opts)
%PROBESTEADYFBM Frozen-geometry steady-state f_bm from a scaled initial state.
%
%   [FBM, Y_SS] = PROBESTEADYFBM(P, FLD, VAL, F0_FRAC) overrides parameter
%   FLD to VAL (FLD = "" for none), starts from a state whose bone volume
%   fraction (and osteocyte density) is scaled by F0_FRAC, integrates the
%   FROZEN-GEOMETRY system to steady state, and returns the final f_bm.
%
%   Used to probe P3 bistability: run from a healthy (F0_FRAC=1) and an
%   osteoporotic (F0_FRAC small) start; if the endpoints differ the system
%   is bistable (two attractors) at that parameter value.
%
%   Project: bone-mechanostat (PROJECT_PLAN v2.3)
arguments
    p (1,1) struct
    fld (1,1) string
    val (1,1) double
    f0_frac (1,1) double
    opts.days (1,1) double = 3650
end
q = p;
if fld ~= "", q.(fld) = val; end
info = stateVector("single");
ctx  = makeContext(scenarioLibrary("sedentary", durationDays = opts.days), q);
ctx.freezeGeom = true;
y0 = baselineState("single", q);
y0(info.idx.f_bm) = q.f_bm_0 * f0_frac;
y0(info.idx.n_ot) = q.n_ot_0 * max(f0_frac, 0.2);
odeo = odeset(RelTol = 1e-7, AbsTol = 1e-10, NonNegative = find(info.nonNegative));
sol  = ode15s(@(t, y) rhsFull(t, y, ctx), [0 opts.days], y0, odeo);
y_ss = sol.y(:, end);
fbm  = y_ss(info.idx.f_bm);
end
