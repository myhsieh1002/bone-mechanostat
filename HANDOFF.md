# HANDOFF — bone-mechanostat

**接手者請先讀這份，再讀 `PROJECT_PLAN_bone_mechanostat.md`（v2.9，含附錄 C1–C20）與 `README.md`。**

主持人：謝明諭 (Ming-Yu Hsieh)｜MATLAB R2026a｜語言：程式碼英文、討論與計畫書中文。

---

## 1. 這個專案是什麼

骨重塑力學生物學多尺度數學模型。核心命題：**鈣是「許可性」因子，機械負荷才是「指令性」因子**。八個耦合模組 M1–M8（器官力學 → 孔彈性剪應力 → MSIC 通道劑量 → 骨細胞訊號 SOST/Wnt → 骨細胞族群 → 三表面結構+礦化 → aBMD ＋ 全身鈣–PTH–1,25D 恆定），串成可模擬、可校正、可做分歧分析的完整鏈路。

**三個可發表預測，目前定論：**
| | 預測 | 結果 |
|---|---|---|
| **P1** | 鈣許可、負荷指令 | ✅ 量化成立（V7 補鈣 +0.97% 且一年達平台，符合 Tai 2015） |
| **P2** | 部位專一性（局部負荷造成不對稱、全身介入不能） | ✅ 定量成立（V6 網球肱骨盲測湧現，幾何增益、密度不變） |
| **P3** | 骨鬆為替代穩態（鞍結點雙穩） | ❌ **否證 —— 模型單穩**；骨鬆為對雌激素之陡峭連續位移 |

**P3 是否證結果，不是失敗**（附錄 C15）。論文敘事應據此改寫，見 §7。

---

## 1b. ⚡ 2026-07-26 session 的四項工作（A/B/D/C 全做完）

版本推進 v2.4 → **v2.9**，測試 61 → **72**，新增附錄 **C16–C20**。各項定論：

| | 工作 | 結果 |
|---|---|---|
| **A** | P3 敘事改寫（C16） | 全文統一為「已否證」。三條**措辭紀律**：陡峭≠雙穩、速率不對稱≠動力學不可逆、否證入主論文 |
| **B** | P5e modeling 飽和界（C17） | 假影修掉。**飽和界必要但不充分**（不移動不動點），故補上 `out.validity` 彈性有效域守衛。**成果：首次取得不凍結幾何的有效遲滯探針，f_bm 0.95→0.40→0.9485，P3 否證獲第二條獨立佐證** |
| **D** | E0–E6 實驗＋七張論文圖（C18） | P1 量化成立。**V5 由否轉是**（C6.4 風險解除）；**V5b 骨層級符號翻轉**（降級，待 Fu 2025）；V9 弱形式成立、V12 次相加 7.7% |
| **C** | P5d 小樑腔室（C19） | 3.6× 放大確認，但 **V8 停在 +4.5% 未達標**。**診斷推翻 P5d 前提：BV/TV 不是槓桿**，缺口是 `delta_ab` |
| **P5g** | 重擬 `delta_ab`（C20） | 修的是**目標函數的腔室範疇錯誤**（V8/V10 一直算在皮質模型上還進 `chi2`）。`delta_ab` 0.09184 → **0.24875**，**V8 = 12.506% 首次真正達標**；V1/V2/V7/V6/V14 逐字不變 |

**下一步 = P5h：加 romosozumab 停藥反彈機制達成 V10 —— 目前唯一仍未達的定量標的。** 已診斷清楚（C20.4）：這是**時間尺度**問題不是結構問題。模型的增益**確實會逆轉**，但停藥後 2.85 年才達峰、第 6 年才跌回 12 個月水準，比臨床慢約 5 倍。`lambda_S` 與 `K_L` 掃遍文獻全域都無效（`gS` 飽和使 `lambda_S` 在 `gS(S)/gS(1)` 中相消；且硬化蛋白過衝本身只有 +7.2%，那是 mechanostat 的後果不是參數）。缺的是**藥理層面的停藥反彈**（臨床 CTX 會衝到基線以上）。

> ⚠️ **C19.4 有一處已更正的錯誤**：它曾聲稱 `delta_ab` ×2.5–3 可同時達成 V8 與翻正 V10。**不成立** —— V10 對 `delta_ab` 非單調，過零在 ×4（該處 V8 已 +18.45%，出帶）。更正見 C20.4。

