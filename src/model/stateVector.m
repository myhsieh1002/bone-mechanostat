function info = stateVector(mode)
%STATEVECTOR Canonical ordering and metadata of the ODE state vector.
%
%   INFO = STATEVECTOR() or STATEVECTOR("single") describes the 17-state
%   single-compartment system.  STATEVECTOR("two") describes the 30-state
%   two-compartment system (13 local states duplicated per site + 4 shared
%   systemic states), per PROJECT_PLAN v1.3 §4.4.
%
%   Every module must index the state through this function.  Hard-coding
%   y(7) somewhere is how sign errors survive code review.
%
%   Input
%     mode  (1,1) string  "single" (default) or "two"
%
%   Output
%     info  (1,1) struct with fields
%       names       (1,n) string  state names, in order
%       units       (1,n) string  units, aligned with names
%       modules     (1,n) string  owning module tag
%       nonNegative (1,n) logical states that ODE15S must keep >= 0
%       idx         (1,1) struct  name -> index, e.g. info.idx.f_bm
%       n           (1,1) double  number of states
%
%   See also RHSFULL, RHSTWOSITE, SIMULATE.

%   Project: bone-mechanostat (PROJECT_PLAN v1.4)

arguments
    mode (1,1) string {mustBeMember(mode, ["single" "two"])} = "single"
end

% --- local (per-site) states: 13 -----------------------------------------
% (v2.3: the two mineral pools m1, m2 collapsed to one intensive rho_min --
%  see MINERALIZATION / appendix C13.)
localNames = ["Ca_i" "Y"   "S"   "T"   "n_ot" "beta" ...
              "R"    "B"   "C"   ...
              "r_p"  "r_e" "f_bm" "rho_min"];
localUnits = ["-"    "-"   "-"   "-"   "-"    "-"    ...
              "-"    "-"   "-"   ...
              "m"    "m"   "-"   "kg/m^3"];
localMods  = ["M4"   "M4"  "M4"  "M4"  "M4"   "M5"   ...
              "M6"   "M6"  "M6"  ...
              "M7"   "M7"  "M7"  "M7"];

% --- shared systemic states: 4 -------------------------------------------
% A_reb (v2.10, P5h) is the compensatory up-regulation of SOST transcription
% built up during sustained anti-sclerostin antibody exposure.  It is a
% property of the treatment, not of a site, so it is shared -- and it is
% ZERO unless romosozumab has been given, which is what keeps every
% drug-free target (V1, V2, V7, V6, V14) untouched by construction.
sysNames = ["Ca_s"    "P"  "V_D" "A_reb"];
sysUnits = ["mmol/L"  "-"  "-"   "-"];
sysMods  = ["M8"      "M8" "M8"  "M4"];

switch mode
    case "single"
        names   = [localNames, sysNames];
        units   = [localUnits, sysUnits];
        modules = [localMods,  sysMods];
    case "two"
        names   = [localNames + "_A", localNames + "_B", sysNames];
        units   = [localUnits,        localUnits,        sysUnits];
        modules = [localMods,         localMods,         sysMods];
end

info = struct();
info.names       = names;
info.units       = units;
info.modules     = modules;
info.n           = numel(names);
info.nonNegative = true(1, info.n);   % every state is a concentration,
                                      % density, radius or fraction
info.idx = struct();
for k = 1:info.n
    info.idx.(matlab.lang.makeValidName(names(k))) = k;
end
end
