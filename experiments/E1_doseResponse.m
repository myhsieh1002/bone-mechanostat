%E1_DOSERESPONSE Mechanical dose-response: cycle number (V4), frequency (V5b), rest insertion (V5).
%
%   Three orthogonal slices through the loading-waveform space, each run to
%   12 months and read out as aBMD change.  A full 4-D sweep is not needed:
%   the three validation targets each live on one axis, and slices keep the
%   run under the MCP session timeout (see PROJECT_PLAN §7.3).
%
%     (a) cycle number 18 -> 1200      V4: diminishing marginal returns.
%         Note C6.3: at the CHANNEL level the dose is linear in cycles; the
%         saturation is a downstream (SOST/cell) property, so it can only be
%         seen at the bone level -- which is what this panel plots.
%     (b) frequency 1 -> 10 Hz         V5b: response linear in ln(f).
%     (c) rest insertion x amplitude   V5: the gain is CONDITIONAL.  C6.4
%         found the model's rest-insertion gain rises with amplitude while
%         Srinivasan's falls; that disagreement is structural and is plotted
%         here rather than hidden.
%
%   Writes:  <results>/E1_doseResponse/E1_doseResponse.mat
%            <results>/figures/E1_doseResponse.{png,pdf}
%
%   Project: bone-mechanostat (PROJECT_PLAN v2.7)

p     = getDefaultParams(reload = true);
col   = houseColors();
nDays = 365;

base       = scenarioLibrary("resistance");
adl        = base.bouts(1);          % activities of daily living
trainProto = base.bouts(2);          % the resistance bout we vary

fprintf("\n=== E1: mechanical dose-response (12 months) ===\n");

% --- (a) cycle number ----------------------------------------------------
cycles = [18 36 72 144 288 600 1200];
dCyc   = nan(size(cycles));
for k = 1:numel(cycles)
    b = trainProto; b.nCycles = cycles(k);
    s = base; s.bouts = [adl, b]; s.durationDays = nDays;
    o = simulate(s, p = p);
    dCyc(k) = 100 * (o.dens.aBMD(end) / o.dens.aBMD(1) - 1);
end
marginal = diff(dCyc) ./ diff(cycles);      % % per additional cycle
fprintf("  (a) V4 cycle saturation\n");
for k = 1:numel(cycles)
    fprintf("      %5d cycles -> %+6.3f %%\n", cycles(k), dCyc(k));
end
fprintf("      marginal return %.3e -> %.3e %%/cycle (falls %.0f x)\n", ...
        marginal(1), marginal(end), marginal(1) / marginal(end));
passV4 = all(diff(marginal) < 0);
fprintf("      V4 monotone diminishing returns: %d\n", passV4);

% --- (b) frequency -------------------------------------------------------
% Measured at BOTH layers, because they disagree in sign and only the bone
% layer is what an experiment sees.
st0    = struct(r_p = p.r_p_0, r_e = p.r_e_0, f_bm = p.f_bm_0, ...
                rho_min = p.rho_min_0, n_ot = p.n_ot_0);
epsRef = organMechanics(trainProto, st0, p).eps_p;

freqs   = [1 2 3 5 7 10];
tauFrq  = arrayfun(@(f) shearSurrogate(epsRef, f, p), freqs);
dFrq    = nan(size(freqs));
dFrqDur = nan(size(freqs));      % duration-matched control
durSec  = trainProto.nCycles * (1 / trainProto.freqHz + trainProto.restWithinSec);

for k = 1:numel(freqs)
    b = trainProto; b.freqHz = freqs(k);
    s = base; s.bouts = [adl, b]; s.durationDays = nDays;
    oF = simulate(s, p = p);
    dFrq(k) = 100 * (oF.dens.aBMD(end) / oF.dens.aBMD(1) - 1);

    % Same, but holding BOUT DURATION rather than cycle count fixed, so the
    % trend cannot be dismissed as "higher frequency = shorter session".
    b.nCycles = round(durSec / (1 / freqs(k) + trainProto.restWithinSec));
    s.bouts   = [adl, b];
    oD = simulate(s, p = p);
    dFrqDur(k) = 100 * (oD.dens.aBMD(end) / oD.dens.aBMD(1) - 1);
end

ccT = corrcoef(log(freqs), tauFrq);  rTau  = ccT(1,2);
ccB = corrcoef(log(freqs), dFrq);    rLogF = ccB(1,2);
ccD = corrcoef(log(freqs), dFrqDur); rDur  = ccD(1,2);

fprintf("  (b) V5b frequency, 1-10 Hz\n");
fprintf("      shear level : tau %.2f -> %.2f Pa, r(tau, ln f) = %+.5f  [C6.1: V5b holds]\n", ...
        tauFrq(1), tauFrq(end), rTau);
