function assertForceControlled(s)
%ASSERTFORCECONTROLLED Reject any scenario that prescribes strain directly.
%
%   ASSERTFORCECONTROLLED(S) throws boneMechanostat:strainControlledInput if
%   the scenario struct S carries a strain-like field.
%
%   Loading must be specified as FORCE (momentScale / axialScale).  Strain
%   is a regulated OUTPUT of ORGANMECHANICS, computed from the current
%   geometry and material state.  Prescribing it re-opens the mechanostat
%   feedback loop -- the v1.2 defect that made f_bm a pure integrator and
%   left the system without a set point (PROJECT_PLAN v1.3 appendix C1).
%
%   This lives in its own file so that SCENARIOLIBRARY and
%   TEST_CLOSEDLOOP exercise the SAME code.  An earlier version kept a
%   private copy in each, and the test passed against its own copy while
%   the real guard was broken.
%
%   Input
%     s  (1,1) struct  scenario definition
%
%   See also SCENARIOLIBRARY, ORGANMECHANICS.

%   Project: bone-mechanostat (PROJECT_PLAN v1.4)

arguments
    s (1,1) struct
end

forbidden = ["strain" "eps" "epsilon" "microstrain" "sed" ...
             "strainenergy" "epspeak" "eps_peak"];

fn = string(fieldnames(s));
hit = fn(ismember(lower(fn), forbidden));

if ~isempty(hit)
    name = "<unnamed>";
    if isfield(s, "name")
        name = string(s.name);
    end
    % NOTE: build the message with + (string concatenation).  Writing
    % ["a" "b"] here would create a 1x2 string ARRAY, and error() would
    % reject it as an invalid format -- masking this error ID with
    % MATLAB:badformat_mx.  That exact bug shipped in the first draft.
    msg = "Scenario '%s' specifies strain-like field(s): %s." + newline + ...
          "Loading MUST be force-controlled (momentScale / axialScale). " + ...
          "Prescribing strain re-opens the mechanostat feedback loop " + ...
          "(PROJECT_PLAN v1.3 4.2 M1, appendix C1).";
    error("boneMechanostat:strainControlledInput", msg, ...
          name, strjoin(hit, ", "));
end
end
