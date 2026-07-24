function [D_eff, D_mech] = loadingDose(tau_max, surrogate, n_ot, p)
%LOADINGDOSE M3 -- effective daily osteogenic dose (table lookup).
%
%   [D_EFF, D_MECH] = LOADINGDOSE(TAU_MAX, SURROGATE, N_OT, P) evaluates
%
%       D_mech = surrogate.F(tau_max)                                 [s]
%       D_eff  = D_mech * (n_ot / n_ot_0)^zeta                        [s]
%
%   The n_ot factor is P3's positive feedback #1: bone loss buries fewer
%   osteocytes, the sensing network thins, and the same force produces a
%   weaker osteogenic signal (PROJECT_PLAN v1.3 §4.2 M4(a)).  In v1.3 this
%   factor was specified but D_mech had no consumer at all, so the feedback
%   was inert -- v1.4 connected it (appendix C5.1).
%
%   D_EFF is the ONE scalar crossing the fast/slow interface.  Its single
%   consumer is the Ca2+ influx term in OSTEOCYTESIGNAL.  If a second
%   consumer ever appears, the fast/slow separation has been broken.
%
%   Inputs
%     tau_max   (1,1) double  peak wall shear stress                  [Pa]
%     surrogate (1,1) struct  from BUILDDOSESURROGATE
%     n_ot      (1,1) double  osteocyte density                       [-]
%     p         (1,1) struct  parameters (n_ot_0, zeta)
%
%   Outputs
%     D_eff   (1,1) double  effective dose                            [s]
%     D_mech  (1,1) double  dose before the n_ot factor               [s]
%
%   See also BUILDDOSESURROGATE, DAILYDOSE, OSTEOCYTESIGNAL.

%   Project: bone-mechanostat (PROJECT_PLAN v1.5)

arguments
    tau_max (1,1) double {mustBeNonnegative}
    surrogate (1,1) struct
    n_ot (1,1) double {mustBeNonnegative}
    p (1,1) struct
end

D_mech = surrogate.F(tau_max);
D_eff  = D_mech * (n_ot / p.n_ot_0)^p.zeta;
end
