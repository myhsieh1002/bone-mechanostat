function [tau, diag] = poroelastic1D(eps_t, tvec, p, opts)
%POROELASTIC1D M2 -- 1D Biot poroelasticity along the drainage path.
%
%   [TAU, DIAG] = POROELASTIC1D(EPS_T, TVEC, P) solves
%
%       dp/dt = c_p d2p/dz2 - (1/S) deps/dt,      c_p = k_p / (mu S)
%
%   on z in [0, L] with a symmetry boundary at z = 0 (dp/dz = 0, deep in
%   the tissue) and a drained boundary at z = L (p = 0, the Haversian
%   canal), then returns the wall shear stress on the osteocyte process
%
%       tau(t) = (a/2) |dp/dz| * Gamma_PCM
%
%   Time stepping is Crank-Nicolson (unconditionally stable, 2nd order in
%   time), so TVEC may be coarse relative to the pore-pressure diffusion
%   time without the solution blowing up.
%
%   This is the REFERENCE implementation.  For pure sinusoidal loading the
%   closed-form steady-periodic solution used by SHEARSURROGATE is exact
%   and far cheaper; this solver exists to (a) validate that closed form
%   and (b) handle the non-sinusoidal waveforms that rest insertion
%   produces, for which no steady-periodic solution applies.
%
%   Inputs
%     eps_t     (1,:) double  tissue strain time course                [-]
%     tvec      (1,:) double  time grid, strictly increasing           [s]
%     p         (1,1) struct  parameters (k_perm, mu_fluid, S_stor,
%                             a_canal, Gamma_PCM, L_poro)
%     opts.nz   (1,1) double  spatial nodes.  Default 81
%     opts.p0   (:,1) double  initial pore pressure.  Default zeros
%
%   Outputs
%     tau   (1,:) double  wall shear stress                           [Pa]
%     diag  (1,1) struct  .z [m], .pField [Pa], .c_p [m^2/s],
%                         .t_poro [s] = L^2/c_p, .dpdz_L [Pa/m]
%
%   Example
%     p = getDefaultParams();
%     t = linspace(0, 5, 5001);
%     e = 1000e-6 * 0.5 .* (1 - cos(2*pi*1*t));      % 1 Hz, 1000 ue
%     tau = poroelastic1D(e, t, p);
%
%   See also SHEARSURROGATE, BUILDSHEARSURROGATE, MSICGATING.

%   Project: bone-mechanostat (PROJECT_PLAN v1.5)

arguments
    eps_t (1,:) double
    tvec (1,:) double
    p (1,1) struct
    opts.nz (1,1) double {mustBePositive} = 81
    opts.p0 (:,1) double = double.empty(0,1)
end

if numel(eps_t) ~= numel(tvec)
    error("boneMechanostat:sizeMismatch", ...
          "eps_t (%d) and tvec (%d) must be the same length.", ...
          numel(eps_t), numel(tvec));
end
if any(diff(tvec) <= 0)
    error("boneMechanostat:nonMonotonicTime", "tvec must increase strictly.");
end

L   = p.L_poro;
c_p = p.k_perm / (p.mu_fluid * p.S_stor);      % [m^2/s]

nz = round(opts.nz);
z  = linspace(0, L, nz).';
dz = z(2) - z(1);

% --- Laplacian: dp/dz = 0 at z=0 (ghost node), p = 0 at z=L -------------
% The Dirichlet node is held at zero and excluded from the unknowns.
n  = nz - 1;
e  = ones(n, 1);
A  = spdiags([e, -2*e, e], -1:1, n, n);
A(1, 2) = 2;                                   % ghost node: p_0 = p_2
A  = A / dz^2;

nt = numel(tvec);
if isempty(opts.p0)
    pv = zeros(n, 1);
else
    pv = opts.p0(1:n);
end

pField = zeros(nz, nt);
pField(1:n, 1) = pv;

Im = speye(n);
depsdt = gradient(eps_t, tvec);                % [1/s]

% Refactorise only when the step size changes (uniform grids: once).
lastDt = NaN;
Lf = []; Uf = []; Pf = []; Aexp = [];
for k = 2:nt
    dt = tvec(k) - tvec(k-1);
    if ~(abs(dt - lastDt) <= 1e-12 * max(dt, 1))
        Aimp = Im - (dt * c_p / 2) * A;
        Aexp = Im + (dt * c_p / 2) * A;
        [Lf, Uf, Pf] = lu(Aimp);
        lastDt = dt;
    end
    src = -(1 / p.S_stor) * 0.5 * (depsdt(k) + depsdt(k-1));   % [Pa/s]
    rhs = Aexp * pv + dt * src;
    pv  = Uf \ (Lf \ (Pf * rhs));
    pField(1:n, k) = pv;
end

% --- shear from the pressure gradient at the drained face ---------------
% |dp/dz| peaks at z = L; one-sided second-order difference.
dpdz_L = (3*pField(nz, :) - 4*pField(nz-1, :) + pField(nz-2, :)) / (2*dz);
tau = (p.a_canal / 2) * p.Gamma_PCM * abs(dpdz_L);

diag = struct();
diag.z      = z;
diag.pField = pField;
diag.c_p    = c_p;
diag.t_poro = L^2 / c_p;
diag.dpdz_L = dpdz_L;
end
