function [y_ss, J, eig_J] = steadyState(p, opts)
%STEADYSTATE Frozen-geometry fixed point, its Jacobian and eigenvalues.
%
%   [Y_SS, J, EIG_J] = STEADYSTATE(P) integrates the frozen-geometry system
%   to steady state from the baseline (or a supplied) initial condition and
%   returns the fixed point, a finite-difference Jacobian of the non-frozen
%   states, and its eigenvalues.  Used by E0 for the baseline equilibrium
%   and by the P6 bifurcation work to classify stability.
%
%   *** Geometry (r_p, r_e) is frozen (appendix C15): the full system has no
%   stationary geometric fixed point (C7.2), so the meaningful equilibrium is
%   that of the fast + porosity + systemic states at fixed envelope. ***
%
%   Inputs
%     p          (1,1) struct  parameters
%     opts.y0    (:,1) double  initial state.  Default baselineState
%     opts.E2    (1,1) double  oestrogen.  Default 1
%     opts.days  (1,1) double  integration horizon.  Default 3000
%
%   Outputs
%     y_ss   (:,1) double  fixed point (16 states; r_p, r_e held)
%     J      (:,:) double  Jacobian of the 14 non-geometry states   [1/day]
%     eig_J  (:,1) double  eigenvalues (stable iff all real parts < 0)
%
%   See also CONTINUATION, FBMNULLCLINE, RHSFULL.

%   Project: bone-mechanostat (PROJECT_PLAN v2.3)

arguments
    p (1,1) struct
    opts.y0 (:,1) double = double.empty(0,1)
    opts.E2 (1,1) double = 1
    opts.days (1,1) double = 3000
end

info = stateVector("single");
sc = scenarioLibrary("sedentary", durationDays = opts.days);
sc.E2 = opts.E2;
ctx = makeContext(sc, p); ctx.freezeGeom = true;

if isempty(opts.y0)
    y0 = baselineState("single", p);
else
    y0 = opts.y0;
end

odeo = odeset(RelTol = 1e-8, AbsTol = 1e-11, NonNegative = find(info.nonNegative));
sol  = ode15s(@(t, y) rhsFull(t, y, ctx), [0 opts.days], y0, odeo);
y_ss = sol.y(:, end);

% Finite-difference Jacobian over the non-geometry states.
keep = setdiff(1:info.n, [info.idx.r_p, info.idx.r_e]);
f0 = rhsFull(0, y_ss, ctx);
n = numel(keep);
J = zeros(n, n);
for j = 1:n
    dy = zeros(info.n, 1);
    h = 1e-6 * max(abs(y_ss(keep(j))), 1e-6);
    dy(keep(j)) = h;
    fj = rhsFull(0, y_ss + dy, ctx);
    J(:, j) = (fj(keep) - f0(keep)) / h;
end
eig_J = eig(J);
end