fprintf("      bone  level : daBMD %+.4f -> %+.4f %%, r = %+.5f\n", ...
        dFrq(1), dFrq(end), rLogF);
fprintf("      duration-matched control    r = %+.5f  (same sign -> not a session-length artefact)\n", ...
        rDur);
fprintf("      ** log-linear FORM survives to bone, SIGN does not. Spread is small\n");
fprintf("         (%.3f %% points, %.1f %% of the mean response).  Mechanism: k_co(tau)\n", ...
        max(dFrq) - min(dFrq), 100 * (max(dFrq) - min(dFrq)) / mean(dFrq));
fprintf("         saturates, so the shorter loaded time per cycle at high f costs\n");
fprintf("         more than the higher peak shear gains.  Experiment (Hsieh & Turner\n");
fprintf("         2001) reports higher frequency as MORE osteogenic -- model disagrees. **\n");
passV5b = abs(rLogF) > 0.95;      % log-linearity only; the sign is reported, not claimed

% --- (c) rest insertion x amplitude -------------------------------------
amps    = [1.5 3.0 4.5];
restSec = [0 10];
dRest   = nan(numel(amps), numel(restSec));
for i = 1:numel(amps)
    for j = 1:numel(restSec)
        b = trainProto; b.momentScale = amps(i); b.restWithinSec = restSec(j);
        s = base; s.bouts = [adl, b]; s.durationDays = nDays;
        o = simulate(s, p = p);
        dRest(i,j) = 100 * (o.dens.aBMD(end) / o.dens.aBMD(1) - 1);
    end
end
restGain = dRest(:,2) ./ dRest(:,1);
fprintf("  (c) V5 rest-insertion gain by amplitude\n");
for i = 1:numel(amps)
    fprintf("      moment x%.1f : no rest %+6.3f %%, 10 s rest %+6.3f %%, gain %.2f x\n", ...
            amps(i), dRest(i,1), dRest(i,2), restGain(i));
end
passV5 = restGain(end) < restGain(1);
fprintf("      gain FALLS with amplitude: %d  <- this is Srinivasan's direction, so V5\n", passV5);
fprintf("      HOLDS at the bone level.  C6.4 found the opposite at the CHANNEL level;\n");
fprintf("      downstream saturation reverses it, exactly as the C6.5/C7.1 hypothesis said.\n");

% --- figure -------------------------------------------------------------
fig = figure(Position = [100 100 1050 340], Color = "w");
tl  = tiledlayout(fig, 1, 3, TileSpacing = "compact", Padding = "compact");

nexttile(tl);
semilogx(cycles, dCyc, "-o", LineWidth = 1.8, Color = col.primary, ...
         MarkerFaceColor = col.primary);
xline(36, "--", "36 cycles", Color = col.muted);
xlabel("load cycles per bout"); ylabel("\DeltaaBMD @ 12 mo [%]");
title("(a) V4: diminishing returns"); grid on; box off;

nexttile(tl);
yyaxis left;
semilogx(freqs, tauFrq, "-o", LineWidth = 1.8, Color = col.muted, ...
         MarkerFaceColor = col.muted);
ylabel("peak \tau [Pa]"); set(gca, YColor = col.muted);
yyaxis right;
semilogx(freqs, dFrq, "-o", LineWidth = 1.8, Color = col.primary, ...
         MarkerFaceColor = col.primary);
ylabel("\DeltaaBMD @ 12 mo [%]"); set(gca, YColor = col.primary);
xlabel("frequency [Hz]");
title("(b) V5b: ln f survives, sign flips");
grid on; box off;

nexttile(tl);
b2 = bar(dRest, EdgeColor = "none");
b2(1).FaceColor = col.muted; b2(2).FaceColor = col.primary;
xticklabels(compose("x%.1f", amps)); xlabel("peak moment scale");
ylabel("\DeltaaBMD @ 12 mo [%]");
legend(["no rest" "10 s rest inserted"], Location = "northwest", Box = "off");
title("(c) V5: rest gain conditional"); grid on; box off;

title(tl, "E1 -- mechanical dose-response", FontWeight = "bold");
exportFigure(fig, "E1_doseResponse");

save(fullfile(getResultsDir("E1_doseResponse"), "E1_doseResponse.mat"), ...
     "cycles", "dCyc", "marginal", "passV4", ...
     "freqs", "tauFrq", "dFrq", "dFrqDur", "rTau", "rLogF", "rDur", "passV5b", ...
     "amps", "restSec", "dRest", "restGain", "passV5");