**新增的踩雷點**：
1. `continuation` 回傳的 `branch.stable{k}` 是**對 `branch.fps{k}` 的邏輯遮罩**，不是不動點值。誤讀會讓整條分支變成常數 1.0。取值用 `fps(find(st,1))`。
2. **讀任何模擬結果前先看 `out.validity.ok`**。false 代表軌跡逸出線性彈性域（>7000 με），其幾何不是物理結果。
3. **bedrest 超過約 7.5 個月會塌到孔隙率地板**（V2 的 180 天視窗仍完全有效）。長期廢用模擬目前無效 —— P5f 候選。
4. **`evalTargets` 現在會呼叫 `trabecularParams`**（V8/V10 算在小樑腔室）。故 `trabecularParams` **絕不可**再呼叫 `evalTargets`，否則無限遞迴 —— 它改用閉式的 `turnoverRate.m`。

---

## 2. 現況：P1–P6 + P5e/P5d 完成，v2.8，72 測試全過

```
git log --oneline  (12 commits, branch main)
bca019f P6 bifurcation: P3 falsified -- model is monostable (v2.4)
13f632c P5b+P5c: V6 emerges as a blind test -- geometric gain, density unchanged (v2.3)
e6e9303 P5b diagnosis (docs only, code kept at v2.2)
6a5f33d P5 two-site: P2 qualitatively holds; V6f exposes M7 gap
04e149e Identifiability: 3 params identifiable, PTH pair correlated but bounded (v2.1)
ebf52c2 P4 calibration: full model passes all targets AND both hold-outs (v2.0)
6030c34 Literature backfill: Pivonka 2008 + Peterson & Riggs 2010
1a219b1 P4 structure: M8 calcium homeostasis wired in
4744a74 P3 biology: M4-M7 live, C6.5 joint test passes
3d6317a P2 mechanics: M2 poroelasticity + M3 channel gating
8ed60a9 P1 verified
138f128 P1 skeleton
```

執行方式（每次 MATLAB session 開頭）：
```matlab
cd('.../骨骼鈣質吸收數學模型'); addpath('src'); setupPath(); maxNumCompThreads(4);
runtests("tests")     % 61 tests, 8 files
```

**73 個 .m 檔**：`src/`（模組實作）、`tests/`（8 支測試）、`experiments/`（E0–E6 骨架，多數尚未實作）。

---

## 3. 架構速覽（改任何東西前先懂這些）

- **狀態向量**（`src/model/stateVector.m`）：單站 **16 態**（13 局部 + 3 全身）、雙站 **29 態**（13×2 + 3 共用）。局部：Ca_i, Y, S, T, n_ot, beta, R, B, C, r_p, r_e, f_bm, **rho_min**（v2.3 起礦化為單一 intensive 態，取代舊 m1/m2）。全身：Ca_s, P, V_D。
- **單站生物學單一真相源**：`src/model/siteRHS.m`。`rhsFull`（單站）與 `rhsTwoSite`（雙站）都呼叫它，避免分歧。改生物學只改 `siteRHS`。
- **入口**：`simulate(scenario, p=..., y0=...)`。情境由 `scenarioLibrary.m` 產生（`sedentary/bedrest/resistance/tennis/romosozumab/lowCalcium/highCalcium`）。
- **參數**：全部從 `data/parameters_literature.csv` 讀（欄位 name,symbol,value,unit,lower,upper,module,source,confidence,description）。**`src/**` 內硬編碼數值 = 缺陷**，`test_units` 會抓。
- **校正/分析**：`calibrate` `evalTargets` `balanceBoneFormation` `identifiability` `continuation` `steadyState` `fbmNullcline`（都在 `src/analysis`、`src/model`）。
- **驗證標的**：`data/validation_targets.csv`（V1–V15）。`holdout=TRUE` 者（V6, V10, V14）為盲測，**不得進校正目標函數**。

---

## 4. ⚠️ 四條不可違反的規則（各對應一個發生過的缺陷）

1. **負荷輸入必須是「力」（M_L, F_L），永遠不是「應變」。** 應變是 `organMechanics` 由當下幾何算出的輸出。違反 = 剪斷 mechanostat 負回饋（v1.2 的致命缺陷）。→ `test_closedloop.m`。
2. **通道只建模一次**：MSIC 三態只在 `msicGating.m`。不得另寫 P_o(τ) sigmoid，參數表不得出現 a_r, τ_r, p, τ_th, q。→ `test_noPhenomParams.m`。
3. **絕不 `savepath`**：本機多個 CCD session 各自 driving 一個 MATLAB R2026a，workspace 隔離但**共用 preferences 目錄**。`savepath` 會污染其他 session。路徑一律 `setupPath.m` 於 session 內加。`parpool` 必須 `parpool('Processes',3)` 上限（10 核機器，其他 session 也要用）。
4b. **`delta_ab` 只在用藥時生效**（`clr = delta_S + delta_ab*u_romo`），故 V1/V2/V7/V6/V14 在數學上與它無關 —— 這是 P5g 得以單參數重擬的根據。
5. **`results/` 不進 iCloud**：專案在 iCloud Drive，`.mat` 會被 evict 成佔位檔而使 `load` 失敗。一律經 `getResultsDir()` 寫到 `~/Documents/MATLAB/bone-mechanostat-results/`。`.gitignore` 已排除 `results/`、`*.mat`、`Reference/`（版權 PDF）。

