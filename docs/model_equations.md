# S1 Text. Model equations

Specification of modules M1–M8 as implemented. Symbols and values are tabulated in **S1 Table**; every parameter used below is read from that table at run time, and hard-coded numerical constants in the source are treated as defects and rejected by an automated check.

---

## State vector

Thirteen local states per skeletal site, plus four shared systemic states.

| Group | States | Module |
|---|---|---|
| Osteocyte signalling | $C_a$, $Y$, $S$, $T$, $n_{ot}$ | M4 |
| Wnt | $\beta$ | M5 |
| Cell populations | $R$, $B$, $C$ | M6 |
| Structure and mineral | $r_p$, $r_e$, $f_{bm}$, $\bar\rho_{\min}$ | M7 |
| Systemic (shared) | $\mathrm{Ca}_s$, $P$, $V_D$, $A_{reb}$ | M8, M4 |

Single compartment: 13 + 4 = 17 states. Two compartments: 13 × 2 + 4 = 30. Signalling and cell variables are non-dimensionalised to 1 at baseline; structural variables carry physical units.

The per-site right-hand side is implemented once and called by both the single- and two-compartment assemblers, so the two cannot diverge.

---

## M1 — Organ-level mechanics

**The input is force, never strain.** Scenarios supply peak bending moment $M_L$ and peak axial force $F_L$ per loading bout. Strain is a regulated *output* computed from current geometry and material state. Prescribing strain converts the model from force control to strain control and severs the mechanostat feedback loop; an automated check rejects any scenario carrying a strain-like field.

Idealised hollow circular cortical cross-section:

$$A_g = \pi\left(r_p^2 - r_e^2\right), \qquad I_g = \frac{\pi}{4}\left(r_p^4 - r_e^4\right)$$

Apparent modulus, separating matrix quantity from matrix mineralisation:

$$E_{\mathrm{app}} = E_{\mathrm{ref}}\, f_{bm}^{\,\kappa_E} \left(\bar\rho_{\min}/\bar\rho_{\min,0}\right)^{\nu_E}$$

Peak strain at the periosteal and endocortical surfaces, bending plus axial:

$$\varepsilon_p = \frac{M_L\, r_p}{E_{\mathrm{app}} I_g} + \frac{F_L}{E_{\mathrm{app}} A_g}, \qquad
\varepsilon_e = \frac{M_L\, r_e}{E_{\mathrm{app}} I_g} + \frac{F_L}{E_{\mathrm{app}} A_g}$$

with $\bar\varepsilon = \tfrac12(\varepsilon_p + \varepsilon_e)$.

*Loop gain.* Differentiating gives $\partial \ln \varepsilon_p / \partial \ln f_{bm} = -\kappa_E$, verified numerically to $4.7\times10^{-12}$. In the thin-wall limit $I_g \approx \pi r^3 t_c$, so $\varepsilon \propto M_L / (E r^2 t_c)$: periosteal expansion is mechanically far more efficient than cortical thickening ($r^2$ against $t_c$). Numerically $\partial\ln\varepsilon/\partial\ln r_p = -4.27$ against $-2.50$ for $f_{bm}$. This is why loading enlarges rather than densifies cortical bone, and it emerges from parameter values rather than being imposed.

*Numerical guard.* $E_{\mathrm{app}} \propto f_{bm}^{\kappa_E}$ diverges as $f_{bm}\to 0$; a floor $f_{bm,\min}$ is applied inside the constitutive law only.

---

## M2 — Poroelastic lacunocanalicular shear

One-dimensional Biot consolidation along a canaliculus of radius $a$:

$$\frac{\partial p}{\partial t} = c_p \frac{\partial^2 p}{\partial z^2} - \frac{1}{S_{\mathrm{stor}}}\frac{\partial \varepsilon}{\partial t}, \qquad c_p = \frac{k_{\mathrm{perm}}}{\mu\, S_{\mathrm{stor}}}$$

$$\tau_{\mathrm{oc}}(t) = \frac{a}{2}\left|\frac{\partial p}{\partial z}\right| \Gamma_{\mathrm{PCM}}$$

