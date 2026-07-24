function op = msicCycleOperator(tau_max, freqHz, restWithinSec, p, opts)
%MSICCYCLEOPERATOR M3 -- exact affine map for one load cycle plus its rest.
%
%   OP = MSICCYCLEOPERATOR(TAU_MAX, FREQHZ, RESTWITHINSEC, P) characterises
%   one loading cycle as an affine operator on the channel state:
%
%       y_out = OP.A * y_in + OP.c            y = [O; I]
%       dose  = OP.g' * y_in + OP.h           dose = int O dt over the cycle
%
%   *** WHY THIS EXISTS ***
%   MSICGATING is linear in (O, I) for a prescribed tau(t).  A day of
%   walking is ~2000 identical cycles; stepping through all of them at the
%   resolution needed to resolve a 1 Hz waveform costs ~2e5 matrix
%   exponentials, and E1 must sweep thousands of loading protocols.
%   Because every cycle presents the SAME waveform, one cycle determines
%   the map, and n cycles follow by iterating it -- exactly, at the cost of
%   three single-cycle integrations.
%
%   Within a cycle, shear magnitude is taken as
%       tau(t) = tau_max |sin(2 pi f t)|,  t in [0, 1/f]
%   then zero for RESTWITHINSEC.  Two shear peaks per load cycle is correct:
%   shear tracks strain RATE, and for eps = eps_pk (1 - cos)/2 the rate
%   peaks once on loading and once on unloading.  The channel responds to
%   magnitude, hence the absolute value.
%
%   Inputs
%     tau_max        (1,1) double  peak shear in the cycle             [Pa]
%     freqHz         (1,1) double  loading frequency                   [Hz]
%     restWithinSec  (1,1) double  rest inserted after the cycle       [s]
%     p              (1,1) struct  parameters
%     opts.nPerCycle (1,1) double  samples per load cycle.  Default 60
%     opts.nRest     (1,1) double  samples in the rest gap.  Default 12
%
%   Output
%     op  (1,1) struct  .A (2x2) .c (2x1) .g (2x1) .h (1,1)
%                       .T [s] cycle duration incl. rest
%
%   See also MSICGATING, BUILDDOSESURROGATE.

%   Project: bone-mechanostat (PROJECT_PLAN v1.5)

arguments
    tau_max (1,1) double {mustBeNonnegative}
    freqHz (1,1) double {mustBePositive}
    restWithinSec (1,1) double {mustBeNonnegative}
    p (1,1) struct
    opts.nPerCycle (1,1) double {mustBePositive} = 60
    opts.nRest (1,1) double {mustBePositive} = 12
end

Tload = 1 / freqHz;
tL = linspace(0, Tload, round(opts.nPerCycle) + 1);
wL = tau_max * abs(sin(2 * pi * freqHz * tL));

if restWithinSec > 0
    tR = Tload + linspace(0, restWithinSec, round(opts.nRest) + 1);
    tvec = [tL, tR(2:end)];
    tau_t = [wL, zeros(1, numel(tR) - 1)];
else
    tvec = tL;
    tau_t = wL;
end

% Linearity: three runs pin down the affine map exactly.
[yc, dc] = localRun([0; 0]);
[y1, d1] = localRun([1; 0]);
[y2, d2] = localRun([0; 1]);

op = struct();
op.c = yc;
op.h = dc;
op.A = [y1 - yc, y2 - yc];
op.g = [d1 - dc; d2 - dc];
op.T = tvec(end);

    function [yEnd, dose] = localRun(y0)
        [O, I, ~, dose] = msicGating(tau_t, tvec, p, y0 = y0);
        yEnd = [O(end); I(end)];
    end
end
