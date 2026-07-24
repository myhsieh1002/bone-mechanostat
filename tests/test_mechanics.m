function tests = test_mechanics()
%TEST_MECHANICS P2 -- M2 poroelasticity and M3 channel gating.
%
%   Run with:  runtests("tests/test_mechanics.m")
%
%   The strongest checks here are cross-validations between two independent
%   implementations of the same physics:
%     - Crank-Nicolson finite differences vs the closed-form steady-periodic
%       Biot solution
%     - step-by-step channel integration vs the exact per-cycle affine map
%   Either alone could be wrong in a way no plausibility check would catch;
%   agreement between them is real evidence.
%
%   Project: bone-mechanostat (PROJECT_PLAN v1.5)

tests = functiontests(localfunctions);
end

% -------------------------------------------------------------------------
function setupOnce(tc)
tc.TestData.p = getDefaultParams(reload = true);
end

% === M2 ==================================================================

function testClosedFormMatchesPDE(tc)
% P2 definition of done.  The Biot problem is linear, so the closed form is
% exact and this is limited only by discretisation.
rep = buildShearSurrogate(tc.TestData.p);
verifyLessThan(tc, rep.maxRelErr, 0.01, ...
    "Closed-form shear must match the finite-difference PDE to < 1%.");
end

function testShearScalesLinearlyWithStrain(tc)
% Biot is linear: doubling strain must exactly double the shear.
p = tc.TestData.p;
t1 = shearSurrogate(1000e-6, 1, p);
t2 = shearSurrogate(2000e-6, 1, p);
verifyEqual(tc, t2, 2*t1, "Shear must be linear in strain.", ...
    RelTol = 1e-12);
end

function testFrequencyAsymptotes(tc)
% Low frequency: tau ~ f.  High frequency: tau ~ sqrt(f).
%
% PROJECT_PLAN v1.4 assumed shear SATURATES at high frequency.  It does
% not: the pressure approaches its undrained value everywhere except in a
% boundary layer of thickness sqrt(c_p/omega) at the drained face, and as
% that layer thins the gradient there grows.  This test pins the corrected
% behaviour so the saturating form cannot quietly return.
p = tc.TestData.p;
lo = [1e-3 2e-3];               % well below f_poro
hi = [1e4 2e4];                 % well above

sLo = log(shearSurrogate(1e-3, lo(2), p) / shearSurrogate(1e-3, lo(1), p)) / log(2);
sHi = log(shearSurrogate(1e-3, hi(2), p) / shearSurrogate(1e-3, hi(1), p)) / log(2);

verifyEqual(tc, sLo, 1.0, "Low-frequency exponent should be 1.", AbsTol = 0.02);
verifyEqual(tc, sHi, 0.5, "High-frequency exponent should be 1/2.", AbsTol = 0.02);
verifyGreaterThan(tc, sHi, 0.4, "Shear must NOT saturate at high frequency.");
end

function testV5bLogarithmicFrequency(tc)
% V5b: mechanostat parameters depend logarithmically on frequency over
% 1-10 Hz (Marques 2023).  This emerges because the poroelastic crossover
% f_poro sits inside that band, so the exponent slides from ~1 to ~0.5
% across it.  No fitted parameter is involved.
p = tc.TestData.p;
f = logspace(0, 1, 25);
tau = arrayfun(@(x) shearSurrogate(1e-3, x, p), f);

rLog  = corr(log(f).', tau.');
rLin  = corr(f.', tau.');

verifyGreaterThan(tc, rLog, 0.99, "tau should be near-linear in ln(f) over 1-10 Hz.");
verifyGreaterThan(tc, rLog, rLin, "ln(f) should fit better than f.");
end

function testPhysiologicalShearBand(tc)
% Everyday activity must land in the 0.8-3 Pa window (P2 acceptance).
% K_tau is the lumped gain calibrated for exactly this.
p = tc.TestData.p;
st = struct(r_p = p.r_p_0, r_e = p.r_e_0, ...
            f_bm = p.f_bm_0, rho_min = p.rho_min_0);
b = scenarioLibrary("sedentary").bouts(1);
tau = shearSurrogate(organMechanics(b, st, p).eps_p, b.freqHz, p);

verifyGreaterThanOrEqual(tc, tau, p.tau_target_lo);
verifyLessThanOrEqual(tc, tau, p.tau_target_hi);
end

% === M3 ==================================================================

function testCycleOperatorMatchesStepwise(tc)
% The affine per-cycle map must reproduce step-by-step integration exactly
% (the system is linear, so it should agree to machine precision).
p = tc.TestData.p;
n = 20; nps = 60; tauPk = 2;

t = linspace(0, n, n*nps + 1);
w = tauPk * abs(sin(2*pi*t));
[~, ~, ~, Dstep] = msicGating(w, t, p);

