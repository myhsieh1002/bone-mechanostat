function dT = estrogenTNF(T, E2, p)
%ESTROGENTNF M4(b) -- oestrogen-withdrawal TNF-alpha pathway.
%
%     dT/dt = k_T K_E^n_E/(K_E^n_E + E2^n_E) - delta_T T
%
%   TNF-alpha then (i) raises sclerostin via lambda_T in OSTEOCYTESIGNAL and
%   (ii) biases resorption towards the endocortical surface via lambda_xi in
%   SURFACEALLOCATION.  Together those produce the postmenopausal phenotype
%   of a wider but thinner cortex (V15).
%
%   *** Identifiability warning (PROJECT_PLAN v1.3 §4.2 M4(b)) ***
%   E2 now reaches RANKL by two routes -- directly through lambda_E and
%   indirectly through TNF-alpha/SOST/lambda_S.  lambda_E and lambda_T
%   partially compensate and must NOT both be opened as free parameters;
%   IDENTIFIABILITY.M must profile them.
%
%   Inputs
%     T   (1,1) double  TNF-alpha                                  [-]
%     E2  (1,1) double  oestrogen, premenopausal = 1                [-]
%     p   (1,1) struct  parameters
%   Output
%     dT  (1,1) double  derivative                                 [1/day]
%
%   *** NOT IMPLEMENTED -- scheduled for phase P3 (M4) ***
%
%   Project: bone-mechanostat (PROJECT_PLAN v1.4)

error("boneMechanostat:notImplemented", ...
      "estrogenTNF is a phase-P3 deliverable (M4) and is not implemented yet.");
end