with $\Gamma_{\mathrm{PCM}}$ the pericellular matrix amplification factor.

**The frequency dependence is the exact closed-form solution, not a fitted surrogate.** For harmonic loading the problem admits

$$\hat\tau_{\max}(\varepsilon_{\mathrm{peak}}, f) = K_\tau\, \varepsilon_{\mathrm{peak}}\, \Phi(f), \qquad \Phi(f) = \left|k \tanh(kL)\right|,\quad k = \sqrt{\mathrm{i}\,2\pi f / c_p}$$

giving $\tau \propto f$ at low frequency crossing to $\tau \propto \sqrt{f}$ at high frequency, and **never saturating**. This has two consequences. It yields log-linearity of $\tau$ against $\ln f$ over 1–10 Hz with $r = 0.99883$ and no fitted parameter. And it corrects an earlier saturating surrogate under which that log-linearity would have been unreachable, since a saturating form drives the high-frequency slope to zero.

*Cross-validation.* A Crank–Nicolson finite-difference solution of the full PDE agrees with the closed form to a maximum relative error of 0.0029 %.

---

## M3 — Daily mechanical dose

**The channel is modelled exactly once.** Mechanosensitive ion channel gating (Piezo1, with $J_{\mathrm{alt}}$ lumping integrin, primary cilium and connexin-43 parallel routes) has closed, open and inactivated states, and all shear dependence lives in the opening rate:

$$k_{co}(\tau) = k_{co}^{\max}\left[1 + \exp\!\left(-(\tau - \tau_{50})/k_\tau\right)\right]^{-1}$$

$$\frac{dO}{dt} = k_{co}(\tau)\,C_h - (k_{oc} + k_{oi})\,O, \qquad
\frac{dI}{dt} = k_{oi} O - k_{ic} I, \qquad C_h = 1 - O - I$$

The interface between the sub-second and daily timescales is a **single scalar**, the daily integral of open probability:

$$D_{\mathrm{mech}}(d) = \int_{\mathrm{day}} O\big(t;\tau(t)\big)\, dt$$

where $\tau(t)$ follows from the day's bout structure through M1 and M2.

*Phenomenological terms removed.* Earlier versions carried a parallel empirical dose law with parameters $a_r, \tau_r, p, \tau_{th}, q$ alongside the three-state model, encoding the same phenomena twice; worse, the scalar that was supposed to cross the timescale boundary had no downstream consumer, so mechanical signalling never actually crossed it. All five parameters were deleted and the phenomena now emerge:

| Phenomenon | Emergent mechanism |
|---|---|
| Diminishing return with cycle number | $I$ accumulates during loading, depleting $C_h$ |
| Rest-insertion gain | During rest $I \xrightarrow{k_{ic}} C_h$, restoring available channels |
| Threshold | Lower limb of the $k_{co}(\tau)$ sigmoid; no hard threshold, so dose is small but non-zero as $\tau\to0$ |
| Supralinearity | Steepness $k_\tau$ of the sigmoid |

*Cross-validation.* An affine per-cycle operator agrees with stepwise integration to $2.2\times10^{-15}$.

*Implementation.* Because geometry adapts, $\hat\tau$ drifts and $D_{\mathrm{mech}}$ must be re-evaluated; a within-day integral at second resolution cannot sit inside the ODE right-hand side. A one-dimensional interpolant of $D_{\mathrm{mech}}$ against $\hat\tau_{\max}$ is built offline per bout structure, and the slow system performs a table lookup.

---

## M4 — Osteocyte signalling

Calcium influx is driven by the daily mean open probability, gated by osteocyte sensing capacity:

$$\frac{dC_a}{dt} = k_C\left[(1 - f_{\mathrm{alt}})\, \hat{D}_{\mathrm{eff}} + f_{\mathrm{alt}} - C_a\right], \qquad
\hat{D}_{\mathrm{eff}} = \frac{D_{\mathrm{mech}}\,(n_{ot}/n_{ot,0})^{\zeta}}{D_{\mathrm{eff},0}}$$

