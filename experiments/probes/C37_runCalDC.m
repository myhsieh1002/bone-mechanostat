% Locate the project from this file, never from a hard-coded home directory
% (PROJECTROOT doc rule).  This file lives in <root>/experiments/probes.
here = fileparts(mfilename("fullpath"));
root = string(fileparts(fileparts(here)));
addpath(fullfile(root,"src")); setupPath(); maxNumCompThreads(4);
addpath(here);
p0 = getDefaultParams(reload=true); p0.D_C = 2.1e-3;
p0.k_ot = osteocyteBurialRate(p0); p0.k_form = balanceBoneFormation(p0);
fprintf("calibrateDC starting with D_C = %.4g\n", p0.D_C);
try, parpool("Processes", 3); catch e, disp(e.message); end
tic; out = C37_calibrateDC(p0, maxEval = 120, useParallel = true); el = toc;
fprintf("\n=== calibrateDC done in %.0f s  fval %.4f exitflag %d\n", el, out.fval, out.exitflag);
disp(table(out.freeNames.', out.xFit.', VariableNames = ["param" "fit"]));
t = out.targets;
fprintf("V1 %.4f V2 %.4f V7 %.4f V7slope %.4f V8 %.4f V8cort %.4f V16 %.4f V10 %.4f V14 %.4f chi2 %.4f\n", ...
    t.V1, t.V2, t.V7, t.V7slope, t.V8, t.V8cort, t.V16, t.V10, t.V14, t.chi2);
save(fullfile(here, "calibrateDC_result.mat"), "out", "el");
