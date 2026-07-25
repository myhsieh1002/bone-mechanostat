function fig = plotIdentifiability(out, opts)
%PLOTIDENTIFIABILITY Visualise the identifiability analysis.
%
%   FIG = PLOTIDENTIFIABILITY(OUT) draws the 2-D chi-square map over
%   (K_P_sost, lambda_P) with the Delta-chi2 confidence contour and the
%   calibrated point, plus the three 1-D conditional scans.  OUT is the
%   IDENTIFIABILITY output.
%
%   The map is the headline: a diagonal low-chi2 valley is the visual
%   signature of the K_P_sost / lambda_P compensation (appendix C11).
%
%   Inputs
%     out            (1,1) struct  from IDENTIFIABILITY
%     opts.threshold (1,1) double  Delta-chi2 contour.  Default 1.0
%     opts.save      (1,1) logical  export via exportFigure.  Default false
%
%   Output
%     fig  (1,1) matlab.ui.Figure
%
%   See also IDENTIFIABILITY, EXPORTFIGURE.

%   Project: bone-mechanostat (PROJECT_PLAN v2.0)

arguments
    out (1,1) struct
    opts.threshold (1,1) double = 1.0
    opts.save (1,1) logical = false
end

primary = "#028090";
accent  = "#C1543A";

fig = figure(Position = [100 100 1300 380], Color = "w");
tl = tiledlayout(fig, 1, 5, TileSpacing = "compact", Padding = "compact");

% --- 2-D map (spans two tiles) ------------------------------------------
ax1 = nexttile(tl, [1 2]);
kp = out.mapAxes.K_P_sost;
lp = out.mapAxes.lambda_P;
z  = out.map.';                       % rows = lambda_P, cols = K_P_sost
imagesc(ax1, log10(kp), log10(lp), z);
set(ax1, YDir = "normal");
colormap(ax1, flipud(bone));
cb = colorbar(ax1);  cb.Label.String = "\chi^2";
hold(ax1, "on");
contour(ax1, log10(kp), log10(lp), z, ...
        out.chi2minMap + [1 1]*opts.threshold, LineColor = accent, LineWidth = 2);
% calibrated optimum
plot(ax1, log10(31.34), log10(3.684), "p", MarkerSize = 14, ...
     MarkerFaceColor = accent, MarkerEdgeColor = "k");
xlabel(ax1, "log_{10} K_{P,sost}");
ylabel(ax1, "log_{10} \lambda_P");
title(ax1, sprintf("\\chi^2 map (ridge r = %.2f)", out.ridgeCorr));
hold(ax1, "off");

% --- three 1-D conditional scans ----------------------------------------
names = ["k_res" "K_S" "delta_ab"];
labels = ["k_{res}" "K_S" "\delta_{ab}"];
for j = 1:3
    ax = nexttile(tl);
    s = out.scan.(names(j));
    plot(ax, log10(s.grid), s.chi2, "-o", Color = primary, ...
         LineWidth = 1.5, MarkerFaceColor = primary, MarkerSize = 4);
    yline(ax, min(s.chi2) + opts.threshold, "--", Color = accent);
    xlabel(ax, "log_{10} " + labels(j));
    ylabel(ax, "\chi^2");
    title(ax, names(j) + " (" + out.class.(names(j)) + ")", ...
          Interpreter = "none", FontSize = 8);
    grid(ax, "on");
end

title(tl, "Parameter identifiability (profile / conditional \chi^2)", ...
      FontWeight = "bold");

if opts.save
    exportFigure(fig, "identifiability");
end
end
