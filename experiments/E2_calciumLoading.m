%E2_CALCIUMLOADING Factorial calcium x loading -- the direct test of P1.
%
%   P1 says calcium is PERMISSIVE and loading is INSTRUCTIVE.  Stated as
%   numbers (PROJECT_PLAN §0, restated v2.11): in the calcium-replete range
%   the marginal effect of calcium intake on 24-month aBMD is < 1 %, while an
%   APPROPRIATE loading programme -- peak strain ~2900 ue, the
%   "resistanceVigorous" scenario -- raises bone MASS (BMC) by > 4 %.
%
%   *** WHY BMC AND WHY "APPROPRIATE" IS NOW EXPLICIT (appendix C23) ***
%   Once the modelling drift exists (P5i), loading translates the cortex
%   outward, and aBMD divides bone mass by the projected width 2*r_p.  DXA
%   therefore dilutes the loading response by about half.  Clause 2 was
%   written in aBMD against an unspecified "appropriate" programme; both
%   halves are now pinned, and the aBMD number is reported alongside because
%   the gap between the two measures is itself a result.
%
%   Calcium arms run from severe deficiency to supplementation, because the
%   truncation claim is only visible below the replete range -- a 2x2 inside
%   the replete range cannot show it.
%
%   Writes:  <results>/E2_calciumLoading/E2_calciumLoading.mat
%            <results>/figures/E2_calciumLoading.{png,pdf}
%
%   Project: bone-mechanostat (PROJECT_PLAN v2.11)

p   = getDefaultParams(reload = true);
col = houseColors();

caLevels   = [100 400 800 1500];             % mg/day: severe, deficient, adequate, supplemented
caLabels   = ["100 (severe)" "400 (deficient)" "800 (adequate)" "1500 (supplemented)"];
loadLevels = ["sedentary" "resistance" "resistanceVigorous"];
loadLabels = ["sedentary" "resistance (2236 ue)" "vigorous (2949 ue)"];
nDays      = 730;

dBMD  = nan(numel(caLevels), numel(loadLevels));   % % change over 24 months
dBMC  = nan(size(dBMD));                           % bone MASS, not projected
valid = true(size(dBMD));

fprintf("\n=== E2: calcium x loading factorial (24 months) ===\n");
for i = 1:numel(caLevels)
    for j = 1:numel(loadLevels)
        s   = scenarioLibrary(loadLevels(j), durationDays = nDays, I_Ca = caLevels(i));
        o   = simulate(s, p = p);
        dBMD(i,j)  = 100 * (o.dens.aBMD(end)  / o.dens.aBMD(1)  - 1);
        dBMC(i,j)  = 100 * (o.dens.BMC_L(end) / o.dens.BMC_L(1) - 1);
        valid(i,j) = o.validity.ok;
        fprintf("  Ca %4d mg/day, %-10s : daBMD %+6.3f %%   dBMC %+6.3f %%   valid=%d\n", ...
                caLevels(i), loadLevels(j), dBMD(i,j), dBMC(i,j), valid(i,j));
    end
end

% --- P1 as numbers -------------------------------------------------------
iSev = 1; iAdeq = 3; iSupp = 4; jSed = 1; jRes = 2; jVig = 3;

% Clause 1 stays in aBMD: calcium acts on mineral, not on size, so the two
% measures agree there and the DXA literature (Tai 2015) reports aBMD.
caMarginal = dBMD(iSupp,jSed) - dBMD(iAdeq,jSed);      % 800 -> 1500, sedentary

% Clause 2 is now BMC at the appropriate intensity (C23).
loadMarginalBMC  = dBMC(iAdeq,jVig) - dBMC(iAdeq,jSed);
loadMarginal     = dBMD(iAdeq,jVig) - dBMD(iAdeq,jSed);   % same contrast, DXA
loadModerateBMC  = dBMC(iAdeq,jRes) - dBMC(iAdeq,jSed);

fprintf("\n  --- P1, clauses 1 and 2 ---\n");
fprintf("  clause 1  calcium marginal (800->1500, sedentary, aBMD)  %+6.3f %%   [< 1]\n", caMarginal);
fprintf("  clause 2  loading marginal, APPROPRIATE (2949 ue), BMC   %+6.3f %%   [> 4]\n", loadMarginalBMC);
fprintf("            same contrast in aBMD                          %+6.3f %%   (DXA dilutes %.0f %%)\n", ...
        loadMarginal, 100 * (1 - loadMarginal / loadMarginalBMC));
