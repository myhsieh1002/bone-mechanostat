function fig = plotDoseSurface(res, opts)
%PLOTDOSESURFACE Plot the E1 mechanical dose-response surface.
%
%   Shows the 24-month response over (strain amplitude x frequency x cycle
%   number x rest insertion).  Must visibly reproduce the 36-cycle saturation
%   (V4) and the conditional rest-insertion gain (V5).
%
%   Inputs
%     res  (1,1) struct  E1 sweep results
%     opts .sliceBy, .colormap
%   Output
%     fig  (1,1) matlab.ui.Figure
%
%   *** NOT IMPLEMENTED -- scheduled for phase P5 (viz) ***
%
%   Project: bone-mechanostat (PROJECT_PLAN v1.4)

error("boneMechanostat:notImplemented", ...
      "plotDoseSurface is a phase-P5 deliverable (viz) and is not implemented yet.");
end
