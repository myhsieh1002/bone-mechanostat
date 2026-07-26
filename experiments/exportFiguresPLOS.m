%EXPORTFIGURESPLOS Regenerate every paper figure as a PLOS-compliant TIFF.
%
%   Runs E0-E6 and writes <results>/figures_plos/FigN.tif meeting PLOS's
%   figure requirements:
%
%     - TIFF, LZW compression, 300 dpi
%     - width <= 2250 px (7.5 in), height <= 2625 px (8.75 in)
%     - all text >= 8 pt at final printed size
%
%   *** WHY REGENERATE RATHER THAN CONVERT THE PNGs ***
%   The PNGs are 2653-3054 px wide at 300 dpi, i.e. 8.8-10.2 inches -- all
%   wider than PLOS allows.  Downsampling them alone would shrink the printed
%   figure to 7.5 in and take the 9.5 pt text down to about 7.4 pt, under the
%   8 pt minimum.  Both the raster AND the font have to be handled together.
%
%   *** WHY NOT RESIZE THE CANVAS ***
%   The first attempt set the figure Position and iterated until the render
%   fitted.  That does not work: the map from canvas inches to rendered
%   pixels is quantised and non-monotone on this machine -- measured 6.50 in
%   -> 2986 px, 5.00 -> 1472, 4.00 -> 1481, 3.00 -> 898 -- because MATLAB
%   snaps figures to display-dependent sizes.  Iterating against a step
%   function did not converge, and one figure was written 18 % over the width
%   limit and reported as fine.
%
%   *** WHAT THIS DOES INSTEAD ***
%   Deterministic: one probe, no iteration.  Leave the canvas alone, measure
%   what it renders, then downscale the raster to fit while pre-compensating
%   the font so it lands at >= 8 pt AFTER the downscale:
%
%       s = min(2250/W, 2625/H, 1)      scale required to fit
%       F = 8/s                         font to set before export
%
%   At 300 dpi a point is 300/72 px, so text set to F pt and scaled by s ends
%   up at F*s = 8 pt in the final image -- which is 8 pt in print, since the
%   TIFF carries 300 dpi and is placed at (pixels/300) inches.
%
%   Project: bone-mechanostat (PROJECT_PLAN v2.12)

plosFontMin = 8;        % PLOS minimum text size, points
plosDPI     = 300;
plosMaxW    = 2250;     % px  (7.5 in)
plosMaxH    = 2625;     % px  (8.75 in)

plosJobs = ["E0_baseline"        "Fig1"
            "E1_doseResponse"    "Fig2"
            "E2_calciumLoading"  "Fig3"
            "E3_unloading"       "Fig4"
            "E4_pharmacology"    "Fig5"
            "E5_siteSpecificity" "Fig6"
            "E6_bifurcation"     "Fig7"];

plosOutDir = getResultsDir("figures_plos");
plosReport = strings(size(plosJobs, 1), 1);
plosProbe  = fullfile(tempdir, "plos_probe.tif");

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
fprintf("\n=== PLOS compliance summary ===\n%s\n", plosReport);
fprintf("\nAll compliant: %d\n", ~any(contains(plosReport, "false")));
