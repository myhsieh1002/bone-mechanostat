function D_eff = loadingDose(tau_max, surrogate, n_ot, p)
%LOADINGDOSE M3 -- daily osteogenic mechanical dose (table lookup).
%
%     D_mech      = surrogate(tau_max)                           [s]
%     D_mech_eff  = D_mech * (n_ot / n_ot_0)^zeta                 [s]
%
%   The n_ot factor is P3's positive feedback #1: bone loss buries fewer
%   osteocytes, the sensing network thins, and the same force produces a
%   weaker osteogenic signal (PROJECT_PLAN v1.3 §4.2 M4(a)).
%
%   D_eff is the ONE scalar crossing the fast/slow interface.  Its single
%   consumer is the Ca2+ influx term in OSTEOCYTESIGNAL.
%
%   Inputs
%     tau_max   (1,1) double  peak wall shear stress              [Pa]
%     surrogate (1,1) struct  from BUILDDOSESURROGATE
%     n_ot      (1,1) double  osteocyte density                   [-]
%     p         (1,1) struct  parameters (n_ot_0, zeta)
%   Output
%     D_eff     (1,1) double  effective daily dose                [s]
%
%   *** NOT IMPLEMENTED -- scheduled for phase P2 (M3) ***
%
%   Project: bone-mechanostat (PROJECT_PLAN v1.4)

error("boneMechanostat:notImplemented", ...
      "loadingDose is a phase-P2 deliverable (M3) and is not implemented yet.");
end
