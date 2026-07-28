# HANDOFF — bone-mechanostat

**接手者請先讀這份，再讀 `PROJECT_PLAN_bone_mechanostat.md`（v2.14，含附錄 C1–C27）與 `README.zh-TW.md`（中文工作版；`README.md` 為對外英文版）。**

主持人：謝明諭 (Ming-Yu Hsieh)｜MATLAB R2026a｜語言：程式碼英文、討論與計畫書中文。

---

## 0. ✅ 標的稽核已完成 —— 但留下三件事

**V1–V16 全部標的都已用「主張／判準／誠實比對」過完一遍**（附錄 C24、C25、C26）。這一節保留，因為方法與教訓對後續改稿仍然適用。

### 稽核結論：四項未達，兩項部分達成，並查出兩個模型缺陷

| | |
|---|---|
| **未達** | V5b（頻率符號）、V7b（血清鈣 MR 符號）、V13（幅度天花板，結構性）、V15（骨膜未外擴） |
| **部分達成** | V3（方向對、無衰減）、V10（方向對、終點過衝 1.47 %） |
| ~~模型缺陷 1~~ | ~~血清鈣擺動 15 %~~ → **P5k 已修**：現為 **1.61 %**（C27） |
| ~~模型缺陷 2~~ | ~~骨→血耦合可忽略~~ → **P5k 已修**：廢用第 60 天 PTH **−19.9 %**（臨床 −24 %）（C27） |
| **新的結構衝突** | **V7 與 V16 搶同一個 `lambda_P`**：V7 要 ≥7、V16 要 ≤4，無解。取 6 為折衷，V16 = 1.184 落在 1.2–1.4 之外（容差 0.15 內）—— C27.5 |

**P5k 已於 v2.14 完成**（附錄 C27）。鈣模組兩半重建 + 重擬。**所有盲測（V6a–f、V10、V14）在一次結構重寫加重擬之後全數存活。**

### ⚠️ 送出前務必做的三件事

1. **全數字對帳**。C25.1 查出稿件寫 −13.967 %、實際 −12.416 %（舊參數殘值），同批還有四個數字微漂。
   ```matlab
   r = evalTargets(getDefaultParams(reload=true), holdout=true);
   ```
   **稿件裡每一個數字都必須能由當前 HEAD 重跑得到。**
2. **引註缺口掃描**。凡寫「文獻報告的」「臨床觀察到的」而未指名出處者，一律視為缺口。本輪撞到兩次（V10/V16 為 C25.4；V1/V2/V3 為 C26.1），共補進三筆文獻（23 McClung 2018、24 Spatz 2012、25 Parfitt 2002）。
3. **三份同步 + 重建 docx**（見 §5）。

### ✅ 稿件數字已與 v2.14 對帳完畢（2026-07-28）

**三個語言版本 + 兩份 docx 皆已更新並重建**；引註完整性複驗通過（25/25 有引用、無孤兒 bibitem、LaTeX 環境平衡）。下表保留為變更紀錄。

**仍未完成的兩件事：**
1. **七張 TIFF 需重出** —— 圖的數字全變了：`run(fullfile(projectRoot(),'experiments','exportFiguresPLOS.m'))`
2. **辨識性分析仍在跑** —— 稿件與 S1 Fig 的 `r = −0.89` 仍是舊參數組的值。結果出來後要更新稿件「校正，以及被保留的部分」一節。`K_P_sost` 現落在上界 100，該節須據實說明。

