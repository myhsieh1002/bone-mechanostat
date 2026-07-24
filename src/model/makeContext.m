function ctx = makeContext(scenario, p, opts)
%MAKECONTEXT Precompute everything RHSFULL needs, once per simulation.
%
%   CTX = MAKECONTEXT(SCENARIO, P) builds the dose surrogate, resolves the
%   representative bout, and records the baseline dose used to
%   non-dimensionalise the mechanical signal.
%
%   Building the dose surrogate costs a few hundred day-integrations of the
%   channel model.  Doing that inside the ODE right-hand side -- which
%   ODE15S calls thousands of times -- would be catastrophic, and doing it
%   with a PERSISTENT cache would silently pin every E6 sample to the first
%   parameter set seen.  Hence an explicit context object.
%
%   Inputs
%     scenario      (1,1) struct  from SCENARIOLIBRARY
%     p             (1,1) struct  parameters
%     opts.tauGrid  (1,:) double  dose surrogate grid                  [Pa]
%
%   Output
%     ctx  (1,1) struct  .p .scenario .idx .peakBout .doseSurrogate
%                        .D_eff_0 .tau_0 .eps_0
%
%   See also RHSFULL, SIMULATE, BUILDDOSESURROGATE.

%   Project: bone-mechanostat (PROJECT_PLAN v1.6)

arguments
    scenario (1,1) struct
    p (1,1) struct
    opts.tauGrid (1,:) double = 0:0.25:15
end

info = stateVector("single");

[~, iPeak] = max([scenario.bouts.momentScale]);

ctx = struct();
ctx.p          = p;
ctx.scenario   = scenario;
ctx.idx        = info.idx;
ctx.peakBout   = scenario.bouts(iPeak);
ctx.doseSurrogate = buildDoseSurrogate(scenario.bouts, p, ...
                                       tauGrid = opts.tauGrid, ...
                                       label = scenario.name);

% --- reference dose ------------------------------------------------------
% *** This MUST be a fixed canonical scenario, not the one being run. ***
% Normalising to the current scenario's own baseline dose sets
% D_eff_hat = 1 for every protocol, so a resistance-training run and a bed-
% rest run would both start -- and stay -- at the same signalling state,
% and no intervention could ever differ from any other.  That bug produced
% identical bone responses for 36 and 1200 cycles before it was caught.
%
% The reference is sedentary loading at the unadapted geometry: the state
% at which the M4-M6 cascade is DEFINED to sit at 1.
ref = scenarioLibrary("sedentary");
[~, iRef] = max([ref.bouts.momentScale]);
refBout = ref.bouts(iRef);

st0 = struct(r_p = p.r_p_0, r_e = p.r_e_0, ...
             f_bm = p.f_bm_0, rho_min = p.rho_min_0);

refSurrogate = buildDoseSurrogate(ref.bouts, p, ...
                                  tauGrid = opts.tauGrid, label = "reference");
mRef  = organMechanics(refBout, st0, p);
tauRef = shearSurrogate(mRef.eps_p, refBout.freqHz, p);

ctx.D_eff_0 = loadingDose(tauRef, refSurrogate, p.n_ot_0, p);
ctx.eps_ref = mRef.eps_p;
ctx.tau_ref = tauRef;

% This scenario's own starting values, for diagnostics only.
m0 = organMechanics(ctx.peakBout, st0, p);
ctx.eps_0 = m0.eps_p;
ctx.tau_0 = shearSurrogate(m0.eps_p, ctx.peakBout.freqHz, p);
end
