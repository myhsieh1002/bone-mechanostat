function d = osteocyteSignal(y, D_eff, P_pth, E2, u_romo, p)
%OSTEOCYTESIGNAL M4-M5 -- Piezo1/Ca -> YAP/TAZ -> SOST -> Wnt/beta-catenin, plus RANKL and OPG.
%
%     dCa/dt   = J_max (D_eff/T_day) + J_alt - k_C Ca
%     dY/dt    = k_Y Ca^n/(K_Y^n + Ca^n) (1-Y) - delta_Y Y
%     dS/dt    = beta_S [1+(Y/K_S)^h]^-1 [1+P/K_P]^-1 (1 + lambda_T T/(K_T+T))
%                - (delta_S + delta_ab u_romo) S
%     W_eff    = W_0 K_W^m/(K_W^m + S^m)
%     dbeta/dt = k_beta W_eff - delta_beta beta
%     L_RANKL  = L_0 (1+lambda_S S/(K_L+S))(1+lambda_P P/(K_PL+P))(1-lambda_E E2)
%     O_OPG    = O_0 (1 + lambda_beta beta/(K_beta+beta))
%
%   Note the Ca2+ driver: the daily mean open probability D_eff/T_day, NOT a
%   P_o(tau) sigmoid.  That sigmoid was deleted in v1.4 (see MSICGATING).
%
%   Sclerostin's dual action -- blocking Wnt AND raising RANKL via lambda_S --
%   is innovation N2 and the mechanism behind V13.
%
%   Inputs
%     y      (1,1) struct  current signalling states (Ca_i, Y, S, T, beta)
%     D_eff  (1,1) double  daily mechanical dose                   [s]
%     P_pth  (1,1) double  PTH                                     [-]
%     E2     (1,1) double  oestrogen, premenopausal = 1             [-]
%     u_romo (1,1) double  romosozumab on/off                       [-]
%     p      (1,1) struct  parameters
%   Output
%     d  (1,1) struct  derivatives (.Ca_i .Y .S .beta) [1/day] and
%                      algebraic outputs (.L_RANKL .O_OPG .W_eff)   [-]
%
%   *** NOT IMPLEMENTED -- scheduled for phase P3 (M4-M5) ***
%
%   Project: bone-mechanostat (PROJECT_PLAN v1.4)

error("boneMechanostat:notImplemented", ...
      "osteocyteSignal is a phase-P3 deliverable (M4-M5) and is not implemented yet.");
end