| | v2.13（稿件現值） | **v2.14（正確值）** |
|---|---|---|
| V1 骨轉換 | 7.19 %/yr | **7.03** |
| V2 廢用流失 | 1.153 %/mo | **1.196** |
| V3 硬化蛋白 | +48.8 % | **+61.2 %**（離 Spatz 峰值 +42 % 更遠了） |
| V7（400→1500） | +1.140 % | **+0.705 %**（僅勉強在 0.7–1.8 內） |
| V7slope | −0.2385 | **−0.140** |
| V8 小樑 | +12.497 % | **+12.160 %** |
| V8 皮質 | +2.437 % | **+2.202 %** |
| **V16** | 1.305 ✅ | **1.184 ❌ 已不在 1.2–1.4**（差 0.016，容差 0.15 內） |
| V10 小樑 | −12.416 % | **−12.866 %** |
| V10 皮質 | 未報告 | −2.679 % |
| V14 | 761.8 με | 761.8（不變） |
| 小樑/皮質放大 | 5.1 倍 | **5.5 倍** |
| P1 子句 1 | +0.470 % | **+0.323 %** |
| P1 子句 2（BMC） | +4.589 % | **+4.633 %** |
| 同對比 aBMD | +1.865 % | **+1.905 %** |
| 中等強度（2236 με） | +3.093 % | **+3.133 %** |
| **負荷/鈣比值** | 9.8 倍 | **14.3 倍** |
| P1 子句 3 絕對 | 3.938 vs 4.878（19 %） | **3.751 vs 4.808（22 %）** |
| **P1 子句 3 差異中的差異** | **−0.536（反轉）** | **+0.333（成立）** |
| 循環數 18→1200 | +0.540→+2.541，41 倍 | **+0.561→+2.271，35 倍** |
| 休息插入低幅值增益 | 11.08 倍 | **13.99 倍** |
| 頻率（骨層級） | +0.770→+0.611 | **+0.797→+0.635** |
| V6a–f | 11.44 / 11.74 / 10.04 / 23.57 / 13.44 / 1.27 | **12.48 / 11.78 / 10.54 / 24.02 / 13.03 / 1.76**（六項仍全過） |
| V12 併用 | +2.898（次相加 10.8 %） | **+2.734（次相加 10.2 %，−0.311 點）** |
| P3 回復 | 99.7 % | **100.4 %** |
| 骨膜棘輪 | +0.213 mm | **+0.005 mm** |
| V7b 血鈣擺動 | 15.15 % | **1.55 %** |
| V7b 箝制 +2 % | aBMD +0.124 % | **+0.714 %**（符號仍錯，且大了六倍） |
| V11 比值 | 25.8（十年回復 51.5 %） | **23.68（57.7 %）** |
| V15 骨內膜 | +0.0585 mm | **+0.0593 mm**（骨膜仍為 −0.0022，仍未達） |
| 廢用對策 | 0.896 %/mo，防住 22 % | **0.957 %/mo，防住 20 %** |

### ✅ 兩處敘事已改（記錄）

1. **P1 子句 3 不再反轉。** 差異中的差異由 −0.536 變成 **+0.333**，也就是「鈣缺乏截斷負荷所能建造的量」在這個框架下**也成立**。稿件的招牌句「**三個子句有兩個**會在不同度量下符號反轉」**已經錯了 —— 現在只有子句 2（BMC vs aBMD）會反轉**。**已改**：摘要、Results P1 末段、Discussion、圖 7 caption。處理方式不是把第二句悄悄拿掉，而是**如實寫出它曾經反轉、直到別處模組被修好** —— 這反而把方法學論點講得更利：一個被報告的交互作用，其符號取決於兩個模組之外的缺陷。
2. **V16 由達標變成未達標**，且原因是 C27.5 的結構衝突。**已改**：Results 新增一段說明 V7/V16 的結構衝突（C27.5），Limitations 亦同。

### ⚠️ 第三次撞到同一種 bug：把結論寫死在字串裡

- `E2` 印 `-> claim REVERSES` 是**寫死的字串**，值變成 +0.333 之後仍照印。**已修為依符號判斷。**
- `E7` 印的血鈣「*** DEFECT ***」整段也是寫死的，1.55 % 之後仍照印。**已修為依數值判斷。**
- 加上 C25.1 的 V10 舊值殘留 —— **凡「結論」都必須由當下的數算出來，不可寫死。**

### 其他待辦

- 七張 **TIFF 需重出**（圖的數字全變了）：`run(fullfile(projectRoot(),'experiments','exportFiguresPLOS.m'))`
- **辨識性分析需重跑**（S1 Fig 與稿件的 r = −0.89 都是舊的）
- `K_P_sost` 現在落在上界 100；稿件的辨識性段落須據實說明

---

### 🟡 稿件：彈性律那組已改完，其餘等 Fu 2025

**已改完（2026-07-28）**：彈性律那組數字與那句錯誤陳述，三個格式 + 兩份 docx 皆已更新。**未重出 TIFF**（刻意）。

