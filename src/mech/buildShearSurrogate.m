function report = buildShearSurrogate(p, opts)
%BUILDSHEARSURROGATE M2 -- verify the closed-form shear model against the PDE.
%
%   REPORT = BUILDSHEARSURROGATE(P) sweeps (eps_peak, f), solves the Biot
%   problem numerically with POROELASTIC1D, and compares against the
%   closed-form SHEARSURROGATE.  It returns agreement statistics and the
%   calibration provenance of K_tau.
%
%   *** THERE IS NOTHING TO FIT (v1.5) ***
%   PROJECT_PLAN v1.4 called for an offline sweep fitted to
%       tauhat = K_tau eps (f/f_0)^alpha / (1 + (f/f_c)^alpha)
%   with a target of R^2 > 0.98.  The Biot problem is linear and admits an
%   exact steady-periodic solution (see SHEARSURROGATE), so the closed form
%   is not a fit and there is no residual: agreement with the PDE is limited
%   only by discretisation.  The P2 acceptance criterion becomes "closed
%   form matches the PDE to < 1%", which is far stronger than R^2 > 0.98
%   against a phenomenological form that was, in any case, wrong about the
%   high-frequency asymptote.
%
%   Inputs
%     p             (1,1) struct  parameters
%     opts.epsGrid  (1,:) double  peak strains to test                 [-]
%     opts.freqGrid (1,:) double  frequencies to test                  [Hz]
%     opts.nCycles  (1,1) double  cycles simulated before sampling.  Default 8
%     opts.nz       (1,1) double  spatial nodes.  Default 81
%     opts.save     (1,1) logical write to getResultsDir.  Default false
%
%   Output
%     report  (1,1) struct  .maxRelErr .medRelErr .relErr (grid)
%                           .tauFD .tauClosed .epsGrid .freqGrid
%                           .c_p .t_poro .f_poro .K_tau .calibration
%
%   See also POROELASTIC1D, SHEARSURROGATE.

%   Project: bone-mechanostat (PROJECT_PLAN v1.5)

arguments
    p (1,1) struct
    opts.epsGrid (1,:) double = [200 500 1000 2000 3000] * 1e-6
    opts.freqGrid (1,:) double = [0.5 1 2 5 10]
    opts.nCycles (1,1) double {mustBePositive} = 8
    opts.nz (1,1) double {mustBePositive} = 81
    opts.save (1,1) logical = false
end

c_p    = p.k_perm / (p.mu_fluid * p.S_stor);
t_poro = p.L_poro^2 / c_p;
f_poro = c_p / (2 * pi * p.L_poro^2);

nE = numel(opts.epsGrid);
nF = numel(opts.freqGrid);
tauFD     = zeros(nE, nF);
tauClosed = zeros(nE, nF);

for j = 1:nF
    f  = opts.freqGrid(j);
    nT = max(2000, round(200 * opts.nCycles));
    t  = linspace(0, opts.nCycles / f, nT);
    settled = t > (opts.nCycles - 2) / f;      % last two cycles only

    for i = 1:nE
        e   = opts.epsGrid(i) * 0.5 .* (1 - cos(2 * pi * f * t));
        tau = poroelastic1D(e, t, p, nz = opts.nz);
        tauFD(i, j)     = max(tau(settled));
        tauClosed(i, j) = shearSurrogate(opts.epsGrid(i), f, p);
    end
end

% The closed form carries the lumped gain K_tau; the PDE carries the
% microstructural (a/2)*Gamma/S.  Compare SHAPE by removing the constant
% ratio between them, and report that ratio separately -- it is exactly
% what K_tau absorbs.
scale  = median(tauClosed(:) ./ tauFD(:));
relErr = abs(scale * tauFD - tauClosed) ./ tauClosed;

report = struct();
report.epsGrid   = opts.epsGrid;
report.freqGrid  = opts.freqGrid;
report.tauFD     = tauFD;
report.tauClosed = tauClosed;
report.relErr    = relErr;
report.maxRelErr = max(relErr(:));
report.medRelErr = median(relErr(:));
report.c_p       = c_p;
report.t_poro    = t_poro;
report.f_poro    = f_poro;
report.K_tau     = p.K_tau;
report.scaleFDtoClosed = scale;

report.calibration = "K_tau is a LUMPED gain absorbing (a/2)*Gamma_PCM/S_stor. " + ...
    "The microstructural placeholders in the CSV (k_perm, S_stor, a_canal, " + ...
    "Gamma_PCM) are mutually inconsistent with the physiological 0.8-3 Pa " + ...
    "band -- together they overpredict by ~4 orders of magnitude. K_tau is " + ...
    "therefore anchored directly: 1000 ue at 1 Hz -> 2 Pa. Awaiting Weinbaum " + ...
    "1994 (B1 #4). The FREQUENCY dependence is unaffected by this rescaling: " + ...
    "it is set by c_p and L_poro alone.";

if opts.save
    outFile = fullfile(getResultsDir("surrogates"), "shearSurrogate_report.mat");
    save(outFile, "report");
    fprintf("Saved: %s\n", outFile);
end
end
