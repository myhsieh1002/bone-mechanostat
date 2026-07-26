function [y0, info] = baselineState(mode, p)
%BASELINESTATE Initial condition at the assumed healthy adult baseline.
%
%   [Y0, INFO] = BASELINESTATE() returns the 17-element initial state for
%   the single-compartment model; BASELINESTATE("two") returns the 31-element
%   two-compartment version with both sites starting identical.
%
%   Signalling variables (M4-M6) are non-dimensionalised so that the
%   baseline steady state is 1 (PROJECT_PLAN §7.1).  Structural variables
%   carry physical units and come from the parameter CSV.
%
%   This is a STARTING GUESS, not a fixed point.  E0 / STEADYSTATE is what
%   solves for the true baseline equilibrium and back-calibrates the free
%   parameters so that turnover lands in V1's 5-10 %/yr window.
%
%   Inputs
%     mode  (1,1) string  "single" (default) or "two"
%     p     (1,1) struct  parameters; default GETDEFAULTPARAMS()
%
%   Outputs
%     y0    (:,1) double  initial state
%     info  (1,1) struct  STATEVECTOR(mode) output
%
%   See also STATEVECTOR, STEADYSTATE, SIMULATE.

%   Project: bone-mechanostat (PROJECT_PLAN v1.4)

arguments
    mode (1,1) string {mustBeMember(mode, ["single" "two"])} = "single"
    p (1,1) struct = getDefaultParams()
end

info = stateVector(mode);

% Signalling and cell variables are non-dimensionalised to 1 at baseline
% (PROJECT_PLAN §7.1); structural variables carry physical units.
% Mineralisation is now a single intensive mean density (v2.3).
base = struct( ...
    Ca_i = 1, ...
    Y    = 1, ...
    S    = 1, ...
    T    = 1, ...
    n_ot = p.n_ot_0, ...
    beta = 1, ...
    R    = 1, ...
    B    = 1, ...
    C    = 1, ...
    r_p  = p.r_p_0, ...
    r_e  = p.r_e_0, ...
    f_bm = p.f_bm_0, ...
    rho_min = p.rho_min_0, ...
    Ca_s = p.Ca_s_0, ...
    P    = 1, ...
    V_D  = p.V_D_0, ...
    A_reb = 0);      % no antibody exposure yet, so no compensatory SOST tone

y0 = zeros(info.n, 1);
for k = 1:info.n
    name = regexprep(info.names(k), "_(A|B)$", "");   % strip site suffix
    field = matlab.lang.makeValidName(name);
    if ~isfield(base, field)
        error("boneMechanostat:missingBaseline", ...
              "No baseline value defined for state '%s'.", info.names(k));
    end
    y0(k) = base.(field);
end
end
