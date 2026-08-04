# bone-mechanostat

**Mechanotransduction-Coupled Multiscale Model of Bone Remodeling**

謝明諭 (Ming-Yu Hsieh), MD, PhD ｜ ORCID [0000-0002-5797-3474](https://orcid.org/0000-0002-5797-3474)

> 鈣決定「能不能蓋」，負荷決定「要不要蓋」。

> **P1 三個子句都帶度量限定**（v2.11, C23）：子句 1 以 aBMD、子句 2 以 **BMC** 且負荷須達 ≈2900 με、子句 3 以**絕對框架**。
> 換度量會翻轉子句 2 與 3 的結論 —— 這本身是本模型的一項方法學結果。

MATLAB R2026a ｜ 計畫書：[PROJECT_PLAN_bone_mechanostat.md](PROJECT_PLAN_bone_mechanostat.md)（v2.11）

---

## 現況

| 階段 | 內容 | 狀態 |
|---|---|---|
| **P1** | 目錄骨架、參數 CSV、單位測試、`simulate` 介面 | ✅ **完成並驗證**（MATLAB R2026a） |
| **P2** | M1–M3 力學模組 | ✅ **完成並驗證**（Biot 閉式解、MSIC 三態） |
| **P3** | M4–M7 生物模組 | ✅ **完成並驗證**（C6.5 三項聯合檢定通過） |
| **P4** | M8 鈣恆定 + **全模型校正** | ✅ **完成**（53/53）：5 標的＋2 盲測全達標，**V7 鈣命題成立** |
| **P5** | 雙腔室（部位專一性 P2/V6） | ✅ **P2 定量成立**（58 測試）：V6 盲測湧現（幾何增益、密度不變）。V8/V10 重定位為小樑範疇→P5d |
| **P6** | 動力系統分析（P3） | ✅ **完成**（61 測試）：**P3 否證 —— 模型單穩**，骨鬆為陡峭連續位移非雙穩 |
| **P5e** | modeling 飽和界 + 彈性有效域守衛 | ✅ **完成**（67 測試）：假影修掉，**P3 否證獲第二條獨立佐證**（附錄 C17） |
| **E0–E6** | 實驗腳本 + 七張論文圖 | ✅ **完成**（附錄 C18）：P1 量化、**V5 平反**、**V5b 骨層級符號翻轉**、V9/V12 部分成立 |
| **P5d** | 小樑腔室 | ⚠️ **部分完成**（附錄 C19）：3.6× 放大確認，V8 未達；診斷缺口為 `delta_ab` 而非 BV/TV |
| **P5g** | 重擬 `delta_ab` | ✅ **完成**（附錄 C20）：修掉目標函數的腔室範疇錯誤，**V8=12.51% 首次真正達標**；V10 診斷為時間尺度問題 |
| **P5h** | 停藥反彈機制 | ✅ **完成**（79 測試，附錄 C21）：**V10 = −12.42%，以 hold-out 身分達標**（校正到 CTX 標記 V16 而非 BMD）；**V9 強形式一併解決** |
| **P5i** | modeling drift（V6e） | ✅ **完成**（81 測試，附錄 C22）：**V6e 髓腔 +13.44%，V6 六項全過** |
| **C23** | P1 第二句重述 | ✅ **主持人裁決**：改以 **BMC** 陳述、「適當負重」定義為 **≈2900 με**（新情境 `resistanceVigorous`）→ **+4.589% ✅** |
| P7 | 論文 | 🔄 敘事已定調（v2.5，附錄 C16）：P1✅／P2✅／**P3❌ 如實入主論文** |

**M1–M8 全模型可跑並已校正，含雙腔室、小樑腔室與分歧分析；81/81 測試通過。** `rhsFull` 串起完整訊號鏈：
力學 → 剪應力 → MSIC 劑量 → 骨細胞訊號 → 細胞族群 → 三表面結構 + 礦化 → aBMD，
外加全身鈣恆定雙向耦合。

**已校正並附辨識性分析**：`calibrate` / `evalTargets` / `balanceBoneFormation` /
`identifiability`（＋`plotIdentifiability` / `exportFigure`）。

**雙腔室（P5）**：`siteRHS`（單站生物學單一真相源）/ `rhsTwoSite` / `makeContextTwoSite`。

**E0–E6 七支實驗腳本可執行**，各產出一張論文圖到 `~/Documents/MATLAB/bone-mechanostat-results/figures/`：

```matlab
run(fullfile(projectRoot(), "experiments", "E2_calciumLoading.m"))   % P1
run(fullfile(projectRoot(), "experiments", "E5_siteSpecificity.m"))  % P2
run(fullfile(projectRoot(), "experiments", "E6_bifurcation.m"))      % P3
```

尚未實作（骨架，呼叫會拋 `notImplemented`）：`sensitivityLHS` / `sobolIndices`（Sobol）、
`plotDoseSurface` / `plotTrajectories` / `plotStructure` / `plotBifurcation`（圖形目前直接寫在實驗腳本內）。

## 快速開始

```matlab
cd('/path/to/骨骼鈣質吸收數學模型')
addpath('src'); setupPath();

runtests("tests")     % 91 tests

s   = scenarioLibrary("sedentary", durationDays = 730);
out = simulate(s);
plot(out.t/365, out.dens.aBMD); xlabel("years"); ylabel("aBMD [kg/m^2]");

% ALWAYS check this before reading a result off a run (v2.6, appendix C17):
% false means the trajectory left the linear-elastic domain that the whole
% mechanics stack assumes, so its geometry is not a physical result.
out.validity.ok
```

## 三條不可違反的規則

這三條各自對應一個已經**發生過**的設計缺陷，寫成測試是為了防止復發。

**1. 負荷輸入必須是「力」，永遠不是「應變」**

`scenarioLibrary` 只回傳峰值彎矩 $M_L$ 與軸向力 $F_L$。應變是 `organMechanics`
由當下幾何與材料狀態算出的**輸出**。

v1.2 把應變當外生輸入 —— 那是應變控制，等於剪斷 mechanostat 的負回饋線。後果不會
報錯：$f_{bm}$ 變成純積分器（V7 的鈣平台永遠出不來），系統沒有設定點（E6 的鞍結點
分歧無物可尋）。→ `test_closedloop.m`

**2. 通道只建模一次**

MSIC 三態閘控只存在於 `msicGating.m`。不得在任何地方另寫 $P_o(\tau)$ sigmoid，
參數表不得再出現 $a_r,\ \tau_r,\ p,\ \tau_{th},\ q$。

v1.3 以前這些現象各有兩套表述（四重重複計數），而真正該跨越快慢尺度的純量
$D_{\text{mech}}$ **沒有任何消費者**。→ `test_noPhenomParams.m`

**3. 絕不呼叫 `savepath`**

本機多個 Claude Code session 各自driving 一個 MATLAB R2026a：workspace 隔離，但
**共用 preferences 目錄**。`savepath` 改寫全域 `pathdef.m`，會污染其他 session。
路徑一律由 `setupPath.m` 於 session 內加入。`parpool` 須明確限制
（`parpool('Processes', 3)`）—— 這是 10 核機器，其他 session 也要用。

## 目錄

```
src/params/    參數與情境       src/model/     組裝、求解、狀態向量
src/mech/      M1–M3 力學       src/analysis/  靈敏度、延續、校正、辨識性
src/signal/    M4–M5 訊號       src/viz/       繪圖（house style）
src/cells/     M6 細胞族群      experiments/   E0–E6
src/bone/      M7 結構與礦化    tests/         單位、閉環、防回潮、守恆、回歸
src/systemic/  M8 鈣恆定        data/          參數 CSV、驗證標的 CSV
```

## 資料檔

- `data/parameters_literature.csv` — 每個參數的值、單位、上下界、模組、**出處**、信心度。
  程式一律從此讀取；`src/**` 內硬編碼數值視為缺陷。目前多數為 `source=assumed` 佔位，
  待計畫書附錄 B1–B3 的文獻到手後替換。
- `data/validation_targets.csv` — V1–V16。`holdout=TRUE` 者（V6a–V6f 網球、V10 停藥、
  V14 湧現 ε\*）為**盲測**，不得進入校正目標函數。V16（停藥後 CTX 過衝）為 v2.10 新增的
  校正標的 —— 它存在的理由正是**讓 V10 得以維持盲測身分**（附錄 C21.3）。

## 輸出路徑

`results/` **不在此目錄**。本專案位於 iCloud Drive，`.mat` 會被同步甚至 evict 成佔位檔
而使 `load` 失敗。一律經 `getResultsDir()` 寫到
`~/Documents/MATLAB/bone-mechanostat-results/`。

## P1 驗證結果（MATLAB R2026a，2026-07-24）

`checkcode` 零問題；三支測試 **27/27 通過**（0.82 s）。

**閉環迴路已驗證**：$d\ln\varepsilon_p/d\ln f_{bm} = -2.5000$，與解析預期 $-\kappa_E$
吻合至 $4.7\times10^{-12}$。骨量增加確實使應變下降 —— mechanostat 的負回饋成立。

基線峰值應變（microstrain）：

| 情境 | $\varepsilon_p$ | $\varepsilon_e$ | 判讀 |
|---|---|---|---|
| bedrest | 15 | 11 | 等同卸載 |
| sedentary | 762 | 566 | 日常活動帶 400–1500 ✓ |
| resistance | 2236 | 1648 | 高生理區，低於 3000 上限 ✓ |
| tennis | 2851 | 2067 | 接近生理上限（菁英選手） ✓ |

基線密度計量：aBMD 0.946 g/cm²、vBMD 1140 mg/cm³、Co.Ar 174 mm²、
Tot.Ar 346 mm²、M.Cav 172 mm²、I 7191 mm⁴ —— 均為肱骨幹合理量級。

24 個月積分：0.04 s，10 步，0 次失敗，aBMD 漂移 0.000e+00 %（stub 應為平坦）。

> **附帶發現**：$f_{bm,0}=0.95$ 已接近 1.0 天花板（皮質孔隙率僅約 5%），
> 故皮質骨幾乎無致密化空間，增加勁度只能靠幾何。且
> $d\ln\varepsilon/d\ln r_p = -4.27$ 明顯強於 $-2.50$。此即 Haapasalo「骨變大而非變密」
> 的力學根源，且係由參數設定自然湧現，非寫死。

## P2 結果（2026-07-24）

**驗證**：Crank-Nicolson 有限差分 vs Biot 閉式解，最大相對誤差 **0.0029%**；
MSIC 仿射週期算子 vs 逐步積分，吻合至 **2.2e-15**。兩組皆為獨立實作的交叉驗證。

**三項與計畫書原假設不符的實測結果**（均經參數掃描確認為結構性）：

| | 發現 | 影響 |
|---|---|---|
| ✅ | **M2 高頻不飽和**：$\tau\propto f$（低頻）→ $\sqrt f$（高頻），永不飽和 | **V5b 免費達成** —— 1–10 Hz 內對 $\ln f$ 之 $r=0.99911$，零擬合參數。原飽和形式會使此標的不可能 |
| ⚠️ | **V4 無法由通道產生**：劑量對循環數漸近線性（指數 0.98–1.00），$k_{oi}\times k_{ic}$ 跨四數量級皆然 | v1.4「V4 從擬合變成預測」**撤回**。須改由下游飽和解釋 |
| ⚠️ | **V5 方向相反**：休息插入增益隨幅值**遞增**（1.61→3.06），Srinivasan 為遞減 | 全參數空間同向，結構性 |

**風險升級**：V4 與 V5 現在共同依賴同一個未檢定的「下游飽和」假說，使
$K_S, h_S, K_Y, n_Y$（全部 `assumed`/`low`）承擔雙重解釋責任。
**P3 完成後須立即檢定**，早於任何全模型校正 —— 詳見計畫書附錄 C6.5。

## P4 全模型校正（2026-07-25）— 里程碑

先取得 Pivonka 2008 與 Peterson & Riggs 2010 全文（逐表轉錄於
[reference_parameters.md](data/reference_parameters.md)），修正 M6 兩個嚴重錯誤的佔位速率
（D_B 差 **7600×**、D_C 差 **100×**），再以 `surrogateopt` 對 V1/V2/V7/V8 校正 5 個自由參數
（`k_res`, `K_S`, `K_P_sost`, `lambda_P`, `delta_ab`；`k_form` 由骨量平衡導出）。

| 標的 | 值 | 目標 | |
|---|---|---|---|
| V1 骨轉換率 | 7.19 %/yr | 5–10 | ✅ |
| V2 廢用流失 | 1.15 %/mo | 1.0–1.5 | ✅ |
| **V7 鈣效應** | **+0.97 %** | 0.7–1.8 | ✅ |
| V7 平台斜率 | +0.036 %/yr | \|·\|<0.3 | ✅ |
| V8 romosozumab@12mo | +12.8 % | 11–14 | ⚠️ 見下（v2.9 已於小樑腔室重擬達標，附錄 C20） |
| **V10 停藥回落**（盲測） | **−5.8 %** | <0 | ⚠️ 見下（v2.10 已由反彈機制達標 −12.4%，附錄 C21） |
| **V14 湧現 ε\***（盲測） | **762 με** | 100–1500 | ✅ |

> **⚠️ v2.3 更正**：P4 的 V8/V10「通過」後來發現**倚賴礦化膨脹假影**（舊 M7 使 rho_min
> 於形成時錯誤上升）。v2.3 修正礦化後，V8/V10 重定位為**小樑/脊椎範疇**（本模型為皮質截面，
> 無法在不靠假影下重現 +11–14% 之脊椎值）。詳見附錄 C14；V6/V14 盲測不受影響仍成立。

**V14 hold-out 盲測未參與擬合卻通過 —— 預測力的直接證據。**（另 v2.3 新增 V6 盲測，見 P5）

**使用者的原始問題現在有量化解答**：補鈣（800→1500 mg）使 aBMD **+0.97% 且一年達平台**，
與 Tai 2015 統合分析的「非漸進式、+0.7–1.8%」吻合。方向正確源於 PTH 經 RANKL 主導
（與 Lemaire/Pivonka 一致）。詳見計畫書附錄 C8–C10。

## 待辦

- [x] ✅ **辨識性分析完成**（`identifiability.m`）：k_res/K_S/delta_ab 可辨識；(K_P_sost, lambda_P) 相關對（r=−0.89，聯合有界）。處置：固定其一 或 報告聯合 CI
- [ ] 收緊 PTH 對：由獨立文獻固定 `lambda_P`（PTH→RANKL 劑量反應）或 `K_P_sost`（Bellido SOST–PTH）
- [ ] 取得 **Lemaire 2004**（#1，館際服務中）→ R/B/C 基線穩態複核
- [ ] 取得 Fu 2025（#5）→ MSIC 三態；Weinbaum 1994（#4）→ M2 微結構；Martin 1984（#6b）→ $S_v$
- [ ] 以 Haapasalo 2000 全文替換 `r_p_0` / `r_e_0` 的推算值
- [x] ✅ **P5 雙腔室**：P2 定性成立（局部負荷造成不對稱、全身介入不能）
- [x] ✅ **P5b+P5c**：intensive 礦化 ODE + Frost modeling → **V6 盲測湧現**（幾何增益、密度不變，附錄 C14）
- [x] ⚠️ **P5d 部分完成**：`trabecularParams.m` 建成，3.6× 放大確認但 V8 停在 +4.5%。**BV/TV 不是槓桿**（附錄 C19）
- [x] ✅ **P5g 完成**：`delta_ab` 0.09184 → **0.24875**。修的是**目標函數的腔室範疇錯誤**（V8/V10 一直算在皮質模型上）。**V8=12.506% 首次真正達標**，V1/V2/V7/V6/V14 逐字不變（附錄 C20）
- [x] ✅ **P5h 完成**：新增狀態 `A_reb`（抗體暴露下 SOST 轉錄代償上調）。**V10 +1.68% → −12.42%，且維持盲測身分**（校正到新標的 **V16 停藥後 CTX 過衝**，非 BMD）。**V9 強形式一併解決** —— 同一機制同時解釋自限性與反彈（附錄 C21）
- [ ] 加抗體 PK（現為階躍函數）—— 硬化蛋白尖峰幅度被誇大、CTX 峰在停藥後 3 週而非臨床 3 個月（C21.6）
- [ ] 取得 romosozumab 治療下的 SOST mRNA / 游離硬化蛋白時序，複驗 `sost_reb = 1.80`（現為 V16 反推值，`confidence=low`）
- [ ] 雙腔室管線（皮質＋小樑共用鈣池，N3 延伸）—— 在 `delta_ab` 重擬之後再做（C19.5）
- [x] ✅ **P6 分歧分析**：P3 否證（單穩），骨鬆為陡峭連續位移（附錄 C15）
- [x] ✅ **P3 敘事改寫**（v2.5，附錄 C16）：全文統一為「已否證」，三條措辭紀律 —— 陡峭≠雙穩、速率不對稱≠動力學不可逆、否證入主論文
- [x] ✅ **P5e**：modeling 飽和界＋彈性有效域守衛 `out.validity`（附錄 C17）。V6 盲測未重校仍存活；**首次取得不凍結幾何的有效遲滯探針，f_bm 0.95→0.40→0.9485，無遲滯 —— P3 否證第二條佐證**
- [x] ✅ 重製分歧圖為 `E6_bifurcation.png`，已標註 f_bm < 0.391 為線性彈性域外（C18.6）
- [x] ✅ **E0–E6 實驗腳本 + 七張論文圖**（附錄 C18）
- [ ] **Fu 2025 到手後首要複驗 V5b 骨層級符號**（模型與 Hsieh & Turner 方向相反，C18.3）
- [x] ✅ **P5i 完成**：M7 加 modeling drift（`chi_drift`），**V6e 由 −2.88% → +13.44%，V6 六項全過**（附錄 C22）
- [x] ✅ **C22.5 已裁決（選項 1）**：**P1 第二句改以 BMC 陳述**，「適當負重」定義為峰值應變 **≈2900 με**（新情境 `resistanceVigorous`）。實測 **BMC +4.589% ✅**（同一對比 aBMD 僅 +1.865% —— **DXA 稀釋 59%**）。中等強度阻力訓練（2236 με）BMC +3.093% 不足以支持該子句，已如實寫入（附錄 C23）
- [ ] **P5f 候選**：bedrest 超過 ~7.5 個月塌到孔隙率地板（缺不依賴力學的基礎形成率）
- [ ] Sobol / LHS 全域靈敏度（`sensitivityLHS`、`sobolIndices` 仍為骨架）
- [ ] E1–E5 實驗（含 E2 的 2×2 補鈣×負重因子分析）
