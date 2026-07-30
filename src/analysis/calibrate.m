function out = calibrate(opts)
%CALIBRATE Fit a few free parameters to the non-hold-out validation targets.
%
%   OUT = CALIBRATE() runs the P4 calibration pass: it opens a SHORT list
%   of free parameters and fits them to V1, V2, V7 (+ plateau) and V8,
%   holding k_form derived from bone balance throughout.  The hold-out
%   targets (V6, V10, V14) are evaluated blindly AFTER the fit and never
%   enter the objective (PROJECT_PLAN §9).
%
%   Free parameters (5, inside §9's 4-6 budget):
%     k_res      turnover magnitude              -> V1 (k_form derived)
%     K_S        SOST mechanical sensitivity     -> V2 disuse violence
%     K_P_sost   PTH -> SOST strength            -> V7 sign/magnitude
%     lambda_P   PTH -> RANKL strength           -> V7 (works with K_P_sost)
%     delta_ab   romosozumab clearance           -> V8
%
%   k_ot and k_form are DERIVED at every trial point, not fitted: both are
%   determined by the baseline state (OSTEOCYTEBURIALRATE, appendix C34, and
%   BALANCEBONEFORMATION).  k_res moves both, so re-deriving inside the
%   objective is not optional -- leaving k_ot behind is what produced the
%   514-fold osteocyte/bone turnover contradiction in the first place.
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

freeNames = ["k_res" "K_S" "K_P_sost" "lambda_P" "delta_ab"];
lb = [1e-8, 0.1,  1.0,  0.5,  0.02];
ub = [1e-6, 5.0,  100,  10,   2.0];
% Start from the incumbent parameter set, which is inside the feasible
% region for most bands, so the surrogate only polishes.
%
% sost_reb was on this list from v2.14 to v2.23 and is OFF it again at
% v2.24 (appendix C35).  It was added because V16 was said to be in the
% objective and would identify it; V16 was never actually in the objective,
% and measuring the leverage showed it could not have identified it anyway
% -- sost_reb moves V16 by 0.04 over its whole range while moving V8 from
% 63.6 to 0.47.  It is a second V8 parameter, degenerate with delta_ab
% along the V8 ridge, and nothing in the target set separates them.  Two
% parameters on one target is the unidentifiable degree of freedom that
% section 9 risk 1 exists to prevent, so sost_reb stays at its P5h value
% and delta_ab carries V8 alone.
x0 = [p0.k_res, p0.K_S, p0.K_P_sost, p0.lambda_P, p0.delta_ab];

objfun = @(x) localObjective(x, freeNames, p0);

soOpts = optimoptions("surrogateopt", ...
    MaxFunctionEvaluations = opts.maxEval, ...
    InitialPoints = x0, ...
    UseParallel = opts.useParallel, ...
    Display = "iter", ...
    PlotFcn = []);

[xFit, fval, exitflag] = surrogateopt(objfun, lb, ub, soOpts);

pFit = localApply(xFit, freeNames, p0);
pFit.k_ot   = osteocyteBurialRate(pFit);
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
    % k_ot and k_form are both DETERMINED by the baseline state, so they
    % must be re-derived at every trial point -- otherwise k_res moves the
    % bone turnover while the osteocyte turnover stays behind (C34).
    p.k_ot   = osteocyteBurialRate(p);
    p.k_form = balanceBoneFormation(p);
    r = evalTargets(p, years = 1.5);
    % V16 is deliberately NOT here, and the reason took a measurement to
    % establish (appendix C35).  The header claimed from v2.14 that it was,
    % which left sost_reb free with nothing constraining it.  Adding it does
    % not fix that: sost_reb moves V16 by 0.04 across its entire 0-3 range
    % and moves V8 from 63.6 to 0.47, so V16 cannot break the
    % (delta_ab, sost_reb) degeneracy it was introduced to break.  What
    % adding V16 does do is bias lambda_P downwards -- against V7, whose
    % band is Tai 2015's, in favour of a 1.2-1.4 band that is our own
    % invention (the source says only "above baseline").  The identifiable
    % fix is to drop sost_reb from the free list, which is done above.
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
