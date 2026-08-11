% exportFiguresBMMB  Export the seven paper figures to Biomechanics and
%   Modeling in Mechanobiology specification.
%
%   Identical in method to exportFiguresPLOS -- see that file for why the
%   font is pre-compensated before downscaling rather than after.  Only the
%   canvas limits differ, and they are the binding difference: BMMB allows
%   174 mm for a single-column text area (PLOS allowed 190 mm), so figures
%   exported for PLOS are 16 mm too wide and would be rejected at the
%   technical check.  Height is capped at 234 mm.
%
%       174 mm = 6.8504 in -> 2055 px at 300 dpi
%       234 mm = 9.2126 in -> 2763 px at 300 dpi
%
%   Because the font is set to plosFontMin/scale before the raster is
%   downscaled, the narrower canvas costs no legibility: text still lands at
%   8 pt in print, inside the 8-12 pt BMMB asks for.
%
%   Project: bone-mechanostat (PROJECT_PLAN v2.25)

plosFontMin = 8;        % PLOS minimum text size, points
plosDPI     = 300;
plosMaxW    = 2055;     % px  (174 mm, BMMB single-column text area)
plosMaxH    = 2763;     % px  (234 mm)

plosJobs = ["E0_baseline"        "Fig1"
            "E1_doseResponse"    "Fig2"
            "E2_calciumLoading"  "Fig3"
            "E3_unloading"       "Fig4"
            "E4_pharmacology"    "Fig5"
            "E5_siteSpecificity" "Fig6"
            "E6_bifurcation"     "Fig7"];

plosOutDir = getResultsDir("figures_bmmb");
plosReport = strings(size(plosJobs, 1), 1);
plosProbe  = fullfile(tempdir, "bmmb_probe.tif");

for plosK = 1:size(plosJobs, 1)
    plosFig = runExperimentFigure(plosJobs(plosK, 1));
    plosOut = fullfile(plosOutDir, plosJobs(plosK, 2) + ".tif");

    % 1. Probe: what does this canvas actually render to?
    exportgraphics(plosFig, plosProbe, Resolution = plosDPI);
    plosNative = imfinfo(plosProbe);

    % 2. Scale needed to fit, and the font that survives it.
    plosScale = min([plosMaxW / plosNative.Width, ...
                     plosMaxH / plosNative.Height, 1]);
    plosFont  = plosFontMin / plosScale;

    % 3. Re-export with the compensating font, then downscale the raster.
    fontsize(plosFig, plosFont, "points");
    exportgraphics(plosFig, plosProbe, Resolution = plosDPI);
    plosImg = imread(plosProbe);

    % Resize to an EXPLICIT target size clamped to the limits, not by a
    % scale factor: IMRESIZE rounds the output up, which put two figures
    % 10-13 px over the width limit -- compliant to the eye, rejected by the
    % checker.  Recompute from the actual image too, since the second export
    % need not match the probe exactly.
    [plosH, plosWpx, ~] = size(plosImg);
    plosScale = min([plosMaxW / plosWpx, plosMaxH / plosH, 1]);
    if plosScale < 1
        plosTarget = [min(floor(plosH * plosScale), plosMaxH), ...
                      min(floor(plosWpx * plosScale), plosMaxW)];
        plosImg = imresize(plosImg, plosTarget, "lanczos3");
    end
    imwrite(plosImg, plosOut, Compression = "lzw", Resolution = plosDPI);

    plosInfo = imfinfo(plosOut);
    plosOK = plosInfo.Width <= plosMaxW && plosInfo.Height <= plosMaxH ...
             && plosInfo.XResolution >= plosDPI;
    plosReport(plosK) = sprintf("  %-5s %5d x %4d px  %4.2f x %4.2f in  %5.2f MB  %s  font %4.1f -> %.1f pt  %s", ...
        plosJobs(plosK, 2), plosInfo.Width, plosInfo.Height, ...
        plosInfo.Width / plosDPI, plosInfo.Height / plosDPI, ...
        dir(plosOut).bytes / 1e6, plosInfo.Compression, ...
        plosFont, plosFont * plosScale, string(plosOK));
end

close all force;
fprintf("\n=== BMMB compliance summary ===\n%s\n", plosReport);
fprintf("\nAll compliant: %d\n", ~any(contains(plosReport, "false")));
