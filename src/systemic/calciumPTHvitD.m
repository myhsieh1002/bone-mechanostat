function d = calciumPTHvitD(Ca_s, P, V_D, I_Ca, v_form, v_res, p)
%CALCIUMPTHVITD M8 -- systemic calcium / PTH / 1,25(OH)2D homeostasis.
%
%     Abs      = a_p I_Ca + [a_a I_Ca/(K_I + I_Ca)] [V_D/(K_VD + V_D)]
%     dCa_s/dt = Abs + phi_res v_res - phi_form v_form - Renal(Ca_s, P)
%     dP/dt    = P_max/[1 + (Ca_s/Ca_50)^n_P] - delta_P P
%     dV_D/dt  = k_VD P/(K_VP + P) - delta_VD V_D
%
%   *** This module is what makes P1's hypothesis quantitative. ***
%   Raising calcium intake must reach bone only along the physiological path
%   -- serum Ca up, PTH down, resorption slightly down, sclerostin
%   disinhibited -- giving a SMALL effect with essentially no gain on the
%   formation side.  Combined with the v1.3 mechanical feedback, the BMD
%   response should settle to a new equilibrium rather than accrue: that is
%   V7's non-progressive plateau, and it should be EMERGENT, not fitted.
%
%   Saturable absorption (K_I) is the reason a higher intake buys
%   progressively less.
%
%   Inputs
%     Ca_s   (1,1) double  serum ionised calcium                  [mmol/L]
%     P      (1,1) double  PTH                                     [-]
%     V_D    (1,1) double  1,25(OH)2D                              [-]
%     I_Ca   (1,1) double  calcium intake                         [mg/day]
%     v_form (1,1) double  formation velocity                     [m/day]
%     v_res  (1,1) double  resorption velocity                    [m/day]
%     p      (1,1) struct  parameters
%   Output
%     d  (1,1) struct  .Ca_s .P .V_D derivatives
%
%   *** NOT IMPLEMENTED -- scheduled for phase P4 (M8) ***
%
%   Project: bone-mechanostat (PROJECT_PLAN v1.4)

error("boneMechanostat:notImplemented", ...
      "calciumPTHvitD is a phase-P4 deliverable (M8) and is not implemented yet.");
end
