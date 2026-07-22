function surrogate = buildDoseSurrogate(bouts, p, opts)
%BUILDDOSESURROGATE M3 -- offline map from peak shear to daily osteogenic dose.
%
%   Builds a 1-D interpolant  D_mech(tauhat_max)  for one fixed bout
%   structure, by integrating MSICGATING over a simulated day:
%
%     D_mech = int_day O(t) dt                                    [s]
%
%   *** Why this is needed (introduced by the v1.3 closed loop) ***
%   Before v1.3, tauhat was constant for a given scenario, so the daily dose
%   could be computed once.  Now geometry adapts, tauhat drifts, and the dose
%   must follow -- but a seconds-resolution day integrated inside the ODE15S
%   right-hand side over several thousand simulated days is not affordable.
%   Hence: sweep offline, interpolate online.
%
%   Inputs
%     bouts (1,:) struct  scenario bout structure (fixed)
%     p     (1,1) struct  parameters
%     opts  .tauGrid [Pa], .save (logical)
%   Output
%     surrogate (1,1) struct  griddedInterpolant + provenance
%
%   *** NOT IMPLEMENTED -- scheduled for phase P2 (M3) ***
%
%   Project: bone-mechanostat (PROJECT_PLAN v1.4)

error("boneMechanostat:notImplemented", ...
      "buildDoseSurrogate is a phase-P2 deliverable (M3) and is not implemented yet.");
end
