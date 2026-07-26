%E5_SITESPECIFICITY Two compartments, one shared calcium pool -- the test of P2.
%
%   P2 says a side-to-side bone difference can only be produced by LOCAL
%   loading, never by a systemic intervention, because the two sites share
%   one calcium/PTH pool but have their own mechanical dose.
%
%   The loaded arm is compared against Haapasalo 2000's pQCT measurements of
%   tennis players (V6a-f).  V6 is a HOLD-OUT: it was never in the
%   calibration objective, so everything here is prediction, not fit.  The
%   discriminating one is V6f -- the gain has to be GEOMETRIC, with
%   volumetric density essentially unchanged.
%
%   Two control arms are run, because "local loading works" is only half the
%   claim.  If a systemic intervention could also make the arms differ, P2
%   would be empty.
%
%   Writes:  <results>/E5_siteSpecificity/E5_siteSpecificity.mat
%            <results>/figures/E5_siteSpecificity.{png,pdf}
%
%   Project: bone-mechanostat (PROJECT_PLAN v2.7)

p   = getDefaultParams(reload = true);
col = houseColors();

% --- arm 1: unilateral loading ------------------------------------------
sTen = scenarioLibrary("tennis");            % 5 years, dominant side loaded
oTen = simulate(sTen, p = p);

% --- arms 2 and 3: systemic interventions, both sides loaded identically -
sCa  = sTen; sCa.boutsA = sTen.boutsB; sCa.bouts = sCa.boutsA; sCa.I_Ca = 1500;
oCa  = simulate(sCa, p = p);

sDrug = sTen; sDrug.boutsA = sTen.boutsB; sDrug.bouts = sDrug.boutsA;
sDrug.drug.romosozumab.startDay = 0; sDrug.drug.romosozumab.stopDay = 365;
oDrug = simulate(sDrug, p = p);

sideDiff = @(o, f) 100 * (o.dens.(f + "_A")(end) / o.dens.(f + "_B")(end) - 1);

% --- V6a-f against Haapasalo's bands ------------------------------------
metrics = ["BMC_L"     "Tot_Ar"   "Co_Ar"    "I_max"    "MCav_Ar"  "vBMD"];
labels  = ["BMC"       "Tot.Ar"   "Co.Ar"    "I_max"    "M.Cav"    "Co.Dn"];
vid     = ["V6a"       "V6b"      "V6c"      "V6d"      "V6e"      "V6f"];
lo      = [14          16         12         27         19         -2];
hi      = [27          21         32         67         19          0];
tol     = [10          10         10         15         10          2];

fprintf("\n=== E5: site specificity (tennis, 5 years) -- V6 is a HOLD-OUT ===\n");
fprintf("  %-4s %-8s %10s   %-16s  %s\n", "id", "metric", "model", "Haapasalo", "within tol");
model = nan(1, numel(metrics));
inTol = false(1, numel(metrics));
for k = 1:numel(metrics)
    model(k) = sideDiff(oTen, metrics(k));
    inTol(k) = model(k) >= lo(k) - tol(k) && model(k) <= hi(k) + tol(k);
    fprintf("  %-4s %-8s %+9.2f %%   %+5.0f to %+5.0f %%     %d\n", ...
            vid(k), labels(k), model(k), lo(k), hi(k), inTol(k));
end
fprintf("  V6 metrics within tolerance: %d of %d\n", sum(inTol), numel(inTol));
if ~inTol(5)
    fprintf("  ** V6e (marrow cavity) is the one that misses: Haapasalo found the\n");
    fprintf("     loaded arm's medullary cavity ALSO enlarged (+19 %%), i.e. periosteal\n");
    fprintf("     apposition outran endocortical change.  The model instead contracts\n");
    fprintf("     the cavity (%+.2f %%), so it reproduces the outward drift but not the\n", model(5));
    fprintf("     endocortical resorption that should accompany it.  M7's r_e response\n");
    fprintf("     to loading is the gap; the geometric claim (V6b-d) is unaffected. **\n");
end

% --- P2: only the local intervention can make the sides differ ----------
asymLoad = sideDiff(oTen,  "BMC_L");
asymCa   = sideDiff(oCa,   "BMC_L");
asymDrug = sideDiff(oDrug, "BMC_L");

fprintf("\n  P2 -- side-to-side BMC difference by intervention type\n");
fprintf("      unilateral LOADING          %+8.4f %%\n", asymLoad);
fprintf("      systemic calcium 1500 mg    %+8.4f %%\n", asymCa);
fprintf("      systemic romosozumab        %+8.4f %%\n", asymDrug);
passP2 = asymLoad > 3 && abs(asymCa) < 0.05 && abs(asymDrug) < 0.05;
fprintf("      P2 holds (local yes, systemic no): %d\n", passP2);
fprintf("      validity: tennis=%d calcium=%d drug=%d\n", ...
        oTen.validity.ok, oCa.validity.ok, oDrug.validity.ok);

% --- figure -------------------------------------------------------------
fig = figure(Position = [100 100 980 360], Color = "w");
tl  = tiledlayout(fig, 1, 2, TileSpacing = "compact", Padding = "compact");

nexttile(tl); hold on;
for k = 1:numel(metrics)
    fill([k-0.35 k+0.35 k+0.35 k-0.35], [lo(k) lo(k) hi(k) hi(k)], col.muted, ...
         FaceAlpha = 0.30, EdgeColor = "none");
end
bar(model, 0.45, FaceColor = col.primary, EdgeColor = "none");
yline(0, "-", Color = col.ink);
xticks(1:numel(metrics)); xticklabels(labels); xtickangle(30);
ylabel("loaded vs contralateral [%]");
title("V6 hold-out vs Haapasalo (grey = literature band)"); box off; grid on;

nexttile(tl);
bar([asymLoad asymCa asymDrug], 0.5, FaceColor = col.primary, EdgeColor = "none");
xticklabels(["unilateral" "calcium" "romosozumab"]); xtickangle(20);
ylabel("side-to-side \DeltaBMC [%]");
title("P2: only local loading makes sides differ"); box off; grid on;

title(tl, "E5 -- site specificity", FontWeight = "bold");
exportFigure(fig, "E5_siteSpecificity");

save(fullfile(getResultsDir("E5_siteSpecificity"), "E5_siteSpecificity.mat"), ...
     "metrics", "labels", "vid", "lo", "hi", "tol", "model", "inTol", ...
     "asymLoad", "asymCa", "asymDrug", "passP2");
