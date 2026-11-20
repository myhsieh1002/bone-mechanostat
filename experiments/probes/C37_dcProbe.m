function R = C37_dcProbe(stage, which)
%DCPROBE In-memory probe of D_C = 0.210 (HEAD) vs 2.1e-3 (Pivonka Table 3).
%   Never writes the CSV.  Results accumulate in dcProbe_results.mat here.
here = fileparts(mfilename("fullpath"));            % <root>/experiments/probes
root = string(fileparts(fileparts(here)));          % never hard-code a home directory
addpath(fullfile(root, "src")); setupPath(); maxNumCompThreads(4);
resFile = fullfile(here, "dcProbe_results.mat");
if isfile(resFile), S = load(resFile); R = S.R; else, R = struct(); end

if nargin < 2, which = 1:2; end
p0 = getDefaultParams(reload = true);
p1 = p0; p1.D_C = 2.1e-3;                       % Pivonka D_OCp read as a timescale
p2 = p0; p2.D_C = 0.7;                          % Pivonka A_OCa: the relative-form relaxation rate of C
p3 = p2; p3.D_B = 0.189; p3.D_R = 0.178;        % + A_OBa for B, Lemaire D_B/pi_C0 for R [exploratory]
p4 = p2; p4.D_R = 0.178;                        % D_C 0.7 + R timescale only
p5 = p2; p5.D_B = 0.189;                        % D_C 0.7 + B timescale only
sets = {p0, p1, p2, p3, p4, p5}; names = ["HEAD" "DC21e3" "DC07" "RelForm" "DR0178" "DB0189"];
for i = which
    sets{i}.k_ot = osteocyteBurialRate(sets{i}); sets{i}.k_form = balanceBoneFormation(sets{i});
    fprintf("%-7s D_R=%.4g D_B=%.4g D_C=%.4g k_ot=%.6g k_form=%.6g\n", names(i), sets{i}.D_R, sets{i}.D_B, sets{i}.D_C, sets{i}.k_ot, sets{i}.k_form);
end

switch stage
case "A"   % evalTargets with holdout, for both
    for i = which
        tic; r = evalTargets(sets{i}, holdout = true); el = toc;
        R.(names(i)).targets = r; R.(names(i)).evalSeconds = el;
        fprintf("\n[%s] %.0f s\n V1 %.4f V2 %.4f V7 %.4f V7slope %.4f\n V8 %.4f V8cort %.4f V16 %.4f\n V10 %.4f V14 %.4f chi2 %.4f\n", ...
            names(i), el, r.V1, r.V2, r.V7, r.V7slope, r.V8, r.V8cort, r.V16, r.V10, r.V14, r.chi2);
        disp(r.pass); disp(r.passHoldout);
    end
case "B"   % steady state eigenvalues + baseline drift + cell-population time constants
    for i = which
        p = sets{i};
        [~, ~, ev] = steadyState(p);
        o = simulate(scenarioLibrary("sedentary", durationDays = 730), p = p);
        drift = 100 * (o.dens.aBMD(end) / o.dens.aBMD(1) - 1);
        R.(names(i)).eigMaxReal = max(real(ev)); R.(names(i)).eig = ev;
        R.(names(i)).drift24 = drift;
        R.(names(i)).C_end = o.get.C(end); R.(names(i)).B_end = o.get.B(end);
        fprintf("[%s] max Re(eig) %.4e   drift24 %+.4f %%   C(end) %.6f  B(end) %.6f  valid=%d\n", ...
            names(i), max(real(ev)), drift, o.get.C(end), o.get.B(end), o.validity.ok);
        % osteoclast response time: step pi_L via romosozumab start, cortical
        oR = simulate(scenarioLibrary("romosozumab", durationDays = 60), p = p);
        R.(names(i)).C_romo60 = oR.get.C(end);
        fprintf("       C after 60 d romosozumab (cortex): %.4f ; C min %.4f at day %.1f\n", ...
            oR.get.C(end), min(oR.get.C), oR.t(find(oR.get.C == min(oR.get.C), 1)));
    end
