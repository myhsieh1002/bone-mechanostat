function [lb, ub, names] = paramBounds(subset)
%PARAMBOUNDS Lower/upper bounds for LHS sampling and calibration.
%
%   [LB, UB, NAMES] = PARAMBOUNDS() returns bounds for every parameter that
%   the CSV marks as varying (lower < upper).  Parameters with lower ==
%   upper are definitional constants (T_day, f_0, n_ot_0, ...) and are
%   excluded -- sampling them would waste LHS/Sobol dimensions.
%
%   [...] = PARAMBOUNDS(SUBSET) restricts to the given parameter names or
%   to a module tag ("M1".."M8").
%
%   Discipline (PROJECT_PLAN §9): at most 4-6 parameters may be opened as
%   free during calibration.  The full bound set returned here is for
%   GLOBAL SENSITIVITY (E6), not for fitting.  calibrate.m must pass an
%   explicit short SUBSET.
%
%   Inputs
%     subset  (1,:) string  Parameter names or a single module tag.
%                           Default: all varying parameters.
%
%   Outputs
%     lb, ub  (1,n) double  Bounds, in the CSV's units for each parameter.
%     names   (1,n) string  Parameter names, aligned with lb/ub.
%
%   See also GETDEFAULTPARAMS, SENSITIVITYLHS, SOBOLINDICES, CALIBRATE.

%   Project: bone-mechanostat (PROJECT_PLAN v1.4)

arguments
    subset (1,:) string = string.empty
end

p = getDefaultParams();
t = p.meta;

varying = t.lower < t.upper;
t = t(varying, :);

if ~isempty(subset)
    isModuleTag = isscalar(subset) && any(strcmp(subset, unique(t.module)));
    if isModuleTag
        t = t(strcmp(t.module, subset), :);
    else
        [tf, loc] = ismember(subset, t.name);
        if ~all(tf)
            error("boneMechanostat:unknownParam", ...
                  "Unknown or non-varying parameter(s): %s", ...
                  strjoin(subset(~tf), ", "));
        end
        t = t(loc, :);
    end
end

names = t.name(:).';
lb    = t.lower(:).';
ub    = t.upper(:).';
end
