%E4_PHARMACOLOGY Romosozumab: self-limitation (V9), withdrawal (V10), loading interaction (V12).
%
%   Four arms over 24 months: control, romosozumab (12 months on, then 12
%   months washout), loading alone, and romosozumab + loading.
%
%   *** SCOPE (appendix C14) ***  V8/V10 are LUMBAR SPINE numbers and the
%   spine is trabecular.  This model is a cortical diaphyseal section with
%   f_bm ~ 0.95, i.e. almost no room to densify, so it cannot reproduce
%   +11-14 % at 12 months without the mineralisation artefact that v2.3
%   removed.  Direction and shape are therefore reported; the spine
%   magnitude is not claimed.  Quantitative V8/V10 wait on the trabecular
%   compartment (P5d).
%
%   Writes:  <results>/E4_pharmacology/E4_pharmacology.mat
%            <results>/figures/E4_pharmacology.{png,pdf}
%
%   Project: bone-mechanostat (PROJECT_PLAN v2.7)

p     = getDefaultParams(reload = true);
col   = houseColors();
nDays = 730;
stopD = 365;                          % romosozumab is stopped at 12 months

arms = ["control" "romosozumab" "loading" "romo + loading"];
o    = cell(1, 4);

sC = scenarioLibrary("sedentary",   durationDays = nDays);
sR = scenarioLibrary("romosozumab", durationDays = nDays);
sL = scenarioLibrary("resistance",  durationDays = nDays);
sRL = sR; sRL.bouts = sL.bouts;       % drug schedule from sR, loading from sL

o{1} = simulate(sC,  p = p);
o{2} = simulate(sR,  p = p);
o{3} = simulate(sL,  p = p);
o{4} = simulate(sRL, p = p);

pct = @(x) 100 * (x ./ x(1) - 1);
[~, k12] = min(abs(o{1}.t - stopD));

fprintf("\n=== E4: pharmacology (24 months, drug stopped at month 12) ===\n");
fprintf("  %-15s  %10s  %10s   valid\n", "arm", "@12 mo", "@24 mo");
d12 = nan(1,4); d24 = nan(1,4);
for k = 1:4
    d = pct(o{k}.dens.aBMD);
    d12(k) = d(k12); d24(k) = d(end);
    fprintf("  %-15s  %+9.3f %%  %+9.3f %%      %d\n", ...
            arms(k), d12(k), d24(k), o{k}.validity.ok);
end

% --- V8 direction --------------------------------------------------------
v8 = d12(2) - d12(1);
fprintf("\n  V8 romosozumab @12 mo, over control: %+.3f %%   (direction must be +; spine\n", v8);
fprintf("     magnitude 11-14 %% is trabecular and out of scope -- see C14)   pass=%d\n", v8 > 0);

% --- V9 self-limitation: the formation marker should roll over ON drug ---
B    = o{2}.get.B;
onDr = o{2}.t <= stopD;
[Bpk, iPk] = max(B(onDr));
rollover = iPk < sum(onDr) - 1;       % peak strictly inside the treatment window

% A rollover is the strong form.  Deceleration -- the rise flattening in the
% second half of the course -- is the weak form, and is what the marker data
% actually show most clearly, so report both.
half   = round(sum(onDr) / 2);
rise1  = B(half) - B(1);
rise2  = B(k12)  - B(half);
decel  = rise2 < rise1;

fprintf("  V9 self-limitation\n");
fprintf("     strong form (marker peaks before month 12): %d", rollover);
if ~rollover
    fprintf("   <- NOT reproduced: osteoblasts are still rising at month 12");
end
fprintf("\n");
fprintf("     weak form (rise decelerates): %d   first half %+.4f vs second half %+.4f\n", ...
        decel, rise1, rise2);
fprintf("     peak on-drug value %.3f x baseline at month %.1f\n", Bpk / B(1), o{2}.t(iPk) / 30);

% --- V10 withdrawal ------------------------------------------------------
v10 = d24(2) - d12(2);
fprintf("  V10 change over the 12-month washout: %+.3f %%   (spine reports a fall;\n", v10);
fprintf("      cortical section holds as the small gain matures -- documented limit)\n");

% --- V12 loading x drug interaction --------------------------------------
gainDrug = d24(2) - d24(1);
gainLoad = d24(3) - d24(1);
gainBoth = d24(4) - d24(1);
interaction = gainBoth - (gainDrug + gainLoad);
relDev = 100 * interaction / (gainDrug + gainLoad);
fprintf("\n  V12 loading x anabolic drug, at 24 months\n");
fprintf("      drug alone %+.3f, loading alone %+.3f, combined %+.3f %%\n", ...
        gainDrug, gainLoad, gainBoth);
