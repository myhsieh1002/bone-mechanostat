function out = simulate(scenario, opts)
%SIMULATE Unified entry point: run a scenario and return time series.
%
%   OUT = SIMULATE(SCENARIO) integrates the model over SCENARIO.durationDays
%   with ODE15S and returns a time-series struct.  SCENARIO comes from
%   SCENARIOLIBRARY (or is a struct of the same shape).
%
%   OUT = SIMULATE(SCENARIO, p = P, y0 = Y0, ...) overrides parameters,
%   initial condition and solver settings.
%
%   Solver settings follow PROJECT_PLAN §7.1: RelTol 1e-6, AbsTol 1e-9,
%   NonNegative on every state.  ODE23S is available as a fallback for the
%   stiff regimes expected once M2-M8 are live.
%
%   Inputs
%     scenario        (1,1) struct
%     opts.p          (1,1) struct  parameters.  Default GETDEFAULTPARAMS()
%     opts.y0         (:,1) double  initial state. Default BASELINESTATE
%     opts.outputDays (1,:) double  times to report [day].  Default daily
%     opts.solver     (1,1) string  "ode15s" (default) or "ode23s"
%     opts.relTol     (1,1) double  default 1e-6
%     opts.absTol     (1,1) double  default 1e-9
%
%   Output
%     out  (1,1) struct with fields
%       t          (n,1) double  time                                 [day]
%       y          (n,m) double  states, columns per STATEVECTOR
%       names      (1,m) string  state names
%       units      (1,m) string  state units
%       get        (1,1) struct  name -> column vector, e.g. out.get.f_bm
%       dens       (1,1) struct  DENSITOMETRY outputs along the trajectory
%       scenario   (1,1) struct  the scenario as run
%       p          (1,1) struct  the parameters as run
%       solverStats(1,1) struct  nsteps / nfailed / nfevals
%
%   Example
%     s   = scenarioLibrary("sedentary", durationDays = 730);
%     out = simulate(s);
%     plot(out.t / 365, out.dens.aBMD); xlabel("years"); ylabel("aBMD");
%
%   See also SCENARIOLIBRARY, RHSFULL, STATEVECTOR, DENSITOMETRY.

%   Project: bone-mechanostat (PROJECT_PLAN v1.4)

arguments
    scenario (1,1) struct
    opts.p (1,1) struct = getDefaultParams()
    opts.y0 (:,1) double = double.empty(0,1)
    opts.outputDays (1,:) double = double.empty(1,0)
    opts.solver (1,1) string {mustBeMember(opts.solver, ["ode15s" "ode23s"])} = "ode15s"
    opts.relTol (1,1) double {mustBePositive} = 1e-6
    opts.absTol (1,1) double {mustBePositive} = 1e-9
end

p = opts.p;

mode = "single";
if isfield(scenario, "sites") && scenario.sites == "two"
    mode = "two";
end
info = stateVector(mode);

if isempty(opts.y0)
    y0 = baselineState(mode, p);
else
    y0 = opts.y0;
end
if numel(y0) ~= info.n
    error("boneMechanostat:badInitialState", ...
          "Initial state has %d elements, expected %d.", numel(y0), info.n);
end

if isempty(opts.outputDays)
    tspan = 0:1:scenario.durationDays;
else
    tspan = opts.outputDays;
end

switch mode
    case "single"
        rhs = @(t, y) rhsFull(t, y, scenario, p);
    case "two"
        rhs = @(t, y) rhsTwoSite(t, y, scenario, p);
end

odeOpts = odeset(RelTol = opts.relTol, AbsTol = opts.absTol, ...
                 NonNegative = find(info.nonNegative));

solverFcn = str2func(opts.solver);
sol = solverFcn(rhs, [tspan(1) tspan(end)], y0, odeOpts);

t = tspan(:);
y = deval(sol, t).';

out = struct();
out.t        = t;
out.y        = y;
out.names    = info.names;
out.units    = info.units;
out.scenario = scenario;
out.p        = p;

out.get = struct();
for k = 1:info.n
    out.get.(matlab.lang.makeValidName(info.names(k))) = y(:, k);
end

out.dens = localDensitometry(out, info, p, mode);

out.solverStats = struct(nsteps = sol.stats.nsteps, ...
                         nfailed = sol.stats.nfailed, ...
                         nfevals = sol.stats.nfevals);
end

% -------------------------------------------------------------------------
function dens = localDensitometry(out, info, p, mode)
%LOCALDENSITOMETRY Evaluate DENSITOMETRY along the trajectory.
switch mode
    case "single"
        suffixes = "";
    case "two"
        suffixes = ["_A" "_B"];
end

dens = struct();
for s = suffixes
    ix = info.idx;
    f_bm = out.y(:, ix.(matlab.lang.makeValidName("f_bm" + s)));
    m1   = out.y(:, ix.(matlab.lang.makeValidName("m1" + s)));
    m2   = out.y(:, ix.(matlab.lang.makeValidName("m2" + s)));
    r_p  = out.y(:, ix.(matlab.lang.makeValidName("r_p" + s)));
    r_e  = out.y(:, ix.(matlab.lang.makeValidName("r_e" + s)));

    rho = (m1 + m2) ./ max(f_bm, p.f_bm_min);
    d = densitometry(r_p, r_e, f_bm, rho, p);

    fn = string(fieldnames(d));
    for k = 1:numel(fn)
        dens.(matlab.lang.makeValidName(fn(k) + s)) = d.(fn(k));
    end
end
end
