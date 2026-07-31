function k_form = balanceBoneFormation(p)
%BALANCEBONEFORMATION Derive k_form so adult bone mass is balanced.
%
%   K_FORM = BALANCEBONEFORMATION(P) returns the formation rate constant
%   for which d(A_g f_bm)/dt = 0 at the baseline state, given all other
%   parameters in P (including k_res and everything that shapes the
%   surface allocation eta/xi).
%
%   *** WHY THIS IS DERIVED, NOT FREE (appendix C7.2) ***
%   There is no stationary geometric fixed point (eta_p > xi_p always), so
%   the only defensible baseline condition is conservation of bone MASS.
%   That fixes k_form/k_res.  During calibration, changing k_res or any
%   parameter that alters eta/xi would otherwise break the baseline; this
%   keeps it balanced by construction, exactly as k_form was set in P3.
%
%   The turnover MAGNITUDE (V1) is then carried by k_res alone -- scaling
%   k_res and k_form together changes turnover without touching balance.
%
%   Input
%     p  (1,1) struct  parameters (uses k_res, geometry, S_v, allocation)
%
%   Output
%     k_form  (1,1) double  balanced formation rate constant       [m/day]
%
%   See also CALIBRATE, EVALTARGETS, SURFACEALLOCATION.

%   Project: bone-mechanostat (PROJECT_PLAN v1.9)

arguments
    p (1,1) struct
end

% Baseline mechanics -> surface allocation at the unadapted geometry.
st = struct(r_p = p.r_p_0, r_e = p.r_e_0, ...
            f_bm = p.f_bm_0, rho_min = p.rho_min_0);
b = scenarioLibrary("sedentary").bouts(1);
mech = organMechanics(b, st, p);

% Dose function for the strain-gradient allocation.  The tau grid MUST
% match makeContext's, or the derived k_form balances a slightly different
% surrogate than the simulation uses and the baseline drifts (~0.1 %/yr --
% enough to fail the drift test).
sg = buildDoseSurrogate(scenarioLibrary("sedentary").bouts, p, tauGrid = 0:0.25:15);
doseFcn = @(e) sg.F(shearSurrogate(e, b.freqHz, p));
% D_eff_hat = 1: this is the reference state by definition, so the
% unloading bias is inert here whatever lambda_xi_mech is.
[eta, xi] = surfaceAllocation(mech, 1, 1, doseFcn, p);

[~, S_v_hat] = specificSurface(p.f_bm_0, p);
A_g = pi * (p.r_p_0^2 - p.r_e_0^2);

% d(A_g f_bm)/dt = f_bm * dA_g/dt + A_g * df_bm/dt = 0, at B = C = 1.
%   dA_g/dt   = 2 pi ( r_p dr_p/dt - r_e dr_e/dt )
%   dr_p/dt   = k_form eta_p - k_res xi_p
%   dr_e/dt   = k_res xi_e - k_form eta_e
%   df_bm/dt  = (S_v_hat/w)( k_form eta_i - k_res xi_i )
% Linear in k_form; solve for the root r = k_form/k_res, then scale.
fun = @(r) p.f_bm_0 * 2*pi*( p.r_p_0*(r*eta(1) - xi(1)) ...
                           - p.r_e_0*(xi(2) - r*eta(2)) ) ...
        + A_g * (S_v_hat/p.w_wall) * (r*eta(3) - xi(3));

ratio  = fzero(fun, 1);
k_form = ratio * p.k_res;
end
