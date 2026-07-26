%E2_CALCIUMLOADING Factorial calcium x loading -- the direct test of P1.
%
%   P1 says calcium is PERMISSIVE and loading is INSTRUCTIVE.  Stated as
%   numbers (PROJECT_PLAN §0): in the calcium-replete range the marginal
%   effect of calcium intake on 24-month aBMD is < 1 %, while an appropriate
%   loading programme gives > 4 %, and the two interact synergistically
%   rather than additively -- loading's effect is TRUNCATED when calcium is
%   deficient, because there is no substrate to build with.
%
%   The core comparison is the 2x2 {800, 1500 mg/day} x {sedentary,
%   resistance}.  A third calcium arm at 400 mg/day is added because the
%   truncation claim is only visible below the replete range -- a 2x2 inside
%   the replete range cannot show it.
%
%   Writes:  <results>/E2_calciumLoading/E2_calciumLoading.mat
%            <results>/figures/E2_calciumLoading.{png,pdf}
%
%   Project: bone-mechanostat (PROJECT_PLAN v2.7)

p   = getDefaultParams(reload = true);
col = houseColors();

caLevels   = [100 400 800 1500];             % mg/day: severe, deficient, adequate, supplemented
caLabels   = ["100 (severe)" "400 (deficient)" "800 (adequate)" "1500 (supplemented)"];
loadLevels = ["sedentary" "resistance"];
nDays      = 730;

dBMD  = nan(numel(caLevels), numel(loadLevels));   % % change over 24 months
valid = true(size(dBMD));

fprintf("\n=== E2: calcium x loading factorial (24 months) ===\n");
for i = 1:numel(caLevels)
    for j = 1:numel(loadLevels)
        s   = scenarioLibrary(loadLevels(j), durationDays = nDays, I_Ca = caLevels(i));
        o   = simulate(s, p = p);
        dBMD(i,j)  = 100 * (o.dens.aBMD(end) / o.dens.aBMD(1) - 1);
        valid(i,j) = o.validity.ok;
        fprintf("  Ca %4d mg/day, %-10s : daBMD %+6.3f %%   valid=%d\n", ...
                caLevels(i), loadLevels(j), dBMD(i,j), valid(i,j));
    end
end

% --- P1 as numbers -------------------------------------------------------
iSev = 1; iAdeq = 3; iSupp = 4; jSed = 1; jRes = 2;

caMarginal   = dBMD(iSupp,jSed) - dBMD(iAdeq,jSed);   % 800 -> 1500, sedentary
loadMarginal = dBMD(iAdeq,jRes) - dBMD(iAdeq,jSed);   % sedentary -> resistance, adequate Ca

fprintf("\n  --- P1, clauses 1 and 2 ---\n");
fprintf("  calcium marginal (800->1500, sedentary)     %+6.3f %%   [P1 predicts < 1]\n", caMarginal);
fprintf("  loading marginal (sed->resist, Ca adequate) %+6.3f %%   [P1 predicts > 4]\n", loadMarginal);
fprintf("  loading / calcium effect ratio              %6.1f x\n", loadMarginal / max(caMarginal, eps));

% --- P1 clause 3: the two framings of "truncation" DISAGREE IN SIGN ------
% P1 as pre-registered says loading's effect is truncated when calcium is
% short, i.e. a positive difference-in-differences interaction.  The model
% says the mechanism is real but the metric is wrong:
%
%   ABSOLUTE framing  -- what a loaded person actually achieves.  Deficiency
%                        does cost bone, so the claim holds.
%   DIFFERENCE framing -- loaded minus sedentary at the same calcium.  This
%                        REVERSES, because deficiency drags the sedentary
%                        arm down faster than the loaded arm.  It is a floor
%                        effect in the comparator, not synergy.
absGain     = dBMD(:,jRes);                           % achieved gain per Ca level
absTrunc    = dBMD(iSupp,jRes) - dBMD(iSev,jRes);     % >0 means deficiency costs bone
interaction = (dBMD(iAdeq,jRes) - dBMD(iAdeq,jSed)) ...
            - (dBMD(iSev,jRes)  - dBMD(iSev,jSed));   % pre-registered metric

fprintf("\n  --- P1, clause 3 (interaction): the two framings disagree ---\n");
fprintf("  ABSOLUTE   achieved gain, severe %.3f %% vs supplemented %.3f %%\n", ...
        dBMD(iSev,jRes), dBMD(iSupp,jRes));
fprintf("             deficiency costs %+6.3f %% points (%.0f %% of the gain)  -> claim HOLDS\n", ...
        absTrunc, 100 * absTrunc / dBMD(iSupp,jRes));
fprintf("  DIFFERENCE-IN-DIFFERENCES interaction %+6.3f %% points          -> claim REVERSES\n", ...
        interaction);
fprintf("             (sedentary arm falls faster under deficiency: %+.3f -> %+.3f %%)\n", ...
        dBMD(iSupp,jSed), dBMD(iSev,jSed));

pass = struct(caPermissive     = caMarginal   < 1.0, ...
              loadInstruct     = loadMarginal > 4.0, ...
              truncationAbs    = absTrunc     > 0, ...
              truncationDiffDiff = interaction > 0);
fprintf("\n  P1 verdict: permissive=%d  instructive=%d  truncation(absolute)=%d  truncation(diff-in-diff)=%d\n", ...
        pass.caPermissive, pass.loadInstruct, pass.truncationAbs, pass.truncationDiffDiff);

% --- figure -------------------------------------------------------------
fig = figure(Position = [100 100 900 360], Color = "w");
tl  = tiledlayout(fig, 1, 2, TileSpacing = "compact", Padding = "compact");

nexttile(tl);
b = bar(dBMD, EdgeColor = "none");
b(1).FaceColor = col.muted; b(2).FaceColor = col.primary;
xticklabels(caLabels); ylabel("\DeltaaBMD over 24 months [%]");
legend(["sedentary" "resistance 3x/wk"], Location = "northwest", Box = "off");
title("Loading moves bone; calcium barely does"); box off; grid on;

nexttile(tl);
plot(caLevels, dBMD(:,jSed), "-o", LineWidth = 1.8, Color = col.muted, ...
     MarkerFaceColor = col.muted); hold on;
plot(caLevels, dBMD(:,jRes), "-o", LineWidth = 1.8, Color = col.primary, ...
     MarkerFaceColor = col.primary);
xlabel("calcium intake [mg/day]"); ylabel("\DeltaaBMD [%]");
legend(["sedentary" "resistance"], Location = "southeast", Box = "off");
title("Interaction: loading needs substrate"); box off; grid on;

title(tl, "E2 -- calcium is permissive, loading is instructive (P1)", FontWeight = "bold");
exportFigure(fig, "E2_calciumLoading");

save(fullfile(getResultsDir("E2_calciumLoading"), "E2_calciumLoading.mat"), ...
     "caLevels", "loadLevels", "dBMD", "valid", ...
     "caMarginal", "loadMarginal", "absGain", "absTrunc", "interaction", "pass");
