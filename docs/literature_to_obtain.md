# 待取得文獻清單（館際借閱用）

**更新於 2026-07-28（v2.15）。** 依對模型的價值排序。書目取自 `投稿PLOS Comp Biol/references_verified.md` 的查證紀錄；PMID 與 DOI 皆逐筆核對過 PubMed 紀錄。

**已有全文（不必再借）**：Pivonka 2008（`Reference/02.pdf`）、Peterson & Riggs 2010（`03.pdf`）、Lemaire 2004（`10.pdf`）。

---

## 1. Fu et al. 2025 —— 最高價值

> Fu R, Wang C, Shahneela N, Ud Din R, Yang H. **A whole bone–lacunocanalicular network–osteocyte model examining bone adaptation to distinct loading parameters.** *International Journal of Mechanical Sciences.* 2025;286:109931.
> doi:10.1016/j.ijmecsci.2025.109931
> **PMID：無**（Int J Mech Sci 為力學期刊，PubMed 未收錄。請以 DOI 或 ScienceDirect 檢索）

解鎖 `k_co_max`、`k_oc`、`k_oi`、`k_ic` 四個 MSIC 三態速率常數（全為佔位值）。**V5b 頻率符號翻轉的首要複驗對象**，並連動 V4、V5。

## 2. Wijenayaka et al. 2011

> Wijenayaka AR, Kogawa M, Lim HP, Bonewald LF, Findlay DM, Atkins GJ. **Sclerostin stimulates osteocyte support of osteoclast activity by a RANKL-dependent pathway.** *PLoS One.* 2011;6(10):e25900.
> doi:10.1371/journal.pone.0025900 ｜ **PMID 21991382**
> （PLoS One 為 open access，應可直接下載）

解鎖 V13 的結構性天花板：`K_L` = 0.5 而基線 S = 1，最大倍率恆為 1.33。要定 `K_L` 非讀原文不可。

## 3. Haapasalo et al. 2000

> Haapasalo H, Kontulainen S, Sievänen H, Kannus P, Järvinen M, Vuori I. **Exercise-induced bone gain is due to enlargement in bone size without a change in volumetric bone density: a peripheral quantitative computed tomography study of the upper arms of male tennis players.** *Bone.* 2000;27(3):351–357.
> doi:10.1016/s8756-3282(00)00331-8 ｜ **PMID 10962345**

解鎖 `r_p_0`、`r_e_0`（現值由 Tot.Ar／M.Cav.Ar 量級**推算**）。**這是全部六個 V6 盲測的出處**，論文最強的預測力主張架在這篇上。

## 4. Li et al. 2019

> Li X, Han L, Nookaew I, Mannen E, Silva MJ, Almeida M, et al. **Stimulation of Piezo1 by mechanical signals promotes bone anabolism.** *eLife.* 2019;8:e49631.
> doi:10.7554/eLife.49631 ｜ **PMID 31588901**
> （eLife 為 open access）

解鎖 `tau_50`、`k_tau_sig`。後者是 v1.5 為了讓 V2 成立而下修的擬合值。

## 5. Weinbaum, Cowin & Zeng 1994

> Weinbaum S, Cowin SC, Zeng Y. **A model for the excitation of osteocytes by mechanical loading-induced bone fluid shear stresses.** *Journal of Biomechanics.* 1994;27(3):339–360.
> doi:10.1016/0021-9290(94)90010-8 ｜ **PMID 8051194**

解鎖 `k_perm`、`S_stor`、`a_canal`、`Gamma_PCM`；可把集總的 `K_tau` 由標定值改成推導值。

## 6a. Lerebours et al. 2015

> Lerebours C, Thomas CDL, Clement JG, Buenzli PR, Pivonka P. **The relationship between porosity and specific surface in human cortical bone is subject specific.** *Bone.* 2015;72:109–117.
> doi:10.1016/j.bone.2014.11.016 ｜ **PMID 25433340**

## 6b. Martin 1984

> Martin RB. **Porosity and specific surface of bone.** *Critical Reviews in Biomedical Engineering.* 1984;10(3):179–222.
> **PMID 6368124** ｜ DOI：無（1984 年舊刊，可能需紙本或掃描）