---

## 5. 目前的校正值（v2.4，皆在 CSV，`source=calibrated`）

| 參數 | 值 | 定何標的 |
|---|---|---|
| `k_res` | 3.744e-7 | V1 骨轉換 7.19%/yr（`k_form` 由 `balanceBoneFormation` 導出，隨 k_res 連動，**非自由**） |
| `K_S` | 1.27 | V2 廢用 1.15%/mo。**⚠️ V2 對 K_S 高度敏感（設定點附近陡變）** |
| `K_P_sost` | 31.34 | V7 方向/幅度。**與 `lambda_P` 為相關對（r=−0.89）** |
| `lambda_P` | 3.684 | V7 |
| `delta_ab` | 0.0918 | V8（但 V8 已重定位為小樑範疇，見下） |
| `mu_turn_0` | 1e-4 | 礦化周轉（rho_min 隨形成下降）+ V2 緩衝 |
| `k_model` | 3.5e-4 | Frost modeling 幅度（V6 幾何增益）。**只縮放幅度，V6 型態與此無關** |

校正方法：`surrogateopt`，`rng(20260722)`，pool 上限 3。目標 V1/V2/V7；hold-out V6/V10/V14。

---

## 6. 已知問題與範疇界線（接手前必讀）

1. **V8/V10 重定位為小樑/脊椎範疇**（附錄 C14）。舊 P4 的 V8「通過」倚賴礦化膨脹**假影**（舊 M7 使 rho_min 於形成時錯誤上升）。v2.3 修正礦化後，皮質模型（f_bm≈0.95 近天花板）無法重現腰椎 romosozumab +11–14%（那是小樑現象）。`test_calibration` 現只斷言方向。**→ P5d：加小樑腔室（低 f_bm）。**
2. **Frost modeling 項在極端應變下無界**（附錄 C15.4）。病理性低 f_bm → 高應變 → r_p 吹爆（曾算出皮質厚 99mm）。這使全系統病理模擬無效，且是 P6 差點誤判 P3 的原因。**→ P5e：modeling 項於極端應變加飽和界。**
3. **(K_P_sost, lambda_P) 相關對**（附錄 C11，r=−0.89，聯合有界但個別觸界）。**→ 由獨立文獻固定其一**（lambda_P 取 PTH→RANKL 劑量反應；K_P_sost 取 Bellido SOST–PTH），或論文報告聯合信賴區。
4. **V4/V5 倚賴未完全檢定的「下游飽和」假說**（附錄 C6.5/C7.1）：通道層級劑量對循環數線性、休息插入增益方向與 Srinivasan 相反，靠 SOST/細胞下游飽和救回。C7.1 已在骨層級驗證通過，但參數（K_S,h_S,K_Y,n_Y）承擔多重解釋責任，須待 Fu 2025 收斂。

---

## 7. 建議的下一步（依價值排序）

**A. 據實改寫計畫書 §0 的 P3 假說** — P3 是否證的。論文敘事：「模型預測骨鬆為對雌激素之**陡峭連續轉變**（臨界 E2≈0.92），**非**雙穩態；不可逆性另有來源（小樑穿孔/骨細胞死亡，非動力學雙穩）」。這其實是更強、更誠實的科學敘事。**低成本、高價值、不阻塞於文獻。**

**B. P5e：Frost modeling 項加飽和界** — `boneStructure.m` 的 `modeling = k_model*max(0,eps_p-eps*)*sensing`，改為飽和形式（如 `k_model*(eps_p-eps*)/(1+(eps_p-eps*)/eps_sat)`）。使全系統病理模擬有效，且讓 P6 能在完整模型（不凍結幾何）複驗 P3。**中成本。**

**C. P5d：加小樑腔室** — 定量重現 V8/V10 脊椎 romosozumab。需第二個結構腔室（低 f_bm）。**高成本、大結構變動。**

**D. E1–E5 實驗腳本 + 論文圖** — `experiments/E0–E6.m` 目前多是骨架。E2 的 2×2（補鈣×負重）因子分析直接量化 P1 命題，模型已可跑。**中成本。**

**E. 取得待補文獻**（見 §8）並回填/複核。

