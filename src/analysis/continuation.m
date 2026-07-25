function branch = continuation(paramName, range, opts)
%CONTINUATION Trace the porosity fixed point(s) vs a bifurcation parameter.
%
%   BRANCH = CONTINUATION(PARAMNAME, RANGE) sweeps a bifurcation parameter
%   and, at each value, finds the fixed point(s) of the FROZEN-GEOMETRY
%   porosity dynamics as the zeros of the f_bm nullcline (FBMNULLCLINE).
%   Multiple stable zeros in a range would be bistability with a saddle-node
%   (P3); a single zero shifting continuously is monostability.
%
%   *** WHY FROZEN GEOMETRY (appendix C15) ***
%   The osteoporosis bistability question is about the porosity/remodelling
%   dynamics (months-years).  The envelope geometry evolves on a decades
%   timescale and, under pathological low f_bm, the Frost modelling term is
%   outside its validated range (it drives r_p to absurd values at extreme
%   strain).  Freezing the envelope isolates the porosity dynamics cleanly;
%   the full-system transient is NOT a valid bistability probe there.
%
%   Bifurcation parameters of record (PROJECT_PLAN v1.3 §5): E2 (oestrogen),
%   tau_50 (Piezo1 half-activation), beta_S (SOST basal secretion).
%
%   Inputs
%     paramName    (1,1) string  "E2" | "tau_50" | "beta_S" | any p field
%     range        (1,:) double  parameter values to sweep
%     opts.nFbm    (1,1) double   f_bm grid resolution.  Default 60
%     opts.days    (1,1) double   QSS integration horizon.  Default 1500
%
%   Output
%     branch  (1,1) struct  .param, .fps (cell: fixed points per value),
%                           .stable (cell), .nStable, .class, .fold
%
%   See also FBMNULLCLINE, STEADYSTATE, PLOTBIFURCATION.

%   Project: bone-mechanostat (PROJECT_PLAN v2.3)

arguments
    paramName (1,1) string
    range (1,:) double
    opts.nFbm (1,1) double = 60
    opts.days (1,1) double = 1500
end

p0 = getDefaultParams();
fbmGrid = linspace(0.03, 0.985, opts.nFbm);

branch = struct();
branch.paramName = paramName;
branch.param = range;
branch.fps = cell(1, numel(range));
branch.stable = cell(1, numel(range));
branch.nStable = zeros(1, numel(range));

for k = 1:numel(range)
    if paramName == "E2"
        [df, fg] = fbmNullcline(p0, fbmGrid, days = opts.days, E2 = range(k));
    else
        q = p0; q.(paramName) = range(k);
        [df, fg] = fbmNullcline(q, fbmGrid, days = opts.days);
    end
    % fixed points = sign changes of df; stable if df goes + -> - (df/dfbm<0)
    zc = find(diff(sign(df)) ~= 0);
    fps = arrayfun(@(i) fg(i) + (fg(i+1)-fg(i))*abs(df(i))/(abs(df(i))+abs(df(i+1))), zc);
    stable = df(zc) > df(min(zc+1, numel(df)));
    % also treat the top boundary: if df(end)>0 the attractor is at f_bm~ceiling
    if isempty(fps) && df(end) > 0
        fps = fg(end); stable = true;
    elseif isempty(fps) && df(end) < 0
        fps = fg(1);   stable = true;   % collapse to floor
    end
    branch.fps{k} = fps;
    branch.stable{k} = stable;
    branch.nStable(k) = nnz(stable);
end

maxStable = max(branch.nStable);
if maxStable >= 2
    branch.class = "BISTABLE (saddle-node) -- P3 supported";
    % fold = where the number of stable states changes
    branch.fold = range([false, diff(branch.nStable) ~= 0]);
else
    branch.class = "MONOSTABLE -- single attractor, P3 not supported";
    branch.fold = double.empty(1, 0);
end
end
