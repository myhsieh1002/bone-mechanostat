%EXPORTS1FIGIDENTIFIABILITY Render S1 Fig from a saved IDENTIFIABILITY run.
%
%   Reads <results>/calibration/identifiability.mat and writes
%   <results>/figures/S1_Fig_identifiability.png.
%
%   Panel (a) is the 2-D chi-square map over the correlated PTH-pathway pair
%   (K_P_sost, lambda_P); panels (b)-(d) are the 1-D conditional scans of
%   k_res, K_S and delta_ab.
%
%   *** WHY THIS FILE EXISTS (P5o, appendix C34) ***
%   S1 Fig had no script.  It was made by hand at v2.12 and could therefore
%   not be regenerated when P5o moved every calibrated parameter -- the same
%   defect class as a target that is declared but never run.  Anything that
%   appears in the paper has to be reproducible from the repository.
%
%   Run IDENTIFIABILITY(save = true) first.
%
%   Project: bone-mechanostat (PROJECT_PLAN v2.24)

matFile = fullfile(getResultsDir("calibration"), "identifiability.mat");
if ~isfile(matFile)
    error("boneMechanostat:noIdentifiabilityRun", ...
          "Run identifiability(save = true) first; %s not found.", matFile);
end
S   = load(matFile);
idn = S.out;

fig = figure(Position = [100 100 1100 850], Color = "w");
tl  = tiledlayout(fig, 2, 2, TileSpacing = "compact", Padding = "compact");

% --- (a) the 2-D map ------------------------------------------------------
ax = nexttile(tl);
[Kg, Lg] = deal(idn.mapAxes.K_P_sost, idn.mapAxes.lambda_P);
imagesc(ax, Kg, Lg, log10(idn.map).');
set(ax, YDir = "normal");
colormap(ax, parula);
cb = colorbar(ax);
cb.Label.String = "log_{10} \chi^2";
hold(ax, "on");

% Delta-chi2 = 1 contour: the approximate confidence region.
chi2min = min(idn.map(:));
contour(ax, Kg, Lg, idn.map.', [chi2min + 1, chi2min + 1], ...
        LineColor = "w", LineWidth = 1.5);
p = getDefaultParams();
plot(ax, p.K_P_sost, p.lambda_P, "rp", MarkerSize = 12, ...
     MarkerFaceColor = "r");
hold(ax, "off");
xlabel(ax, "K_{P,sost}");
ylabel(ax, "\lambda_P");
title(ax, sprintf("(a) PTH pair: %.1f %% of grid inside \\Delta\\chi^2 = 1, r = %.2f", ...
      100 * nnz(idn.map <= chi2min + 1) / numel(idn.map), idn.ridgeCorr));

% --- (b)-(d) the 1-D conditional scans -----------------------------------
names  = ["k_res" "K_S" "delta_ab"];
labels = ["k_{res} [m/day]" "K_S" "\delta_{ab} [1/day]"];
tags   = ["(b)" "(c)" "(d)"];
for k = 1:numel(names)
    ax = nexttile(tl);
    s  = idn.scan.(names(k));
    semilogy(ax, s.grid, s.chi2, "-o", LineWidth = 1.4, MarkerSize = 5);
    hold(ax, "on");
    xline(ax, p.(names(k)), "r--", LineWidth = 1.2);
    yline(ax, min(s.chi2) + 1, "k:", LineWidth = 1.0);
    hold(ax, "off");
    grid(ax, "on");
    xlabel(ax, labels(k));
    ylabel(ax, "\chi^2");
    title(ax, sprintf("%s %s -- %s", tags(k), names(k), idn.class.(names(k))), ...
          Interpreter = "none");
end

outDir = getResultsDir("figures");
outPng = fullfile(outDir, "S1_Fig_identifiability.png");
exportgraphics(fig, outPng, Resolution = 300);
fprintf("Saved: %s\n", outPng);