$D_{\mathrm{eff},0}$ is the dose under a fixed canonical reference — sedentary loading at unadapted geometry — and never the running scenario's own baseline. Normalising to the scenario's own state would set $\hat{D}_{\mathrm{eff}}=1$ for every protocol, so no intervention could differ from any other.

YAP/TAZ nuclear fraction:

$$\frac{dY}{dt} = k_Y\left[\frac{h_Y(C_a)}{h_Y(1)} - Y\right], \qquad h_Y(c) = \frac{c^{n_Y}}{K_Y^{n_Y} + c^{n_Y}}$$

Sclerostin, with mechanical, PTH and TNF-α inputs:

$$S_{\mathrm{set}} = \frac{f_{\mathrm{mech}}(Y)\, f_{\mathrm{PTH}}(P)\, f_{\mathrm{TNF}}(T)}{f_{\mathrm{mech}}(1)\, f_{\mathrm{PTH}}(1)\, f_{\mathrm{TNF}}(1)}$$

$$f_{\mathrm{mech}}(y) = \frac{1}{1 + (y/K_S)^{h_S}}, \quad
f_{\mathrm{PTH}}(x) = \frac{1}{1 + x/K_{P,\mathrm{sost}}}, \quad
f_{\mathrm{TNF}}(t) = 1 + \frac{\lambda_T t}{K_T + t}$$

$$\frac{dS}{dt} = \delta_S\, S_{\mathrm{set}}\,(1 + A_{reb}) - \left(\delta_S + \delta_{ab}\, u_{\mathrm{romo}}\right) S$$

An anti-sclerostin antibody adds **clearance** ($\delta_{ab} u_{\mathrm{romo}}$), lowering the set point and shortening the time constant.

**Withdrawal rebound.** Sustained antibody exposure also up-regulates *SOST* transcription; $A_{reb}$ carries that compensation and relaxes on its own clock rather than the antibody's:

$$\frac{dA_{reb}}{dt} = \frac{\sigma_{reb}\, u_{\mathrm{romo}} - A_{reb}}{\tau_{reb}}$$

$A_{reb} = 0$ in any run that never sees the drug, so this term cannot perturb any drug-free result. Two consequences follow without further assumptions: during treatment the compensation progressively offsets the antibody, so free sclerostin climbs back toward baseline and the anabolic effect self-limits; and on withdrawal the clearance term vanishes while the raised production does not, so sclerostin overshoots and resorption surges.

**Osteocyte density** (positive feedback: bone loss → fewer sensors → weaker signal → more loss):

$$\frac{dn_{ot}}{dt} = k_{ot}\, \hat{v}_{\mathrm{form}}\left(n_{ot,\max} - n_{ot}\right) - \left[\gamma_{\mathrm{eff}}\, \hat{v}_{\mathrm{res}} + \delta_{ot}(E_2)\right] n_{ot}$$

with $\hat v$ normalised to baseline and $\delta_{ot}(E_2) = \delta_{ot,0}\, E_{2,0}/E_2$. The loss coefficient $\gamma_{\mathrm{eff}}$ is *derived*, not read from the table, so that $n_{ot} = n_{ot,0}$ is a fixed point by construction.

**Oestrogen and TNF-α:** $E_2$ withdrawal raises $T$, which biases resorption endocortically (M7) and raises sclerostin.

---

## M5 — Wnt / β-catenin

$$W_{\mathrm{eff}} = \frac{W(S)}{W(1)}, \qquad W(x) = \frac{K_W^{m_W}}{K_W^{m_W} + x^{m_W}}, \qquad
\frac{d\beta}{dt} = k_\beta\left(W_{\mathrm{eff}} - \beta\right)$$

---

## M6 — Cell populations

Standard RANK/RANKL/OPG structure over responding osteoblast precursors $R$, active osteoblasts $B$ and active osteoclasts $C$, with rate constants taken from the literature. Sclerostin acts **twice** — inhibiting Wnt and up-regulating RANKL — which is what reproduces both the anabolic and the antiresorptive components of anti-sclerostin therapy:

$$g_S(S) = 1 + \frac{\lambda_S S}{K_L + S}, \quad
g_P(P) = 1 + \frac{\lambda_P P}{K_{PL} + P}, \quad
g_E(E_2) = 1 - \lambda_E E_2, \quad
g_B(\beta) = 1 + \frac{\lambda_\beta \beta}{K_\beta + \beta}$$

