function r = probeTargets(kr, ks, kp, lp, da, holdout)
%PROBETARGETS Convenience: set the 5 calibration free params, evaluate targets.
%   R = PROBETARGETS(k_res, K_S, K_P_sost, lambda_P, delta_ab, holdout)
%   applies the free parameters, re-derives k_form for bone balance, and
%   returns EVALTARGETS.  For interactive calibration exploration only.
%
%   Project: bone-mechanostat (PROJECT_PLAN v1.9)
arguments
    kr (1,1) double
    ks (1,1) double
    kp (1,1) double
    lp (1,1) double
    da (1,1) double
    holdout (1,1) logical = true
end
p = getDefaultParams();
p.k_res = kr; p.K_S = ks; p.K_P_sost = kp; p.lambda_P = lp; p.delta_ab = da;
p.k_ot   = osteocyteBurialRate(p);
p.k_form = balanceBoneFormation(p);
r = evalTargets(p, holdout = holdout);
end
