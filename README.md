# bone-mechanostat

**A mechanotransduction-resolved multiscale model of bone adaptation**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![MATLAB R2026a](https://img.shields.io/badge/MATLAB-R2026a-orange.svg)](https://www.mathworks.com)
[![tests 81/81](https://img.shields.io/badge/tests-81%2F81-brightgreen.svg)](tests/)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.21592303.svg)](https://doi.org/10.5281/zenodo.21592303)

Ming-Yu Hsieh, MD, PhD · [ORCID 0000-0002-5797-3474](https://orcid.org/0000-0002-5797-3474)
Chung Shan Medical University, Taichung, Taiwan

*[中文工作版 README](README.zh-TW.md)*

---

## What this is

Models of how a bone cell senses mechanical load are detailed and validated,
but they stop at the osteocyte. Models of bone-cell population dynamics predict
bone density and drug responses, but are driven by a phenomenological stimulus
with no real mechanics in them. Nothing joins the two, so no model has been
able to compare mechanical loading against a drug in the same currency, or let
calcium intake and loading compete for the same bone.

This one joins them. A load is carried continuously from organ-level bending,
through poroelastic lacunocanalicular fluid shear, through three-state
mechanosensitive channel gating, through
Piezo1–Ca²⁺–YAP/TAZ–sclerostin–Wnt signalling, through RANK/RANKL/OPG cell
populations, to three-surface cortical geometry, mineralisation, and the
density a clinical scan would report — with systemic calcium–PTH–vitamin D
coupled bidirectionally.

**The load enters as force. Strain is a regulated output.** That one interface
decision is what makes it a mechanostat rather than a curve fit, and an
automated test enforces it.

---

## Headline results

Six parameters were fitted to six targets. **Eight observations were held out
and never entered the objective**; all eight are recovered.

| | Result | |
|---|---|---|
| **Frost's set point emerges** | **762 µε**, inside the lazy zone between his remodelling (100–300 µε) and modelling (1500–3000 µε) thresholds — computed from channel kinetics, never fitted | hold-out |
| **Loading ≫ calcium** | bone mineral content **+4.59 %** under appropriate loading (≈2900 µε) vs **+0.47 %** for calcium — a **9.8-fold** ratio | |
| **Site specificity** | unilateral loading reproduces all six pQCT indices of the tennis-player humerus; systemic calcium and systemic romosozumab give **0.0000 %** side-to-side difference | hold-out |
| **Romosozumab** | **+12.5 %** spine BMD at 12 months, **−14.0 %** over withdrawal | withdrawal held out |
| **Our own hypothesis, falsified** | osteoporosis is **not** an alternative stable state here — the model is monostable and recovers to **99.7 %** of baseline with no hysteresis | |

Two findings we would flag to anyone using the model:

- **Measurement choice flips conclusions.** The loading effect is +4.59 % in
  bone mineral content and +1.87 % in areal density, because loading moves the
  periosteal surface outward and areal density divides by projected width. Two
  of our three quantitative claims reverse sign under a different but equally
  reasonable measure.
- **One target is not met.** The frequency response is logarithmic in form but
  **wrong in sign** at the bone level, traced to saturation in the channel
  opening rate. The channel rate constants are placeholders; this is the first
  thing to re-check against better values.

---

## Quick start

```matlab
cd /path/to/bone-mechanostat
addpath('src'); setupPath();

runtests("tests")          % 81 assertions

s   = scenarioLibrary("sedentary", durationDays = 730);
out = simulate(s);
plot(out.t/365, out.dens.aBMD); xlabel("years"); ylabel("aBMD [kg/m^2]");

out.validity.ok            % ALWAYS check this -- see below
```

### Always check `out.validity.ok`

Every mechanical layer assumes linear elasticity. Cortical bone yields near
7000 µε; past that, tissue damages rather than adapts, so a trajectory that
goes there is not a slowly remodelling bone and **its geometry is not a
physical result**. Every run reports whether it stayed inside that domain.

This check is not decoration — it is what identified two scope limits we would
otherwise have reported as findings (see *Known limitations*).

### Reproducing every figure in the paper

```matlab
run(fullfile(projectRoot(), "experiments", "E2_calciumLoading.m"))   % calcium vs loading
run(fullfile(projectRoot(), "experiments", "E5_siteSpecificity.m"))  % site specificity
run(fullfile(projectRoot(), "experiments", "E6_bifurcation.m"))      % the falsification
```

`E0`–`E6` each write one figure to
`~/Documents/MATLAB/bone-mechanostat-results/figures/`. Nothing is written into
the source tree.

---

## Repository layout

```
src/params/     parameters, scenarios, trabecular compartment
src/mech/       M1–M3  organ mechanics, poroelasticity, channel gating
src/signal/     M4–M5  osteocyte signalling, Wnt
src/cells/      M6     RANK/RANKL/OPG populations
src/bone/       M7     three-surface structure, mineralisation, densitometry
src/systemic/   M8     calcium–PTH–vitamin D
src/model/      assembly, solver, state vector
src/analysis/   calibration, identifiability, continuation
src/viz/        figure house style
experiments/    E0–E6, one figure each
tests/          81 assertions across 13 files
data/           parameter and validation-target tables
docs/           model equations, parameter provenance
```

### Two files worth reading first

- **`src/model/siteRHS.m`** — the single source of truth for per-site biology.
  Both the single- and two-compartment right-hand sides call it, so they cannot
  diverge.
- **`data/parameters_literature.csv`** — every parameter with its value, unit,
  bounds, owning module, **literature source and confidence grading**.
  Hard-coded numerical constants anywhere in `src/` are treated as defects and
  are caught by an automated test.

---

## Three rules the tests enforce

Each corresponds to a defect that actually occurred.

**1 · Load is force, never strain.** Scenarios return peak bending moment and
axial force only. Strain is computed by `organMechanics` from current geometry.
Prescribing strain is strain control: it severs the negative feedback silently,
turning bone volume fraction into a pure integrator with no set point. →
`test_closedloop.m`

**2 · The channel is modelled exactly once.** Three-state gating lives only in
`msicGating.m`. Earlier versions encoded the same phenomena four times over,
and the scalar that was supposed to cross the fast/slow timescale boundary had
no downstream consumer — so mechanical signalling never actually crossed it. →
`test_noPhenomParams.m`

**3 · Never call `savepath`.** Paths are added per session by `setupPath.m`.
Cap any parallel pool explicitly (`parpool('Processes', 3)`).

---

## Known limitations

Stated here because they bound what the model can be used for.

| | Limitation |
|---|---|
| **Frequency sign** | Log-linear in form but negative in sign at the bone level, against experiment. Channel rate constants are placeholders. The one unmet target. |
| **Long-duration disuse** | Beyond ~7.5 months, complete unloading drives the model to its porosity floor and out of the elastic domain. All disuse results are confined to the 180-day window the target is defined on. |
| **Specific surface** | The bone-volume-fraction ↔ specific-surface curve is a placeholder shared by both compartments. It has been measured to be subject-specific and to differ between cortical and trabecular bone at the same porosity. |
| **Antibody kinetics** | Romosozumab is a step function, not a pharmacokinetic profile, which sharpens the withdrawal transient. The calibrated quantity is the downstream resorption overshoot, which is unaffected. |
| **PTH pair** | Two PTH-pathway parameters are identifiable only jointly (ridge correlation −0.89). The joint region is reported, not marginal intervals. |
| **No architecture** | Trabecular bone is a continuous volume fraction, not a strut network. This is precisely where the falsification of our bistability hypothesis points. |

---

## Documentation

| | |
|---|---|
| `PROJECT_PLAN_bone_mechanostat.md` | Full specification and a dated decision log (appendices C1–C23) recording every correction, artefact and reversal |
| `HANDOFF.md` | Orientation for anyone picking the project up |
| `docs/model_equations.md` | Modules M1–M8 as implemented, the trabecular compartment, the validity domain and numerical methods |
| `docs/parameter_provenance.md` | Where every literature-derived parameter comes from, and the record of verifying all 22 citations |
| `README.zh-TW.md` | Chinese working README |

The decision log is worth a look if you are evaluating the model's
trustworthiness. It records, among other things, a numerical artefact that
grew a 99 mm cortex and nearly produced a false-positive bistability result,
and how it was caught.

---

## Citing

See [`CITATION.cff`](CITATION.cff). Please cite both the software and the paper.

**Software** — concept DOI, always resolves to the newest version:
[`10.5281/zenodo.21592303`](https://doi.org/10.5281/zenodo.21592303)
To cite the exact version used here, v2.12: [`10.5281/zenodo.21592304`](https://doi.org/10.5281/zenodo.21592304)

## Licence

[MIT](LICENSE) for code, tables and documentation. The primary literature from
which parameter values were taken is **not** redistributed here; what is
version-controlled is our transcription of published values, with the source
cited for every entry.