$$L_{\mathrm{RANKL}} = \frac{g_S(S) g_P(P) g_E(E_2)}{g_S(1) g_P(1) g_E(E_{2,0})}, \qquad
O_{\mathrm{OPG}} = \frac{g_B(\beta)}{g_B(1)}$$

$$\pi_L = \frac{L_{\mathrm{RANKL}}}{K_{L3} + L_{\mathrm{RANKL}} + \kappa_{\mathrm{OPG}} O_{\mathrm{OPG}}} \Big/ \left.\phantom{x}\right|_{\text{baseline}}$$

---

## M7 — Structure and mineralisation

**Surface allocation.** Formation follows the strain gradient across the wall, weighted by available surface area:

$$\eta \propto A \odot \left[D(\varepsilon_p),\, D(\varepsilon_e),\, D(\bar\varepsilon)\right], \qquad
A = \left[\xi_{p,0},\, \xi_{e,0},\, \xi_{i,0}\right]$$

normalised to sum to 1. Area weighting is essential: dose alone hands the periosteum ~35 % of all formation despite ~5 % of the surface. Resorption follows area with a TNF-α endocortical bias:

$$\xi \propto A \odot \left[1,\, 1 + \frac{\lambda_\xi (T-1)}{K_T + T},\, 1\right]$$

**Surface evolution.** $r_e$ increasing means endocortical resorption, i.e. a thinning cortex; tracking $r_p$ and $r_e$ separately is what allows the marrow cavity to enlarge while the bone grows.

$$\frac{dr_p}{dt} = v_{\mathrm{form}} \eta_p - v_{\mathrm{res}} \xi_p + \mathcal{M}, \qquad
\frac{dr_e}{dt} = v_{\mathrm{res}} \xi_e - v_{\mathrm{form}} \eta_e + \chi_{\mathrm{drift}} \mathcal{M}$$

$$\frac{df_{bm}}{dt} = \frac{\hat{S}_v(f_{bm})}{w_{\mathrm{wall}}}\left(v_{\mathrm{form}} \eta_i - v_{\mathrm{res}} \xi_i\right)$$

with $v_{\mathrm{form}} = k_{\mathrm{form}} B$ and $v_{\mathrm{res}} = k_{\mathrm{res}} C$. The specific surface $\hat S_v(f_{bm})$ carries the second positive feedback: as $f_{bm}$ falls there is progressively less surface to rebuild on.

**Frost modelling drift.** Vigorous loading drives direct periosteal apposition, distinct from the dose/remodelling pathway, with a strain threshold (minimum effective strain for modelling) so that it is silent during normal daily activity and during every calibration scenario:

$$\mathcal{M} = k_{\mathrm{model}}\, \frac{\Delta\varepsilon}{1 + \Delta\varepsilon/\varepsilon_{\mathrm{sat}}} \left(\frac{n_{ot}}{n_{ot,0}}\right)^{\zeta}, \qquad
\Delta\varepsilon = \max\!\left(0,\, \varepsilon_p - \varepsilon^*_{\mathrm{model}}\right)$$

Two features are load-bearing. The **saturation** bounds the rate at $k_{\mathrm{model}}\varepsilon_{\mathrm{sat}} = 1.93\ \mu\mathrm{m/day}$; without it the term is linear in strain excess and unbounded, and at pathological bone volume fraction it demands 1513 mm/yr of apposition, producing a spurious 99 mm cortex. The chosen $\varepsilon_{\mathrm{sat}}$ places half-maximal response at the yield strain of cortical bone (7000 με), beyond which tissue damages rather than adapts, and independently places the rate ceiling inside the documented range for rapid mineral apposition (1–5 μm/day). The **drift coupling** $\chi_{\mathrm{drift}} = 1$ makes the term a pure translation of the cortex, conserving wall thickness, as a modelling drift should; $\chi_{\mathrm{drift}} = 0$ would inflate the cortex instead and contracts the marrow cavity under loading, contrary to observation.

