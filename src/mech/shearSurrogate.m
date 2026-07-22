function tau_max = shearSurrogate(eps_peak, freqHz, surrogate)
%SHEARSURROGATE M2 -- fast lookup of peak fluid shear stress.
%
%   tau_max = K_tau eps (f/f_0)^alpha / (1 + (f/f_c)^alpha)
%
%   Inputs
%     eps_peak  (:,1) double  peak tissue strain                  [-]
%     freqHz    (:,1) double  loading frequency                   [Hz]
%     surrogate (1,1) struct  from BUILDSHEARSURROGATE
%   Output
%     tau_max   (:,1) double  peak wall shear stress              [Pa]
%
%   *** NOT IMPLEMENTED -- scheduled for phase P2 (M2) ***
%
%   Project: bone-mechanostat (PROJECT_PLAN v1.4)

error("boneMechanostat:notImplemented", ...
      "shearSurrogate is a phase-P2 deliverable (M2) and is not implemented yet.");
end
