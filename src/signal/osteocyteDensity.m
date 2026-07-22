function dn_ot = osteocyteDensity(n_ot, v_form, v_res, E2, p)
%OSTEOCYTEDENSITY M4(a) -- osteocyte density dynamics (P3 positive feedback #1).
%
%     dn_ot/dt = k_ot v_form (n_ot_max - n_ot)
%                - (gamma_ot v_res + delta_ot(E2)) n_ot
%
%   Osteocytes are buried during formation and removed during resorption;
%   oestrogen withdrawal accelerates their apoptosis.  Coupled with the
%   sensing-gain exponent zeta in LOADINGDOSE this closes the loop
%   loss -> fewer sensors -> weaker signal -> more loss, which is what makes
%   bistability (P3) possible at all.  A purely mechanical closed loop is
%   negative feedback and is monostable.
%
%   Inputs
%     n_ot   (1,1) double  osteocyte density                       [-]
%     v_form (1,1) double  formation surface velocity              [m/day]
%     v_res  (1,1) double  resorption surface velocity             [m/day]
%     E2     (1,1) double  oestrogen                               [-]
%     p      (1,1) struct  parameters
%   Output
%     dn_ot  (1,1) double  derivative                              [1/day]
%
%   *** NOT IMPLEMENTED -- scheduled for phase P3 (M4) ***
%
%   Project: bone-mechanostat (PROJECT_PLAN v1.4)

error("boneMechanostat:notImplemented", ...
      "osteocyteDensity is a phase-P3 deliverable (M4) and is not implemented yet.");
end
