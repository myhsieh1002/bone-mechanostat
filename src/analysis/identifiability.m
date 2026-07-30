function out = identifiability(opts)
%IDENTIFIABILITY Identifiability analysis of the calibrated parameters.
%
%   OUT = IDENTIFIABILITY() answers the §9 risk-1 question in two parts:
%
%   (1) A 2-D chi-square MAP over the flagged pair (K_P_sost, lambda_P),
%       with the other three parameters held at their calibrated values.
%       Both act only through V7, so if they compensate the map shows a
%       diagonal valley of low chi2 (a ridge of equivalent fits) rather
%       than an isolated basin.  This is the rigorous joint picture -- more
%       honest than two separate 1-D profiles for a correlated pair.
%
%   (2) 1-D conditional scans of the other three (k_res, K_S, delta_ab),
%       each pinned by a distinct target (V1, V2, V8).  A clear single
%       minimum ⇒ identifiable.
%
%   chi2 is EVALTARGETS' smooth midpoint metric.  A Delta-chi2 threshold
%   marks the approximate confidence region.
%
%   Cost note: full profile likelihood (re-optimising nuisance params at
%   every grid point) is ~100x more evaluations; the 2-D map over the only
%   correlated pair captures the same structure at a fraction of the cost.
%   The dose surrogate is memoised (buildDoseSurrogate), so each evalTargets
%   is integration-bound (~4 s), and the grid is run in parallel (pool
%   capped at 3, §7.3).
%
%   Inputs
%     opts.nMap      (1,1) double  grid per axis of the 2-D map.  Default 11
%     opts.nScan     (1,1) double  points per 1-D scan.  Default 9
%     opts.spanDecades (1,1) double half-width of every grid, log10.  Default 0.7
%     opts.years     (1,1) double  evalTargets horizon.  Default 1.5
%     opts.threshold (1,1) double  Delta-chi2 for the CI.  Default 1.0
%     opts.useParallel (1,1) logical  Default true
%     opts.save      (1,1) logical  Default false
%
%   Output
%     out  (1,1) struct  .map (K_P_sost x lambda_P chi2), .mapAxes,
%                        .scan (struct per 1-D param), .ci, .class,
%                        .ridgeCorr (correlation along the low-chi2 valley)
%
%   See also CALIBRATE, EVALTARGETS.

%   Project: bone-mechanostat (PROJECT_PLAN v2.0)

arguments
    opts.nMap (1,1) double = 11
    opts.nScan (1,1) double = 9
    opts.spanDecades (1,1) double = 0.7
    opts.years (1,1) double = 1.5
    opts.threshold (1,1) double = 1.0
    opts.useParallel (1,1) logical = true
    opts.save (1,1) logical = false
end

rng(20260722, "twister");
p0 = getDefaultParams();
yrs = opts.years;

if opts.useParallel && isempty(gcp("nocreate"))
    parpool("Processes", 3);
end
nw = 0; if opts.useParallel, nw = Inf; end

% ===== (1) 2-D map over (K_P_sost, lambda_P) ============================
axKP = localLogGrid(p0.K_P_sost, opts.spanDecades, opts.nMap, 1.0, 100);
axLP = localLogGrid(p0.lambda_P, opts.spanDecades, opts.nMap, 0.5, 10);

[KP, LP] = ndgrid(axKP, axLP);
mapFlat = zeros(numel(KP), 1);
kpF = KP(:); lpF = LP(:);
parfor (k = 1:numel(kpF), nw)
    q = p0;
    q.K_P_sost = kpF(k);
    q.lambda_P = lpF(k);
    mapFlat(k) = localChi2(q, yrs);
end
chi2map = reshape(mapFlat, size(KP));

% ridge analysis: among cells within threshold of the min, correlation of
% log(K_P_sost) vs log(lambda_P) -- a compensation ridge shows |corr|~1.
chi2min = min(chi2map(:));
inCI = chi2map - chi2min <= opts.threshold;
lk = log10(KP(inCI));  ll = log10(LP(inCI));
if numel(lk) >= 3 && std(lk) > 0 && std(ll) > 0
    ridgeCorr = corr(lk, ll);
else
    ridgeCorr = NaN;
end

out = struct();
out.map        = chi2map;
out.mapAxes    = struct(K_P_sost = axKP, lambda_P = axLP);
out.chi2minMap = chi2min;
out.ridgeCorr  = ridgeCorr;
out.inCIcount  = nnz(inCI);
out.inCItotal  = numel(inCI);

