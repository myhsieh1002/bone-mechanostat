function [D_mech, detail] = dailyDose(bouts, tauScale, p, opts)
%DAILYDOSE M3 -- integrate channel opening over one full day.
%
%   [D_MECH, DETAIL] = DAILYDOSE(BOUTS, TAUSCALE, P) returns
%   D_mech = int_day O(t) dt for the given bout structure, where TAUSCALE
%   is the peak shear stress [Pa] that a bout of unit momentScale would
%   produce.  Each bout's own peak shear is TAUSCALE * bout.momentScale
%   (peak shear is linear in strain, and strain is linear in load).
%
%   The day is assembled as
%     for each bout:  nCycles x (load cycle + restWithin)  then restAfter
%     remainder of the 86400 s day: quiescent
%
%   Cycles inside a bout are advanced with the exact affine map from
%   MSICCYCLEOPERATOR rather than by stepping; the quiescent remainder is
%   one exact matrix exponential.  A day therefore costs a handful of
%   integrations regardless of how many cycles it contains.
%
%   Inputs
%     bouts     (1,:) struct  scenario bout structure
%     tauScale  (1,1) double  peak shear at momentScale = 1            [Pa]
%     p         (1,1) struct  parameters
%     opts.y0   (:,1) double  initial [O; I].  Default resting state
%
%   Outputs
%     D_mech  (1,1) double  int O dt over the day                      [s]
%     detail  (1,1) struct  .perBout [s], .quiescent [s], .loadedTime [s],
%                           .yEnd, .meanO
%
%   See also MSICCYCLEOPERATOR, BUILDDOSESURROGATE, LOADINGDOSE.

%   Project: bone-mechanostat (PROJECT_PLAN v1.5)

arguments
    bouts (1,:) struct
    tauScale (1,1) double {mustBeNonnegative}
    p (1,1) struct
    opts.y0 (:,1) double = double.empty(0,1)
end

if isempty(opts.y0)
    y = msicRestingState(p);
else
    y = opts.y0(1:2);
end

D_mech  = 0;
tUsed   = 0;
tLoaded = 0;
perBout = zeros(1, numel(bouts));

for k = 1:numel(bouts)
    b = bouts(k);
    if b.nCycles <= 0
        continue
    end

    op = msicCycleOperator(tauScale * b.momentScale, b.freqHz, ...
                           b.restWithinSec, p);

    dBout = 0;
    for n = 1:round(b.nCycles)
        dBout = dBout + op.g.' * y + op.h;
        y = op.A * y + op.c;
    end

    perBout(k) = dBout;
    D_mech = D_mech + dBout;
    tUsed   = tUsed + round(b.nCycles) * op.T + b.restAfterSec;
    tLoaded = tLoaded + round(b.nCycles) * op.T;

    if b.restAfterSec > 0
        [y, dRest] = localQuiescent(y, b.restAfterSec, p);
        D_mech = D_mech + dRest;
    end
end

% Remainder of the day at zero shear.
tRemain = max(0, p.T_day - tUsed);
[y, dQuiet] = localQuiescent(y, tRemain, p);
D_mech = D_mech + dQuiet;

detail = struct();
detail.perBout    = perBout;
detail.quiescent  = dQuiet;
detail.loadedTime = tLoaded;
detail.yEnd       = y;
detail.meanO      = D_mech / p.T_day;
end

% -------------------------------------------------------------------------
function [yEnd, dose] = localQuiescent(y0, dt, p)
%LOCALQUIESCENT Exact relaxation at tau = 0 over an arbitrarily long dt.
%   Constant coefficients, so one matrix exponential is exact.  The dose is
%   obtained by augmenting the state with its own running integral.
if dt <= 0
    yEnd = y0;
    dose = 0;
    return
end

kco = msicOpeningRate(0, p);
M = [-(kco + p.k_oc + p.k_oi), -kco; ...
      p.k_oi,                  -p.k_ic];
b = [kco; 0];

% Augment: [O; I; 1; J] with dJ/dt = O.
Aug = [M,          b,        zeros(2,1); ...
       zeros(1,2), 0,        0; ...
       1, 0,       0,        0];
E = expm(Aug * dt);
s = E * [y0; 1; 0];

yEnd = s(1:2);
dose = s(4);
end
