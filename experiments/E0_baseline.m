%E0_BASELINE Steady-state calibration: turnover (V1), emergent epsilon* (V14), flat baseline.
%
%   Confirms the calibrated model sits at a stable baseline and reports the
%   two zero-cost validation targets that fall out of it: bone turnover
%   (V1, 5-10 %/yr) and the EMERGENT mechanostat set point (V14, expected in
%   Frost's lazy zone, 300-1500 ue, between his remodelling and modelling
%   thresholds).  V14 is a hold-out -- it was never fitted, so
%   it is reported here as a prediction, not a check.
%
%   Writes:  <results>/E0_baseline/E0_baseline.mat
%            <results>/figures/E0_baseline.{png,pdf}
%
%   Project: bone-mechanostat (PROJECT_PLAN v2.7)

p   = getDefaultParams(reload = true);
col = houseColors();

out = simulate(scenarioLibrary("sedentary", durationDays = 730), p = p);
r   = evalTargets(p, holdout = true);

drift = 100 * (out.dens.aBMD(end) / out.dens.aBMD(1) - 1);

fprintf("\n=== E0: baseline steady state ===\n");
fprintf("  V1  turnover            %6.2f %%/yr   (target 5-10)      pass=%d\n", ...
        r.V1, r.pass.V1);
fprintf("  V14 emergent epsilon*   %6.1f ue      (lazy zone 300-1500)  pass=%d  [HOLD-OUT]\n", ...
        r.V14, r.passHoldout.V14);
fprintf("  aBMD drift over 24 mo   %+6.3f %%\n", drift);
fprintf("  linear-elastic domain   max %.0f ue of %.0f ue limit, ok=%d\n", ...
        out.validity.maxStrain * 1e6, out.validity.limit * 1e6, out.validity.ok);

% --- figure -------------------------------------------------------------
fig = figure(Position = [100 100 900 340], Color = "w");
tl  = tiledlayout(fig, 1, 3, TileSpacing = "compact", Padding = "compact");

nexttile(tl);
plot(out.t / 365, out.dens.aBMD, LineWidth = 1.8, Color = col.primary);
xlabel("years"); ylabel("aBMD [kg/m^2]"); title("Baseline is flat");
ylim(out.dens.aBMD(1) * [0.98 1.02]); grid on; box off;

nexttile(tl);
plot(out.t / 365, out.get.f_bm, LineWidth = 1.8, Color = col.primary);
xlabel("years"); ylabel("f_{bm} [-]"); title("Bone volume fraction");
grid on; box off;

nexttile(tl);
bar(1, r.V14, FaceColor = col.primary, EdgeColor = "none");
hold on;
yline(100,  "--", "Frost lower", Color = col.muted);
yline(1500, "--", "Frost upper", Color = col.muted);
ylabel("\epsilon^* [\mue]"); xticks(1); xticklabels("model");
title("V14: emergent set point (hold-out)"); ylim([0 1800]); box off;

title(tl, "E0 -- baseline steady state", FontWeight = "bold");
exportFigure(fig, "E0_baseline");

save(fullfile(getResultsDir("E0_baseline"), "E0_baseline.mat"), "r", "drift");
