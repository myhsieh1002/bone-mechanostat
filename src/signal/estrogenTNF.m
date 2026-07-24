function dT = estrogenTNF(T, E2, p)
%ESTROGENTNF M4(b) -- oestrogen-withdrawal TNF-alpha pathway.
%
%   DT = ESTROGENTNF(T, E2, P) evaluates, in baseline-relative form,
%
%       dT/dt = delta_T [ g(E2)/g(E2_0) - T ]
%       g(E2) = K_E^n_E / (K_E^n_E + E2^n_E)
%
%   so T = 1 is the fixed point at E2 = E2_0 (premenopausal).  The shape is
%   exactly the plan's Hill repression; only the normalisation differs,
%   which removes the free production rate k_T -- it is fixed by requiring
%   T = 1 at baseline.
%
%   TNF-alpha then acts twice: it raises sclerostin via lambda_T in
%   OSTEOCYTESIGNAL, and biases resorption endocortically via lambda_xi in
%   SURFACEALLOCATION.  Together those give the postmenopausal phenotype of
%   a wider but thinner cortex (V15).
%
%   *** Identifiability warning (PROJECT_PLAN v1.3 4.2 M4(b)) ***
%   E2 reaches RANKL by two routes -- directly through lambda_E and
%   indirectly through TNF-alpha/SOST/lambda_S.  lambda_E and lambda_T
%   partially compensate and must NOT both be opened as free parameters.
%
%   Inputs
%     T   (1,1) double  TNF-alpha, baseline 1                          [-]
%     E2  (1,1) double  oestrogen, premenopausal 1                     [-]
%     p   (1,1) struct  parameters (K_E, n_E, delta_T_tnf, E2_0)
%
%   Output
%     dT  (1,1) double  derivative                                 [1/day]
%
%   See also OSTEOCYTESIGNAL, SURFACEALLOCATION.

%   Project: bone-mechanostat (PROJECT_PLAN v1.6)

arguments
    T (1,1) double
    E2 (1,1) double {mustBeNonnegative}
    p (1,1) struct
end

g    = @(e) p.K_E^p.n_E / (p.K_E^p.n_E + e^p.n_E);
Tset = g(E2) / g(p.E2_0);

dT = p.delta_T_tnf * (Tset - T);
end
