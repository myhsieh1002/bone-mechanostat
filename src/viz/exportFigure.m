function files = exportFigure(fig, name, opts)
%EXPORTFIGURE Save a figure in the project house style (PROJECT_PLAN §7.2).
%
%   FILES = EXPORTFIGURE(FIG, NAME) writes NAME.png (300 dpi) and NAME.pdf
%   (vector) into getResultsDir("figures") -- local disk, not iCloud.
%
%   House style: primary #028090, accent #C1543A; 300 dpi PNG + vector PDF,
%   A4-friendly.  Fonts are left to the figure (Helvetica / Microsoft
%   JhengHei set by the caller when Chinese labels are present).
%
%   Inputs
%     fig          (1,1) matlab.ui.Figure
%     name         (1,1) string   base filename, no extension
%     opts.dpi     (1,1) double    Default 300
%     opts.formats (1,:) string    Default ["png" "pdf"]
%
%   Output
%     files  (1,:) string  written paths
%
%   See also GETRESULTSDIR.

%   Project: bone-mechanostat (PROJECT_PLAN v2.0)

arguments
    fig (1,1) matlab.ui.Figure
    name (1,1) string
    opts.dpi (1,1) double = 300
    opts.formats (1,:) string = ["png" "pdf"]
end

dir = getResultsDir("figures");
files = strings(1, numel(opts.formats));
for k = 1:numel(opts.formats)
    f = fullfile(dir, name + "." + opts.formats(k));
    exportgraphics(fig, f, Resolution = opts.dpi);
    files(k) = f;
end
fprintf("Saved figure: %s\n", strjoin(files, ", "));
end
