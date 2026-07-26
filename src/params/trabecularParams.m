function q = trabecularParams(p, opts)
%TRABECULARPARAMS Parameter set for a vertebral TRABECULAR compartment (P5d).
%
%   Q = TRABECULARPARAMS() returns a parameter struct describing a lumbar
%   vertebral body instead of a humeral diaphysis.  The BIOLOGY is untouched
%   -- every signalling, cell-population and systemic parameter is shared
%   with the cortical set, because SITERHS is the single source of truth for
%   per-site biology.  Only structure, geometry, load and the two things
%   those force to change are overridden.
%
%   Why this exists (appendix C14): V8 (romosozumab, lumbar spine, +11-14 %
%   at 12 months) and V10 (post-withdrawal loss) are SPINE numbers, and the
%   spine is trabecular.  The cortical model sits at f_bm ~ 0.95, almost at
%   the densification ceiling, so it cannot reach those magnitudes without
%   the mineralisation artefact that v2.3 removed.
%
%   *** THE TWO NON-OBVIOUS OVERRIDES (appendix C19) ***
%
%   K_tau.  The osteocyte signalling chain is SHARED, so both compartments
%   must sit at the same emergent shear set point or the trabecular site
%   will not be at a steady state.  A vertebral body at realistic load and
%   BV/TV carries ~2800 ue of tissue strain against the cortex's 762 ue, so
%   the poroelastic transfer K_tau must differ.  That is defensible rather
%   than a fudge: K_tau is a microstructural property (permeability,
%   canalicular geometry) and trabecular packets are not osteonal cortex.
%   It is set here BY MATCHING baseline shear, not by fitting an outcome.
%
%   k_res.  Trabecular bone turns over far faster than cortical (literature
%   15-30 %/yr against 5-10).  With the same absolute surface velocity, a
%   compartment holding 8x less bone behind a 7.7x thinner wall turns over
%   ~60x faster -- 438 %/yr if left alone.  k_res is therefore calibrated
%   against the TRABECULAR turnover target, exactly as k_res was calibrated
%   against V1 for cortex.  V8/V10 stay hold-outs.
%
%   Inputs
%     p               (1,1) struct  cortical parameters.  Default GETDEFAULTPARAMS()
%     opts.BVTV       (1,1) double  bone volume fraction.  Default 0.12
%     opts.turnover   (1,1) double  target turnover [%/yr].  Default 20
%
%   Output
%     q  (1,1) struct  parameters for the trabecular compartment
%
%   See also GETDEFAULTPARAMS, BALANCEBONEFORMATION, SITERHS.

%   Project: bone-mechanostat (PROJECT_PLAN v2.8, appendix C19)

arguments
    p (1,1) struct = getDefaultParams()
    opts.BVTV (1,1) double {mustBePositive} = 0.12
    opts.turnover (1,1) double {mustBePositive} = 20
end

q = p;

% --- geometry and structure, from the vertebral literature ---------------
q.r_p_0  = 17.0e-3;    % L2 vertebral body radius; Tot.Ar ~ 900 mm^2
q.r_e_0  =  1.0e-3;    % essentially solid: the tube model needs r_e < r_p
q.f_bm_0 = opts.BVTV;  % vertebral BV/TV, 0.07-0.15 in adults
q.w_wall = 0.13e-3;    % Tb.Th ~ 130 um, not the 1 mm cortical wall

% --- load: the spine is axial, the diaphysis is bent --------------------
q.M_L_0 = 0.30;        % [N*m]
q.F_L_0 = 180;         % [N]

% Frost's MES_m is a strain threshold, and the trabecular compartment sits
% at a higher tissue strain than cortex.  Keeping the cortical 1500 ue would
% leave periosteal modelling permanently ON here, expanding the vertebra
% forever.  Set above the trabecular baseline instead.
q.eps_model_star = 3.0e-3;

% --- K_tau: match the baseline osteocyte shear (see header) -------------
ref = scenarioLibrary("sedentary");
[~, iRef] = max([ref.bouts.momentScale]);
bout = ref.bouts(iRef);

stC  = struct(r_p = p.r_p_0, r_e = p.r_e_0, f_bm = p.f_bm_0, ...
              rho_min = p.rho_min_0, n_ot = p.n_ot_0);
tauC = shearSurrogate(organMechanics(bout, stC, p).eps_p, bout.freqHz, p);

stT  = struct(r_p = q.r_p_0, r_e = q.r_e_0, f_bm = q.f_bm_0, ...
              rho_min = q.rho_min_0, n_ot = q.n_ot_0);
tauT = shearSurrogate(organMechanics(bout, stT, q).eps_p, bout.freqHz, q);

q.K_tau = q.K_tau * tauC / tauT;      % shearSurrogate is linear in K_tau

% --- k_res: calibrate to the trabecular turnover target -----------------
% Turnover is closed form in k_res (TURNOVERRATE), so this is one division,
% not a fitting loop -- and it does NOT call EVALTARGETS, which now
% evaluates V8/V10 on this very compartment and would otherwise recurse.
q.k_res  = q.k_res * opts.turnover / turnoverRate(q);
q.k_form = balanceBoneFormation(q);
end
