function ctx = makeContextTwoSite(scenario, p, opts)
%MAKECONTEXTTWOSITE Precompute context for the two-compartment model.
%
%   CTX = MAKECONTEXTTWOSITE(SCENARIO, P) builds the per-site dose
%   surrogates for site A (loaded, e.g. dominant humerus) and site B
%   (contralateral), which receive DIFFERENT bout structures (scenario
%   .boutsA / .boutsB) but share one systemic calcium pool.
%
%   The reference dose (for non-dimensionalising each site's mechanical
%   signal) is the SAME fixed sedentary scenario for both sites, so the two
%   compartments are compared on one scale -- any asymmetry then comes from
%   the different LOADING, not from a per-site normalisation.
%
%   Inputs
%     scenario      (1,1) struct  two-site scenario (.boutsA, .boutsB, E2,
%                                 I_Ca, drug); .sites == "two"
%     p             (1,1) struct  parameters
%     opts.tauGrid  (1,:) double  dose surrogate grid                   [Pa]
%
%   Output
%     ctx  (1,1) struct  .p .scenario .idx (two-site) .A .B (per-site
%                        contexts: peakBout, doseSurrogate, D_eff_0)
%
%   See also RHSTWOSITE, MAKECONTEXT, SITERHS.

%   Project: bone-mechanostat (PROJECT_PLAN v2.1)

arguments
    scenario (1,1) struct
    p (1,1) struct
    opts.tauGrid (1,:) double = 0:0.25:15
end

if ~isfield(scenario, "boutsA") || ~isfield(scenario, "boutsB")
    error("boneMechanostat:notTwoSite", ...
          "Two-site scenario needs boutsA and boutsB.");
end

info = stateVector("two");

% Shared reference: sedentary at the unadapted geometry (same for A and B).
ref = scenarioLibrary("sedentary");
[~, iRef] = max([ref.bouts.momentScale]);
refBout = ref.bouts(iRef);
st0 = struct(r_p = p.r_p_0, r_e = p.r_e_0, ...
             f_bm = p.f_bm_0, rho_min = p.rho_min_0);
refSurr = buildDoseSurrogate(ref.bouts, p, tauGrid = opts.tauGrid, label = "reference");
tauRef  = shearSurrogate(organMechanics(refBout, st0, p).eps_p, refBout.freqHz, p);
D_eff_0 = loadingDose(tauRef, refSurr, p.n_ot_0, p);

ctx = struct();
ctx.p        = p;
ctx.scenario = scenario;
ctx.idx      = info.idx;
ctx.A = localSiteContext(scenario.boutsA, p, opts.tauGrid, D_eff_0, "siteA");
ctx.B = localSiteContext(scenario.boutsB, p, opts.tauGrid, D_eff_0, "siteB");
end

% -------------------------------------------------------------------------
function sc = localSiteContext(bouts, p, tauGrid, D_eff_0, label)
[~, iPeak] = max([bouts.momentScale]);
sc = struct();
sc.peakBout      = bouts(iPeak);
sc.doseSurrogate = buildDoseSurrogate(bouts, p, tauGrid = tauGrid, label = label);
sc.D_eff_0       = D_eff_0;
end
