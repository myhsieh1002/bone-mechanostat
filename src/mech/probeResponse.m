function [dBMC, out] = probeResponse(momentScale, nCycles, restWithinSec, days, p, opts)
%PROBERESPONSE Bone response to a single prescribed loading protocol.
%
%   [DBMC, OUT] = PROBERESPONSE(MOMENTSCALE, NCYCLES, RESTWITHINSEC, DAYS, P)
%   builds a one-bout scenario, simulates it, and returns the percentage
%   change in bone mineral content per unit length.
%
%   This exists for the appendix C6.5 joint test: the channel model alone
%   cannot produce V4 (cycle-number saturation) or V5's amplitude
%   conditionality, so both must be checked at the level of the BONE
%   RESPONSE, after the downstream Hill functions have had their say.
%   Measuring dose is not enough -- dose is linear in cycle count.
%
%   Inputs
%     momentScale    (1,1) double  peak moment / M_L_0                  [-]
%     nCycles        (1,1) double  load cycles per day                  [-]
%     restWithinSec  (1,1) double  rest inserted between cycles         [s]
%     days           (1,1) double  protocol duration                  [day]
%     p              (1,1) struct  parameters
%     opts.freqHz    (1,1) double  loading frequency.  Default 1       [Hz]
%     opts.background (1,1) logical add 2000-cycle daily activity.  Default true
%
%   Outputs
%     dBMC  (1,1) double  percentage change in BMC per unit length      [%]
%     out   (1,1) struct  full SIMULATE output
%
%   See also SIMULATE, SCENARIOLIBRARY, DAILYDOSE.

%   Project: bone-mechanostat (PROJECT_PLAN v1.7)

arguments
    momentScale (1,1) double {mustBeNonnegative}
    nCycles (1,1) double {mustBeNonnegative}
    restWithinSec (1,1) double {mustBeNonnegative}
    days (1,1) double {mustBePositive}
    p (1,1) struct
    opts.freqHz (1,1) double {mustBePositive} = 1
    opts.background (1,1) logical = true
end

% *** The probe bout sits ON TOP of normal daily activity. ***
% Loading experiments (Yang 2017, Srinivasan 2002) add a protocol to
% animals that are otherwise cage-active; the contrast is loaded-vs-
% contralateral, not loaded-vs-disuse.  An earlier version omitted this
% background, so every protocol sat below the maintenance threshold, all
% groups were losing bone, and the comparison measured how fast disuse
% proceeds rather than how loading responds.
adl = struct(momentScale = 1, axialScale = 1, nCycles = 2000, freqHz = 1, ...
             restWithinSec = 0, restAfterSec = 0, daysOfWeek = []);

bout = struct(momentScale = momentScale, axialScale = 1, ...
              nCycles = nCycles, freqHz = opts.freqHz, ...
              restWithinSec = restWithinSec, restAfterSec = 0, ...
              daysOfWeek = []);

if opts.background
    bouts = [adl, bout];
else
    bouts = bout;
end

scenario = struct( ...
    name = "probe", durationDays = days, E2 = p.E2_0, I_Ca = p.I_Ca_0, ...
    drug = struct(romosozumab = struct(startDay = NaN, stopDay = NaN), ...
                  bisphosphonate = struct(startDay = NaN, stopDay = NaN)), ...
    sites = "single", bouts = bouts);

out  = simulate(scenario, p = p);
dBMC = 100 * (out.dens.BMC_L(end) / out.dens.BMC_L(1) - 1);
end
