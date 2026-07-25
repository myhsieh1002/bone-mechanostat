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

% --- memoisation --------------------------------------------------------
% The dose surrogate depends ONLY on the shear (M2) and channel (M3)
% parameters plus the bout structure -- NOT on any downstream biology
% (k_res, K_S, K_P_sost, ...).  During calibration and identifiability
% those M2/M3 params never change, so rebuilding the surrogate hundreds of
% times is pure waste.  Key the cache on the actual values it reads, so it
% rebuilds the moment any of them changes (no stale-cache hazard).
tauGrid = sort(unique(opts.tauGrid));
key = localCacheKey(bouts, tauGrid, p);

% Small multi-slot MRU cache: distinct scenarios present different bout
% structures within one evalTargets call (adl vs bedrest), so a single slot
% would thrash.  8 slots comfortably covers every scenario in play.
persistent cacheKeys cacheVals
if isempty(cacheKeys)
    cacheKeys = {};
    cacheVals = {};
end
for c = 1:numel(cacheKeys)
    if isequal(cacheKeys{c}, key)
        surrogate = cacheVals{c};
        return
    end
end

dose = zeros(size(tauGrid));
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

cacheKeys{end+1} = key;
cacheVals{end+1} = surrogate;
if numel(cacheKeys) > 8       % drop oldest
    cacheKeys(1) = [];
    cacheVals(1) = [];
end

if opts.save
    outFile = fullfile(getResultsDir("surrogates"), ...
                       "doseSurrogate_" + opts.label + ".mat");
    save(outFile, "surrogate");
    fprintf("Saved: %s\n", outFile);
end
end

% -------------------------------------------------------------------------
function key = localCacheKey(bouts, tauGrid, p)
%LOCALCACHEKEY Fingerprint of everything the dose surrogate depends on.
%   Only the M2 shear params, M3 channel params, and the bout structure.
mech = [p.K_tau, p.k_perm, p.mu_fluid, p.S_stor, p.L_poro, p.f_0, ...
        p.tau_50, p.k_tau_sig, p.k_co_max, p.k_oc, p.k_oi, p.k_ic, p.T_day];
boutVec = zeros(1, 6 * numel(bouts));
for k = 1:numel(bouts)
    b = bouts(k);
    boutVec(6*k-5 : 6*k) = [b.momentScale, b.axialScale, b.nCycles, ...
                            b.freqHz, b.restWithinSec, b.restAfterSec];
end
key = [mech, boutVec, tauGrid];
end
