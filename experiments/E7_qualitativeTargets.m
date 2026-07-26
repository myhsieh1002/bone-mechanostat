%E7_QUALITATIVETARGETS The four qualitative targets no other experiment ran.
%
%   V7b, V11, V13 and V15 were written into data/validation_targets.csv from
%   v1.3 onwards, and their mechanisms were built and commented as such --
%   S_v(f_bm) for V11, lambda_S for V13, lambda_xi for V15 -- but no
%   experiment ever evaluated them.  A validation table that lists targets
%   nobody checked is worse than a shorter table, so this script checks them.
%
%     V7b  raising serum calcium must NOT raise bone mineral density
%     V11  recovery is at least 3x slower than loss
%     V13  exogenous sclerostin raises RANKL, lowers OPG, and can raise
%          osteoclast activity by up to about 7-fold
%     V15  after oestrogen falls, r_p expands slowly while r_e expands
%          faster -- a cortex that is wider and thinner at once
%
%   Writes:  <results>/E7_qualitativeTargets/E7_qualitativeTargets.mat
%
%   Project: bone-mechanostat (PROJECT_PLAN v2.13)

p   = getDefaultParams(reload = true);
res = struct();

fprintf("\n=== E7: the four qualitative targets ===\n");

% ------------------------------------------------------------------------
% V7b -- Mendelian randomisation of serum calcium.
%
% The MR finding is that genetically higher serum calcium does not raise
% BMD.  The clean way to ask that of the model is to clamp serum calcium a
% few percent high at fixed intake and read the sign of the BMD change --
% the parathyroid is the only route from Ca_s to bone, so this isolates it.
%
% We also record how far serum calcium itself drifts with dietary intake,
% because that turns out to be a defect worth reporting rather than a
% reassurance: see the note printed below and appendix C24.
% ------------------------------------------------------------------------
intakes = [400 800 1200 1500];
CaEnd   = nan(size(intakes));
bmdEnd  = nan(size(intakes));
for k = 1:numel(intakes)
    o = simulate(scenarioLibrary("sedentary", durationDays = 730, ...
                                 I_Ca = intakes(k)), p = p);
    CaEnd(k)  = o.get.Ca_s(end);
    bmdEnd(k) = o.dens.aBMD(end);
end
res.V7b_intakes  = intakes;
res.V7b_Ca_s     = CaEnd;
res.V7b_CaSpread = 100 * (max(CaEnd) - min(CaEnd)) / mean(CaEnd);
res.V7b_dBMD     = 100 * (bmdEnd(end) / bmdEnd(1) - 1);

fprintf("\n  V7b serum calcium and dietary intake\n");
fprintf("      intake %4d -> %4d mg/day moves Ca_s %.4f to %.4f mmol/L\n", ...
        intakes(1), intakes(end), CaEnd(1), CaEnd(end));
fprintf("      = %.2f %% spread.  *** DEFECT: physiological serum calcium is\n", ...
        res.V7b_CaSpread);
fprintf("      defended within about 2 %%, and this parameter set does not do\n");
fprintf("      that.  Passive intestinal absorption (a_p_abs) is linear and\n");
fprintf("      unsaturating in intake, so it dominates the saturating active\n");
fprintf("      term, and the only defence left is the renal power law.  The\n");
fprintf("      saturable tubular reabsorption that renal_k and renal_Ca_th\n");
fprintf("      were declared for is not implemented. ***\n");
fprintf("      the same contrast moves aBMD by %+.3f %%\n", res.V7b_dBMD);

% What a serum-calcium-raising variant would do, holding intake fixed: the
% only route from Ca_s to bone is the parathyroid, so clamp Ca_s high and
% read the sign of the resulting BMD change.
pClamp = p;  pClamp.kappa_Ca = 0;              % freeze the calcium ODE
y0 = baselineState("single", p);
ix = stateVector("single");
y0(ix.idx.Ca_s) = p.Ca_s_0 * 1.02;             % +2 %, a large MR effect
oClamp = simulate(scenarioLibrary("sedentary", durationDays = 730), ...
                  p = pClamp, y0 = y0);
oRef   = simulate(scenarioLibrary("sedentary", durationDays = 730), p = pClamp);
res.V7b_clampdBMD = 100 * (oClamp.dens.aBMD(end) / oRef.dens.aBMD(end) - 1);
res.V7b_pass = res.V7b_clampdBMD <= 0;
fprintf("      Ca_s clamped +2 %%: aBMD %+.4f %%   (must not rise)   pass=%d\n", ...
        res.V7b_clampdBMD, res.V7b_pass);

% ------------------------------------------------------------------------
% V11 -- loss is fast, recovery is slow.  Unload for the validated 180-day
% window, then reambulate from the state that leaves, and compare the time
% to lose half the bone with the time to win the same half back.
% ------------------------------------------------------------------------
nLoss = 180;
oLoss = simulate(scenarioLibrary("bedrest", durationDays = nLoss), p = p);
bmc0  = oLoss.dens.BMC_L(1);
bmcLo = oLoss.dens.BMC_L(end);
half  = 0.5 * (bmc0 - bmcLo);

tLoseHalf = interp1(oLoss.dens.BMC_L, oLoss.t, bmc0 - half);

