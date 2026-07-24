function surrogate = buildDoseSurrogate(bouts, p, opts)
%BUILDDOSESURROGATE M3 -- offline map from peak shear to daily dose.
%
%   SURROGATE = BUILDDOSESURROGATE(BOUTS, P) builds a 1-D interpolant
%
%       D_mech(tauScale) = int_day O(t) dt                            [s]
%
%   for one fixed bout structure, where TAUSCALE is the peak shear a bout
%   of unit momentScale would produce.
%
%   *** WHY THIS IS NEEDED (introduced by the v1.3 closed loop) ***
%   Before v1.3, tau was constant for a given scenario, so the daily dose
%   could be computed once.  Now geometry adapts, tau drifts, and the dose
%   must follow -- but a day resolved at 1 Hz inside the ODE15S right-hand
%   side, over several thousand simulated days, is not affordable.  Sweep
%   offline, interpolate online.
%
%   The map is nonlinear in TAUSCALE (the k_co sigmoid), so it genuinely
%   needs a grid; it is exactly linear in nothing, and dose is NOT
%   proportional to shear.
%
%   Inputs
%     bouts        (1,:) struct  bout structure (held fixed)
%     p            (1,1) struct  parameters
%     opts.tauGrid (1,:) double  shear grid.  Default 0:0.25:12        [Pa]
%     opts.save    (1,1) logical write to getResultsDir.  Default false
%     opts.label   (1,1) string  name used when saving.  Default "scenario"
%
%   Output
%     surrogate  (1,1) struct  .F griddedInterpolant, .tauGrid, .dose,
%                              .doseBaseline (tau = 0), .bouts, .label
%
%   Example
%     s = scenarioLibrary("resistance");
%     sg = buildDoseSurrogate(s.bouts, getDefaultParams());
%     D = sg.F(2.5);
%
%   See also DAILYDOSE, LOADINGDOSE, MSICCYCLEOPERATOR.

%   Project: bone-mechanostat (PROJECT_PLAN v1.5)

arguments
    bouts (1,:) struct
    p (1,1) struct
    opts.tauGrid (1,:) double = 0:0.25:12
    opts.save (1,1) logical = false
    opts.label (1,1) string = "scenario"
end

tauGrid = sort(unique(opts.tauGrid));
dose    = zeros(size(tauGrid));

for k = 1:numel(tauGrid)
    dose(k) = dailyDose(bouts, tauGrid(k), p);
end

surrogate = struct();
surrogate.tauGrid      = tauGrid;
surrogate.dose         = dose;
surrogate.doseBaseline = dailyDose(bouts, 0, p);
surrogate.bouts        = bouts;
surrogate.label        = opts.label;
surrogate.F = griddedInterpolant(tauGrid, dose, "pchip", "linear");

if opts.save
    outFile = fullfile(getResultsDir("surrogates"), ...
                       "doseSurrogate_" + opts.label + ".mat");
    save(outFile, "surrogate");
    fprintf("Saved: %s\n", outFile);
end
end
