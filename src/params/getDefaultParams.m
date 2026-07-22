function p = getDefaultParams(opts)
%GETDEFAULTPARAMS Build the single parameter struct from the literature CSV.
%
%   P = GETDEFAULTPARAMS() reads data/parameters_literature.csv and returns
%   a struct whose fields are the parameter NAMES and whose values are the
%   numeric VALUE column (in the units given by the CSV).
%
%   P = GETDEFAULTPARAMS(reload=true) bypasses the cache.
%
%   Metadata (unit, module, source, confidence, bounds, description) is
%   carried in P.meta as a table indexed by parameter name.  Numeric fields
%   and metadata are deliberately kept apart so that RHS code can do
%   P.tau_50 without tripping over non-numeric fields.
%
%   Contract (PROJECT_PLAN §7.1): this is the ONLY place parameter values
%   enter the code base.  Hard-coding a numeric constant anywhere in src/
%   is a defect, not a shortcut -- test_units.m enforces that every symbol
%   used by the model resolves through here.
%
%   Output
%     p  (1,1) struct  Numeric parameter fields + p.meta (table) +
%                      p.units (struct, name -> unit string).
%
%   Example
%     p = getDefaultParams();
%     p.tau_50            % 1.0  [Pa]  MSIC half-activation shear stress
%     p.units.tau_50      % "Pa"
%
%   See also PARAMBOUNDS, SCENARIOLIBRARY, PROJECTROOT.

%   Project: bone-mechanostat (PROJECT_PLAN v1.4)

arguments
    opts.reload (1,1) logical = false
end

persistent cachedP
if ~isempty(cachedP) && ~opts.reload
    p = cachedP;
    return
end

csvFile = fullfile(projectRoot(), "data", "parameters_literature.csv");
if ~isfile(csvFile)
    error("boneMechanostat:missingParamFile", ...
          "Parameter file not found: %s", csvFile);
end

t = readtable(csvFile, TextType = "string", VariableNamingRule = "preserve");

requiredCols = ["name" "symbol" "value" "unit" "lower" "upper" ...
                "module" "source" "confidence" "description"];
missingCols = setdiff(requiredCols, string(t.Properties.VariableNames));
if ~isempty(missingCols)
    error("boneMechanostat:badParamSchema", ...
          "parameters_literature.csv missing column(s): %s", ...
          strjoin(missingCols, ", "));
end

% Duplicate names would silently shadow each other -- fail loudly instead.
[uniqueNames, ~, idx] = unique(t.name, "stable");
if numel(uniqueNames) < height(t)
    dupNames = uniqueNames(accumarray(idx, 1) > 1);
    error("boneMechanostat:duplicateParam", ...
          "Duplicate parameter name(s) in CSV: %s", strjoin(dupNames, ", "));
end

% Guard against a parameter name colliding with the metadata fields.  This
% has to happen BEFORE the assignment loop: a parameter called "units"
% would overwrite p.units with a number and the next iteration would fail
% with an unhelpful error instead of this one.
reserved = ["meta" "units"];
clash = intersect(reserved, string(t.name));
if ~isempty(clash)
    error("boneMechanostat:reservedParamName", ...
          "Parameter name(s) collide with reserved fields: %s", ...
          strjoin(clash, ", "));
end

p = struct();
p.units = struct();
for k = 1:height(t)
    name = matlab.lang.makeValidName(t.name(k));
    p.(name) = t.value(k);
    p.units.(name) = t.unit(k);
end

p.meta = t;
p.meta.Properties.RowNames = cellstr(t.name);

cachedP = p;
end
