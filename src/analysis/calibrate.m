function out = calibrate(opts)
%CALIBRATE Fit a few free parameters to the non-hold-out validation targets.
%
%   OUT = CALIBRATE() runs the P4 calibration pass: it opens a SHORT list
%   of free parameters and fits them to V1, V2, V7 (+ plateau) and V8,
%   holding k_form derived from bone balance throughout.  The hold-out
%   targets (V6, V10, V14) are evaluated blindly AFTER the fit and never
%   enter the objective (PROJECT_PLAN §9).
%
%   Free parameters (6, at the top of §9's 4-6 budget):
%     k_res      turnover magnitude              -> V1 (k_form derived)
%     K_S        SOST mechanical sensitivity     -> V2 disuse violence
%     K_P_sost   PTH -> SOST strength            -> V7 sign/magnitude
%     lambda_P   PTH -> RANKL strength           -> V7 (works with K_P_sost)
%     delta_ab   romosozumab clearance           -> V8
%     sost_reb   SOST rebound plateau            -> V16 (pairs with delta_ab)
%
%   Optimiser: SURROGATEOPT (Global Optimization Toolbox) -- derivative-
%   free, robust to the flat-bottomed banded objective, and it tolerates
%   the occasional failed simulation.  rng(20260722) for reproducibility
%   (§7.1).  The pool is capped at 3 workers (§7.3, shared machine).
%
%   Inputs
%     opts.maxEval (1,1) double  surrogateopt evaluations.  Default 200
%     opts.useParallel (1,1) logical  Default false
%     opts.save    (1,1) logical  write result to getResultsDir.  Default false
%
%   Output
%     out  (1,1) struct  .pFit (calibrated params), .freeNames, .xFit,
%                        .targets (evalTargets at pFit, incl. hold-out),
%                        .fval, .exitflag
%
%   See also EVALTARGETS, BALANCEBONEFORMATION, IDENTIFIABILITY.

%   Project: bone-mechanostat (PROJECT_PLAN v1.9)

arguments
    opts.maxEval (1,1) double = 200
    opts.useParallel (1,1) logical = false
    opts.save (1,1) logical = false
end

rng(20260722, "twister");

p0 = getDefaultParams();

freeNames = ["k_res" "K_S" "K_P_sost" "lambda_P" "delta_ab" "sost_reb"];
lb = [1e-8, 0.1,  1.0,  0.5,  0.02, 0.0];
ub = [1e-6, 5.0,  100,  10,   2.0,  3.0];
% Start from the incumbent parameter set, which is inside the feasible
% region for most bands, so the surrogate only polishes.  sost_reb joined
% the free list at v2.14: it was fitted by hand in P5h, but V16 sits in
% the objective, so leaving it fixed made delta_ab carry two targets.
x0 = [p0.k_res, p0.K_S, p0.K_P_sost, p0.lambda_P, p0.delta_ab, p0.sost_reb];

objfun = @(x) localObjective(x, freeNames, p0);

soOpts = optimoptions("surrogateopt", ...
    MaxFunctionEvaluations = opts.maxEval, ...
    InitialPoints = x0, ...
    UseParallel = opts.useParallel, ...
    Display = "iter", ...
    PlotFcn = []);

[xFit, fval, exitflag] = surrogateopt(objfun, lb, ub, soOpts);

pFit = localApply(xFit, freeNames, p0);
pFit.k_form = balanceBoneFormation(pFit);

out = struct();
out.freeNames = freeNames;
out.xFit      = xFit;
out.pFit      = pFit;
out.fval      = fval;
out.exitflag  = exitflag;
out.targets   = evalTargets(pFit, holdout = true);

if opts.save
    outFile = fullfile(getResultsDir("calibration"), "calibrate_result.mat");
    save(outFile, "out");
    fprintf("Saved: %s\n", outFile);
end
end

% -------------------------------------------------------------------------
function f = localObjective(x, names, p0)
p = localApply(x, names, p0);
try
    p.k_form = balanceBoneFormation(p);
    r = evalTargets(p, years = 1.5);
    f = r.resid.V1^2 + r.resid.V2^2 + 2*r.resid.V7^2 ...
        + r.resid.V7slope^2 + r.resid.V8^2;
catch
    f = 1e6;                     % penalise parameter sets that fail to run
end
if ~isfinite(f)
    f = 1e6;
end
end

% -------------------------------------------------------------------------
function p = localApply(x, names, p0)
p = p0;
for k = 1:numel(names)
    p.(names(k)) = x(k);
end
end