**刻意暫緩其餘對帳，等 Fu 2025**。理由：Fu 給的四個 MSIC 速率常數餵 E1 的三個面板（V4／V5／**V5b**），很可能連動重擬；現在做完整對帳，Fu 一到就要整個重做。而 V5b 目前的失敗其實**說服力不足** —— 審稿人可以說「你只證明了猜的參數給出錯的符號」。拿到 Fu 之後兩種結果都可發表：符號修正＝盲測通過；符號仍錯＝**有出處的否證**。

> **停損點**：若館際兩、三週內拿不到 Fu，就不等了 —— 直接對帳送出，V5b 照現行寫法標為「架在佔位常數上」即可，那個寫法本來就站得住。

### 仍待對帳（等 Fu 之後一次做完）

| | 稿件現值 | **v2.17** |
|---|---|---|
| V14（盲測） | 761.8 με | **786.8** |
| V2 / V7 / V8 / V10 | 1.196 / +0.705 / +12.160 / −11.471 | **1.185 / +0.716 / +12.042 / −11.380** |
| V6a–f | 12.48/11.78/10.54/24.02/13.03/1.76 | **12.88/12.45/10.82/25.22/14.09/1.86** |

✅ 那句錯誤陳述已改寫（主稿 + S1 Text + `docs/model_equations.md`）。新的寫法比舊的更強：**皮質與小樑各有一個量測依據，而非一個被劈成兩半的折衷值**。

⚠️ 七張 TIFF 仍需重出 —— **等 Fu 之後與其餘對帳一起做**，現在重出會白做一次。

---

### 📚 文獻取得狀態（v2.15 更新）

**手上有全文**：Pivonka 2008（`Reference/02.pdf`）、Peterson & Riggs 2010（`03.pdf`）、**Lemaire 2004（`10.pdf`，2026-07-28 新到）**。三者皆已逐字轉錄於 `data/reference_parameters.md`。**PDF 本身永不進版控**（`.gitignore` 第 19 行涵蓋 `Reference/`）。

**仍缺 12 篇，依價值排序**（`references_verified.md` E 段的舊排序已標註過期，且漏了 Haapasalo 與 Srinivasan）：

| | 文獻 | 解鎖 |
|---|---|---|
| **1** | **Fu R, Wang C, Shahneela N, Ud Din R, Yang H.** Int J Mech Sci. 2025;286:109931 | `k_co_max, k_oc, k_oi, k_ic` 四個佔位速率常數；**V5b 首要複驗對象**，連動 V4／V5 |
| **2** | **Wijenayaka AR, Kogawa M, Lim HP, Bonewald LF, Findlay DM, Atkins GJ.** PLoS One. 2011;6(10):e25900 | **V13 的結構性天花板**：`K_L`=0.5 而基線 S=1，最大恆為 1.33 倍。要定 `K_L` 非讀原文不可。v2.13 稽核才浮現的需求 |
| **3** | **Haapasalo H, Kontulainen S, Sievanen H, Kannus P, Jarvinen M, Vuori I.** Bone. 2000;27(3):351–357 | `r_p_0`、`r_e_0` 的說明明寫「awaits full-text confirmation」（現值由 Tot.Ar／M.Cav.Ar 量級**推算**）。**這是六個 V6 盲測的來源**，卻一直不在清單上 |
| **4** | **Li X, Han L, Nookaew I, Mannen E, Silva MJ, Almeida M, et al.** eLife. 2019;8:e49631 | `tau_50`、`k_tau_sig`（後者是 v1.5 為讓 V2 成立而下修的擬合值，等於扛著一個沒出處的數） |
| **5** | **Weinbaum S, Cowin SC, Zeng Y.** J Biomech. 1994;27(3):339–360 | `k_perm, S_stor, a_canal, Gamma_PCM`；可把集總的 `K_tau` 由標定值改成推導值 |
| **6** | **Lerebours C, Thomas CDL, Clement JG, Buenzli PR, Pivonka P.** Bone. 2015;72:109–117 ＋ **Martin RB.** Crit Rev Biomed Eng. 1984;10(3):179–222 | `S_v(f_bm)` 真形式。**Lerebours 更關鍵** —— 它指出皮質與小樑不可共用一條曲線，而我們兩個腔室正是共用的 |
| **7** | **Srinivasan S, Weimer DA, Agans SC, Bain SD, Gross TS.** J Bone Miner Res. 2002;17(9):1613–1620 | V5 的「2–5 倍」是**我們自己設的帶**，而模型給 13.99 倍（超出上界 2.8 倍）。要判斷是模型錯還是帶設錯，得看原始實驗數字。**這一篇原本也不在清單上** |
| **8** | **Currey JD.** J Biomech. 1988;21(2):131–139（＋ Gibson & Ashby, *Cellular Solids*，教科書） | `kappa_E`、`nu_E`。⚠️ **已引用（文獻 16）但未取全文** —— 引用過 ≠ 拿到數。`kappa_E` 決定力學回饋增益，是 E6 關鍵參數 |
| **9** | **Cosman F, Crittenden DB, Adachi JD, Binkley N, Czerwinski E, Ferrari S, et al.** N Engl J Med. 2016;375(16):1532–1543 | romosozumab 逐月 BMD 與骨標記軌跡 → V8/V9/V16 由端點升級為軌跡。**對現在未達的 V16 特別有用** |
| **10** | **Marques FC, Boaretti D, Walle M, Scheuren AC, Schulte FA, Muller R.** Front Bioeng Biotechnol. 2023;11:1140673 | V5b 的定量頻率–反應曲線（現在只用了它的對數形式定性宣稱） |
| **11** | **Schulte FA, Marques FC, Griesbach JK, Weigt C, von Salis-Soglio M, Lambers FM, et al.** Nat Commun. 2026;17:3759 | V12 定量交互作用項 → 檢驗我們的次相加 10.2 % |

