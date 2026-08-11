%E6_BIFURCATION Oestrogen continuation -- the figure that answers P3.
%
%   Regenerates the P3 figure with the two things the v2.4 version lacked:
%   the linear-elastic validity boundary (appendix C17.5), and the full-model
%   hysteresis probe that P5e made possible (C17.6).
%
%   P3 asked whether osteoporosis is an ALTERNATIVE STABLE STATE reached
%   through a saddle-node.  The answer is no -- the model is monostable, and
%   this figure is the evidence.  Two independent routes agree:
%
%     (a) FROZEN GEOMETRY.  Count the zeros of the f_bm nullcline as E2
%         falls.  One zero throughout, sliding continuously.  No fold.
%     (b) FULL MODEL, GEOMETRY FREE.  Drive E2 down, then restore it, and
%         see whether f_bm comes back.  It does, to 99.8 % of baseline.
%         This route only became usable once the modelling term was bounded
%         (P5e); before that the geometry blew up and the run got stuck at
%         the porosity floor, which read as false irreversibility (C15.4).
%
%   *** VALIDITY (C17.5) ***  Below f_bm ~ 0.391 the peak strain exceeds the
%   yield strain of cortical bone, so the linear elasticity the whole
%   mechanics stack assumes no longer holds.  That region is shaded: the
%   monostability conclusion is a property of the nullcline's zero count and
%   survives, but the deep branch must be read as extrapolation.
%
%   Runtime note (PROJECT_PLAN §7.3): keep nFbm and days modest or the MCP
%   session times out.  Sobol/LHS is a separate, still-unimplemented piece.
%
%   Writes:  <results>/E6_bifurcation/E6_bifurcation.mat
%            <results>/figures/E6_bifurcation.{png,pdf}
%
%   Project: bone-mechanostat (PROJECT_PLAN v2.7)

p   = getDefaultParams(reload = true);
col = houseColors();

% f_bm below this leaves the linear-elastic domain, at baseline geometry.
fbmValid = p.f_bm_0 * (761.8e-6 / p.eps_elastic_max) ^ (1 / p.kappa_E);

fprintf("\n=== E6: oestrogen continuation (P3) ===\n");
fprintf("  linear-elastic validity floor: f_bm > %.3f\n", fbmValid);

% --- (a) frozen-geometry continuation -----------------------------------
E2grid = [1.00 0.97 0.95 0.945 0.94 0.93 0.90 0.85 0.75 0.65];
branch = continuation("E2", E2grid, nFbm = 26, days = 700);

fbmStar = nan(size(E2grid));
nStable = nan(size(E2grid));
for k = 1:numel(E2grid)
    nStable(k) = branch.nStable(k);
    fps = branch.fps{k};            % fixed-point VALUES
    st  = branch.stable{k};         % logical mask over fps, not values
    i   = find(st, 1);
    if ~isempty(i), fbmStar(k) = fps(i); end
end

fprintf("  E2      f_bm*     #stable   inside elastic domain\n");
for k = 1:numel(E2grid)
    fprintf("  %.3f   %.4f      %d          %d\n", ...
            E2grid(k), fbmStar(k), nStable(k), fbmStar(k) > fbmValid);
end
monostable = all(nStable <= 1);
fprintf("  monostable everywhere (no saddle-node, no bistability): %d\n", monostable);

% --- (b) full-model hysteresis probe, geometry NOT frozen ---------------
% Chosen at E2 = 0.945 because that is the deepest oestrogen loss whose whole
% trajectory stays inside the elastic domain (C17.5).
sDown = scenarioLibrary("sedentary", durationDays = 365 * 10); sDown.E2 = 0.945;
oDown = simulate(sDown, p = p);
sUp   = scenarioLibrary("sedentary", durationDays = 365 * 20); sUp.E2 = 1.0;
oUp   = simulate(sUp, p = p, y0 = oDown.y(end,:).');

fDown = oDown.get.f_bm; fUp = oUp.get.f_bm;
recovery = 100 * fUp(end) / fDown(1);
ratchet  = 1e3 * (oUp.get.r_p(end) - oDown.get.r_p(1));

fprintf("\n  full-model probe (geometry free):\n");
fprintf("    down  E2 1.0 -> 0.945, 10 yr : f_bm %.4f -> %.4f  valid=%d\n", ...
        fDown(1), fDown(end), oDown.validity.ok);
fprintf("    up    E2 0.945 -> 1.0, 20 yr : f_bm %.4f -> %.4f  valid=%d\n", ...
        fUp(1), fUp(end), oUp.validity.ok);
fprintf("    recovery %.1f %% of baseline -> no hysteresis\n", recovery);
fprintf("    periosteal ratchet %+.3f mm (structural memory, NOT bistability)\n", ratchet);

% --- figure -------------------------------------------------------------
fig = figure(Position = [100 100 940 360], Color = "w");
tl  = tiledlayout(fig, 1, 2, TileSpacing = "compact", Padding = "compact");

ax1 = nexttile(tl); hold(ax1, "on");
xl = [min(E2grid) max(E2grid)];
fill(ax1, [xl fliplr(xl)], [0 0 fbmValid fbmValid], col.accent, ...
     FaceAlpha = 0.12, EdgeColor = "none");
plot(ax1, E2grid, fbmStar, "-o", LineWidth = 2, Color = col.primary, ...
     MarkerFaceColor = col.primary);
yline(ax1, fbmValid, "--", "elastic validity floor", Color = col.accent);
set(ax1, XDir = "reverse");
xlabel(ax1, "oestrogen E_2 [-]"); ylabel(ax1, "f_{bm}^* [-]"); ylim(ax1, [0 1]);
title(ax1, "(a) one branch, no fold -- P3 falsified"); grid(ax1, "on"); box(ax1, "off");

ax2 = nexttile(tl); hold(ax2, "on");
plot(ax2, oDown.t / 365, fDown, LineWidth = 1.8, Color = col.accent);
plot(ax2, 10 + oUp.t / 365, fUp, LineWidth = 1.8, Color = col.primary);
xline(ax2, 10, "--", "E_2 restored", Color = col.muted);
yline(ax2, fDown(1), ":", "baseline", Color = col.ink);
xlabel(ax2, "years"); ylabel(ax2, "f_{bm} [-]");
title(ax2, sprintf("(b) recovers %.1f %%, no hysteresis", recovery));
grid(ax2, "on"); box(ax2, "off");

title(tl, "E6 -- osteoporosis is a steep continuous shift, not a second stable state", ...
      FontWeight = "bold");
exportFigure(fig, "E6_bifurcation");

save(fullfile(getResultsDir("E6_bifurcation"), "E6_bifurcation.mat"), ...
     "E2grid", "fbmStar", "nStable", "monostable", "fbmValid", ...
     "recovery", "ratchet");