兩篇合解 `S_v(f_bm)` 的真實函數形式（現為佔位 `f^s1 (1-f)^s2`）。**Lerebours 更關鍵** —— 它指出皮質與小樑不能共用同一條曲線，而我們兩個腔室正是共用的。

## 7. Srinivasan et al. 2002

> Srinivasan S, Weimer DA, Agans SC, Bain SD, Gross TS. **Low-magnitude mechanical loading becomes osteogenic when rest is inserted between each load cycle.** *Journal of Bone and Mineral Research.* 2002;17(9):1613–1620.
> doi:10.1359/jbmr.2002.17.9.1613 ｜ **PMID 12211431**
>
> ⚠️ **注意：同期第 1621–1628 頁是另一篇不相干的論文（PMID 12211432, Banse et al.）。借閱時請以頁碼 1613 與 PMID 核對。**

V5 的「2–5 倍」是**我們自己設的帶**，而模型給 13.99 倍。要判斷是模型錯還是帶設錯，得看原始實驗數字。

## 8. Currey 1988

> Currey JD. **The effect of porosity and mineral content on the Young's modulus of elasticity of compact bone.** *Journal of Biomechanics.* 1988;21(2):131–139.
> doi:10.1016/0021-9290(88)90006-1 ｜ **PMID 3350827**
>
> 另可併參教科書：Gibson LJ, Ashby MF. *Cellular Solids: Structure and Properties.* 2nd ed. Cambridge University Press; 1997.

解鎖 `kappa_E`、`nu_E`。⚠️ **這篇已經是稿件的文獻 16 —— 引用過不等於拿到數。** `kappa_E` 決定力學回饋增益，是 E6 的關鍵參數。

## 9. Cosman et al. 2016

> Cosman F, Crittenden DB, Adachi JD, Binkley N, Czerwinski E, Ferrari S, et al. **Romosozumab treatment in postmenopausal women with osteoporosis.** *New England Journal of Medicine.* 2016;375(16):1532–1543.
> doi:10.1056/NEJMoa1607948 ｜ **PMID 27641143**

解鎖 romosozumab 逐月 BMD 與骨標記軌跡 → V8/V9/V16 由端點值升級為軌跡擬合。**對現在未達標的 V16 特別有用。**

## 10. Marques et al. 2023

> Marques FC, Boaretti D, Walle M, Scheuren AC, Schulte FA, Müller R. **Mechanostat parameters estimated from time-lapsed in vivo micro-computed tomography data of mechanically driven bone adaptation are logarithmically dependent on loading frequency.** *Frontiers in Bioengineering and Biotechnology.* 2023;11:1140673.
> doi:10.3389/fbioe.2023.1140673 ｜ **PMID 37113673**
> （Frontiers 為 open access）

解鎖 V5b 的定量頻率–反應曲線（現在只用了它的對數形式定性宣稱）。

## 11. Schulte et al. 2026

> Schulte FA, Marques FC, Griesbach JK, Weigt C, von Salis-Soglio M, Lambers FM, et al. **Combined physical and pharmacological anabolic osteoporosis therapies increase bone response and mechanoregulation in female mice.** *Nature Communications.* 2026;17:3759.
> doi:10.1038/s41467-026-70309-2 ｜ **PMID 41807441**
> （Nature Communications 為 open access）

解鎖 V12 的定量交互作用項 → 檢驗我們的次相加 10.2 %。

---

## 取得難度速覽

| 應可直接下載（open access） | 需館際借閱 |
|---|---|
| 2 Wijenayaka（PLoS One）、4 Li（eLife）、10 Marques（Frontiers）、11 Schulte（Nat Commun） | 1 Fu（Elsevier）、3 Haapasalo（Bone）、5 Weinbaum（J Biomech）、6a Lerebours（Bone）、**6b Martin（1984 舊刊，可能最難）**、7 Srinivasan（JBMR）、8 Currey（J Biomech）、9 Cosman（NEJM） |

**建議優先送件**：1（Fu）、3（Haapasalo）、7（Srinivasan）—— 三篇分別對應目前最弱的三處（V5b 未達、六個盲測的幾何基礎、V5 超出自訂帶 2.8 倍）。
