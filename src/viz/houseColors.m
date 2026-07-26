function c = houseColors()
%HOUSECOLORS Project palette (PROJECT_PLAN §7.2).
%
%   C = HOUSECOLORS() returns a struct of RGB triples in [0,1]:
%     .primary  #028090   teal, the default series colour
%     .accent   #C1543A   rust, the contrast/comparison series
%     .muted    grey, for reference lines and literature bands
%     .ink      near-black, for text and axes
%     .series   (4,3) an ordered set for multi-series plots
%
%   Kept in one place so every figure in the paper matches without each
%   experiment script hard-coding hex strings.
%
%   See also EXPORTFIGURE.

%   Project: bone-mechanostat (PROJECT_PLAN v2.7)

c = struct();
c.primary = [0.008 0.502 0.565];    % #028090
c.accent  = [0.757 0.329 0.229];    % #C1543A
c.muted   = [0.60  0.62  0.64];
c.ink     = [0.13  0.14  0.15];
c.series  = [c.primary; c.accent; 0.35 0.45 0.62; 0.72 0.60 0.24];
end