**不需再取得就能結清的帳**：`K_L3`、`kappa_OPG` 的說明寫著「Must be taken from the source full text」，但那個 source 是 Pivonka 2008，全文我們有。

### ⚠️ 22 個參數宣告了卻從未被程式讀取

這是 `renal_k`／`renal_Ca_th` 藏了好幾個月沒被發現的同一個破口（P5k 前），現在確認至少有 22 個：

```
alpha_f f_c tau_target_lo tau_target_hi J_max delta_Y beta_S k_T gamma_ot
L_0 O_0 W_0 delta_beta D_A k_B R_0 B_0 C_0 P_max k_VD renal_k n_renal
```

其中有些是刻意的（`alpha_f`/`f_c`/`n_renal` 已標 superseded；`tau_target_*` 是驗證用非模型參數；`R_0`/`B_0`/`C_0`/`D_A`/`k_B` 因 M6 改為基線相對式而只作出處紀錄）。但**這份名單從來沒有人列過**，所以無法區分「刻意」與「忘了接線」。

**建議做法**：在 `test_units` 加一個檢查 —— 每個參數要嘛被 `src/` 讀取，要嘛在說明中明確標記為 superseded／provenance-only／非模型參數。這樣 P5k 那種「宣告了卻沒實作」就不可能再躲過。

---

### 檢查方法（逐節問三道題）

1. **主張說清楚了嗎？** 讀者不必翻回前言就知道這節在測什麼。
2. **判準寫明了嗎？** 門檻／容差／「什麼情況才算證實」必須在給數字**之前**出現。
3. **數字與判準對得上嗎？** 特別注意：有沒有拿 A 對比的數字去比 B 對比的區間。

### 前一 session 找到的四類缺陷（照著找，很可能還有）

| 類型 | 實例 | 為何危險 |
|---|---|---|
| **拿錯對比去比區間** | P1 子句 1 原寫「+0.470 %，落在 0.7–1.8 % 帶內」。**0.470 不在該帶內** —— 那是 400→1500 對比（+1.140 %）的帶，子句 1 用的是 800→1500 | 審稿人對一下數字就會發現，並連帶懷疑其他數值 |
| **判準從未出現** | P1 三子句門檻（<1 %、>4 %、交互作用為正）**全篇從未寫出** | 讀者只能接受我們說「通過」 |
| **把「部分成立」寫成「成立」** | V5 幅度超出自訂區間兩倍（11.08× vs 2–5×）；V9 達峰時間差 5 倍（第 0.2 月 vs 臨床第 1 月） | 累積起來會讓人覺得我們在挑好的講 |
| **宣稱從未做過的對照** | V12 原文暗示「不同於抗吸收藥」，但**模型裡沒有任何雙磷酸鹽機制**（`scenarioLibrary` 有欄位，無方程式消費它） | 直接的過度宣稱 |