**Mineralisation.** Mean tissue mineral density is a single *intensive* state that falls as new low-density matrix is deposited and rises as existing matrix matures:

$$\frac{d\bar\rho_{\min}}{dt} = \mu_{\mathrm{turn}}\left(\rho_{\mathrm{prim}} - \bar\rho_{\min}\right) + \text{maturation}$$

An earlier two-pool extensive formulation made $\bar\rho_{\min}$ rise during formation — the wrong direction — and that artefact was responsible for an apparent romosozumab result that did not survive correction.

**Densitometry.**

$$\mathrm{BMC}/L = A_g f_{bm} \bar\rho_{\min}, \qquad
\mathrm{aBMD} = \frac{A_g f_{bm} \bar\rho_{\min}}{2 r_p}, \qquad
\mathrm{vBMD} = f_{bm} \bar\rho_{\min}$$

**Both are reported, and the areal size artefact is intentional.** Dividing by projected width reproduces the well-known confounding of bone size with bone density in dual-energy X-ray absorptiometry: periosteal expansion raises areal density even when volumetric density is unchanged. Retaining it is what allows one model to be compared against both the densitometry literature (calcium, romosozumab) and the peripheral quantitative computed tomography literature (racquet-sport asymmetry), and it is the origin of the 59 % dilution of the loading response reported in the main text.

**Bone-mass balance.** Because $\eta_p > \xi_p$ always, there is no stationary geometric fixed point; the only defensible baseline condition is conservation of bone *mass*. $k_{\mathrm{form}}$ is therefore derived at every parameter set from $d(A_g f_{bm})/dt = 0$ rather than fitted, which keeps the baseline balanced by construction when any parameter affecting $\eta$ or $\xi$ changes. Turnover magnitude is then carried by $k_{\mathrm{res}}$ alone.

---

## M8 — Systemic calcium, PTH and 1,25(OH)₂D

Serum calcium, PTH and 1,25-dihydroxyvitamin D with intestinal absorption, renal handling and bone flux, coupled bidirectionally: bone-cell activity draws on and releases to the serum pool, and PTH feeds back into M4 through both sclerostin and RANKL. In the two-compartment model the systemic pool is driven by the mean of the two sites' bone-cell activity, since a single humerus is a negligible fraction of whole-body calcium turnover — the sites are probes of the shared pool, not drivers of it.

Every term below is a calcium flux in mg/day.

$$\frac{d\mathrm{Ca}_s}{dt} = \frac{\kappa_{\mathrm{Ca}}}{k_{\mathrm{ren}}}\left[\mathrm{Abs}(I_{\mathrm{Ca}}, V_D) + \phi_{\mathrm{res}} v_{\mathrm{res}} - \phi_{\mathrm{form}} v_{\mathrm{form}} - \mathrm{Renal}(\mathrm{Ca}_s, P)\right]$$

$$\frac{dP}{dt} = \delta_P\left(P_{\mathrm{set}}(\mathrm{Ca}_s) - P\right), \qquad
\frac{dV_D}{dt} = \delta_{VD}\left(V_{D,\mathrm{set}}(P) - V_D\right)$$

**Absorption** has an unregulated paracellular arm linear in intake and a transcellular arm that saturates in intake and is gated by calcitriol. The second arm carries most of the baseline flux, and it is what buffers a change in dietary calcium: more intake raises serum calcium, which lowers PTH, which lowers $V_D$, which closes the transcellular arm.

$$\mathrm{Abs} = a_p I_{\mathrm{Ca}} + a_a I_{\mathrm{Ca},0}\,\frac{I_{\mathrm{Ca}}}{K_I + I_{\mathrm{Ca}}}\,\frac{V_D}{K_{VD} + V_D}$$

**Renal excretion** is what the tubule fails to reclaim: the excess of serum calcium over a threshold that PTH raises. Its steepness is not a free parameter but a consequence of where the threshold sits — placing it about 2 % below $\mathrm{Ca}_{s,0}$ makes excretion a small difference of two large numbers, which is the same statement as "about 98 % of filtered calcium is reabsorbed". The gain then follows from closing the baseline balance, so the module has one free physiological choice rather than a fitted exponent.

