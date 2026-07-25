function [df, fbmGrid, nOt] = fbmNullcline(p, fbmGrid, opts)
%FBMNULLCLINE df_bm/dt as a function of f_bm, other states equilibrated.
%
%   [DF, FBMGRID, NOT] = FBMNULLCLINE(P, FBMGRID) sweeps bone volume
%   fraction; at each value it FIXES f_bm and the frozen envelope geometry,
%   integrates all other states (fast signalling + n_ot + rho_min + systemic)
%   to quasi-steady state, then reports df_bm/dt.  Zeros of DF are fixed
%   points of the porosity dynamics; three zeros (an S-shaped nullcline) is
%   bistability (P3).  NOT is the equilibrated osteocyte density along the
%   sweep -- the P3 positive-feedback variable.
%
%   Project: bone-mechanostat (PROJECT_PLAN v2.3)
arguments
    p (1,1) struct
    fbmGrid (1,:) double = linspace(0.05, 0.98, 40)
    opts.days (1,1) double = 2000
    opts.E2 (1,1) double = 1
end
info = stateVector("single");
sc = scenarioLibrary("sedentary", durationDays = opts.days);
sc.E2 = opts.E2;
ctx = makeContext(sc, p); ctx.freezeGeom = true;
ix = info.idx;
df = zeros(size(fbmGrid));
nOt = zeros(size(fbmGrid));
odeo = odeset(RelTol = 1e-7, AbsTol = 1e-10, NonNegative = find(info.nonNegative));

for k = 1:numel(fbmGrid)
    y0 = baselineState("single", p);
    y0(ix.f_bm) = fbmGrid(k);
    y0(ix.n_ot) = p.n_ot_0 * max(fbmGrid(k)/p.f_bm_0, 0.2);
    % integrate with f_bm HELD fixed (zero its derivative via a wrapper)
    rhs = @(t, y) localHoldFbm(t, y, ctx, ix.f_bm);
    sol = ode15s(rhs, [0 opts.days], y0, odeo);
    yss = sol.y(:, end);
    yss(ix.f_bm) = fbmGrid(k);
    dy = rhsFull(0, yss, ctx);       % now read the true df_bm at this state
    df(k) = dy(ix.f_bm);
    nOt(k) = yss(ix.n_ot);
end
end

function dy = localHoldFbm(t, y, ctx, iFbm)
dy = rhsFull(t, y, ctx);
dy(iFbm) = 0;                        % hold f_bm fixed while others relax
end