> **第五類，v2.13 才發現，也最嚴重**：**訂了標的卻從來沒有執行**。V7b/V11/V13/V15 在 `data/validation_targets.csv` 裡躺了很久，機制都建了、原始碼註解還寫明「這是 V13 的機制」，但 `evalTargets` 不算、E0–E6 不碰。跑完之後三個是敗的。**檢查任何標的時，第一件事是先確認真的有程式碼在算它**（`grep -rn "V13" experiments/ src/`）。
>
> **另一類、最不易察覺的**：`manuscript.md` 的 Results 段原本只有 3 處引註，`.tex` 卻有 18 處 —— 先寫 `.md`、後在 `.tex` 補引註卻沒回填。**而投稿用的 `.docx` 是從 `.md` 產生的**，那份 Word 檔幾乎沒有引註。已補齊（22 筆全數在正文有引用）。
>
> **教訓：每次改完 `.md` 或 `.tex`，都要跑一次雙向對照**（指令見 §5）。

### 修正時務必三份同步

`manuscript.md`（Word 的來源）、`manuscript.tex`、`manuscript_zh-TW.md`，改完重建兩份 `.docx`。

---

## 1. 這個專案是什麼

骨重塑力學生物學多尺度數學模型。核心命題：**鈣是「許可性」因子，機械負荷才是「指令性」因子**。八個耦合模組 M1–M8：器官力學 → 孔彈性剪應力 → MSIC 通道劑量 → 骨細胞訊號 → 骨細胞族群 → 三表面結構+礦化 → aBMD，外加全身鈣–PTH–1,25D 雙向耦合。

**三個可發表預測，定論：**

| | 預測 | 結果 |
|---|---|---|
| **P1** | 鈣許可、負荷指令 | ✅ 成立，**但三個子句各自帶度量限定**（見 §4 紀律 3） |
| **P2** | 部位專一性 | ✅ 定量成立（V6 六項盲測全過） |
| **P3** | 骨鬆為替代穩態 | ❌ **否證 —— 模型單穩**（兩條獨立路徑佐證） |

**已知缺陷（v2.13）**：(1) 血清鈣隨飲食擺動 15 %，生理約 ±2 %（C24.5）；(2) **骨→血的耦合數值上可忽略**，廢用時 PTH 只動 −0.01 % 而臨床為 −17~−24 %，故「雙向耦合」在結構上為真、數值上實質單向（C26.5）；(3) V13 的 RANKL 反應有結構性天花板 1.33 倍；(4) 模型不產生停經後骨膜外擴。四項均已如實寫入稿件 Results 與 Limitations。(1)(2) 合併為待辦 P5k。

---

## 2. 現況：v2.14，84 測試全過，已公開並取得 DOI

```
GitHub  https://github.com/myhsieh1002/bone-mechanostat   (PUBLIC, MIT)
Zenodo  concept DOI 10.5281/zenodo.21592303   ← 論文引用這個
        v2.12  DOI 10.5281/zenodo.21592304
```

每次 MATLAB session 開頭：
```matlab
cd('.../骨骼鈣質吸收數學模型'); addpath('src'); setupPath(); maxNumCompThreads(4);
runtests("tests")     % 84 tests, 13 files
```

**投稿檔案在 `投稿PLOS Comp Biol/`（已 gitignore，只在本機）**：

| 檔案 | |
|---|---|
| `manuscript.docx` | **建議投稿用**。Times New Roman 12 pt、雙倍行距、連續行號、頁碼 |
| `manuscript.md` | **Word 的來源**。改內容改這份 |
| `manuscript.tex` | LaTeX 版（本機無 LaTeX 工具鏈，**從未編譯驗證過**） |
| `manuscript_zh-TW.{md,docx}` | 中文校稿版，非投稿檔 |
| `figures_tiff/Fig1–7.tif` | 2250 px × 7.50 in、300 dpi、LZW、≥8 pt，符合 PLOS |
| `figures/` | 同樣七張的 PNG/PDF（尺寸超出 PLOS 上限，**勿直接投稿**） |
| `cover_letter.md`、`references.bib`、`references_verified.md`、`supporting_information/` | |
| `build_docx.js` | `node build_docx.js <in.md> <out.docx> [字型]` |