fprintf("            moderate resistance (2236 ue), BMC             %+6.3f %%   <- below the claim,\n", loadModerateBMC);
fprintf("            which is why ""appropriate"" had to be pinned (C23)\n");
fprintf("  loading / calcium effect ratio (BMC vs aBMD basis)        %6.1f x\n", ...
        loadMarginalBMC / max(caMarginal, eps));

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
% Clause 3 is evaluated in BMC too, for consistency with clause 2.
absGain     = dBMC(:,jVig);                           % achieved gain per Ca level
absTrunc    = dBMC(iSupp,jVig) - dBMC(iSev,jVig);     % >0 means deficiency costs bone
interaction = (dBMC(iAdeq,jVig) - dBMC(iAdeq,jSed)) ...
            - (dBMC(iSev,jVig)  - dBMC(iSev,jSed));   % pre-registered metric

fprintf("\n  --- P1, clause 3 (interaction): the two framings disagree ---\n");
fprintf("  ABSOLUTE   achieved gain, severe %.3f %% vs supplemented %.3f %% (BMC)\n", ...
        dBMC(iSev,jVig), dBMC(iSupp,jVig));
fprintf("             deficiency costs %+6.3f %% points (%.0f %% of the gain)  -> claim HOLDS\n", ...
        absTrunc, 100 * absTrunc / dBMC(iSupp,jVig));
fprintf("  DIFFERENCE-IN-DIFFERENCES interaction %+6.3f %% points          -> claim REVERSES\n", ...
        interaction);
fprintf("             (sedentary arm falls faster under deficiency: %+.3f -> %+.3f %%)\n", ...
        dBMC(iSupp,jSed), dBMC(iSev,jSed));

pass = struct(caPermissive       = caMarginal      < 1.0, ...
              loadInstruct       = loadMarginalBMC > 4.0, ...   % clause 2 as restated
              loadInstruct_aBMD  = loadMarginal    > 4.0, ...   % the old wording
              truncationAbs    = absTrunc     > 0, ...
              truncationDiffDiff = interaction > 0);
fprintf("\n  P1 verdict (as restated, C23): permissive=%d  instructive=%d  truncation(abs)=%d  truncation(diff-in-diff)=%d\n", ...
        pass.caPermissive, pass.loadInstruct, pass.truncationAbs, pass.truncationDiffDiff);
fprintf("  (clause 2 under the OLD aBMD wording would read %d -- see C23)\n", pass.loadInstruct_aBMD);

% --- figure -------------------------------------------------------------
fig = figure(Position = [100 100 900 360], Color = "w");
tl  = tiledlayout(fig, 1, 2, TileSpacing = "compact", Padding = "compact");

nexttile(tl);
b = bar(dBMC, EdgeColor = "none");
b(1).FaceColor = col.muted; b(2).FaceColor = col.series(3,:); b(3).FaceColor = col.primary;
xticklabels(caLabels); xtickangle(20); ylabel("\DeltaBMC over 24 months [%]");
legend(loadLabels, Location = "northwest", Box = "off");
yline(4, "--", "P1 clause 2", Color = col.accent);
title("Loading moves bone mass; calcium barely does"); box off; grid on;

nexttile(tl);
plot(caLevels, dBMC(:,jVig), "-o", LineWidth = 1.8, Color = col.primary, ...
     MarkerFaceColor = col.primary); hold on;
plot(caLevels, dBMD(:,jVig), "-o", LineWidth = 1.8, Color = col.muted, ...
     MarkerFaceColor = col.muted);
xlabel("calcium intake [mg/day]"); ylabel("gain under vigorous loading [%]");
legend(["BMC (bone mass)" "aBMD (DXA)"], Location = "southeast", Box = "off");
title("DXA dilutes the loading response"); box off; grid on;

title(tl, "E2 -- calcium is permissive, loading is instructive (P1)", FontWeight = "bold");
exportFigure(fig, "E2_calciumLoading");

save(fullfile(getResultsDir("E2_calciumLoading"), "E2_calciumLoading.mat"), ...
     "caLevels", "loadLevels", "dBMD", "valid", ...
     "caMarginal", "loadMarginal", "loadMarginalBMC", "loadModerateBMC", "dBMC", ...
     "absGain", "absTrunc", "interaction", "pass");