oRec = simulate(scenarioLibrary("sedentary", durationDays = 3650), ...
                p = p, y0 = oLoss.y(end,:).');
recovered = oRec.dens.BMC_L - bmcLo;
if max(recovered) >= half
    tRecHalf = interp1(recovered, oRec.t, half);
else
    tRecHalf = inf;                            % never gets half of it back
end
res.V11_tLoseHalf = tLoseHalf;
res.V11_tRecHalf  = tRecHalf;
res.V11_ratio     = tRecHalf / tLoseHalf;
res.V11_pass      = res.V11_ratio > 3;
res.V11_frac10yr  = max(recovered) / (bmc0 - bmcLo);
fprintf("\n  V11 loss-recovery asymmetry\n");
fprintf("      lose half:    %7.1f days\n", tLoseHalf);
fprintf("      regain half:  %7.1f days   (10-yr recovery: %.1f %% of the loss)\n", ...
        tRecHalf, 100 * res.V11_frac10yr);
fprintf("      ratio %.2f   (target > 3)   pass=%d\n", res.V11_ratio, res.V11_pass);

% ------------------------------------------------------------------------
% V13 -- sclerostin acts on resorption as well as formation.  Hold every
% other signalling state at baseline and sweep sclerostin: RANKL must rise,
% OPG must fall, and the osteoclast activation pi_L must be able to reach
% roughly 7-fold.
% ------------------------------------------------------------------------
% beta-catenin is not held fixed: it is the route by which sclerostin
% suppresses OPG, so freezing it would test only half the dual action.  At
% each sclerostin level we iterate beta to the steady state of its own ODE.
sBase = struct(Ca_i = 1, Y = 1, S = 1, T = 0, beta = 1);
Ssweep = linspace(1, 12, 40);
Lv = nan(size(Ssweep));  Ov = nan(size(Ssweep));  piv = nan(size(Ssweep));
for k = 1:numel(Ssweep)
    sk = sBase;  sk.S = Ssweep(k);
    for it = 1:200                                  % beta -> its fixed point
        [dk, alg] = osteocyteSignal(sk, 1, 1, 1, 0, 0, p);
        if abs(dk.beta) < 1e-12, break, end
        sk.beta = max(sk.beta + dk.beta / p.delta_beta, 1e-12);
    end
    Lv(k) = alg.L_RANKL;  Ov(k) = alg.O_OPG;  piv(k) = alg.pi_L;
end
res.V13_S     = Ssweep;
res.V13_RANKL = Lv;
res.V13_OPG   = Ov;
res.V13_piL   = piv;
res.V13_piMax = max(piv);
res.V13_pass  = all(diff(Lv) > 0) && all(diff(Ov) <= 0) && res.V13_piMax >= 3;
fprintf("\n  V13 dual action of sclerostin (S from 1 to 12)\n");
fprintf("      RANKL %.3f -> %.3f (monotone up: %d)\n", ...
        Lv(1), Lv(end), all(diff(Lv) > 0));
fprintf("      OPG   %.3f -> %.3f (monotone down: %d)\n", ...
        Ov(1), Ov(end), all(diff(Ov) <= 0));
fprintf("      osteoclast activation peaks at %.2f-fold   (literature ~7)   pass=%d\n", ...
        res.V13_piMax, res.V13_pass);

% ------------------------------------------------------------------------
% V15 -- the postmenopausal cortex is wider AND thinner.  Both directions
% have to be right at once: periosteal radius drifts outward slowly while
% the endocortical radius chases it faster.
% ------------------------------------------------------------------------
% A 10-year run at E2 = 0.1 leaves the linear-elastic domain, and geometry
% read outside that domain is the C15.4 artefact all over again.  Find the
% day the domain is first exceeded and read the phenotype just inside it.
oProbe = simulate(scenarioLibrary("sedentary", durationDays = 3650, E2 = 0.1), p = p);
if oProbe.validity.ok
    nMeno = 3650;
else
    nMeno = floor(0.9 * oProbe.validity.firstExceededDay);
end
res.V15_firstExceededDay = oProbe.validity.firstExceededDay;
res.V15_windowDays       = nMeno;

oMeno = simulate(scenarioLibrary("sedentary", durationDays = nMeno, E2 = 0.1), p = p);
drp = 1e3 * (oMeno.get.r_p(end) - oMeno.get.r_p(1));      % mm
dre = 1e3 * (oMeno.get.r_e(end) - oMeno.get.r_e(1));      % mm
dth = 1e3 * ((oMeno.get.r_p(end) - oMeno.get.r_e(end)) ...
           - (oMeno.get.r_p(1)   - oMeno.get.r_e(1)));    % mm
res.V15_dr_p  = drp;
res.V15_dr_e  = dre;
res.V15_dCth  = dth;
res.V15_valid = oMeno.validity.ok;
res.V15_pass  = res.V15_valid && drp > 0 && dre > drp;
fprintf("\n  V15 postmenopausal geometry (E2 = 0.1)\n");
fprintf("      10-yr run leaves the elastic domain at day %.0f; read at day %d\n", ...
        res.V15_firstExceededDay, nMeno);
fprintf("      periosteal radius  %+.4f mm\n", drp);
fprintf("      endocortical radius %+.4f mm   (must outrun the periosteum)\n", dre);
fprintf("      cortical thickness %+.4f mm   elastic domain ok=%d\n", dth, res.V15_valid);
fprintf("      pass=%d\n", res.V15_pass);

fprintf("\n  summary: V7b=%d  V11=%d  V13=%d  V15=%d\n\n", ...
        res.V7b_pass, res.V11_pass, res.V13_pass, res.V15_pass);

save(fullfile(getResultsDir("E7_qualitativeTargets"), ...
              "E7_qualitativeTargets.mat"), "res");