**⚠️ 這個資料夾不在版控、也不在 git 歷史中**（v2.12 以 filter-branch 移除）。換機器或重新 clone 不會帶過去，請自行備份。資料夾內兩份屬於程式碼的文件已搬到 `docs/model_equations.md` 與 `docs/parameter_provenance.md`。

---

## 3. 送出前仍未完成

- [x] ✅ **標的稽核已完成**（V1–V16 全部，附錄 C24–C26）
- [ ] **送出前三件事**（見 §0）：全數字對帳、引註缺口掃描、三份同步
- [ ] **CRediT 貢獻**：主持人自行填寫；稿件 Declarations 已留帶分類清單的空位（`[roles]`）
- [ ] **`manuscript.tex` 從未編譯**：本機無 `pdflatex`。若要用 LaTeX 投稿請先在 Overleaf 跑一次。（已通過靜態檢查：環境配對、括號、cite↔bibitem、label↔ref）
- [ ] 投稿系統 Funding 欄填：`The authors received no specific funding for this work.`

**作者（已定稿）**：
第一 Hsiang-Lin Lee（ORCID 0000-0003-1422-1042, s31079@gmail.com）
第二 Tzu-Ling Wang（0000-0003-3520-0531, purplering@icloud.com）
**通訊 Ming-Yu Hsieh**（0000-0002-5797-3474, cshy1392@csh.org.tw）

---

## 4. 敘事紀律（改稿時務必維持，來源見附錄）

1. **P3 的否證寫進主論文，不放補充材料**（C16）。全文唯一「模型推翻自身先驗假說」的結果。
2. **陡峭 ≠ 雙穩；速率不對稱 ≠ 動力學不可逆**（C16.2）。E2≈0.92 的陡過渡與 V11 的回復慢，都不得寫成雙穩態證據。
3. **P1 三個子句各自帶度量**（C23）：子句 1 用 aBMD、子句 2 用 **BMC 且負荷 ≈2900 με**、子句 3 用**絕對框架**。換度量會翻轉子句 2 與 3。
4. **hold-out 就是 hold-out**：V6a–f、V10、V14 從未進入目標函數。這是全文預測力主張的地基。
5. **假影要如實交代**（C15.4、C17、C24.4）：99 mm 皮質假影已寫入 Results；V15 的 +5.75 mm 骨膜外擴同屬此類，**不得報告**。
6. **失敗的標的照樣寫進 Results**（C24）：V7b/V13/V15 三敗已成獨立一節「Four targets we had specified but never run」。不要為了好看把它挪到補充材料。
7. **⚠️ 不得寫 "pre-registered"**。假說確實在校正前（2026-07-23）寫進計畫書、校正在 07-25，但**從未在任何公開登記平台登錄**，repo 到 07-26 才公開，且當日重寫過歷史。稿件現在的寫法是陳述順序並明確聲明不主張正式預先登記 —— **不要升級回去**。

---

## 5. 常用檢查指令

```bash
# 引註雙向對照（.md 是 Word 的來源，最容易漏）
cd "投稿PLOS Comp Biol"
python3 -c "
import re
s=open('manuscript.md',encoding='utf-8').read(); body=s[:s.index('## References')]
n=set()
for m in re.findall(r'\[([0-9]+(?:\s*,\s*[0-9]+)*)\]', body): n.update(int(x) for x in m.replace(' ','').split(','))
print('未引用:', sorted(set(range(1,26))-n) or 'none')"   # 目前 25 筆
```

```bash
# .tex 結構與引註對應
python3 -c "
import re; from collections import Counter
s=open('manuscript.tex',encoding='utf-8').read()
B,E=Counter(re.findall(r'\\\\begin\{(\w+\*?)\}',s)),Counter(re.findall(r'\\\\end\{(\w+\*?)\}',s))
print('環境失衡:', {k:(B[k],E[k]) for k in set(B)|set(E) if B[k]!=E[k]} or 'none')
c={k.strip() for m in re.findall(r'\\\\cite\{([^}]*)\}',s) for k in m.split(',')}
i=set(re.findall(r'\\\\bibitem\{([^}]*)\}',s))
print('引而未列:', sorted(c-i) or 'none', '| 列而未引:', sorted(i-c) or 'none')"
```