$$\mathrm{Renal} = k_{\mathrm{ren}}\max\left(\mathrm{Ca}_s - \mathrm{Ca}_{\mathrm{th}}, 0\right), \qquad
\mathrm{Ca}_{\mathrm{th}} = \mathrm{Ca}_{\mathrm{th},0} + \lambda_{P}^{\mathrm{ren}}\,\Delta\,(P - 1)$$

$$\Delta = \mathrm{Ca}_{s,0} - \mathrm{Ca}_{\mathrm{th},0}, \qquad
k_{\mathrm{ren}} = \frac{\mathrm{Abs}_0 + \phi_{\mathrm{res}} - \phi_{\mathrm{form}}}{\Delta}$$

**Skeletal exchange** uses $\phi_{\mathrm{res}} = \phi_{\mathrm{form}}$, so it vanishes at baseline and carries the true skeletal calcium flux under perturbation. Their magnitude is the order of adult skeletal calcium turnover, which is what allows unloading to suppress PTH.

*This module was rebuilt at v2.14.* The earlier form failed in both directions at once: the transcellular arm had been written as a fraction rather than a flux and so contributed under 0.1 % of absorption, leaving serum calcium to swing 15 % across the dietary range, while $\phi_{\mathrm{res}}$ and $\phi_{\mathrm{form}}$ were three orders of magnitude below the flux they were normalised against, so bone could not move serum calcium at all. Both are reported in the main text.

---

## Trabecular compartment

A vertebral trabecular compartment is derived from the cortical parameter set by overriding **only** structure, geometry and load — the biology is shared, since the per-site right-hand side is common. Geometry and bone volume fraction come from the vertebral literature; trabecular thickness replaces cortical wall thickness.

Two overrides are forced rather than chosen, and both are worth stating because they generalise to any multi-compartment extension.

1. **The shared signalling chain forces both compartments onto the same emergent shear set point.** A vertebra at realistic load and bone volume fraction carries ~2773 με of tissue strain against the cortex's 762 με, so the poroelastic transfer coefficient $K_\tau$ must differ. This is defensible — $K_\tau$ is a microstructural property and trabecular packets are not osteonal cortex — and it is set by *matching baseline shear*, not by fitting any outcome.
2. **Frost's minimum effective strain for modelling is a strain threshold and must scale likewise**, or modelling remains permanently active in the trabecular compartment and the vertebra expands without limit.

$k_{\mathrm{res}}$ is calibrated against the *trabecular* turnover target (literature 15–30 %/yr against 5–10 for cortex), exactly as it is calibrated against cortical turnover for cortex; left alone it would be 438 %/yr, because the same absolute surface velocity acting on eight-fold less bone behind a 7.7-fold thinner wall turns over ~60-fold faster. The romosozumab targets remain hold-outs.

*Free consistency check.* $E_{\mathrm{ref}}$ and $\kappa_E$ are shared and untuned; at a bone volume fraction of 0.12 they give an apparent modulus of 99.8 MPa, inside the measured 50–300 MPa range for vertebral trabecular bone. The elastic law therefore holds across two orders of magnitude of porosity without adjustment.

---

## Validity domain

Every mechanical layer — the power-law modulus, the Euler–Bernoulli section, the Biot solution — assumes linear elasticity. Cortical bone yields near 7000 με; beyond that, tissue damages rather than adapts, and a trajectory that goes there is not a slowly remodelling bone. Each simulation therefore reports peak strain against this limit, and results from runs that exceed it are not interpreted.

This check identified two scope limits reported in the main text: unloading beyond ~7.5 months drives the model to its porosity floor and out of the elastic domain, and the deep branch of the oestrogen continuation below $f_{bm} \approx 0.391$ is extrapolation.

---

## Numerical methods

`ode15s`, relative tolerance $10^{-6}$, absolute tolerance $10^{-9}$, non-negativity enforced on all states. Bifurcation analysis freezes the envelope geometry to isolate porosity dynamics, since envelope evolution is a decades-scale process while the bistability question is months-to-years; the full-system transient with geometry free is used as an independent check only where it stays inside the elastic domain.
