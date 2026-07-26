function v = turnoverRate(p)
%TURNOVERRATE Annual gross bone turnover, in closed form.
%
%   V = TURNOVERRATE(P) returns the annual gross resorbed bone fraction as
%   a percentage, i.e. the V1 observable for cortex and its trabecular
%   analogue for a vertebral compartment.
%
%       turnover = 100 * 365 * (S_v_hat / w_wall) * k_res * xi_i_0 / f_bm_0
%
%   At the compartment's own baseline S_v_hat is 1 by construction, so this
%   needs no simulation.  That matters for two reasons: EVALTARGETS gets V1
%   for free, and TRABECULARPARAMS can solve k_res for a turnover target
%   directly instead of iterating -- which also breaks what would otherwise
%   be mutual recursion between the two (P5g).
%
%   Because it is closed form it also inverts:
%
%       k_res = target * f_bm_0 * w_wall / (100 * 365 * S_v_hat * xi_i_0)
%
%   Input
%     p  (1,1) struct  parameters
%
%   Output
%     v  (1,1) double  gross turnover                                [%/yr]
%
%   See also EVALTARGETS, TRABECULARPARAMS, BALANCEBONEFORMATION.

%   Project: bone-mechanostat (PROJECT_PLAN v2.9)

arguments
    p (1,1) struct
end

[~, S_v_hat] = specificSurface(p.f_bm_0, p);
grossRes = (S_v_hat / p.w_wall) * p.k_res * p.xi_i_0;    % [1/day] of f_bm
v = 100 * 365 * grossRes / p.f_bm_0;                     % [%/yr]
end