fprintf("      strictly additive would be %+.3f, so interaction %+.3f %% points (%+.1f %% of additive)\n", ...
        gainDrug + gainLoad, interaction, relDev);
fprintf("      V12 asks for additive-or-synergistic with an anabolic.  The model gives\n");
fprintf("      SLIGHTLY SUB-additive (%.1f %% short): the two act through the same\n", -relDev);
fprintf("      SOST->Wnt node, so they partly compete for it.  Direction of the\n");
fprintf("      combination is still positive and much larger than either alone --\n");
fprintf("      the qualitative claim (unlike bisphosphonate) survives; strict\n");
fprintf("      additivity does not.\n");

% --- trabecular compartment: where V8/V10 actually live (P5d, C19) ------
q    = trabecularParams(p);
oTr  = simulate(sR, p = q);
oTrC = simulate(scenarioLibrary("sedentary", durationDays = nDays), p = q);
dTr  = pct(oTr.dens.aBMD); dTrC = pct(oTrC.dens.aBMD);
v8Tr  = dTr(k12) - dTrC(k12);
v10Tr = dTr(end) - dTr(k12);
amp   = v8Tr / v8;

fprintf("\n  --- trabecular compartment (P5d) ---\n");
fprintf("      V8  @12 mo   cortical %+.3f %%  ->  trabecular %+.3f %%   (%.1fx amplification)\n", ...
        v8, v8Tr, amp);
fprintf("      V10 washout  cortical %+.3f %%  ->  trabecular %+.3f %%\n", v10, v10Tr);
fprintf("      target V8 +11 to +14 %% is NOT reached, and BV/TV is not the lever\n");
fprintf("      (flat 4.33-4.59 %% across BV/TV 0.06-0.15).  The gap is delta_ab,\n");
fprintf("      whose value was fitted in P4 against the artefact-contaminated V8.\n");
fprintf("      See appendix C19.  valid: drug=%d control=%d\n", oTr.validity.ok, oTrC.validity.ok);

% --- figure -------------------------------------------------------------
fig = figure(Position = [100 100 1050 340], Color = "w");
tl  = tiledlayout(fig, 1, 3, TileSpacing = "compact", Padding = "compact");

nexttile(tl); hold on;
for k = 1:4
    plot(o{k}.t / 30, pct(o{k}.dens.aBMD), LineWidth = 1.8, ...
         Color = col.series(k,:));
end
xline(stopD / 30, "--", "drug stopped", Color = col.muted);
xlabel("months"); ylabel("\DeltaaBMD [%]");
legend(arms, Location = "northwest", Box = "off");
title("Four arms"); grid on; box off;

nexttile(tl);
plot(o{2}.t / 30, o{2}.get.B / o{2}.get.B(1), LineWidth = 1.8, Color = col.primary);
hold on;
xline(o{2}.t(iPk) / 30, ":", "peak", Color = col.accent);
xline(stopD / 30, "--", "drug stopped", Color = col.muted);
xlabel("months"); ylabel("osteoblasts / baseline");
title("V9: the anabolic effect self-limits"); grid on; box off;

nexttile(tl); hold on;
plot(oTr.t / 30, dTr, LineWidth = 1.8, Color = col.primary);
plot(o{2}.t / 30, pct(o{2}.dens.aBMD), LineWidth = 1.8, Color = col.muted);
fill([0 24 24 0], [11 11 14 14], col.accent, FaceAlpha = 0.15, EdgeColor = "none");
xline(stopD / 30, "--", Color = col.muted);
xlabel("months"); ylabel("\DeltaaBMD [%]");
legend(["trabecular" "cortical" "V8 target band"], Location = "northwest", Box = "off");
title(sprintf("V8: %.1fx amplification, target not reached", amp));
grid on; box off;

title(tl, "E4 -- romosozumab, withdrawal and loading", FontWeight = "bold");
exportFigure(fig, "E4_pharmacology");

save(fullfile(getResultsDir("E4_pharmacology"), "E4_pharmacology.mat"), ...
     "arms", "d12", "d24", "v8", "v10", "rollover", "decel", "Bpk", ...
     "gainDrug", "gainLoad", "gainBoth", "interaction", "relDev", ...
     "v8Tr", "v10Tr", "amp");
