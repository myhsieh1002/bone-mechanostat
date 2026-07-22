function s = scenarioLibrary(name, opts)
%SCENARIOLIBRARY Named simulation scenarios (loading, calcium, hormones, drugs).
%
%   S = SCENARIOLIBRARY(NAME) returns a scenario struct for one of:
%
%     "sedentary"     baseline daily activity only
%     "resistance"    sedentary + resistance training 3x/week
%     "bedrest"       mechanical load removed (tau -> ~0)
%     "spaceflight"   as bedrest, plus an optional in-flight countermeasure
%     "tennis"        two-site: dominant humerus loaded, contralateral not
%     "romosozumab"   sedentary + 12 months Scl-Ab, then washout
%     "lowCalcium"    sedentary at 400 mg/day
%     "highCalcium"   sedentary at 1500 mg/day
%
%   *** INTERFACE CONTRACT (PROJECT_PLAN v1.3 §7.1) ***
%   The loading specification is expressed as FORCE -- peak bending moment
%   M_L [N*m] and peak axial force F_L [N] -- and NEVER as strain.  Strain
%   is a regulated OUTPUT computed by organMechanics from the current
%   geometry and material state; prescribing it would cut the mechanostat
%   feedback loop, which is precisely the v1.2 defect that v1.3 fixed.
%   test_closedloop.m enforces the absence of strain-like fields here.
%
%   Loading is given per bout.  Each element of S.bouts is a struct:
%     momentScale   (1,1) double  peak bending moment / p.M_L_0        [-]
%     axialScale    (1,1) double  peak axial force  / p.F_L_0          [-]
%     nCycles       (1,1) double  load cycles in this bout             [-]
%     freqHz        (1,1) double  loading frequency                    [Hz]
%     restWithinSec (1,1) double  rest inserted BETWEEN cycles         [s]
%     restAfterSec  (1,1) double  rest following this bout             [s]
%     daysOfWeek    (1,:) double  1=Mon .. 7=Sun; [] means every day
%
%   Inputs
%     name              (1,1) string
%     opts.durationDays (1,1) double = 730     % 24 months
%     opts.E2           (1,1) double = 1       % oestrogen, premenopausal = 1
%     opts.I_Ca         (1,1) double = NaN     % mg/day; NaN -> CSV default
%
%   Output
%     s  (1,1) struct  Scenario definition; see SIMULATE for how it is used.
%
%   See also SIMULATE, ORGANMECHANICS, GETDEFAULTPARAMS.

%   Project: bone-mechanostat (PROJECT_PLAN v1.4)

arguments
    name (1,1) string
    opts.durationDays (1,1) double {mustBePositive} = 730
    opts.E2 (1,1) double {mustBeNonnegative} = 1
    opts.I_Ca (1,1) double = NaN
end

p = getDefaultParams();

s = struct();
s.name         = name;
s.durationDays = opts.durationDays;
s.E2           = opts.E2;
s.I_Ca         = opts.I_Ca;
if isnan(s.I_Ca)
    s.I_Ca = p.I_Ca_0;
end
s.drug  = struct("romosozumab", struct("startDay", NaN, "stopDay", NaN), ...
                 "bisphosphonate", struct("startDay", NaN, "stopDay", NaN));
s.sites = "single";

% Baseline activities of daily living: low amplitude, many cycles (walking,
% reaching).  Present in every scenario except unloading.
adl = localBout(momentScale = 1.0, axialScale = 1.0, nCycles = 2000, ...
                freqHz = 1.0, restWithinSec = 0, restAfterSec = 0);

switch name
    case "sedentary"
        s.bouts = adl;

    case "resistance"
        training = localBout(momentScale = 3.0, axialScale = 2.5, ...
                             nCycles = 40, freqHz = 0.5, ...
                             restWithinSec = 10, restAfterSec = 180, ...
                             daysOfWeek = [1 3 5]);
        s.bouts = [adl, training];

    case {"bedrest", "spaceflight"}
        s.bouts = localBout(momentScale = 0.02, axialScale = 0.02, ...
                            nCycles = 200, freqHz = 1.0, ...
                            restWithinSec = 0, restAfterSec = 0);

    case "tennis"
        s.sites = "two";
        playing = localBout(momentScale = 4.0, axialScale = 2.0, ...
                            nCycles = 300, freqHz = 1.5, ...
                            restWithinSec = 2, restAfterSec = 600, ...
                            daysOfWeek = [1 2 4 6]);
        s.boutsA = [adl, playing];   % dominant humerus
        s.boutsB = adl;              % contralateral
        s.bouts  = s.boutsA;         % convenience for single-site tools
        s.durationDays = max(opts.durationDays, 5 * 365);

    case "romosozumab"
        s.bouts = adl;
        s.drug.romosozumab.startDay = 0;
        s.drug.romosozumab.stopDay  = 365;

    case "lowCalcium"
        s.bouts = adl;
        s.I_Ca  = 400;

    case "highCalcium"
        s.bouts = adl;
        s.I_Ca  = 1500;

    otherwise
        error("boneMechanostat:unknownScenario", ...
              "Unknown scenario '%s'.  See HELP SCENARIOLIBRARY.", name);
end

s = localValidate(s);
end

% -------------------------------------------------------------------------
function b = localBout(o)
arguments
    o.momentScale (1,1) double {mustBeNonnegative}
    o.axialScale (1,1) double {mustBeNonnegative}
    o.nCycles (1,1) double {mustBeNonnegative}
    o.freqHz (1,1) double {mustBePositive}
    o.restWithinSec (1,1) double {mustBeNonnegative} = 0
    o.restAfterSec (1,1) double {mustBeNonnegative} = 0
    o.daysOfWeek (1,:) double = []
end
b = o;
end

% -------------------------------------------------------------------------
function s = localValidate(s)
%LOCALVALIDATE Reject any attempt to prescribe strain directly.
forbidden = ["strain" "eps" "epsilon" "microstrain" "SED", ...
             "strainEnergy" "epsPeak" "eps_peak"];
fn = string(fieldnames(s));
hit = fn(ismember(lower(fn), lower(forbidden)));
if ~isempty(hit)
    error("boneMechanostat:strainControlledInput", ...
          ["Scenario '%s' specifies strain-like field(s): %s.\n" ...
           "Loading MUST be force-controlled (momentScale / axialScale). " ...
           "Prescribing strain re-opens the mechanostat feedback loop " ...
           "(PROJECT_PLAN v1.3 §4.2 M1, appendix C1)."], s.name, ...
          strjoin(hit, ", "));
end
end
