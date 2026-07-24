function d = boneCellPopulation(R, B, C, alg, p)
%BONECELLPOPULATION M6 -- Lemaire/Pivonka cell populations, Wnt-coupled.
%
%   D = BONECELLPOPULATION(R, B, C, ALG, P) evaluates, in baseline-relative
%   form,
%
%       dR/dt = k_R [ piC (1 + gamma_beta (beta - 1)) - R / piC ]
%       dB/dt = k_B [ R / piC - B / (1 + gamma_surv (beta - 1)) ]
%       dC/dt = k_C [ piL - piC C ]
%
%   with piC the TGF-beta activation of Lemaire (2004),
%
%       piC(C) = (C + f0 Cs) / (C + Cs),  normalised to 1 at C = 1
%
%   and piL the RANKL/OPG activation supplied by OSTEOCYTESIGNAL.
%
%   *** WHY BASELINE-RELATIVE (v1.6) ***
%   The plan writes these with absolute rate constants D_R, D_B, D_C, D_A,
%   k_B.  Those must come from Lemaire (2004) / Pivonka (2008) (B1 #1, #2);
%   the CSV currently holds order-of-magnitude placeholders explicitly
%   marked as NOT the published values.  With placeholders, the absolute
%   form has no fixed point anywhere near the intended baseline, so E0
%   cannot even start.  Normalising to baseline collapses each equation to
%   one timescale, makes R = B = C = 1 a fixed point by construction, and
%   leaves the shape functions untouched.  When the real constants arrive
%   they enter as the timescales k_R, k_B, k_C -- the same quantities that
%   govern the dynamics -- so nothing has to be rewritten.
%
%   Inputs
%     R, B, C  (1,1) double  populations, baseline 1                   [-]
%     alg      (1,1) struct  from OSTEOCYTESIGNAL; uses .pi_L and .beta
%     p        (1,1) struct  parameters
%
%   Output
%     d  (1,1) struct  .R .B .C derivatives                       [1/day]
%
%   See also OSTEOCYTESIGNAL, BONESTRUCTURE.

%   Project: bone-mechanostat (PROJECT_PLAN v1.6)

arguments
    R (1,1) double
    B (1,1) double
    C (1,1) double
    alg (1,1) struct
    p (1,1) struct
end

beta = alg.beta;

% TGF-beta activation, normalised to 1 at C = 1.
f0  = 0.05;                                   % Lemaire's residual fraction
piC = @(c) (c + f0 * p.C_s_TGF) / (c + p.C_s_TGF);
pC  = piC(max(C, 1e-9)) / piC(1);

survival = max(1 + p.gamma_surv * (beta - 1), 1e-6);
prolif   = 1 + p.gamma_beta * (beta - 1);

d.R = p.D_R * (pC * prolif - R / pC);
d.B = p.D_B * (R / pC - B / survival);
d.C = p.D_C * (alg.pi_L - pC * C);
end
