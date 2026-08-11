# Cover letter

To the Editors
*PLOS Computational Biology*

Dear Editors,

Please consider the enclosed manuscript, **"From fluid shear to sclerostin: a mechanotransduction-resolved multiscale model of bone adaptation, and what it falsifies"**, for publication as a Research Article.

Skeletal modelling has advanced from two ends and met in the middle nowhere. Models of how an osteocyte senses mechanical load are detailed and validated, but stop at the osteocyte. Models of bone-cell population dynamics predict bone density and drug responses, but are driven by a phenomenological stimulus with no real mechanics in it. The consequence is that no existing model can compare mechanical loading against a drug in the same currency, or let calcium intake and loading compete for the same bone — which is exactly the comparison clinicians and patients make daily.

We join the two ends. The model carries a load continuously from organ-level bending through poroelastic lacunocanalicular shear, three-state channel gating, Piezo1–Ca²⁺–YAP/TAZ–sclerostin–Wnt signalling, RANK/RANKL/OPG population dynamics, three-surface geometry and mineralisation, to the density a clinical scan reports, with systemic calcium–PTH–vitamin D coupled bidirectionally.

Three features seem to us to fit your journal particularly well.

**The model predicts rather than accommodates.** Five parameters were fitted to five targets; eight observations were withheld and never entered the objective. All eight are recovered, including all six peripheral quantitative computed tomography indices of the racquet-sport humerus and the post-withdrawal bone loss after anti-sclerostin therapy. Most strikingly, Frost's mechanostat set point — a phenomenological constant inferred from observation in 1987 and never derived — emerges at 787 με, inside the lazy zone between the two thresholds he proposed, at no cost in free parameters. Two further constants that look like free parameters are derived from the baseline state rather than fitted, and we describe in the paper what happened when one of them was not.

**We report the falsification of our own hypothesis in the main text.** We predicted, before calibration, that osteoporosis would appear as an alternative stable state reached through a saddle-node bifurcation. It does not: the model is monostable by two independent routes, and a full withdrawal-and-recovery probe returns to 100.3 % of baseline with no hysteresis. We think this is more informative than confirmation would have been. Bistability is easy to produce in complex physiological models and correspondingly fragile — a numerical artefact very nearly delivered exactly that conclusion here, and we describe how it was caught. What the falsification buys is a boundary: the mechanostat's negative feedback is strong enough to rescue low bone mass at the porosity scale, so clinical irreversibility must originate in structural loss that continuum porosity dynamics cannot represent. That is a testable prediction, not a shrug.

**One of our three quantitative claims reverses sign under a different measure, and a second did until an unrelated module was repaired.** The loading effect is +4.582 % in bone mineral content and +1.778 % in areal density, because loading translates the cortex outward and areal density divides by projected width. The calcium–loading interaction was negative as a difference-in-differences and positive in absolute terms; rebuilding the systemic calcium module made it positive on both framings, and we report that history rather than only the current sign, because a conclusion that flips when an unrelated module is corrected is one to hold loosely. Neither reversal is a modelling error; both are faithful consequences of well-understood measurement properties. We report the measure-sensitivity itself as a result, because it bears directly on how loading trials should choose and report their endpoints.

**We report our own errors, and two of them changed results.** During preparation we found that the model's osteocyte population turned over 514-fold faster than its own bone — an internal contradiction, not a disagreement with data, that every validation target had passed for two years. Correcting it cost us one calibration target and improved a held-out one, and we report both directions. We also built three separate mechanisms to let the model adopt a measured specific-surface exponent in place of one we know to be six-fold wrong; all three failed, in three different ways — specificity, authority, physiology — and that pattern is reported in the main text as a structural result rather than buried. We would rather submit a paper that says which of its own numbers moved and why.

All code, parameter tables with literature sources and confidence grading, validation target definitions, all seven experiment scripts and a 91-assertion automated test suite are already publicly deposited at https://github.com/myhsieh1002/bone-mechanostat and archived on Zenodo (concept DOI 10.5281/zenodo.21592303), so reviewers can run the model during review. Every figure is regenerated by a single named script.

The manuscript is original, is not under consideration elsewhere, and involves no human or animal subjects. All authors have approved the submission and declare no competing interests. No funding was received for this work.

Thank you for your consideration.

Yours sincerely,

**Ming-Yu Hsieh, MD, PhD** (corresponding author)
Vice Chairman and Associate Professor, School of Medicine, Chung Shan Medical University
Director, Division of Pediatric Surgery, Chung Shan Medical University Hospital
Director, Center for Evidence-Based Medicine, Chung Shan Medical University Hospital
Taichung, Taiwan
cshy1392@csh.org.tw · ORCID 0000-0002-5797-3474

on behalf of the co-authors:
Hsiang-Lin Lee, MD, PhD (ORCID 0000-0003-1422-1042)
Tzu-Ling Wang, MSN (ORCID 0000-0003-3520-0531)