我（前一 session）跑到 P6 結束時 context 將滿。上一則使用者選了「2」（傾向 P5d/P5e 路線），但隨即改為要求 handoff。**接手時請先與使用者確認要走 A–E 哪條。**

---

## 8. 文獻狀態

**已取得全文**（存 `Reference/`，git-ignored；轉錄於 `data/reference_parameters.md`）：
- Pivonka 2008 *Bone* 43:249（M6 速率常數，Table 3）— 已回填 D_B, D_C 等。
- Peterson & Riggs 2010 *Bone* 46:49（M8 鈣恆定）— 已提取血鈣/PTH/GFR 量級。

**待取得**：
- **Lemaire 2004** *J Theor Biol* 229:293（#1，館際服務中）→ R/B/C 基線穩態、π 函數解離常數複核。
- Fu 2025 *Int J Mech Sci*（#5）→ MSIC 三態速率常數（現為佔位）。
- Weinbaum 1994 *J Biomech* 27:339（#4）→ M2 微結構（k_perm, S_stor, a, Γ；現以集總 K_tau 吸收）。
- Martin 1984（#6b）→ 比表面積 S_v(f_bm) 五階多項式（現為佔位 f^s1(1-f)^s2）。
- Haapasalo 2000（V6 已用摘要值；全文可替換 r_p_0/r_e_0 推算值）。

多數佔位參數標 `source=assumed, confidence=low`；文獻到手後替換並複驗校正。

---

## 9. MATLAB MCP 環境注意事項（實務踩雷）

- **長模擬會 timeout**：MCP `evaluate_matlab_code` 閒置逾 1800s 會中止。**避免**：>40 年的單次模擬、或 `continuation` 用密網格（>~1000 次 QSS 積分）。分批跑、用 `outputDays` 減輸出點、`relTol=1e-4` 放寬容差、`fbmNullcline`/`continuation` 用 `nFbm<30, days<800`。
- **script 內不能定義 local function** 再被 anonymous handle 呼叫（MCP wrapper 限制）。需要 helper 就寫成獨立 `.m` 檔（如 `probeSteadyFbm.m`, `fbmNullcline.m`）。
- **`verifyEqual(tc,a,b,...)` 的 Name=Value（RelTol/AbsTol）必須放在 msg 之後**、所有位置引數之後 —— 否則 R2026a 解析錯誤。這個雷踩過很多次。
- **不要在 workspace 用 `all`/`merge` 當變數名**（覆蓋內建函式）。
- MATLAB 斷線重連後會遺失 workspace，但 `setupPath` 後即可續跑（狀態都在 CSV/檔案）。

---

## 10. 計畫書附錄索引（決策與發現的完整紀錄，都在 PROJECT_PLAN v2.4）

- **A/B**：文獻查證、待補清單、Tier 1 缺口。
- **C1**：力學回饋迴路定案（力控制而非應變控制）。
- **C5**：M3/M4 介面（通道只建模一次，刪 5 個唯象參數）。
- **C6**：P2 實測修訂（M2 高頻不飽和→V5b 免費、V4/V5 撤回）。
- **C7**：P3 生物模組（C6.5 聯合檢定通過；無靜止不動點，只質量平衡）。
- **C8/C9**：P4 系統耦合、Pivonka/P&R 回填、V7 平台。
- **C10**：P4 校正里程碑（盲測通過）。
- **C11**：辨識性（3 可辨識 + PTH 相關對）。
- **C12/C13**：P5 雙腔室 P2；V6f 診斷（需兩獨立修正）。
- **C14**：P5b+P5c V6 盲測湧現（礦化 ODE + Frost modeling）。
- **C15**：P6 分歧分析（P3 否證，單穩；攔下 modeling 幾何吹爆假影）。

**方法論主軸**（多次出現）：每一次「修正使模型更誠實」—— 撤回 V4「預測」、揭露 D_B/D_C 佔位錯 100–7600×、揭露 V8 礦化假影、攔下 P3 幾何吹爆假影。接手時**保持這個誠實標準**：盲測不進校正、假影要查證、否證要如實報告。

---

## 11. 圖與結果檔（本機 `~/Documents/MATLAB/bone-mechanostat-results/`，不在 git）

- `figures/identifiability.png` — (K_P_sost, lambda_P) 二維 χ² 圖 + 三參數一維掃描。
- `figures/bifurcation_E2.png` — f_bm* vs E2 單穩分支。
- `calibration/calibrate_final.mat`, `identifiability.mat` — 校正/辨識性結果。

---

*Handoff 撰於 2026-07-26｜v2.4/61 測試（Opus 4.8）→ **v2.9/72 測試、附錄 C16–C20**（Opus 5，同日 A/B/D/C 四項 + P5g）*