```bash
# 重建兩份 Word（改完 .md 一定要跑）。docx 套件非預裝，需先 npm install
cd <有 node_modules/docx 的目錄>
node build_docx.js ".../manuscript.md"       ".../manuscript.docx"
node build_docx.js ".../manuscript_zh-TW.md" ".../manuscript_zh-TW.docx" "PingFang TC"
```

```matlab
% 重建 PLOS 規格 TIFF（改過任何 E0–E6 的圖就要跑）
run(fullfile(projectRoot(),'experiments','exportFiguresPLOS.m'))
```

---

## 6. ⚠️ 踩雷點（每一條都真的發生過）

1. **負荷輸入必須是「力」，永遠不是「應變」**（v1.2 致命缺陷）→ `test_closedloop.m`
2. **通道只建模一次**，只在 `msicGating.m` → `test_noPhenomParams.m`
3. **絕不 `savepath`**；`parpool('Processes',3)` 上限（10 核機器，其他 session 也要用）
4. **`results/` 不進 iCloud**，一律經 `getResultsDir()`
5. **`delta_ab` 只在用藥時生效**（`clr = delta_S + delta_ab*u_romo`），故 V1/V2/V7/V6/V14 在數學上與它無關 —— 這是 P5g 單參數重擬的根據
6. **讀任何模擬結果前先看 `out.validity.ok`**。false 代表逸出線性彈性域（>7000 με），其幾何不是物理結果
7. **bedrest 超過約 7.5 個月會塌到孔隙率地板**（V2 的 180 天視窗仍完全有效）
8. **`continuation` 的 `branch.stable{k}` 是對 `branch.fps{k}` 的邏輯遮罩，不是不動點值**。誤讀會讓整條分支變成常數 1.0。取值用 `fps(find(st,1))`
9. **`evalTargets` 會呼叫 `trabecularParams`**，故後者**絕不可**回頭呼叫前者（無限遞迴）；它改用閉式的 `turnoverRate.m`
10. **`run()` 與被執行的腳本共用 workspace**。實驗腳本用 `k`/`i`/`j`/`f`/`s` 當迴圈變數，會蓋掉呼叫端的索引 —— 這曾讓圖存成錯的檔名並使迴圈越界。用 `runExperimentFigure.m` 隔離
11. **MATLAB 畫布吋數→輸出像素是量化且非單調的**（6.5 吋→2986 px、5.0→1472、4.0→1481、3.0→898）。不要迭代調畫布；用 `exportFiguresPLOS.m` 的「量測一次 → 算縮放比 → 預先放大字級」確定性做法
12. **`git log --name-only` 對非 ASCII 路徑會做 octal 轉義**，用 `grep "投稿PLOS"` 掃會得到**假陰性**。用 pathspec（`git log -- '投稿PLOS Comp Biol'`）或 `-c core.quotepath=false`
13. **血清鈣擺動 15 %，而守門的測試界也是 15 %**（C24.5）。`testSerumCalciumIsTightlyRegulated` 的名字與註解說「a few percent」，斷言卻是 `< 0.15`。它原是防 55 % 失控用的，之後被當成恆定性檢查讀。**看斷言，不要看測試名字。** 修法是改模型（P5k）不是改測試，故門檻刻意保留
14. **`renal_k` 與 `renal_Ca_th` 宣告在參數表裡，`calciumPTHvitD.m` 從未讀過**。可飽和小管重吸收沒有實作。改動腎臟模組前先確認自己在改真的被用到的東西
15. **MCP wrapper 限制**：script 內不能定義 local function 再被 anonymous handle 呼叫（要另存 `.m`）；`verifyEqual` 的 Name=Value 必須放在 msg 之後
16. **長模擬會 timeout**（>1800 s）。`continuation` 用 `nFbm<30, days<800`

---

## 7. 這個 session（2026-07-26）做了什麼

