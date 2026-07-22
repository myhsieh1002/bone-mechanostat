function files = exportFigure(fig, name, opts)
%EXPORTFIGURE Save a figure in the project house style.
%
%   House style (PROJECT_PLAN §7.2): primary #028090, accent #C1543A;
%   Microsoft JhengHei for Chinese, Helvetica for English; 300 dpi PNG plus
%   vector PDF, A4-friendly.
%
%   Output goes to GETRESULTSDIR("figures") -- local disk, not iCloud.
%
%   Inputs
%     fig  (1,1) matlab.ui.Figure
%     name (1,1) string  base filename, no extension
%     opts .width_mm, .height_mm, .dpi, .formats
%   Output
%     files (1,:) string  written file paths
%
%   *** NOT IMPLEMENTED -- scheduled for phase P2 (viz) ***
%
%   Project: bone-mechanostat (PROJECT_PLAN v1.4)

error("boneMechanostat:notImplemented", ...
      "exportFigure is a phase-P2 deliverable (viz) and is not implemented yet.");
end
