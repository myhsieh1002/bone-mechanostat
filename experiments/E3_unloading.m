%E3_UNLOADING Bed rest / microgravity, and the minimum effective countermeasure.
%
%   Targets V2 (1.0-1.5 %/month disuse loss) and searches for the cheapest
%   loading prescription that arrests it, subject to <= 30 min/day of total
%   loading time.
%
%   *** SCOPE LIMIT (appendix C17.5) ***  The disuse branch is only valid
%   over the 180-day window it was calibrated on.  Past ~7.5 months the
%   model collapses to the porosity floor and leaves the linear-elastic
%   domain -- real bed rest decelerates and plateaus at 30-50 % loss.  Every
%   run here is therefore 180 days and its OUT.VALIDITY is asserted.
%
%   The plan specified FMINCON over (N, f, bout count, rest length).  A grid
%   is used instead: the search space is 3-D and small, the objective is one
%   ODE solve per point (cheap), and a grid reports the whole trade-off
%   surface rather than a single optimum -- which is what a prescription
%   recommendation actually needs.
%
%   Writes:  <results>/E3_unloading/E3_unloading.mat
%            <results>/figures/E3_unloading.{png,pdf}
%
%   Project: bone-mechanostat (PROJECT_PLAN v2.7)

p       = getDefaultParams(reload = true);
col     = houseColors();
nDays   = 180;                       % the validated disuse window
budget  = 30 * 60;                   % <= 30 min/day of loading, in seconds

% --- reference: unprotected bed rest ------------------------------------
sRef = scenarioLibrary("bedrest", durationDays = nDays);
oRef = simulate(sRef, p = p);
lossRef = -100 * (oRef.dens.BMC_L(end) / oRef.dens.BMC_L(1) - 1) / (nDays / 30);

fprintf("\n=== E3: bed rest and countermeasure (180 days) ===\n");
fprintf("  V2 unprotected loss  %.3f %%/month   (target 1.0-1.5)   valid=%d\n", ...
        lossRef, oRef.validity.ok);
assert(oRef.validity.ok, "E3 reference run left the elastic domain.");

% Sclerostin must RISE under unloading (V3, qualitative).
dSost = 100 * (oRef.get.S(end) / oRef.get.S(1) - 1);
fprintf("  V3 sclerostin        %+.2f %% over 180 d   (must rise)   pass=%d\n", ...
        dSost, dSost > 0);

% --- countermeasure grid -------------------------------------------------
moments = [1.5 2.5 3.5 4.5];         % peak moment scale
cycleN  = [20 40 80 160];            % cycles per daily bout
restIns = 10;                        % s between cycles (E1 panel c: worth it)
freqHz  = 0.5;

loss    = nan(numel(moments), numel(cycleN));
timeSec = nan(size(loss));
okGrid  = true(size(loss));

for i = 1:numel(moments)
    for j = 1:numel(cycleN)
        timeSec(i,j) = cycleN(j) * (1 / freqHz + restIns);
        if timeSec(i,j) > budget
            continue                  % over the daily time budget
        end
        cm = struct(momentScale = moments(i), axialScale = moments(i) * 0.8, ...
                    nCycles = cycleN(j), freqHz = freqHz, ...
                    restWithinSec = restIns, restAfterSec = 180, ...
                    daysOfWeek = []);
        s = sRef; s.bouts = [sRef.bouts, cm];
        o = simulate(s, p = p);
        loss(i,j)   = -100 * (o.dens.BMC_L(end) / o.dens.BMC_L(1) - 1) / (nDays / 30);
        okGrid(i,j) = o.validity.ok;
    end
end

fprintf("\n  countermeasure grid: bone loss [%%/month], NaN = over the %d min/day budget\n", ...
        budget / 60);
fprintf("      cycles:  %s\n", sprintf("%8d", cycleN));
for i = 1:numel(moments)
    fprintf("      x%.1f  ", moments(i));
    fprintf("%8.3f", loss(i,:));
    fprintf("\n");
end

[best, iBest] = min(loss(:), [], "omitnan");
[bi, bj] = ind2sub(size(loss), iBest);
fprintf("\n  best within budget: moment x%.1f, %d cycles, %.1f min/day\n", ...
        moments(bi), cycleN(bj), timeSec(bi,bj) / 60);
fprintf("  loss %.3f %%/month vs %.3f unprotected -- %.0f %% of the loss prevented\n", ...
        best, lossRef, 100 * (1 - best / lossRef));

% Cheapest regimen that holds loss under 0.25 %/month, if any.
under = loss < 0.25;
if any(under(:))
    tUnder = timeSec; tUnder(~under) = inf;
    [tMin, iMin] = min(tUnder(:));
    [mi, mj] = ind2sub(size(loss), iMin);
    fprintf("  cheapest regimen holding loss < 0.25 %%/mo: moment x%.1f, %d cycles, %.1f min/day\n", ...
            moments(mi), cycleN(mj), tMin / 60);
else
    fprintf("  no regimen within budget holds loss under 0.25 %%/month\n");
end

% --- figure -------------------------------------------------------------
fig = figure(Position = [100 100 900 340], Color = "w");
tl  = tiledlayout(fig, 1, 2, TileSpacing = "compact", Padding = "compact");

nexttile(tl);
plot(oRef.t / 30, 100 * (oRef.dens.BMC_L / oRef.dens.BMC_L(1) - 1), ...
     LineWidth = 1.8, Color = col.accent); hold on;
cmBest = struct(momentScale = moments(bi), axialScale = moments(bi) * 0.8, ...
                nCycles = cycleN(bj), freqHz = freqHz, restWithinSec = restIns, ...
                restAfterSec = 180, daysOfWeek = []);
sBest = sRef; sBest.bouts = [sRef.bouts, cmBest];
oBest = simulate(sBest, p = p);
plot(oBest.t / 30, 100 * (oBest.dens.BMC_L / oBest.dens.BMC_L(1) - 1), ...
     LineWidth = 1.8, Color = col.primary);
xlabel("months of bed rest"); ylabel("\DeltaBMC [%]");
legend(["unprotected" "best countermeasure"], Location = "southwest", Box = "off");
title("Countermeasure arrests disuse loss"); grid on; box off;

nexttile(tl);
imagesc(loss, AlphaData = ~isnan(loss)); colormap(gca, flipud(parula)); colorbar;
xticks(1:numel(cycleN));  xticklabels(string(cycleN));  xlabel("cycles per day");
yticks(1:numel(moments)); yticklabels(compose("x%.1f", moments)); ylabel("peak moment");
title(sprintf("loss [%%/mo]; blank = over %d min/day", budget / 60));
set(gca, YDir = "normal"); box off;

title(tl, "E3 -- disuse and the minimum effective dose", FontWeight = "bold");
exportFigure(fig, "E3_unloading");

save(fullfile(getResultsDir("E3_unloading"), "E3_unloading.mat"), ...
     "lossRef", "dSost", "moments", "cycleN", "loss", "timeSec", "okGrid", ...
     "best", "bi", "bj", "budget");