op = msicCycleOperator(tauPk, 1, 0, p, nPerCycle = nps);
y = msicRestingState(p);
Daff = 0;
for k = 1:n
    Daff = Daff + op.g.' * y + op.h;
    y = op.A * y + op.c;
end

verifyEqual(tc, Daff, Dstep, "Affine cycle map must equal stepwise integration.", ...
    RelTol = 1e-9);
end

function testOccupanciesArePhysical(tc)
p = tc.TestData.p;
t = 0:0.01:30;
tau = 3 * abs(sin(2*pi*t));
[O, I, C_h] = msicGating(tau, t, p);

verifyTrue(tc, all(O >= -1e-12) && all(I >= -1e-12) && all(C_h >= -1e-12), ...
    "Occupancies must be non-negative.");
verifyEqual(tc, O + I + C_h, ones(size(O)), "Occupancies must sum to 1.", ...
    AbsTol = 1e-10);
end

function testRestingStateIsAFixedPoint(tc)
% Starting at the resting state with zero shear, nothing should move.
p = tc.TestData.p;
y0 = msicRestingState(p);
t = linspace(0, 100, 201);
[O, I] = msicGating(zeros(size(t)), t, p, y0 = y0);

verifyEqual(tc, O(end), y0(1), RelTol = 1e-8);
verifyEqual(tc, I(end), y0(2), RelTol = 1e-8);
end

function testLoadingRaisesDoseAboveDisuse(tc)
% If loading barely moves the daily dose, the mechanical signal is drowned
% by the resting open probability and V2 (disuse bone loss) becomes
% unreachable.  k_tau_sig was calibrated against exactly this.
p = tc.TestData.p;
st = struct(r_p = p.r_p_0, r_e = p.r_e_0, ...
            f_bm = p.f_bm_0, rho_min = p.rho_min_0);

D = zeros(1, 2);
names = ["bedrest" "sedentary"];
for k = 1:2
    s = scenarioLibrary(names(k));
    [~, i] = max([s.bouts.momentScale]);
    tau = shearSurrogate(organMechanics(s.bouts(i), st, p).eps_p, ...
                         s.bouts(i).freqHz, p);
    D(k) = dailyDose(s.bouts, tau / s.bouts(i).momentScale, p);
end

verifyGreaterThan(tc, D(2)/D(1), 2, ...
    "Sedentary dose must exceed bed rest by more than 2x.");
end

function testRestInsertionRaisesDose(tc)
% Rest insertion must raise the dose -- I relaxes back to C_h during the
% gap, so more channels are available for the next cycle.
%
% NOTE: this asserts only the SIGN.  The amplitude dependence runs opposite
% to Srinivasan (2002): in this model the gain GROWS with load amplitude,
% because more inactivation has accumulated for rest to relieve.  That is
% structural -- it holds across the whole (k_oi, k_ic) plane -- so V5's
% conditionality cannot come from the channel and must be tested at the
% level of the downstream response in P3.  See PROJECT_PLAN appendix C6.
p = tc.TestData.p;
b0 = struct(momentScale = 1, axialScale = 1, nCycles = 36, freqHz = 1, ...
            restWithinSec = 0, restAfterSec = 0, daysOfWeek = []);
b1 = b0;  b1.restWithinSec = 10;

base = dailyDose(b0, 0, p);
d0 = dailyDose(b0, 1.5, p) - base;
d1 = dailyDose(b1, 1.5, p) - base;

verifyGreaterThan(tc, d1, d0, "Rest insertion must raise the daily dose.");
end

function testDoseSurrogateInterpolates(tc)
% The interpolant must reproduce the values it was built from.
p = tc.TestData.p;
s = scenarioLibrary("resistance");
sg = buildDoseSurrogate(s.bouts, p, tauGrid = 0:0.5:6);

for tau = [0.5 2.25 4.75]
    verifyEqual(tc, sg.F(tau), dailyDose(s.bouts, tau, p), sprintf("Surrogate off at tau = %.2f Pa.", tau), ...
    RelTol = 0.02);
end
end

function testLoadingDoseAppliesOsteocyteGain(tc)
% D_eff = D_mech * (n_ot/n_ot_0)^zeta -- P3 positive feedback #1.
p = tc.TestData.p;
s = scenarioLibrary("sedentary");
sg = buildDoseSurrogate(s.bouts, p, tauGrid = 0:1:6);

[dFull, dMech] = loadingDose(2, sg, p.n_ot_0, p);
verifyEqual(tc, dFull, dMech, "At n_ot = n_ot_0 the gain must be exactly 1.", ...
    RelTol = 1e-12);

dLow = loadingDose(2, sg, 0.8 * p.n_ot_0, p);
verifyEqual(tc, dLow, dMech * 0.8^p.zeta, RelTol = 1e-12);
verifyLessThan(tc, dLow, dMech, "Osteocyte loss must weaken the dose.");
end