v2.4 → **v2.12**，測試 61 → **81**，新增附錄 **C16–C23**。

| | |
|---|---|
| **A** P3 敘事改寫（C16） | 全文統一為「已否證」，立三條措辭紀律 |
| **B** P5e modeling 飽和界（C17） | 假影修掉。**飽和界必要但不充分**，補 `out.validity` 彈性域守衛。取得不凍結幾何的有效遲滯探針，P3 否證獲第二條佐證 |
| **D** E0–E6 實驗＋七張圖（C18） | **V5 由否轉是**；**V5b 骨層級符號翻轉**（降級） |
| **C** P5d 小樑腔室（C19） | 3.6× 放大確認，**診斷推翻 P5d 前提：BV/TV 不是槓桿** |
| **P5g**（C20） | 修**目標函數的腔室範疇錯誤**，`delta_ab` 重擬 → V8 = 12.51 % 首次真正達標 |
| **P5h**（C21） | 新增狀態 `A_reb`（停藥反彈）→ **V10 = −13.97 %，以 hold-out 身分達標**；V9 強形式一併解決 |
| **P5i**（C22） | modeling drift → **V6e 髓腔 +13.44 %，V6 六項全過** |
| **C23** | 主持人裁決：**P1 第二句改以 BMC 陳述**，「適當負重」定義為 ≈2900 με |
| **C24**（v2.13） | 稽核發現 **V7b/V11/V13/V15 從未被執行**；新增 `E7_qualitativeTargets.m` 跑完，一過三敗。附帶查出血清鈣 15 % 擺動缺陷與 15 % 界的假保證測試。兩份 SI 表由中文改為英文（PLOS 需求），`data/` 亦同步為單一英文來源 |
| **P7** | 稿件、七張 TIFF、S1 Text、22 筆文獻查證、Word/LaTeX/中文三版、cover letter |
| repo | 公開、MIT、CITATION.cff、英文 README、Zenodo DOI |

**V1–V16 現況（v2.13 更新，四項未達）**：

| | 未達之處 |
|---|---|
| **V5b** | 骨層級頻率符號 r = −0.998，與 Hsieh & Turner 相反 |
| **V3** | 方向對，但**無衰減** —— 模型第 28 天即達 +48.8 % 並持平，實測第 60 天達峰 +42 %、第 90 天回落至 +22 % |
| **V10** | 方向對（−12.416 %），但**幅度過衝** —— 吐回增益 111.8 %，24 個月跌破基線 1.47 %，臨床是「趨近」基線 |
| **V7b** | 血清鈣 +2 % → aBMD +0.124 %，符號錯 |
| **V13** | 破骨活化僅 1.42 倍（文獻約 7 倍），且此天花板是結構性的 |
| **V15** | 骨膜向內 −0.0022 mm，未重現停經後骨徑增寬 |

**不要再寫「僅 V5b 未達」。** 那句話在 v2.12 之前為真，是因為另外三個從來沒被執行過。

---

## 8. 之後的科學工作（稿件送出後）

依價值排序，均記於計畫書附錄：

1. **小樑穿孔的顯式表徵** —— P3 否證直接指向這裡。連續 f_bm 描述無法捕捉「模板喪失」，而那是不可逆性唯一還沒被排除的來源。
2. **取得 Fu 2025 全文**（Int J Mech Sci. 2025;286:109931）→ MSIC 三態速率常數 → 複驗 V5b。
3. **`S_v(f_bm)` 換掉佔位函數** —— Lerebours 2015（PMID 25433340）實測該關係為個體專一，且皮質與小樑在同孔隙度下顯著不同，而我們兩個腔室共用一條曲線。
4. **P5f：bedrest 長期崩潰** —— 缺一個不依賴力學的基礎形成率。
5. **Sobol / LHS 全域靈敏度** —— `sensitivityLHS`、`sobolIndices` 仍為骨架。
6. **抗體 PK** —— 現為階躍函數，使停藥暫態較實際尖銳。

---

*Handoff 更新於 2026-07-26｜v2.4/61 測試（Opus 4.8）→ **v2.13/81 測試、附錄 C16–C26、V1–V16 稽核完畢、投稿就緒**（Opus 5）｜送出前三件事見 §0*