% marginal profiles from the map (min over the other axis).
out.profKP = min(chi2map, [], 2).';
out.profLP = min(chi2map, [], 1);

% ===== (2) 1-D conditional scans =======================================
scanNames = ["k_res" "K_S" "delta_ab"];
lbAll = struct(k_res = 1e-8, K_S = 0.1, delta_ab = 0.02);
ubAll = struct(k_res = 1e-6, K_S = 5.0, delta_ab = 2.0);

out.scan = struct();
for nm = scanNames
    xc = p0.(nm);
    grid = localLogGrid(xc, opts.spanDecades, opts.nScan, lbAll.(nm), ubAll.(nm));
    prof = zeros(size(grid));
    parfor (ig = 1:numel(grid), nw)
        q = p0;
        q.(nm) = grid(ig);
        prof(ig) = localChi2(q, yrs);
    end
    out.scan.(nm) = struct(grid = grid, chi2 = prof);
end

% ===== classification ===================================================
out.class = struct();
out.ci    = struct();

% Classify the pair on BOTH axes: how correlated (ridge) and how bounded
% (span).  A strong correlation with an unbounded valley is structural
% non-identifiability; a strong correlation with a bounded region is a
% correlated-but-jointly-bounded pair -- individually loose, jointly OK.
spanFrac = out.inCIcount / out.inCItotal;
strongCorr = ~isnan(ridgeCorr) && abs(ridgeCorr) > 0.7;
if strongCorr && spanFrac > 0.5
    pairClass = "structurally non-identifiable (unbounded compensation ridge)";
elseif strongCorr
    pairClass = sprintf("correlated (r=%.2f) but jointly bounded -- individually loose, pair identifiable", ridgeCorr);
elseif spanFrac > 0.5
    pairClass = "practically non-identifiable (wide, uncorrelated)";
else
    pairClass = "jointly identifiable, weak correlation";
end
out.class.pair_KP_lambdaP = pairClass;
out.spanFrac = spanFrac;

for nm = scanNames
    g = out.scan.(nm).grid;  c = out.scan.(nm).chi2;
    cmin = min(c);
    below = g(c - cmin <= opts.threshold);
    out.ci.(nm) = [min(below), max(below)];
    hitLo = c(1)   - cmin > opts.threshold;
    hitHi = c(end) - cmin > opts.threshold;
    if hitLo && hitHi
        out.class.(nm) = "identifiable";
    elseif hitLo || hitHi
        out.class.(nm) = "practically non-identifiable";
    else
        out.class.(nm) = "structurally non-identifiable";
    end
end

localReport(out, scanNames);

if opts.save
    outFile = fullfile(getResultsDir("calibration"), "identifiability.mat");
    save(outFile, "out");
    fprintf("Saved: %s\n", outFile);
end
end

% -------------------------------------------------------------------------
function g = localLogGrid(xc, span, n, lo, hi)
%LOCALLOGGRID Log-spaced grid centred on xc, clamped to [lo,hi] as a RANGE
%   (not element-wise), so no duplicate endpoints reach contour/imagesc.
a = max(log10(lo), log10(xc) - span);
b = min(log10(hi), log10(xc) + span);
g = logspace(a, b, n);
end

% -------------------------------------------------------------------------
function c = localChi2(p, yrs)
try
    p.k_ot   = osteocyteBurialRate(p);
    p.k_form = balanceBoneFormation(p);
    r = evalTargets(p, years = yrs);
    c = r.chi2;
catch
    c = 1e6;
end
if ~isfinite(c), c = 1e6; end
end

% -------------------------------------------------------------------------
function localReport(out, scanNames)
fprintf("\n=== Identifiability ===\n");
fprintf("2-D map (K_P_sost x lambda_P): chi2min=%.3g, CI spans %d/%d cells, ridge corr=%.2f\n", ...
    out.chi2minMap, out.inCIcount, out.inCItotal, out.ridgeCorr);
fprintf("  -> %s\n", out.class.pair_KP_lambdaP);
for nm = scanNames
    fprintf("%-10s CI=[%.3g, %.3g]  %s\n", nm, out.ci.(nm)(1), out.ci.(nm)(2), out.class.(nm));
end
end