case "C"   % E3 disuse (V2, V3 sclerostin, PTH) + V11 loss/recovery (E7 recipe)
    for i = which
        p = sets{i};
        oLoss = simulate(scenarioLibrary("bedrest", durationDays = 180), p = p);
        bmc0 = oLoss.dens.BMC_L(1); bmcLo = oLoss.dens.BMC_L(end); half = 0.5*(bmc0-bmcLo);
        tLoseHalf = interp1(oLoss.dens.BMC_L, oLoss.t, bmc0 - half);
        dSost = 100*(oLoss.get.S(end)/oLoss.get.S(1)-1);
        [~,k28] = min(abs(oLoss.t-28)); [~,k60] = min(abs(oLoss.t-60));
        dPTH28 = 100*(oLoss.get.P(k28)/oLoss.get.P(1)-1); dPTH60 = 100*(oLoss.get.P(k60)/oLoss.get.P(1)-1);
        oRec = simulate(scenarioLibrary("sedentary", durationDays = 3650), p = p, y0 = oLoss.y(end,:).');
        recovered = oRec.dens.BMC_L - bmcLo;
        if max(recovered) >= half, tRecHalf = interp1(recovered, oRec.t, half); else, tRecHalf = inf; end
        R.(names(i)).V2 = -100*(bmcLo/bmc0-1)/6; R.(names(i)).V3_dSost = dSost;
        R.(names(i)).dPTH28 = dPTH28; R.(names(i)).dPTH60 = dPTH60;
        R.(names(i)).V11_tLoseHalf = tLoseHalf; R.(names(i)).V11_tRecHalf = tRecHalf;
        R.(names(i)).V11_ratio = tRecHalf/tLoseHalf; R.(names(i)).V11_frac10yr = max(recovered)/(bmc0-bmcLo);
        R.(names(i)).C_bedrest_end = oLoss.get.C(end);
        fprintf("[%s] V2 %.4f %%/mo  V3 sost %+.2f %%  PTH d28 %+.2f d60 %+.2f  C(180d) %.4f  valid=%d\n", ...
            names(i), R.(names(i)).V2, dSost, dPTH28, dPTH60, oLoss.get.C(end), oLoss.validity.ok);
        fprintf("       V11 lose-half %.1f d, regain-half %.1f d, ratio %.2f, 10-yr %.1f %%\n", ...
            tLoseHalf, tRecHalf, tRecHalf/tLoseHalf, 100*max(recovered)/(bmc0-bmcLo));
    end
case "D"   % E6 full-model hysteresis probe
    for i = which
        p = sets{i};
        sDown = scenarioLibrary("sedentary", durationDays = 365*10); sDown.E2 = 0.945;
        oDown = simulate(sDown, p = p);
        sUp = scenarioLibrary("sedentary", durationDays = 365*20); sUp.E2 = 1.0;
        oUp = simulate(sUp, p = p, y0 = oDown.y(end,:).');
        fD = oDown.get.f_bm; fU = oUp.get.f_bm;
        R.(names(i)).E6_fDown = [fD(1) fD(end)]; R.(names(i)).E6_fUpEnd = fU(end);
        R.(names(i)).E6_recovery = 100*fU(end)/fD(1);
        R.(names(i)).E6_ratchet = 1e3*(oUp.get.r_p(end)-oDown.get.r_p(1));
        R.(names(i)).E6_valid = [oDown.validity.ok oUp.validity.ok];
        fprintf("[%s] f_bm %.4f -> %.4f -> %.4f ; recovery %.1f %% ; ratchet %+.3f mm ; valid %d %d\n", ...
            names(i), fD(1), fD(end), fU(end), 100*fU(end)/fD(1), 1e3*(oUp.get.r_p(end)-oDown.get.r_p(1)), oDown.validity.ok, oUp.validity.ok);
    end
case "E"   % V6 six tennis indices (E5 recipe) + P2 asymmetry
    metrics = ["BMC_L" "Tot_Ar" "Co_Ar" "I_max" "MCav_Ar" "vBMD"];
    lo = [14 16 12 27 19 -2]; hi = [27 21 32 67 19 0]; tol = [10 10 10 15 10 2];
    for i = which
        p = sets{i};
        oTen = simulate(scenarioLibrary("tennis"), p = p);
        sideDiff = @(o, f) 100*(o.dens.(f+"_A")(end)/o.dens.(f+"_B")(end)-1);
        m = arrayfun(@(f) sideDiff(oTen, f), metrics);
        inTol = m >= lo-tol & m <= hi+tol;
        R.(names(i)).V6 = m; R.(names(i)).V6_inTol = inTol; R.(names(i)).V6_valid = oTen.validity.ok;
        fprintf("[%s] V6 a-f: %s  inTol %d/6  valid=%d\n", names(i), sprintf("%+.2f ", m), sum(inTol), oTen.validity.ok);
    end
end
save(resFile, "R");
end
