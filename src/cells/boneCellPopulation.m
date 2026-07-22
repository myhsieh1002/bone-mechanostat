function d = boneCellPopulation(R, B, C, L_RANKL, O_OPG, beta, p)
%BONECELLPOPULATION M6 -- Lemaire/Pivonka bone cell populations, extended by Wnt coupling.
%
%     dR/dt = D_R pi_C (1 + gamma_beta beta) - (D_B/pi_C) R
%     dB/dt = (D_B/pi_C) R - k_B B/(1 + gamma_surv beta)
%     dC/dt = D_C pi_L - D_A pi_C C
%     pi_L  = L_RANKL / (K_L3 + L_RANKL + kappa O_OPG)
%
%   *** Rate constants must come from B1 #1 (Lemaire 2004) and B1 #2
%   (Pivonka 2008).  The CSV currently holds order-of-magnitude placeholders
%   marked source=Lemaire2004 / Pivonka2008 with confidence=low -- these are
%   NOT the published values and must be replaced before P4 calibration. ***
%
%   Inputs
%     R, B, C   (1,1) double  cell populations                     [-]
%     L_RANKL   (1,1) double  RANKL                                [-]
%     O_OPG     (1,1) double  OPG                                  [-]
%     beta      (1,1) double  beta-catenin                         [-]
%     p         (1,1) struct  parameters
%   Output
%     d  (1,1) struct  .R .B .C derivatives                        [1/day]
%
%   *** NOT IMPLEMENTED -- scheduled for phase P3 (M6) ***
%
%   Project: bone-mechanostat (PROJECT_PLAN v1.4)

error("boneMechanostat:notImplemented", ...
      "boneCellPopulation is a phase-P3 deliverable (M6) and is not implemented yet.");
end
