# 骨重塑力學生物學多尺度數學模型
## Mechanotransduction-Coupled Multiscale Model of Bone Remodeling
### 研究計劃書 (Research Proposal & Implementation Plan for Claude Code)

**主持人**：謝明諭 (Ming-Yu Hsieh), MD, PhD
中山醫學大學醫學系副主任｜中山醫學大學附設醫院小兒外科主任、實證醫學中心主任
ORCID: 0000-0002-5797-3474｜myhsieh@me.com

**版本**：v1.7｜**日期**：2026-07-24｜**實作語言**：MATLAB (R2026a)｜**執行者**：Claude Code

> **v1.7 變更摘要（P3 生物模組）**：M4–M7 實作完成，40/40 測試通過。**附錄 C6.5 的三項聯合檢定全數通過** —— 下游飽和假說成立，V4 與 V5 的條件性在骨層級同時重現，C6.5 的預案不需啟動。另修正兩個實作缺陷（形成分配漏掉表面積、正規化參考點錯誤），並確認**結構上不存在靜止不動點**（$\eta_p$ 恆 > $\xi_p$），P3 判準改為骨量漂移 < 0.1%/yr。詳見附錄 C7。
>
> **v1.6 變更摘要（P2 實作後的實測修訂）**：M2/M3 實作並執行後，三項與計畫書原假設不符的結果經數值確認，**均非參數選擇問題而是結構性的**：
> 1. **M2 高頻不飽和**。Biot 問題的閉式解給出低頻 $\tau\propto f$、高頻 $\tau\propto\sqrt f$，**永不飽和**。原代理函數形式已由精確閉式解 $\tau=K_\tau\varepsilon\,\Phi(f)$ 取代（$\Phi$ 由 $|k\tanh kL|$ 決定，零擬合參數）。**意外收穫：V5b 因此免費達成**（1–10 Hz 內對 $\ln f$ 之 $r=0.999$）；原飽和形式會使高頻斜率趨零而讓 V5b 不可能。
> 2. **V4 無法由通道產生**。$k_{oi}\times k_{ic}$ 跨四個數量級掃描，216→1200 循環的指數恆在 0.80–1.03（≈線性）。週期驅動下三態系統進入極限環，此後每循環貢獻相同。**V4 必須改由下游飽和解釋**，v1.4「V4 從擬合變成預測」之宣稱**撤回**。
> 3. **V5 幅值依賴方向相反**。休息插入增益隨幅值**遞增**（與 Srinivasan 相反），在整個參數空間皆然。此為 v1.4 附錄 C5.3 預告之風險，現已數值證實。
>
> 詳見附錄 C6。**風險升級**：V4 與 V5 現在共同依賴同一個未經檢定的「下游傳遞函數飽和」假說。

> **v1.4 變更摘要（M3／M4 介面定案）**：M3 原本同時保留唯象劑量式與機制式 MSIC 三態模型，兩者對同一組現象形成**四重重複計數**；更嚴重的是 $D_{\text{mech}}$ **從未被下游方程式消費** —— 力學訊號實際走 M4 的 $P_o(\tau)$，而 $P_o$ 是通道開啟機率的第三種表述，亦即快慢尺度介面從未接上（連帶使 v1.3 的正回饋 #1 懸空）。v1.4 定案：**通道只建模一次，介面只有一個純量**。M3 全面改寫為 $D_{\text{mech}}=\int_{\text{day}}O\,dt$，M4 刪除 $P_o(\tau)$，$\tau_{50},k_\tau$ 遷入 $k_{co}(\tau)$。**淨刪 5 個唯象自由參數**。詳見 §4.2 M3／M4 與附錄 C5。

> **v1.3 變更摘要（力學回饋迴路定案）**：v1.2 以前的 M1 把**應變**當作外生輸入，等同「應變控制」，使 mechanostat 的負回饋線斷開 —— 其後果是 $f_{bm}$ 成為純積分器（V7 的平台不可能出現）、且無設定點可言（P3/E6 失去對象）。v1.3 將負荷輸入改為**力控制**，並依 Haapasalo et al. (2000) 的實測結果把 M7 擴充為**骨膜／骨內膜／皮質內三表面幾何模型**。同時補上 P3 所需的兩個正回饋機制（比表面積 $S_v$、骨細胞密度 $n_{ot}$）與雌激素模組。詳見 §4.2 與附錄 C。

---

## 0. 一頁摘要 (Executive Summary)

**核心科學命題**：鈣是骨形成的**許可性 (permissive)** 因子，機械負荷才是**指令性 (instructive)** 因子。單獨補鈣在鈣攝取已足量者身上，理論上只能產生極小的骨密度增益；唯有透過骨細胞 (osteocyte) 的力學感測 — Piezo1 → Ca²⁺ → YAP/TAZ → Sclerostin↓ → Wnt/β-catenin↑ — 才會啟動真正的骨形成。

**本計畫要做的事**：建立一個**四尺度耦合的 MATLAB 模型**，把
「器官層級應變 → 骨小管液體剪應力 → 骨細胞訊號傳導 → 骨細胞族群動力學 → 骨體積分率與礦化 → aBMD」
串成一條可模擬、可驗證、可做參數靈敏度與分歧分析 (bifurcation) 的完整鏈路，並外掛**全身鈣–PTH–維生素D 恆定模組**，使「補鈣」與「負重」可以在同一個模型內做 2×2 因子比較。

**三個可發表的預測 (falsifiable predictions)**：
1. **P1 — 許可性 vs 指令性**：在鈣攝取充足區間，鈣攝取量對 24 個月 aBMD 的邊際效益 < 1%；同期間適當負重方案 > 4%。二者交互作用為**協同但非相加** (loading 的效果在鈣不足時被截斷)。
2. **P2 — 部位專一性的數學來源**：以「共用全身鈣池 + 各自局部力學劑量」的雙腔室模型，可自然重現網球選手優勢側肱骨骨量高於非優勢側的現象，且此差異**不可能**由任何全身性介入 (補鈣、抗 Sclerostin 抗體) 產生。
3. **P3 — 骨質疏鬆作為替代穩態 (alternative stable state)**：以 Piezo1 力學敏感度 $\tau_{50}$、SOST 基礎分泌率 $\beta_S$ 與雌激素 $E_2$ 為分歧參數（**v1.3 更正**：設定點 ε\* 在閉環模型中是輸出而非輸入，見 §5 註與 V14），模型應出現**鞍結點分歧 (saddle-node bifurcation)** 與雙穩態；一旦跨越臨界點，單靠移除擾動無法回復 — 這對應臨床上「骨質流失快、回補慢」的不對稱性。其機制來源為兩個正回饋：小樑穿孔後無表面可重建（$S_v\to0$）、以及骨細胞流失導致力學感測能力衰減（$n_{ot}\downarrow$）。

（P3 的分析架構與主持人先前 HFpEF 動力系統研究 [bifurcation of HFpEF heterogeneity] 一脈相承，可共用程式基礎設施。）

---

## 1. 背景與理論基礎 (Corrected Scientific Basis)

### 1.1 骨骼是一個具備感測器的自適應結構

骨組織重量組成約為：礦物質 (hydroxyapatite) 60–70%、有機基質 20–25% (其中約 90% 為 type I collagen)、水約 10%。真正做決策的是細胞，而 **osteocyte 占骨細胞總數約 90–95%**，以樹突狀突起經由 canaliculi 互相連結，形成類神經網路的 lacuno-canalicular network (LCN)。

### 1.2 力學感測的物理鏈路

生理活動下骨組織的整體應變僅約 **400–3,000 microstrain (0.04–0.3%)**，遠低於直接活化細胞膜通道所需的量。關鍵在於**放大機制**：

> 骨組織是 poroelastic 材料。週期性負荷造成孔隙壓力梯度 → LCN 內組織液流動 → 作用於 osteocyte 突起的**液體剪應力 (fluid shear stress, FSS) 約 0.8–3 Pa**，這是細胞真正「感覺到」的訊號。

因此力學刺激的效力**取決於應變速率與頻率，而非單純的應變大小** — 這是模型必須內建的第一個關鍵非線性。

### 1.3 分子訊號級聯

| 環節 | 分子 | 作用 |
|---|---|---|
| 感測 | **Piezo1** (機械敏感陽離子通道)、integrin、primary cilium、connexin 43 hemichannel | FSS 開啟 Piezo1 → Ca²⁺ 內流 |
| 轉譯 | Ca²⁺ → **YAP/TAZ** 核轉位、ERK/MAPK、NO/PGE₂ | 力學訊號 → 轉錄程式 |
| 煞車解除 | **Sclerostin (SOST)** ↓ | SOST 拮抗 LRP5/6，抑制 Wnt |
| 執行 | **Wnt/β-catenin** ↑ | 成骨細胞分化、存活↑；**OPG↑ / RANKL↓** → 蝕骨↓ |

**重點：Sclerostin 是雙效煞車** — 它同時壓制骨形成 *並* 促進 RANKL 表現而助長骨吸收。這解釋了為何抗 Sclerostin 抗體 (romosozumab) 是目前唯一的**雙效藥物** (formation↑ + resorption↓)。

### 1.4 三個必須內建的臨床觀察

1. **劑量飽和**：Rubin & Lanyon — 約 40 個負荷循環後成骨反應即接近飽和；再多循環幾無增益。
2. **休息插入效應 (rest insertion)**：Robling 等 — 將同樣循環數拆成數段、中間插入 8–14 秒休息，成骨反應顯著放大 (LCN 液流「再充填」)。
3. **不對稱動力學**：失重/臥床時骨量流失約 **1–1.5%/月**，但回地面後恢復需數年；且在失重狀態下**額外補鈣不僅無效，反而因骨吸收釋鈣造成高尿鈣與腎結石風險**。

---

## 2. 對前置 AI 回答 (ChatGPT) 的評估

整體判斷：**方向正確，機轉主幹 (Piezo1 → Sclerostin → Wnt) 敘述無誤，可作為建模的起點**，但有若干需修正或補強之處，已全部反映在本計畫的模型結構中。

| # | 原回答敘述 | 評估 | 修正／補強 |
|---|---|---|---|
| 1 | 骨組成 60% 礦物 / 30% 膠原 / 10% 細胞水分 | 略偏 | 應為礦物 60–70%、有機基質 20–25%、水 ~10%；膠原是有機基質的 ~90%，非總重的 30% |
| 2 | Osteocyte 占骨細胞 95% | 可接受 | 文獻常見範圍 90–95% |
| 3 | 應變 0.1–0.3% | 正確 | 即 1,000–3,000 με，屬生理上限區間；日常活動多在 400–1,500 με |
| 4 | 「骨頭只變形而人感覺不到，但液流推動 osteocyte」 | **正確且關鍵** | 這正是本模型的 poroelastic 放大模組 (M2) |
| 5 | Piezo1 為最重要感測器 | 大致正確但需保留 | Piezo1 為近年主流候選 (2019 起)，但 integrin/cilium/Cx43 並非可忽略；模型以 Piezo1 為主通道並保留平行路徑參數 |
| 6 | Sclerostin 抑制造骨、像煞車 | 正確但不完整 | **遺漏 Sclerostin 同時上調 RANKL** 促進骨吸收；此為雙效機轉，必須建模 |
| 7 | 完全未提 **RANKL/OPG 軸** | **重大遺漏** | Osteocyte 是體內 RANKL 的主要來源；沒有此軸就無法建構骨吸收側方程式 |
| 8 | Romosozumab 心血管風險「仍在討論」 | **本文原評估過苛，予以撤回** | 文獻查證後：ARCH (對照 alendronate) 之 MACE 不平衡確實導致黑框警示，但 FRAME (對照安慰劑) 未見差異，且前臨床與遺傳學證據均未支持因果機轉。ChatGPT 的「仍在討論」實屬允當；僅需補述黑框警示之存在 |
| 9 | 未提 romosozumab 的**自限性 (self-limiting)** 與停藥後骨量回落 | **重大遺漏** | 藥效約 12 個月後衰減，停藥後需接續抗吸收藥；此自限性正是負回饋的證據，是本模型最有價值的驗證標的之一 |
| 10 | 「骨頭不是看血液中的鈣」 | 過度簡化 | 血鈣/PTH 確實會透過 PTH 驅動骨吸收；正確表述是**鈣是許可性因子、負荷是指令性因子**，二者作用層級不同 |
| 11 | 隱含「補鈣無用」 | 需修正 | 在**鈣攝取不足或維生素D 缺乏族群** (如機構安養長者)，鈣+VitD 確實降低骨折風險；「無用」僅適用於已足量者的邊際增量 |
| 12 | 太空人「補鈣沒用」 | 正確但可更強 | 更精確：不僅無效，且因骨吸收釋鈣造成高尿鈣，額外補鈣有腎結石風險 |
| 13 | 完全未提 **Frost mechanostat theory** | 概念遺漏 | 這是整個領域的理論骨幹 (設定點 ε\*、lazy zone)。**v1.3 更正**：本模型不把 ε\* 當輸入參數，而是由閉環結構讓它湧現，再與 Frost 的區間對照（V14） |
| 14 | 未提劑量飽和與休息插入效應 | 遺漏 | 這是「運動處方能否被最佳化」的科學基礎，也是本計畫 E3 實驗的核心 |
| 15 | 建議做多尺度骨重塑模型 | 方向正確但未察覺前人工作 | Lemaire (2004)、Pivonka (2008–2010)、Scheiner & Pivonka (2013) 已有 mechanobiological 骨重塑模型；**本計畫必須明確定位增量創新**（見 §3） |

**給使用者的一句話結論**：您的直覺 (「有需求才會蓋骨頭」) 在機轉層面成立，但精確的說法不是「補鈣沒用」，而是 —— **鈣決定「能不能蓋」，負荷決定「要不要蓋」。**

---

## 3. 研究定位與創新點 (Novelty Positioning)

**已有工作**：
- Lemaire et al. (2004)：RANK–RANKL–OPG 骨細胞族群 ODE 模型（本計畫的 M6 基礎）
- Pivonka et al. (2008, 2010)：加入 PTH、藥物介入
- Scheiner, Pivonka & Hellmich (2013)：以 strain energy density (SED) 現象學地驅動成骨細胞增殖
- Peterson & Riggs (2010)：全身鈣–PTH–維生素D 多尺度恆定模型（本計畫的 M8 基礎）
- **Fu et al. (2025), *Int J Mech Sci*：whole bone–LCN–osteocyte 多尺度模型** ⚠️ **最接近本計畫的競爭工作**。已建構「整骨變形 → LCN 液流 → FSS → 機械敏感離子通道 (MSIC) 開／關／失活」的完整前端，並成功再現負荷幅度、頻率、循環數、恢復時間的效應。**但其模型止於 osteocyte 反應**，未接續 SOST/Wnt/RANKL、細胞族群、礦化或全身鈣。
- Mehrpooya et al. (2026), *BMMB*：osteocyte 網路訊號傳播的 1D 骨適應模型
- Schulte et al. (2026), *Nat Commun*：小鼠實驗證實機械負荷與 anabolic 藥物 (PTH、Scl-Ab) 呈**加成／協同**，與 bisphosphonate 則否

**既有缺口**：既有工作在**前端 (力學感測)** 與**後端 (細胞族群動力學)** 各自成熟，但**尚無研究把兩端接起來**。因此目前沒有任何模型能同時：
(a) 區分「相同 SED、不同頻率／休息插入」的差異（前端做得到，但無 BMD 輸出）；
(b) 在同一模型內比較「機械負荷」與「抗 Sclerostin 藥物」的等效性（後端做得到，但無真實力學輸入）；
(c) 解釋 romosozumab 的自限性；
(d) 讓「補鈣」與「負重」在同一框架下競爭（無人納入全身鈣恆定）。

**本計畫的四項增量創新**：

| 創新 | 內容 |
|---|---|
| **N1（已依 Fu 2025 重新定位）** | **端到端接合**：採用 Fu 等人已驗證的 FSS→MSIC 前端（含開／關／**失活 (inactivation)** 三態），向下游延伸至 **Piezo1→Ca²⁺→YAP/TAZ→SOST→Wnt→細胞族群→礦化→aBMD**。創新不在於「重做力學感測」，而在於**首次讓負荷波形參數一路貫通到臨床可量測的 BMD 軌跡** |
| **N2** | 建模 **Sclerostin 的雙效性** (抑制 Wnt 且上調 RANKL)，並以此再現 romosozumab 的雙效藥理與自限性負回饋 |
| **N3** | **雙腔室 (loaded / unloaded) + 共用全身鈣池**架構，將「部位專一性」轉化為可檢驗的數學命題，直接對應網球選手肱骨不對稱資料 |
| **N4** | 對 mechanostat 設定點做**分歧與雙穩態分析**，提出「骨質疏鬆為替代穩態」的動力系統假說 |

---

## 4. 模型架構 (Model Specification)

### 4.1 尺度分離與整體結構

```
[輸入] 日常負荷「力」排程 M_L(t), F_L(t)、鈣攝取 I_Ca(t)、維生素D、藥物、E₂
   │
   ├─ M1 器官力學：力 + 幾何 + 材料 → 應變 ε_p, ε_e          〔秒〕
   ├─ M2 Poroelasticity：ε, f → 骨小管液體剪應力 τ           〔秒〕
   ├─ M3 力學劑量整合：τ, N, 休息 (MSIC 三態) → D_mech(d)     〔日〕
   ├─ M4 Osteocyte 訊號：Piezo1→Ca→YAP/TAZ→SOST, RANKL       〔分–時〕
   │      ＋ n_ot 骨細胞密度、E₂⊣TNF-α→SOST
   ├─ M5 Wnt/β-catenin                                       〔時〕
   ├─ M6 骨細胞族群 (Lemaire/Pivonka 擴充)：R, B, C           〔日–週〕
   ├─ M7 三表面幾何 (r_p, r_e) + f_bm + 礦化 → aBMD / vBMD     〔月–年〕
   └─ M8 全身 Ca–PTH–1,25D 恆定（與 M6/M7 雙向耦合）          〔時–日〕
   │
   └──[閉環] r_p, r_e, f_bm, ρ̄_min ──→ E_app, I_g, A_g ──→ 回到 M1
```

**這條回饋線是整個 mechanostat 的本體**：施加的是力，被調控的是應變。骨量增加 → 剛度與慣性矩上升 → 同樣的力產生較小的應變 → 刺激下降 → 形成趨緩。沒有這條線，模型只是一條開路的前饋鏈。

**關鍵數值策略**：M1–M2 的時間尺度為秒，M7 為年，直接聯立求解不可行。採 **fast/slow decomposition**：
- M1–M4 的快變數以**準穩態近似 (QSSA)** 求解，離線建成**代理函數 (surrogate)** `shearSurrogate.m`；
- 慢系統 (M5–M8) 以 `ode15s` 在「日」為單位積分，每日呼叫一次力學劑量函數。

### 4.2 各模組方程式

#### M1 — 器官層級力學（**v1.3 改為力控制閉環**）

**輸入是力，不是應變。** 每日活動由 `scenarioLibrary.m` 提供峰值**彎矩** $M_L(d)$ 與**軸向力** $F_L(d)$；應變是被調控的輸出。

理想化皮質骨空心圓管截面，三個結構狀態變數：

$$r_p\ \text{(骨膜半徑, periosteal)},\qquad r_e\ \text{(骨內膜半徑, endocortical)},\qquad f_{bm}\ \text{(皮質內骨體積分率)}$$

幾何量：

$$A_g=\pi\big(r_p^2-r_e^2\big),\qquad I_g=\tfrac{\pi}{4}\big(r_p^4-r_e^4\big)$$

材料（Currey / Gibson–Ashby 冪律，分離「基質量」與「基質礦化度」）：

$$E_{\text{app}}=E_{\text{ref}}\;f_{bm}^{\,\kappa}\;\Big(\bar\rho_{\min}/\bar\rho_{\min,0}\Big)^{\nu},\qquad \kappa\approx2\text{–}3,\ \ \nu\approx1\text{–}2$$

峰值應變（骨膜表面與骨內膜表面，彎曲主導 + 軸向疊加）：

$$\boxed{\ \varepsilon_p=\frac{M_L\,r_p}{E_{\text{app}}I_g}+\frac{F_L}{E_{\text{app}}A_g}\ },\qquad
\varepsilon_e=\frac{M_L\,r_e}{E_{\text{app}}I_g}+\frac{F_L}{E_{\text{app}}A_g}$$

時間波形與應變能密度同前：

$$\varepsilon(t)=\varepsilon_p\,g(t),\quad g(t)=\tfrac{1}{2}\big(1-\cos 2\pi f t\big),\qquad \Psi=\tfrac{1}{2}E_{\text{app}}\varepsilon_p^2$$

> **無因次形式**（依 §7.1 規範，供實作使用）：
> $$\frac{\varepsilon_p}{\varepsilon_{p,0}}=\frac{M_L}{M_{L,0}}\cdot\frac{r_p}{r_{p,0}}\cdot\frac{E_{\text{app},0}\,I_{g,0}}{E_{\text{app}}\,I_g}$$
> 薄壁近似下 $I_g\approx\pi r^3 t_c$，故 $\varepsilon\propto M_L/(E\,r^2 t_c)$ —— **骨膜外擴的力學效率遠高於皮質增厚**（$r^2$ vs $t_c$）。這正是 Haapasalo 觀察到「尺寸增大、vBMD 不變」的力學原因，模型不需額外假設即可產生。

> **數值注意**：$E_{\text{app}}\propto f_{bm}^{\kappa}$，當 $f_{bm}\to0$ 時 $\varepsilon\to\infty$。實作須設下限保護（`f_bm_min`，列入參數 CSV），並在 `test_units.m` 加入該邊界檢查。

> 進階選項（Phase 7）：以 FEM 或匯入 QCT 幾何取代解析截面。第一版**不做 FEM**。

#### M2 — Poroelastic 液體剪應力
1D Biot 孔彈性方程（沿骨小管方向 z，半徑 a 的 canaliculus）：

$$\frac{\partial p}{\partial t}=c_p\frac{\partial^2 p}{\partial z^2}-\frac{1}{S}\frac{\partial \varepsilon}{\partial t},\qquad c_p=\frac{k_p}{\mu S}$$

$$\tau_{\text{oc}}(t)=\frac{a}{2}\left|\frac{\partial p}{\partial z}\right|\cdot\Gamma_{\text{PCM}}$$

其中 $\Gamma_{\text{PCM}}$ 為 pericellular matrix 放大因子 (Weinbaum–Cowin–Zeng)。
**代理函數**（離線由上式掃描擬合，供慢系統呼叫）：

$$\hat\tau_{\max}(\varepsilon_{\text{peak}},f)=K_\tau\,\varepsilon_{\text{peak}}\,\frac{(f/f_0)^{\alpha}}{1+(f/f_c)^{\alpha}}$$

（低頻近似 $\tau\propto f^{\alpha}$，$\alpha\approx0.5$–1；高頻因孔隙壓力來不及消散而飽和。）

#### M3 — 每日成骨力學劑量（**v1.4 全面改寫：唯象項全數移除**）

> **v1.4 修正的缺陷（原 B4#3）**：v1.3 以前，M3 同時保留了唯象式 $D_{\text{mech}}=\sum\Phi_{\text{rest}}(\Delta t_i)N_i^{p}[\max(0,\hat\tau_i-\tau_{th})]^{q}$ **與**機制式 MSIC 三態模型。兩者各自編碼了同一組現象（休息插入增益、循環數飽和、閾值、超線性），形成四重重複計數。更嚴重的是：追查下游可發現 **$D_{\text{mech}}$ 從未被任何方程式消費** —— 力學訊號實際上是經由 M4 的 $P_o(\tau)$ 進入 $dC_a/dt$，而 $P_o$ 又是 MSIC 開啟機率的第三種表述。亦即快慢尺度的介面從未真正接上。v1.4 的定案是：**通道只建模一次，介面只有一個純量。**

**唯一的通道模型**。MSIC（即 Piezo1，保留 $J_{\text{alt}}$ 涵蓋 integrin/cilium/Cx43 平行路徑）具 closed → open → **inactivated** 三態；τ 依賴性**全部**住在開啟速率裡：

$$k_{co}(\tau)=k_{co}^{\max}\Big[1+\exp\big(-(\tau-\tau_{50})/k_\tau\big)\Big]^{-1}$$

$$\frac{dO}{dt}=k_{co}(\tau)\,C_h-\big(k_{oc}+k_{oi}\big)O,\qquad \frac{dI}{dt}=k_{oi}O-k_{ic}I,\qquad C_h=1-O-I$$

**每日力學劑量 = 開啟機率的日內時間積分**：

$$\boxed{\ D_{\text{mech}}(d)=\int_{\text{day}}O\big(t;\tau(t)\big)\,dt\ }$$

其中 $\tau(t)$ 由當日 bout 結構（$n_b$ 段、各段 $N_i$ 循環、頻率 $f_i$、間隔 $\Delta t_i$）經 M1→M2 產生。

**已移除**：$\Phi_{\text{rest}}$、$a_r$、$\tau_r$、$N^p$、$p$、$\tau_{th}$、$q$ —— 共 5 個唯象自由參數。它們所編碼的現象全數由三態動力學湧現：

| 現象 | v1.3 以前的唯象參數 | v1.4 的湧現機制 |
|---|---|---|
| 循環數報酬遞減 (V4) | $N^p,\ p<1$ | 負荷期間 $I$ 累積 → $C_h$ 耗竭 → 後續循環貢獻遞減 |
| 休息插入增益 (V5) | $\Phi_{\text{rest}},\ a_r,\ \tau_r$ | 間隔 $\Delta t$ 期間 $I\xrightarrow{k_{ic}}C_h$ → 下一循環可開啟的通道變多 |
| 閾值 | $\tau_{th}$ | $k_{co}(\tau)$ sigmoid 的下緣（半活化點 $\tau_{50}$）。**不設硬閾值**：$\tau\to0$ 時劑量極小但非零，較符合生理，且廢用側的骨流失由下游 SOST 上升承擔（見 M4） |
| 超線性 | $q\approx1\text{–}2$ | $k_{co}(\tau)$ sigmoid 的陡度 $k_\tau$ |

**保留的參數**：$\tau_{50}, k_\tau$（**由 M4 遷入，非新增**）；$k_{co}^{\max}, k_{oc}, k_{oi}, k_{ic}$（**取自 Fu et al. 2025，屬文獻固定值而非擬合值**，見 B1 #5）。淨效果是以 4 個文獻常數換掉 5 個自由參數 —— 對 §9 的頭號辨識性風險是純粹的改善。

**V5 條件性的機制解釋**（附錄 A4 的正反兩組結果）。三態模型本身在**高**幅值下累積較多 $I$，故單看劑量，休息插入在高幅值時的相對增益反而較大 —— 這與 Srinivasan (2002) 「低幅值下才顯著」的觀察方向相反。因此 V5 的條件性**不能只靠通道解釋**，而是來自**劑量→反應傳遞函數的飽和**：高幅值時下游（SOST 的 Hill 抑制、細胞族群反應）已接近上限，額外劑量無法轉譯為骨形成；低幅值時位於陡峭段，同樣的相對劑量增益產生巨大的絕對反應差（3.8% → 21.9%）。
> ⚠️ **此為機制假說，尚待驗證**。必須取得 B2 #8（Srinivasan 2002）與 #9（Yang 2017）全文的完整負荷參數後，以同一組參數同時擬合正反兩例來檢定。若無法同時滿足，則須重新檢視是否另有機制（例如骨細胞對單次負荷事件與連續循環的區辨）。這是本模型最具鑑別力的單一檢定。

**頻率依賴**：Marques et al. (2023) 之時間序列 micro-CT 資料顯示 mechanostat 參數對負荷頻率呈**對數依賴**。M2 代理函數與 M3 合成後須通過此檢核：$\Delta\text{BV/TV}\propto \ln f$ 於 1–10 Hz 區間。
> ⚠️ **辨識性註記**：頻率現在有**兩條**進入路徑 —— M2 的流體力學（高頻時孔隙壓力來不及消散）與 M3 的通道動力學（高頻時通道跟不上）。兩者物理上確實各自存在，但在校正時難以分離。V5b 校正時應**先以 M2 獨立標定** $\alpha, f_c$（由 `poroelastic1D` 的離線掃描決定，不參與擬合），再檢視 M3 是否仍需調整。

**實作要求（v1.4 新增，由 v1.3 閉環引發）**：v1.2 時 $\hat\tau$ 於給定情境下是常數，$D_{\text{mech}}$ 可只算一次；**閉環後幾何隨時間適應，$\hat\tau$ 會漂移**，$D_{\text{mech}}$ 必須隨之更新。日內積分（秒級解析度 × 數千日）不可能放進 `ode15s` 的 RHS。故 `loadingDose.m` 須改為：對每個 scenario 的固定 bout 結構，離線建立 $D_{\text{mech}}$ 對 $\hat\tau_{\max}$ 的**一維內插代理函數**（`buildDoseSurrogate.m`），慢系統僅做查表。

#### M4 — Osteocyte 訊號傳導（**v1.3 新增 $n_{ot}$ 與雌激素路徑**）

**力學訊號的唯一入口**（**v1.4 修正**）。原本的 $P_o(\tau)=[1+\exp(-(\tau-\tau_{50})/k_\tau)]^{-1}$ **已刪除** —— 它是 MSIC 開啟機率的第三種表述，與 M3 的三態模型重複。$\tau_{50}$ 與 $k_\tau$ 已遷入 M3 的 $k_{co}(\tau)$。Ca²⁺ 內流改由 M3 算出的**日均開啟機率**驅動：

$$\boxed{\ \frac{dC_a}{dt}=J_{\max}\cdot\frac{D_{\text{mech}}^{\text{eff}}(d)}{T_{\text{day}}}+J_{\text{alt}}-k_C C_a\ }$$

（$D_{\text{mech}}^{\text{eff}}$ 定義見下方 (a)；$T_{\text{day}}=1$ 日，使該項為無因次的日均開啟機率，符合 §7.1 的無因次化規範。$J_{\text{alt}}$ 保留為 integrin／primary cilium／Cx43 等平行路徑的集總項，其不確定性於 E6 靈敏度分析中涵蓋。）

> **這同時修好了「$D_{\text{mech}}$ 是孤兒」的問題**：v1.3 以前 $D_{\text{mech}}$ 在 M3 定義後未被任何下游方程式使用，快慢尺度的介面實際上是斷的。現在 $D_{\text{mech}}^{\text{eff}}$ 恰有一個消費者，M1→M2→M3→M4 形成單一條無分歧的訊號路徑。

$$\frac{dY}{dt}=k_Y\frac{C_a^{n}}{K_Y^{n}+C_a^{n}}(1-Y)-\delta_Y Y \quad\text{(YAP/TAZ 核內比例)}$$

**(a) 骨細胞密度與力學感測增益（正回饋 #1）**

骨細胞在骨形成時被埋入基質、在骨吸收時被移除，並隨雌激素缺乏與老化而凋亡：

$$\frac{dn_{ot}}{dt}=k_{ot}\,v_{\text{form}}\big(n_{ot}^{\max}-n_{ot}\big)-\big(\gamma_{ot}\,v_{\text{res}}+\delta_{ot}(E_2,\text{age})\big)\,n_{ot}$$

感測網路的完整性直接縮放力學劑量：

$$\boxed{\ D_{\text{mech}}^{\text{eff}}(d)=D_{\text{mech}}(d)\cdot\big(n_{ot}/n_{ot,0}\big)^{\zeta}\ },\qquad \zeta\approx1\text{–}2$$

> **這是 P3 的正回饋核心**：骨流失 → 感測器減少 → 同樣的力產生較弱的成骨訊號 → 更多流失。它與 M1 的力學負回饋競爭，兩者的相對強度決定系統是單穩態或雙穩態。

**(b) 雌激素 → TNF-α → SOST（補上 v1.2 附錄 B4#1 的缺口）**

$E_2(t)$ 為外生輸入（情境：停經前／圍停經下降／停經後／HRT）。TNF-α 為動態變數：

$$\frac{dT}{dt}=k_T\,\frac{K_E^{n_E}}{K_E^{n_E}+E_2^{n_E}}-\delta_T\,T\qquad\text{(TNF-}\alpha)$$

Sclerostin 方程式加入 TNF-α 促進項：

$$\frac{dS}{dt}=\beta_S\,\underbrace{\frac{1}{1+(Y/K_S)^{h}}}_{\text{力學抑制}}\cdot\underbrace{\frac{1}{1+P/K_{P}}}_{\text{PTH 抑制}}\cdot\underbrace{\Big(1+\lambda_T\frac{T}{K_T+T}\Big)}_{\text{TNF-}\alpha\text{ 促進（新）}}-\big(\delta_S+\delta_{\text{ab}}u_{\text{romo}}(t)\big)S$$

$$L_{\text{RANKL}}=L_0\Big(1+\lambda_S\frac{S}{K_L+S}\Big)\Big(1+\lambda_P\frac{P}{K_{PL}+P}\Big)\Big(1-\lambda_E\,E_2\Big)$$

$$O_{\text{OPG}}=O_0\Big(1+\lambda_\beta\frac{\beta}{K_\beta+\beta}\Big)$$

> **辨識性警告**：$E_2$ 現在有兩條下游路徑 —— 直接經 $\lambda_E$ 作用於 RANKL，以及間接經 TNF-α→SOST→$\lambda_S$。兩者在停經模擬中會部分互償。$\lambda_E$ 與 $\lambda_T$ **必須列入 `identifiability.m` 的 profile likelihood 檢查**，不可同時開放為自由參數。

#### M5 — Wnt/β-catenin
$$W_{\text{eff}}=W_0\frac{K_W^{m}}{K_W^{m}+S^{m}},\qquad \frac{d\beta}{dt}=k_\beta W_{\text{eff}}-\delta_\beta\beta$$

#### M6 — 骨細胞族群（Lemaire 擴充式）
$$\frac{dR}{dt}=D_R\,\pi_C^{\text{TGF}\beta}\big(1+\gamma_\beta\beta\big)-\frac{D_B}{\pi_C^{\text{TGF}\beta}}R$$

$$\frac{dB}{dt}=\frac{D_B}{\pi_C^{\text{TGF}\beta}}R-\frac{k_B B}{1+\gamma_{\text{surv}}\beta}$$

$$\frac{dC}{dt}=D_C\,\pi_L-D_A\,\pi_C^{\text{TGF}\beta}\,C,\qquad
\pi_L=\frac{L_{\text{RANKL}}}{K_{L3}+L_{\text{RANKL}}+ \kappa\,O_{\text{OPG}}}$$

#### M7 — 三表面幾何、骨體積分率與礦化（**v1.3 重寫**）

**依據**：Haapasalo et al. (2000) *Bone* 27(3):351–7 的雙側 pQCT 顯示，網球選手優勢側的骨增益**完全來自幾何**（Tot.Ar +16–21%、Co.Ar +12–32%、$I_{\max}$ +27–67%、髓腔面積亦 +19%），而**皮質體積骨密度 Co.Dn 兩側幾乎相同**（唯一顯著差異為遠端肱骨 −2%，優勢側反而略低）。因此 v1.2 的單一 $f_{bm}$ 表述在機制上不足以承載 V6，**必須追蹤幾何**。

令 $v_{\text{form}}=k_{\text{form}}B$、$v_{\text{res}}=k_{\text{res}}C$（單位：長度／時間），三個表面各自演化：

$$\frac{dr_p}{dt}=v_{\text{form}}\,\eta_p-v_{\text{res}}\,\xi_p\qquad\text{(骨膜：外擴)}$$

$$\frac{dr_e}{dt}=v_{\text{res}}\,\xi_e-v_{\text{form}}\,\eta_e\qquad\text{(骨內膜：}r_e\uparrow\text{ 即內膜吸收、皮質變薄)}$$

$$\frac{df_{bm}}{dt}=\frac{S_v(f_{bm})}{w}\Big[v_{\text{form}}\,\eta_i-v_{\text{res}}\,\xi_i\Big]\qquad\text{(皮質內孔隙)}$$

其中 $\sum\eta=\sum\xi=1$。

**(a) 分配係數由應變梯度決定，不另設自由參數**

彎曲下應變沿半徑線性分布（$\varepsilon(r)=\varepsilon_p\,r/r_p$），而 M3 的劑量函數 $D(\cdot)$ 在次飽和區對應變是**超線性**的（**v1.4 更正**：此超線性現在來自 $k_{co}(\tau)$ sigmoid 的下緣陡度 $k_\tau$，而非已刪除的唯象指數 $q$），故：

$$\eta_p:\eta_e:\eta_i \;=\; D(\varepsilon_p)\,:\,D(\varepsilon_e)\,:\,D(\bar\varepsilon)$$

吸收側 $\xi$ 則以**可用表面積**加權（骨內膜與皮質內表面積遠大於骨膜），並受雌激素調節：

$$\xi_e \propto \xi_{e,0}\Big(1+\lambda_\xi\frac{T}{K_T+T}\Big)\qquad\text{(TNF-}\alpha\uparrow\text{ 使吸收偏向骨內膜)}$$

> 這一組設定免費產生三個表型，均不需額外參數：
> **負重** → 骨膜偏向形成、外擴（Haapasalo，含髓腔同時擴大）；
> **廢用** → 形成劑量處處歸零、吸收偏向內側大表面（V2）；
> **停經／老化** → $T\uparrow$ 使 $\xi_e\uparrow$ → 骨膜緩慢外擴 + 骨內膜吸收 = **變寬變薄**的典型表型。

**(b) 比表面積 $S_v(f_{bm})$（正回饋 #2）**

採 Martin (1984) 型比表面積函數：在中間孔隙率取極大，$f_{bm}\to0$ 或 $\to1$ 時趨零。

$$S_v(f_{bm})=\sum_{j=1}^{5}a_j\,(1-f_{bm})^{j},\qquad \text{峰值約在} f_{bm}\approx0.2\text{–}0.3$$

> **機制意義**：重塑只能發生在既有骨表面上。小樑一旦被吸收穿孔，就沒有表面可供重建 —— $S_v(0)=0$ 使 $f_{bm}=0$ 成為**退化不動點（吸收態）**。這正是 V11「流失快、回復慢」不對稱性的機制來源，且不需任何唯象的不對稱參數。
>
> **數值注意**：該不動點退化（趨近速率亦趨零），`ode15s` 在 $f_{bm}\to0$ 附近會極度緩慢。實作須設 `f_bm_min` 下限與事件偵測，並在 `test_conservation.m` 驗證下限不破壞鈣質量守恆。

**(c) 礦化**（二腔室近似，primary → secondary，維持 v1.2 形式）

$$\frac{dm_1}{dt}=v_{\text{form}}\,m_{\text{prim}}-\kappa_m m_1,\qquad \frac{dm_2}{dt}=\kappa_m m_1-v_{\text{res}}\,\bar m,\qquad \bar\rho_{\min}=\frac{m_1+m_2}{f_{bm}}$$

**(d) 輸出：aBMD 與 vBMD 必須分開報告**

$$\text{BMC}/L=A_g\,f_{bm}\,\bar\rho_{\min},\qquad
\boxed{\ \text{aBMD}=\frac{A_g\,f_{bm}\,\bar\rho_{\min}}{2r_p}\ },\qquad
\text{vBMD (Co.Dn)}=f_{bm}\,\bar\rho_{\min}$$

> **DXA 的骨尺寸假影就此內建**，這是必要的而非瑕疵：V6（網球）的原始資料是 pQCT 的 vBMD 與面積，V8（romosozumab）與 V7（補鈣）的資料是 DXA 的 aBMD。**唯有同時輸出兩者，才能在同一個模型裡對上這兩類量測**，也才能誠實呈現「運動使 aBMD 上升但 vBMD 不變」這件事。

#### M8 — 全身鈣恆定（與 M6/M7 雙向耦合）
$$\text{Abs}=\underbrace{a_p I_{\text{Ca}}}_{\text{被動}}+\underbrace{\frac{a_a I_{\text{Ca}}}{K_I+I_{\text{Ca}}}\cdot\frac{V_D}{K_{VD}+V_D}}_{\text{主動、可飽和}}$$

$$\frac{d\text{Ca}_s}{dt}=\text{Abs}+\underbrace{\phi_{\text{res}}k_{\text{res}}C}_{\text{骨釋鈣}}-\underbrace{\phi_{\text{form}}k_{\text{form}}B}_{\text{骨攝鈣}}-\text{Renal}(\text{Ca}_s,P)$$

$$\frac{dP}{dt}=\frac{P_{\max}}{1+(\text{Ca}_s/\text{Ca}_{50})^{n_P}}-\delta_P P\qquad\text{(PTH)}$$

$$\frac{dV_D}{dt}=k_{VD}\frac{P}{K_{VP}+P}-\delta_{VD}V_D\qquad\text{(1,25(OH)}_2\text{D)}$$

**這個模組是回答使用者原始問題的關鍵**：它讓「增加鈣攝取」的效應循著真實生理路徑傳遞 —— 血鈣↑ → PTH↓ → 骨吸收略降、SOST 去抑制上升 → **淨效果為小幅度、且形成側幾無增益**。

### 4.3 雙腔室（部位專一性）擴充
複製 M1–M7 為 site A (loaded, 如優勢側肱骨) 與 site B (contralateral)，**共用同一組 M8 全身變數**。此架構自然產生「全身介入無法造成部位差異，局部負荷可以」的結論。

**v1.3 補充**：由於 M1/M7 現在包含幾何狀態，雙腔室版本須各自持有 $(r_p, r_e, f_{bm}, m_1, m_2, n_{ot})$，且**各自接收不同的 $M_L, F_L$**。這使 P2 的檢定更為銳利 —— 模型現在可以分別預測兩側的 aBMD **與** vBMD，直接對上 Haapasalo 的雙側 pQCT 設計（同一受試者、同一全身鈣池、僅局部力學不同），而非僅比較一個籠統的「骨量」。

### 4.4 狀態變數清單（v1.3）

| 模組 | 變數 | 數量 |
|---|---|---|
| M4 訊號 | $C_a,\ Y,\ S,\ T,\ n_{ot}$ | 5 |
| M5 | $\beta$ | 1 |
| M6 細胞 | $R,\ B,\ C$ | 3 |
| M7 結構 | $r_p,\ r_e,\ f_{bm},\ m_1,\ m_2$ | 5 |
| M8 全身 | $\text{Ca}_s,\ P,\ V_D$ | 3 |
| **單腔室合計** | | **17** |
| **雙腔室合計** | 14×2 局部 + 3 全身 | **31** |

M3 的 MSIC 三態 $(O, I)$ 於日內以 QSSA 求解並建成代理函數，不進入慢系統狀態向量。31 維對 `ode15s` 毫無壓力。

---

## 5. 模擬實驗設計 (Numerical Experiments)

| ID | 名稱 | 設計 | 主要輸出 |
|---|---|---|---|
| **E0** | 穩態校正 | 求解基線穩定不動點，確認 30 歲健康成人參數下 turnover ≈ 5–10%/yr、BMD 平坦 | 基線參數集 |
| **E1** | 力學劑量–反應曲面 | 掃描 (應變振幅 × 頻率 × 循環數 × 休息插入)，24 個月 | 3D 反應曲面；重現 40-cycle 飽和與 rest-insertion 增益 |
| **E2** | **2×2 因子：補鈣 × 負重** | {低鈣, 高鈣} × {久坐, 阻力訓練 3×/wk}，24 個月 | ΔaBMD%；**驗證 P1**；量化交互作用 |
| **E3** | 失重／臥床 + 對策最佳化 | 微重力設定 (τ→0)；以 `fmincon` 在「每日總負荷時間 ≤ 30 min」限制下最佳化 (N, f, 分段數, 休息長度) | 最小有效成骨劑量處方 |
| **E4** | 藥理模擬 | romosozumab (SOST 清除↑) 12/24 月；停藥；± 接續抗吸收藥；± 併用負荷 | **驗證自限性與停藥回落**；藥物 vs 運動之等效劑量 |
| **E5** | **部位專一性** | 雙腔室：site A 單側負荷 5 年 | A/B 骨量差；**驗證 P2**；對照全身性介入 |
| **E6** | 分歧與靈敏度 | **分歧參數改為 $\tau_{50}$（Piezo1 半活化）、$\beta_S$（SOST 基礎分泌率）、$E_2$** 做 continuation；另掃描正回饋強度 $\zeta$；LHS + Sobol 全域靈敏度 (N=10,000) | **驗證 P3**；辨識關鍵參數 (預期 $\tau_{50}$, $k_\tau$, $K_S$, $\lambda_S$, $\zeta$、以及 M1 的 $\kappa$) |

> **v1.3 重要更正 — 為何 ε\* 不能當分歧參數**：迴路閉合後，Frost 的設定點 $\varepsilon^*$ 與 lazy zone **不再是輸入，而是系統的湧現輸出**（由 $k_{co}(\tau)$ 的 sigmoid、MSIC 的失活動力學與 SOST 的 Hill 函數共同決定）。硬把 $\varepsilon^*$ 當可調參數等於重新剪斷回饋線。E6 應改用其**機制對應物** $\tau_{50}$ / $\beta_S$ 作為連續參數，並把算出的 $\varepsilon^*$ 當作**待驗證的預測值**（見 V14）。

---

## 6. 驗證標的 (Validation Targets)

模型**必須**同時滿足下列定量標的，否則參數需重新校正。存於 `data/validation_targets.csv`。

| # | 現象 | 目標值 | 容差 | 對應實驗 |
|---|---|---|---|---|
| V1 | 成人骨轉換率 | 5–10 %/yr | ±3 | E0 |
| V2 | 臥床／失重骨流失 (髖、腰椎) | 1.0–1.5 %/月 | ±0.5 | E3 |
| V3 | 失重時血清 Sclerostin | 上升 | 定性 | E3 |
| V4 | 負荷循環飽和點 | 36 cycles 已足以引發成骨；36→1200 cycles 邊際效益遞減 | 定性、單調遞減斜率 | E1 |
| | ✅ **v1.7 已達成** | 通道層級劑量確為線性（C6.3），但骨層級反應之邊際效益單調遞減（1.17e-3→1.29e-4 %/cycle）。下游飽和假說成立（C7.1） | | **已通過** |
| V5 | 休息插入 (10 s) 增益 | **條件性**：低幅值負荷下顯著放大（2–5 倍）；高幅值或高循環數下可能無效 | 須重現「效應隨基礎刺激強度遞減」 | E1 |
| V5b | 頻率依賴 | mechanostat 參數 ∝ ln(f)，1–10 Hz | 定性 | E1 |
| | ✅ **v1.6 已達成** | 孔彈性閉式解直接給出：1–10 Hz 內 τ 對 ln(f) 之 r=0.99911，零擬合參數（附錄 C6.1） | | **已通過** |
| V6 | 網球優勢側 vs 對側（Haapasalo 2000, pQCT） | BMC **+14–27 %**；Tot.Ar +16–21 %；Co.Ar +12–32 %；$I_{\max}$ +27–67 %；髓腔面積 +19 %（近端） | ±10（各項） | E5 |
| **V6b** | **優勢側 vs 對側之皮質體積骨密度 Co.Dn** | **≈ 0 %（實測 −2 %～0）** | **±2 %；硬性要求** | **E5** |
| V7 | 鈣（飲食或補充劑）之 BMD 效應 | **+0.7–1.8%，且為「非漸進式」** —— 一年後即達平台，兩年半未再增加 | 絕對值 ±0.8%；**平台形態為硬性要求** | E2 |
| V7b | 血清鈣之孟德爾隨機化 | 遺傳性血鈣升高與 BMD／骨折風險**無關** | 定性（模型中提高 Ca_s 設定不應提升 BMD） | E2 |
| V8 | Romosozumab 腰椎 BMD @12 mo | +11–14 % | ±3 | E4 |
| V9 | Romosozumab 效應自限 | 6–12 個月後形成標記回落 | 定性 | E4 |
| V10 | 停藥後 BMD 回落 | 12 個月內顯著流失 | 定性 | E4 |
| V11 | 流失–回復不對稱 | 回復時間 ≫ 流失時間 | 比值 > 3 | E3, E6 |
| V12 | 負荷 × 藥物交互作用 | 負荷與 **anabolic** 藥 (PTH、Scl-Ab) 為加成／協同；與 **bisphosphonate** 則否 | 交互作用項符號須正確 | E4 |
| V13 | Sclerostin 之雙效性 | 外源 sclerostin 使 RANKL↑、OPG↓，RANKL/OPG 比值上升，破骨活性可增至約 7 倍 | 定性、方向正確 | E4 |
| **V14** | **湧現的 mechanostat 設定點**（v1.3 新增，**零成本標的**） | 迴路閉合後由模型**算出**的 $\varepsilon^*$ 與 lazy zone 寬度，應落在 Frost 提出的 100–1,500 με 區間 | 落在區間內即通過 | E0, E6 |
| **V15** | **停經表型的幾何特徵**（v1.3 新增） | $E_2$ 下降後應出現 $r_p$ 緩慢外擴 **且** $r_e$ 加速外擴 → 皮質變薄而骨徑變寬 | 定性、兩者方向須同時正確 | E6 |

> **V14 的價值**：$\varepsilon^*$ 在 v1.2 是輸入參數，在 v1.3 變成輸出。這意味著本模型可以**預測** Frost 於 1987 年純由觀察提出的設定點數值 —— 這是把唯象理論化約到分子機制的直接證據，也是論文中最有力的單一結果。它不消耗任何自由參數，屬於免費取得的驗證標的。

---

## 7. 軟體架構 (For Claude Code)

```
bone-mechanostat/
├── README.md
├── PROJECT_PLAN.md                     ← 本文件
├── src/
│   ├── getResultsDir.m                 % 【v1.3】results 路徑（本機，非 iCloud）—— 見 §7.1
│   ├── params/
│   │   ├── getDefaultParams.m          % 全參數 struct + 文獻出處欄位
│   │   ├── paramBounds.m               % LHS/擬合用上下界
│   │   └── scenarioLibrary.m           % 久坐/重訓/臥床/太空/藥物 情境
│   ├── mech/
│   │   ├── organMechanics.m            % M1：力+幾何+材料 → ε_p, ε_e【v1.3 新增，閉環核心】
│   │   ├── crossSection.m              % A_g, I_g, E_app 之幾何/材料計算【v1.3 新增】
│   │   ├── poroelastic1D.m             % Biot PDE (finite difference)
│   │   ├── buildShearSurrogate.m       % 離線掃描 → 擬合 → 存 .mat
│   │   ├── shearSurrogate.m            % 快速查詢 τ̂(ε,f)
│   │   ├── msicGating.m                % 【v1.4】MSIC 三態 (C_h,O,I) — 唯一的通道模型
│   │   ├── buildDoseSurrogate.m        % 【v1.4】離線建 D_mech(τ̂) 一維內插（每 scenario 一份）
│   │   └── loadingDose.m               % M3：每日成骨劑量（查表，供慢系統呼叫）
│   ├── signal/
│   │   ├── osteocyteSignal.m           % M4–M5：Piezo1/Ca/YAP/SOST/Wnt
│   │   ├── osteocyteDensity.m          % M4a：n_ot 動力學 + 感測增益【v1.3 新增】
│   │   └── estrogenTNF.m               % M4b：E2 ⊣ TNF-α → SOST【v1.3 新增】
│   ├── cells/
│   │   └── boneCellPopulation.m        % M6：R, B, C
│   ├── bone/
│   │   ├── boneStructure.m             % M7：r_p, r_e, f_bm 三表面演化【v1.3 新增】
│   │   ├── surfaceAllocation.m         % η, ξ 分配係數（應變梯度 + 可用表面）【v1.3 新增】
│   │   ├── specificSurface.m           % S_v(f_bm) Martin 型函數【v1.3 新增】
│   │   ├── mineralization.m            % M7c：m1, m2 → ρ̄_min
│   │   └── densitometry.m              % aBMD / vBMD / BMC 輸出【v1.3 新增】
│   ├── systemic/
│   │   └── calciumPTHvitD.m            % M8
│   ├── model/
│   │   ├── rhsFull.m                   % 組裝完整 ODE 右手邊
│   │   ├── rhsTwoSite.m                % 雙腔室版本
│   │   ├── simulate.m                  % 統一模擬介面 (ode15s)
│   │   └── steadyState.m               % fsolve 求不動點 + 雅可比特徵值
│   ├── analysis/
│   │   ├── sensitivityLHS.m            % LHS + PRCC
│   │   ├── sobolIndices.m
│   │   ├── continuation.m              % 偽弧長延續，偵測 saddle-node
│   │   ├── calibrate.m                 % 對 V1–V11 擬合自由參數
│   │   └── identifiability.m           % profile likelihood
│   └── viz/
│       ├── plotTrajectories.m
│       ├── plotDoseSurface.m
│       ├── plotBifurcation.m
│       └── exportFigure.m              % 統一輸出樣式 (見 §7.2)
├── experiments/
│   ├── E0_baseline.m ... E6_bifurcation.m
├── data/
│   ├── validation_targets.csv
│   └── parameters_literature.csv       % 每個參數：值、單位、範圍、來源
├── results/          % 由程式產生，不進版控
├── tests/
│   ├── test_units.m                    % 單位一致性
│   ├── test_closedloop.m               % 【v1.3】回饋迴路完整性：介面禁用應變輸入 + 擾動回復
│   ├── test_noPhenomParams.m           % 【v1.4】防回潮：參數表禁止出現 a_r, τ_r, p, τ_th, q
│   ├── test_conservation.m             % 鈣質量守恆
│   ├── test_steadystate.m              % 無擾動下 BMD 漂移 < 0.1%/yr
│   └── test_regression.m               % 黃金標準軌跡比對
└── docs/
    └── model_derivation.md
```

### 7.1 實作規範

- **單位**：一律 SI；時間內部以**天 (day)** 為單位；濃度 pM/nM；應力 Pa。所有函式標頭須註明單位。
- **無因次化**：M4–M5 的訊號變數全部無因次化到 [0,1]（以基線穩態為 1），避免病態縮放。
- **求解器**：慢系統 `ode15s`，`RelTol 1e-6, AbsTol 1e-9`；非負性以 `NonNegative` 選項強制。
- **參數 struct**：單一 `p` struct 貫穿全程；**禁止**在函式內硬編碼數值。
- **隨機性**：所有隨機分析設 `rng(20260722,'twister')`。
- **每個模組獨立可測**：每支 `src/**` 檔案須能以 `demo` 模式單獨執行並繪圖。
- **不可先寫程式再找參數**：`data/parameters_literature.csv` 必須先填齊（可先以估計值 + `source = "assumed"` 標記），程式從 CSV 讀取。

**v1.3 新增規範**

- **負荷輸入一律為「力」**：`scenarioLibrary.m` 只得回傳 $M_L, F_L$（N·m 與 N），**禁止**任何情境直接指定應變。應變只能是 `organMechanics.m` 的輸出。此規則是回饋迴路完整性的守門條件，須以 `test_closedloop.m` 自動檢查。
- **幾何單位**：內部一律公尺 (m)，僅在輸出繪圖時換算為 mm。慣性矩 m⁴、面積 m²。
- **閉環回歸測試**（新增 `tests/test_closedloop.m`）：在固定負荷下擾動 $f_{bm}$ 或 $r_p$，系統必須**回復**至原不動點；若發散或單調漂移，即代表回饋線再度斷裂。
- **`results/` 不得放在 iCloud 路徑**：本專案位於 iCloud Drive，`.mat` 與大量輸出檔會被同步、甚至 evict 成佔位檔而導致 `load` 失敗。`results/` 與代理函數 `.mat` 一律指向本機路徑（建議 `~/Documents/MATLAB/bone-mechanostat-results/`），以 `getResultsDir.m` 集中管理；僅程式碼、參數 CSV、文件留在 iCloud。

### 7.3 MATLAB 執行環境注意事項

本機同時有多個 CCD session 各自持有獨立的 MATLAB R2026a 行程（workspace 互相隔離），但**共用同一個 preferences 目錄**。因此：

- ❌ **嚴禁 `savepath`** —— 它改寫全域 `pathdef.m`，會污染其他 session。路徑一律以 `addpath(genpath(projectRoot))` 於 session 內動態加入。
- ❌ 避免 `setpref` / 全域 `matlab.settings` 寫入。
- ⚠️ **`parpool` 須限制 worker 數**：本機為 Apple M1 Max（8 performance + 2 efficiency core），其他 session 可能同時佔用數核。E6 的 Sobol (N=10,000) 與 P2 的代理函數掃描一律以 `parpool('Processes', 3)` 明確指定，不使用預設值。

### 7.2 圖表輸出樣式（house style）
主色 `#028090`，強調色 `#C1543A`；字型 Microsoft JhengHei（中文標註）/ Helvetica（英文）；輸出 300 dpi PNG + 向量 PDF，A4 友善尺寸。

---

## 8. 分階段實作路線 (Phased Roadmap)

| 階段 | 期程 | 內容 | 完成判準 (Definition of Done) |
|---|---|---|---|
| **P1 基礎設施** | W1–2 | repo 骨架、參數 CSV、單位測試、`simulate.m` 介面 | `test_units` 全過；空模型可跑完 24 個月 |
| **P2 力學模組** | W3–5 | M1–M3；`organMechanics` + `crossSection` + `poroelastic1D` + `msicGating` + 兩支代理函數（$\hat\tau$ 與 $D_{\text{mech}}$） | 重現 τ ∈ 0.8–3 Pa；兩支代理函數 R² > 0.98；**`test_closedloop` 通過（擾動 $r_p$/$f_{bm}$ 後回復）**；**`test_noPhenomParams` 通過（參數表中不得出現 $a_r,\tau_r,p,\tau_{th},q$）** |
| **P3 生物模組** | W6–9 | M4–M7；接上 Lemaire 骨細胞族群；三表面幾何 + $S_v$ + $n_{ot}$ + 雌激素 | E0 穩態達 V1；擾動後可回復；**V14（湧現 ε\* ∈ 100–1500 με）達標** |
| **P4 系統耦合** | W10–12 | M8 鈣恆定 + 雙向耦合；全模型校正 | V1–V7 全數達標；**V7 的平台形態須為湧現而非擬合** |
| **P5 核心實驗** | W13–18 | E1–E5；藥理模組 | V8–V10 達標；P1、P2 得到明確結論 |
| **P6 動力系統分析** | W19–24 | E6：continuation、Sobol、identifiability | 明確回答 P3（雙穩態存在與否） |
| **P7 論文與擴充** | W25–36 | 撰稿；選擇性擴充 FEM 幾何、族群層級變異 | 投稿 |

---

## 9. 風險與因應 (Risks & Mitigation)

| 風險 | 影響 | 因應 |
|---|---|---|
| **參數過多、資料太少 → 不可辨識** | 結論不可靠 | 從文獻**固定** ≥80% 參數；僅開放 4–6 個自由參數擬合 V1–V11；強制執行 profile likelihood 並在論文報告 |
| 快慢尺度剛性導致數值失敗 | 模擬中斷 | QSSA + 代理函數；備援用 `ode23s`；加入 mass matrix 形式 |
| 過度擬合驗證標的 | 預測力假象 | 保留 V6 (網球) 與 V10 (停藥) 為**盲測 (hold-out)**，不參與校正 |
| 與 Pivonka 等既有模型區隔不足 | 審稿被質疑新穎性 | 論文中明確做**模型對照實驗**：以 SED-only 版本 vs 完整傳導鏈版本，展示只有後者能重現 V4、V5、V9 |
| 過度宣稱臨床意涵 | 學術風險 | 全文以「in silico hypothesis generation」定調；不提供個人化運動處方 |

**倫理**：純計算研究，不涉及人體或動物受試者，無須 IRB 審查；若後續納入既有去識別化 QCT 影像幾何，另行申請。

---

## 10. 預期產出

1. **主論文（方法／模型）**：*Biomechanics and Modeling in Mechanobiology*、*PLOS Computational Biology*、*Bone* 或 *Journal of Theoretical Biology*。
   暫定標題：*From fluid shear to sclerostin: a mechanotransduction-resolved multiscale model explains why calcium is permissive but loading is instructive in bone adaptation.*
2. **觀點／教育論文**：以 E2 的 2×2 結果撰寫「鈣是許可、負荷是指令」的臨床觀點短文（*Osteoporosis International* perspective 或國內醫學教育期刊）。
3. **對策論文**（若 E3 結果佳）：最小有效成骨劑量處方 → *npj Microgravity* / *Journal of Bone and Mineral Research*。
4. **開源程式碼**：GitHub repo + Zenodo DOI。
5. **選擇性延伸**：將劑量–反應曲面轉為互動式教學模組（Meliora-AI 系列），供醫學生理解 mechanostat 概念。

---

## 11. 給 Claude Code 的首個工作指令（建議）

> 讀取 `PROJECT_PLAN.md`（**v1.3**）。執行 **P1 階段**：
> 1. 建立 §7 的完整目錄結構與空檔案骨架（含 function 簽章與 unit-annotated docstring）。注意 v1.3 新增的 `mech/organMechanics.m`、`mech/crossSection.m`、`bone/boneStructure.m`、`bone/surfaceAllocation.m`、`bone/specificSurface.m`、`bone/densitometry.m`、`signal/osteocyteDensity.m`、`signal/estrogenTNF.m`。
> 2. 依 §4.2 所有方程式，產出 `data/parameters_literature.csv`，欄位為 `name, symbol, value, unit, lower, upper, module, source, confidence`；文獻值填入，未知者標 `source=assumed`。**幾何基線值可暫用 Haapasalo 2000 的肱骨幹數量級。**
> 3. 實作 `getDefaultParams.m`（從 CSV 讀取並建成 struct）、`test_units.m`、`getResultsDir.m`（依 §7.1 指向本機非 iCloud 路徑）。
> 4. 實作 `simulate.m` 的介面骨架（接受 scenario struct，回傳 time-series struct），暫以 stub RHS 通過端到端測試。**scenario struct 的負荷欄位必須是 $M_L, F_L$（力），不得是應變** —— 以 `test_closedloop.m` 的介面檢查強制之。
> **暫勿實作** M2 之 PDE 與任何生物模組 —— 待 P1 通過後再進入 P2。（B4#3 的 M3 重複計數已於 v1.4 解決，不再是 P2 的阻塞條件。）

---

---

## 附錄 A：文獻查證紀錄 (Consensus, 2026-07-22)

本節記錄 v1.0 → v1.1 的修訂依據。**未經查證的原始判斷已全數標示並修正。**

### A1. Sclerostin 雙效性（支持 N2，強力確認）
Sclerostin 直接刺激 osteocyte 支持破骨活性：外源 rhSCL 劑量依賴地上調 RANKL mRNA、下調 OPG mRNA，共培養系統中破骨吸收增加約 7 倍，且此效應可被 OPG 完全消除，並非源自骨細胞凋亡。機轉綜述亦明確指出 sclerostin 一方面阻斷 Wnt、一方面上調 RANKL，故 Scl-Ab 能**解偶聯 (dissociate)** 骨形成與骨吸收 —— 這正是本模型 M4 中 $L_{\text{RANKL}}$ 含 $\lambda_S$ 項的依據。
另有研究顯示 sclerostin 亦誘導 carbonic anhydrase 2 而促成 osteocytic osteolysis，並在大鼠造成尿鈣、尿磷排出增加 —— 提示 M8 中可考慮加入 osteocytic osteolysis 作為第二條骨→血鈣通路（列為 Phase 7 選擇性擴充）。

### A2. Romosozumab 自限性與停藥回落（確認 V9、V10）
Anabolic 效應在治療數月後即消退，其後僅餘抗吸收作用，故臨床用藥限期 12 個月；停藥後效果大致可逆，須接續抗吸收藥維持。動物研究另顯示：停藥一段時間後再給藥，成骨效應可恢復 —— 此「可再充填」特性應納入 E4 的設計。

### A3. 心血管安全性（**修正本文原有的過度批評**）
與安慰劑相比兩組心血管事件相當；與 alendronate 相比則 romosozumab 組嚴重心血管事件較多。惟事件數低、屬事後分析，且 sclerostin 雖表現於血管平滑肌，前臨床與遺傳學研究均未顯示抑制 sclerostin 會增加心血管風險。→ ChatGPT 的「仍在討論」為適切表述，本文 §2 第 8 項已撤回原評估。

### A4. 循環數飽和與休息插入（**修正 V4、V5**）
- **飽和確認**：小鼠脛骨模型中每日僅 36 次負荷即足以在皮質與海綿骨引發成骨反應；循環數增至 216、1200 時皮質骨面積雖續增，但**增益幅度遞減**。→ V4 由「~40 cycles 飽和點」改為「36 cycles 已足夠 + 報酬遞減」。
- **休息插入為條件性效應**：在鳥類尺骨與小鼠脛骨的**低幅值**負荷下，每個循環間插入 10 秒休息可將骨膜標記面積由 3.8% 提升至 21.9%，效果顯著；老齡小鼠中亦能啟動成骨。**但**同一批文獻中，另一組小鼠脛骨壓縮模型（−9 N、4 Hz、每 4 循環插入 10 秒）**未觀察到任何增益**。→ V5 由「明顯放大（定性單調）」改為「條件性：低幅值下顯著、高幅值／高循環數下可能消失」。這反而**強化**了採用 MSIC 三態機制的必要性 —— 唯有機制性模型能同時解釋正反兩組結果。

### A5. **競爭工作警訊（最重要的一項）**
Fu et al. (2025) 已發表 whole bone–LCN–osteocyte 多尺度模型，涵蓋整骨變形產生的 LCN 液流、以及 osteocyte 透過機械敏感離子通道之開啟／關閉／**失活**對 FSS 的反應，並據以檢視負荷幅度、頻率、循環數與恢復時間的效應；其結果顯示循環數增加使通道漸趨失活而造成飽和，短恢復期使通道回到關閉態、長恢復期才回復機械敏感度。
→ **本計畫的 N1 已重新定位**（見 §3）：不宣稱前端創新，改採其三態機制並向下游延伸。**撰稿時必須明確引用並比較。**

### A6. 鈣補充的效應量（**大幅強化 V7**）
59 項 RCT 的統合分析顯示：無論來自飲食或補充劑，增加鈣攝取使 BMD 上升約 **0.7–1.8%**，且此增幅在一年後即達平台、**兩年半以上並未持續累積 (non-progressive)**；效應不因劑量 ≥1000 vs <1000 mg/日、亦不因基線攝取 <800 vs ≥800 mg/日而異，作者結論為不足以帶來臨床上顯著的骨折風險下降。另一項納入 43,869 人的統合分析顯示鈣+VitD 僅在骨盆有微幅 BMD 改善，整體骨折風險未降低。
更關鍵的是孟德爾隨機化研究：在血鈣正常者中，遺傳決定的血鈣升高與跟骨 BMD **無關**、亦未降低骨折風險。
→ **這三項證據合起來，是 P1 假說最強的外部支撐**：「非漸進式平台」是一個極具鑑別力的動力學特徵 —— 任何把補鈣視為持續驅動力的模型都會產生持續斜率而**無法**通過 V7。建議將 V7 提升為**核心校正標的**。

### A7. 藥物與運動的交互作用（新增 V12）
小鼠實驗顯示，機械負荷與 anabolic 療法 (PTH、sclerostin 抗體) 併用時，對預測強度、骨體積與 mechanoregulation 參數呈**加成且協同**；與抗吸收藥 (bisphosphonate) 併用則否。作者並指出強度提升伴隨 remodeling 閾值的移動 —— 恰如 Frost mechanostat 理論之預期。
→ 這同時是 E4 的驗證標的，也**直接支持本模型「藥物改變 mechanostat 設定點」的架構假設**。

### A8. 尚未查證、仍屬待辦的項目
| 項目 | 對應 | 說明 |
|---|---|---|
| 網球選手肱骨不對稱之確切幅度 | V6 | 本文採 +10–30%，尚未以 Consensus 覆核；P2 之定量校正前必須查證 |
| 失重／臥床骨流失速率 1.0–1.5%/月 | V2 | 領域內共識值，但未逐一覆核 |
| LCN 內 FSS 之 0.8–3 Pa 區間 | M2 | 需覆核不同物種／部位之差異 |
| Piezo1 相對於 integrin/cilium/Cx43 之權重 | M4 | 建議在 E6 靈敏度分析中以 $J_{\text{alt}}$ 參數涵蓋不確定性，而非強行定論 |

---

---

## 附錄 B：待補文獻與數值缺口清單

### B0. 目前的可執行狀態

| 階段 | 是否可立即開工 | 說明 |
|---|---|---|
| P1 基礎設施 | ✅ **可以** | 參數 CSV 先以 `source=assumed` 佔位即可，不阻塞。**v1.3 後 CSV 須增列幾何區塊**（$r_{p,0}, r_{e,0}, E_{\text{ref}}, \kappa, \nu$）與正回饋區塊（$a_{1..5}, \zeta, k_{ot}$ 等） |
| P2 力學模組 | ✅ **可以** | 孔彈性方程式已完備；參數可先用文獻常見量級掃描。**閉環部分（M1′）完全不需新文獻即可實作**，$\kappa,\nu$ 可先取 $\kappa=2.5, \nu=1$ 並標 `assumed` |
| P3 生物模組 | ⚠️ 半可 | 方程式結構完備，但 M6 速率常數必須取自 Lemaire/Pivonka 原文；$S_v$ 係數需 B1 #6b |
| **P4 系統耦合與校正** | ❌ **阻塞** | 需要 Tier 1 全文才能填齊參數並做校正 |
| P5–P6 | ❌ 阻塞 | 依賴 P4 |

→ **結論：可以先讓 Claude Code 跑 P1–P2，同時並行蒐集 Tier 1 文獻。**

### B1. Tier 1 — 必須取得全文（沒有這些，參數表填不出來）

| # | 書目 | 用途 | 缺什麼 |
|---|---|---|---|
| **1** | Lemaire V, Tobin FL, Greller LD, Cho CR, Suva LJ. *Modeling the interactions between osteoblast and osteoclast activities in bone remodeling.* **J Theor Biol. 2004;229(3):293–309.** | M6 | 全部速率常數 $D_R, D_B, D_C, D_A, k_B$ 與 $\pi$ 函數的解離常數。**最關鍵的一篇** |
| **2** | Pivonka P, Zimak J, Smith DW, et al. *Model structure and control of bone remodeling: a theoretical study.* **Bone. 2008;43(2):249–263.** | M6 | RANKL–OPG–PTH 完整參數集（Lemaire 的修正擴充版），含 $\kappa$、$K_{L3}$ |
| **3** | Peterson MC, Riggs MM. *A physiologically based mathematical model of integrated calcium homeostasis and bone remodeling.* **Bone. 2010;46(1):49–63.** | M8 | 腸吸收、腎排泄、PTH 與 1,25D 的全部參數。**這篇決定 P1 假說能否量化** |
| **4** | Weinbaum S, Cowin SC, Zeng Y. *A model for the excitation of osteocytes by mechanical loading-induced bone fluid shear stresses.* **J Biomech. 1994;27(3):339–360.** | M2 | 孔隙率 $k_p$、canaliculus 幾何 $a$、PCM 放大因子 $\Gamma$ 的原始推導與數值 |
| **5** | Fu R, et al. *A whole bone–lacunocanalicular network–osteocyte model examining bone adaptation to distinct loading parameters.* **Int J Mech Sci. 2025.** | M3 | **MSIC 三態速率常數 $k_{co}, k_{oc}, k_{oi}, k_{ic}$** — 新版 M3 的核心，無可替代 |
| **6** | Scheiner S, Pivonka P, Hellmich C. *Coupling systems biology with multiscale mechanics, for computer simulations of bone remodeling.* **Comput Methods Appl Mech Eng. 2013;254:181–196.** | 對照組 | 建構「SED-only 對照模型」所需，用於證明本模型的增量價值 |
| **6b** | Martin RB. *Porosity and specific surface of bone.* **CRC Crit Rev Biomed Eng. 1984;10(3):179–222.**（**書目待覆核**） | M7 | **比表面積多項式 $S_v(f_{bm})$ 的五個係數 $a_j$** —— v1.3 的正回饋 #2 與 V11 不對稱性的機制來源，無可替代。Pivonka/Scheiner 系列均沿用此函數，若取不到原文可自其論文轉引 |
| **6c** | Currey JD. *The effect of porosity and mineral content on the Young's modulus of elasticity of compact bone.* **J Biomech. 1988;21(2):131–139.**（**書目待覆核**；另可用 Gibson & Ashby 之 cellular solids 冪律） | M1 | **$E_{\text{app}}=E_{\text{ref}}f_{bm}^{\kappa}(\bar\rho_{\min}/\bar\rho_{\min,0})^{\nu}$ 的指數 $\kappa,\nu$** —— 決定力學回饋迴路的增益大小，是 v1.3 閉環的關鍵敏感參數 |

### B2. Tier 2 — 校正標的需要逐點數值（摘要不夠）

| # | 書目 | 對應標的 | 缺什麼 |
|---|---|---|---|
| 7 | Tai V, Leung W, Grey A, Reid IR, Bolland MJ. *Calcium intake and bone mineral density: systematic review and meta-analysis.* **BMJ. 2015;351:h4183.** | **V7（核心）** | 1 年／2 年／>2.5 年、各部位的**逐點百分比**，用來擬合平台曲線形狀 |
| 8 | Srinivasan S, Weimer DA, Agans SC, Bain SD, Gross TS. *Low-magnitude mechanical loading becomes osteogenic when rest is inserted between each load cycle.* **J Bone Miner Res. 2002;17(9):1613–1620.** | V5（正例） | 完整負荷參數：峰值應變、頻率、波形、循環數、每週天數 |
| 9 | Yang H, Embry RE, Main RP. *Effects of loading duration and short rest insertion on cancellous and cortical bone adaptation in the mouse tibia.* **PLoS ONE. 2017;12(1):e0169601.** | V4 + V5（**反例**） | 36/216/1200 cycles 三組的骨形成率數值。**與 #8 構成 MSIC 校正的雙錨點，兩篇必須成對取得** |
| 10 | Marques FC, et al. *Mechanostat parameters estimated from time-lapsed in vivo micro-CT data … logarithmically dependent on loading frequency.* **Front Bioeng Biotechnol. 2023.** | V5b | 對數關係的斜率與截距 |
| 11 | Schulte FA, et al. *Combined physical and pharmacological anabolic osteoporosis therapies increase bone response and mechanoregulation in female mice.* **Nat Commun. 2026.** | V12 | 交互作用的效應量與 remodeling 閾值位移量 |
| 12 | Frost HM. *Bone "mass" and the "mechanostat": a proposal.* **Anat Rec. 1987;219(1):1–9.** | **V14**, E0, E6 | 設定點 $\varepsilon^*$ 與 lazy zone 的原始定義區間 —— **v1.3 後改作對照標準**（模型算出 ε\* 後與此比對），而非輸入參數來源 |

### B3. Tier 3 — 我目前無法填的數值缺口（附錄 A8 的具體化）

| # | 主題 | 建議書目（**書目資料請代為覆核**） | 缺什麼 |
|---|---|---|---|
| ~~13~~ | ~~網球／壁球選手肱骨不對稱~~ **✅ 已查證 (2026-07-22, PubMed)** | Haapasalo H, Kontulainen S, Sievänen H, Kannus P, Järvinen M, Vuori I. *Exercise-induced bone gain is due to enlargement in bone size without a change in volumetric bone density: a peripheral quantitative computed tomography study of the upper arms of male tennis players.* **Bone. 2000;27(3):351–357.** PMID 10962345｜DOI 10.1016/s8756-3282(00)00331-8 —— **書目資料經 PubMed 覆核無誤** | **已取得（摘要層級）**：n=12 前國手 + 12 配對對照，雙側 pQCT。BMC +14–27%、Tot.Ar +16–21%、Co.Ar +12–32%、Co.Wi.Th +5–25%、$I_{\min}$ +33–61%、$I_{\max}$ +27–67%、髓腔面積 +19%（近端肱骨）；**Co.Dn 與 Tr.Dn 兩側幾乎相同，唯遠端肱骨 −2%**。→ 已寫入 V6/V6b，並據此定案 M7 三表面架構。**仍需全文**以取得各部位絕對值作為 $r_p, r_e$ 的基線 |
| 14 | 臥床／太空飛行骨流失 | LeBlanc A, Schneider V, Shackelford L, et al.（長期臥床系列）；Sibonga JD 等 ISS 資料 | **V2 的部位別月流失率**與**回復動力學曲線**（V11 的不對稱比值） |
| 15 | 失重時 sclerostin 變化 | Spatz JM, et al.（臥床／卸載 sclerostin 系列） | V3 由定性升級為定量 |
| 16 | Piezo1 於 osteocyte | Li X, et al. **eLife. 2019;8:e49631**；Sun W, et al. eLife. 2019 | $\tau_{50}$、Hill 係數 $k_\tau$ —— 目前完全是估計值 |
| 17 | Romosozumab 逐月 BMD 軌跡 | Cosman F, et al. *Romosozumab treatment in postmenopausal women with osteoporosis (FRAME).* **N Engl J Med. 2016;375(16):1532–1543.** | **V8/V9 的逐月曲線**（不只 12 個月終點值），自限性要靠曲線形狀擬合 |
| 18 | LCN 內 FSS 實測範圍 | 建議查 Fritton SP & Weinbaum S. *Annu Rev Fluid Mech.* 2009 綜述 | 0.8–3 Pa 的物種／部位差異 |

> **書目覆核提醒**：#13–#18 的卷期頁碼係依記憶列出，取全文時請一併確認；#1–#12 的書目資料較有把握，但仍建議核對。

### B4. 計劃本身尚存的結構缺口（非文獻問題，是設計問題）

1. ~~**雌激素模組未具體化**~~ → **✅ v1.3 已解決**。已於 M4(b) 補上 $E_2 \dashv \text{TNF-}\alpha \to S$ 動力學，並讓 TNF-α 同時調節 M7 的骨內膜吸收分配 $\xi_e$，使停經表型（變寬變薄）具備機制來源。新增 V15 為其驗證標的。**遺留事項**：$\lambda_E$（直接路徑）與 $\lambda_T$（間接路徑）有互償風險，須納入 profile likelihood。
2. ~~**M7 礦化模組的取捨未定**~~ → **✅ v1.3 已解決**。B3 #13（Haapasalo 2000）已查證：運動的骨增益**完全來自幾何、vBMD 不變**（Co.Dn 兩側差異 −2%～0）。故 M7 已重寫為三表面幾何模型，並同時輸出 aBMD 與 vBMD。原「$f_{bm}\times\bar\rho$ 兩因子式」正式廢止。
3. ~~**M3 的飽和機制有重複計數**~~ → **✅ v1.4 已解決**。實際查核後發現重複計數達**四重**（通道開啟機率、循環數飽和、休息插入、閾值／超線性），且 $D_{\text{mech}}$ 從未被下游消費、快慢介面實為斷開。已將 M3 全面改寫為單一 MSIC 三態模型，$D_{\text{mech}}=\int_{\text{day}}O\,dt$，並刪除 M4 的 $P_o(\tau)$、將 $\tau_{50},k_\tau$ 遷入 $k_{co}(\tau)$。淨刪 5 個唯象自由參數。詳見 §4.2 M3 與附錄 C5。**遺留事項**：V5 條件性的機制解釋（下游飽和假說）須待 B2 #8、#9 全文以同一組參數同時擬合正反兩例來檢定。

### B5. 建議的執行順序

1. **現在**：Claude Code 啟動 P1（目錄骨架 + 參數 CSV 佔位 + 單位測試）。
2. **並行**：取得 Tier 1 的 #1、#2、#3 三篇 —— 這三篇一到，P3、P4 的參數表即可填至約 70%。
3. **接著**：#5（Fu 2025）與 #4（Weinbaum 1994）到手後啟動 P2/P3 的實質實作。
4. **P4 之前**：補齊 Tier 2 的 #7、#8、#9 三篇（V7 與 V4/V5 是最有鑑別力的校正標的）。
5. **P5 之前**：Tier 3 的 #13、#17。
6. **B4 的兩個設計缺口**：#13 到手後一併定案。

---

---

## 附錄 C：v1.3 力學回饋迴路定案紀錄 (2026-07-22)

### C1. 所修正的缺陷

v1.2 的 §4.1 結構圖是一條**純前饋鏈** M1→M2→…→M7，$\varepsilon_{\text{peak}}(x)$ 為外生固定輸入。這等同於**應變控制**，其三個後果均為致命：

| # | 後果 | 說明 |
|---|---|---|
| 1 | $f_{bm}$ 成為**純積分器** | $df_{bm}/dt=k_{\text{form}}B-k_{\text{res}}C$ 中 $B, C$ 不受 $f_{bm}$ 影響。任何持續擾動（如補鈣使 PTH 下降）都會產生**永久斜率**而非平台 → **V7 的「非漸進式平台」在數學上不可能達成**，而附錄 A6 才剛將 V7 訂為核心校正標的 |
| 2 | **沒有設定點** | Mechanostat 的本體就是「骨量↑→剛度↑→應變↓→刺激↓」的負回饋。缺此線則無不動點、無 lazy zone，**E6 的鞍結點分歧與雙穩態不會出現**，P3 無從驗證 |
| 3 | **V6 機制錯誤** | 單一 $f_{bm}$ 只能以密度上升表達骨增益，與 Haapasalo 實測（vBMD 不變）方向相反 |

### C2. 定案內容

| 項目 | 決定 |
|---|---|
| **核心修正** | 負荷輸入由「應變」改為「**力**」($M_L, F_L$)。應變成為被調控的輸出。見 M1′ |
| **幾何解析度** | 三表面（骨膜 $r_p$／骨內膜 $r_e$／皮質內 $f_{bm}$），與 pQCT 的 Tot.Ar／M.Cav.Ar／Co.Ar／Co.Dn 一對一對應。**依據 Haapasalo 2000 實測，非任意選擇** |
| **分配係數** | 由應變梯度與可用表面積決定，**不新增自由參數** |
| **輸出** | aBMD 與 vBMD 分開報告，內建 DXA 骨尺寸假影 |
| **P3 正回饋** | 兩個機制**現在即納入**：(1) 比表面積 $S_v(f_{bm})$ → $f_{bm}=0$ 為吸收態；(2) 骨細胞密度 $n_{ot}$ → 感測增益衰減 |
| **雌激素** | **一併補上**（原 B4#1）：$E_2\dashv\text{TNF-}\alpha\to S$，且 TNF-α 調節骨內膜吸收分配 $\xi_e$ |
| **E6 分歧參數** | 由唯象的 $\varepsilon^*$ 改為機制性的 $\tau_{50}$、$\beta_S$、$E_2$；$\varepsilon^*$ 降格（實為升格）為模型輸出 |
| **新增驗證標的** | V6b（Co.Dn ≈ 0，硬性）、V14（湧現 $\varepsilon^*$ ∈ 100–1500 με）、V15（停經幾何表型） |

### C3. 對 §9 參數風險的影響評估

新增參數為 $r_{p,0}, r_{e,0}, E_{\text{ref}}, \kappa, \nu, a_{1..5}, k_{ot}, \gamma_{ot}, \delta_{ot}, \zeta, k_T, \delta_T, \lambda_T, \lambda_\xi$。其中：

- $r_{p,0}, r_{e,0}$ 為 **pQCT 直接量測值**（Haapasalo 該篇即提供）；
- $E_{\text{ref}}, \kappa, \nu$ 有成熟的材料學文獻（B1 #6c）；
- $a_{1..5}$ 為 Martin 函數的固定係數（B1 #6b），非可調參數。

真正新增的**自由**參數僅 $\zeta$（正回饋強度）與 $\lambda_T$。§9 的「≥80% 由文獻固定、開放 4–6 個自由參數」紀律**不受影響**。$\zeta$ 本身即為 E6 的掃描對象而非擬合對象。

### C4. 尚未處理者

- **B1 #6b、#6c 的書目資料係依記憶列出，取全文時務必覆核。**

---

## 附錄 C5：v1.4 M3／M4 介面定案紀錄 (2026-07-22)

### C5.1 實際查核到的缺陷（比原先判斷嚴重）

原本記錄的問題是「$\Phi_{\text{rest}}$ 與 $N^p$ 與三態模型重複」。逐條追查後發現重複計數共**四重**，且伴隨一個更根本的結構斷裂：

| # | 重複的對象 | 兩處表述 |
|---|---|---|
| 1 | **通道開啟機率本身** | M3 的三態 $O(t)$（機制式）vs M4 的 $P_o(\tau)$ sigmoid（唯象式）。MSIC 即 Piezo1，同一物件被建模兩次 |
| 2 | 循環數飽和 | $N^p\ (p<1)$ vs 失活態 $I$ 的累積 |
| 3 | 休息插入增益 | $\Phi_{\text{rest}}(\Delta t)$ vs $I\xrightarrow{k_{ic}}C_h$ 的回復 |
| 4 | 閾值與超線性 | $\tau_{th}, q$ vs $\tau_{50}, k_\tau$ vs $k_{co}(\tau)$ 的 τ 依賴 |

**結構斷裂**：$D_{\text{mech}}$ 在 M3 定義後，**M5–M8 沒有任何一條方程式使用它**。力學訊號實際上是經 M4 的 $P_o(\tau)$ 進入 $dC_a/dt$。亦即 §4.1 所宣稱的「M1–M4 快變數 QSSA → 每日呼叫一次力學劑量函數」在方程式層面從未實現，M3 是懸空模組。v1.3 新增的 $D_{\text{mech}}^{\text{eff}}=D_{\text{mech}}(n_{ot}/n_{ot,0})^{\zeta}$ 亦一併懸空 —— 亦即 P3 的正回饋 #1 原本不會生效。

### C5.2 定案

| 項目 | 決定 |
|---|---|
| **原則** | 通道只建模一次（M3 的三態），快慢介面只有一個純量（$D_{\text{mech}}^{\text{eff}}$） |
| **M3** | 刪除全部唯象項；$D_{\text{mech}}(d)=\int_{\text{day}}O(t;\tau(t))\,dt$。τ 依賴性收攏於 $k_{co}(\tau)$ 的 sigmoid |
| **M4** | 刪除 $P_o(\tau)$；$dC_a/dt$ 改由 $D_{\text{mech}}^{\text{eff}}/T_{\text{day}}$ 驅動。$\tau_{50}, k_\tau$ 遷入 M3 |
| **參數帳** | **刪除 5 個唯象自由參數**（$a_r,\tau_r,p,\tau_{th},q$）；新增的 $k_{co}^{\max},k_{oc},k_{oi},k_{ic}$ 取自 Fu et al. 2025，屬**文獻固定值** |
| **實作** | 因 v1.3 閉環使 $\hat\tau$ 隨幾何漂移，$D_{\text{mech}}$ 不再是情境常數。須以 `buildDoseSurrogate.m` 離線建 $D_{\text{mech}}(\hat\tau)$ 一維內插，慢系統查表 |
| **新測試** | `test_noPhenomParams.m`：參數表中不得出現已刪除的 5 個符號，防止日後回潮 |

### C5.3 對三個驗證標的的影響

- **V4（循環數飽和）**：改由 $I$ 累積產生，不再有 $p$ 可調 —— 從「擬合」變成「預測」。
- **V5（休息插入的條件性）**：三態模型單獨會給出**與觀察相反**的方向（高幅值下失活較多、休息增益應更大，但 Srinivasan 觀察到低幅值才顯著）。定案採「**下游傳遞函數飽和**」假說解釋：高幅值時 SOST/細胞族群已近上限，額外劑量無法轉譯。**此為待檢定假說，非既成結論**，須以 B2 #8、#9 全文同時擬合正反兩例。若失敗，須重新檢視機制。
- **V5b（頻率對數依賴）**：頻率現有 M2（流體力學）與 M3（通道動力學）兩條路徑，物理上皆真實但校正時難分離。規定 $\alpha, f_c$ 先由 `poroelastic1D` 離線標定且**不參與擬合**。

### C5.4 §9 風險再評估

v1.3 增加了幾何與正回饋參數，v1.4 刪掉 5 個唯象參數並把 4 個新常數釘在文獻上。**兩次修訂合計後，自由參數數量低於 v1.2**，而模型的機制解析度顯著提高。§9 的「≥80% 由文獻固定、開放 4–6 個自由參數」目標較 v1.2 更容易達成。

---

---

## 附錄 C6：P2 實作後的實測修訂 (2026-07-24)

M2/M3 實作完成並在 MATLAB R2026a 執行後，三項原假設被數值否證。全部經參數掃描確認**非參數選擇問題**。

### C6.1 M2：高頻不飽和，且 V5b 因此免費達成

Biot 問題為線性，令 $\varepsilon=\mathrm{Re}\{\hat\varepsilon e^{i\omega t}\}$、$P'(0)=0$、$P(L)=0$：

$$P(z)=\frac{\hat\varepsilon}{S}\left[\frac{\cosh kz}{\cosh kL}-1\right],\quad
\left|\frac{\partial P}{\partial z}\right|_{\max}=\left|\frac{\hat\varepsilon}{S}\right|\big|k\tanh kL\big|,\quad k=\sqrt{i\omega/c_p}$$

漸近：$kL\ll1$ 時 $\tau\propto f$；$kL\gg1$ 時 $\tau\propto\sqrt f$。高頻下孔壓確實趨近不排水值，**但僅在引流面厚度 $\delta=\sqrt{c_p/\omega}$ 的邊界層外**；$\delta$ 隨頻率變薄，該處梯度反而成長。**故不飽和。**

實測（`buildShearSurrogate`，Crank-Nicolson FD vs 閉式解）：最大相對誤差 **0.0029%**，遠優於原訂 R²>0.98 判準。局部指數由 1.000（0.1 Hz）滑至 0.500（100 Hz），與解析漸近完全一致。

**新代理函數**（取代原唯象式，零擬合參數）：

$$\tau_{\max}=K_\tau\,\varepsilon_{\text{peak}}\,\Phi(f),\qquad
\Phi(f)=\frac{|k\tanh kL|}{|k_0\tanh k_0L|}\ \ (\Phi(f_0)=1)$$

**V5b 之意外達成**：$f_{poro}=c_p/(2\pi L^2)=1.59$ Hz 恰落在 1–10 Hz 內，指數在該十倍頻程中由 ~1 平滑滑向 ~0.5。1–10 Hz 內 $\tau$ 對 $\ln f$ 之 $r=0.99911$，優於對 $f$（0.962）與 $\sqrt f$（0.991）。**Marques (2023) 的對數頻率依賴是孔彈性轉角的直接後果，非唯象擬合。** 原飽和形式高頻斜率趨零，V5b 將不可能達成。

> **參數影響**：`alpha_f`、`f_c` 標記為 `superseded`。頻率依賴不再有任何可調指數 —— 由 $c_p$ 與 $L_{poro}$ 完全決定。這消除了 v1.4 C5.3 提出的頻率辨識性隱憂。

### C6.2 M2 微結構參數與生理剪應力區間不相容

以 CSV 中的 $k_p, S, a, \Gamma$ 直接計算，1000 με @ 1 Hz 給出 $\tau=45.7$ kPa，**較 0.8–3 Pa 目標高約四個數量級**。四者皆 `source=assumed, confidence=low`（待 B1 #4 Weinbaum 1994）。

**處置**：引入集總增益 $K_\tau$ 吸收 $(a/2)\Gamma/S$，直接由生理錨點標定（1000 με @ 1 Hz → 2 Pa），標記 `source=calibrated`。**頻率依賴不受此縮放影響**（由 $c_p, L$ 決定），故 C6.1 的結論不因振幅未定而動搖。此舉同時把 5 個弱約束參數縮為 2 個有效參數（$K_\tau$ 與 $t_{poro}=L^2/c_p$），對 §9 辨識性紀律為淨改善。

實測基線（$K_\tau=2000$ Pa/strain）：

| 情境 | $\varepsilon_p$ [με] | $f$ [Hz] | $\tau$ [Pa] |
|---|---|---|---|
| bedrest | 15 | 1.0 | 0.03 |
| sedentary | 762 | 1.0 | **1.52** ✓ 在 0.8–3 帶內 |
| resistance | 2236 | 0.5 | **2.29** ✓ |
| tennis | 2851 | 1.5 | 8.26（劇烈負荷超出日常帶，屬預期） |

### C6.3 V4 無法由三態通道產生（**撤回 v1.4 之宣稱**）

$\tau_{pk}=2$ Pa、1 Hz、無休息下的循環數掃描：

| cycles | 9 | 36 | 216 | 1200 | 3000 |
|---|---|---|---|---|---|
| $D-D_0$ [s] | 1.37 | 4.06 | 21.88 | 119.30 | 297.50 |
| 局部指數 $d\ln D/d\ln N$ | 0.733 | 0.909 | 0.986 | 0.997 | — |

指數**趨向 1.0 而非遞減** —— 劑量對循環數漸近線性。$k_{oi}\in[0.1,50]\times k_{ic}\in[0.001,1]$ 全平面掃描，216→1200 指數恆在 **0.80–1.03**；`k_tau_sig` 由 0.30 掃到 0.05 亦僅 0.984–0.989。

**機制原因**：週期性驅動下線性三態系統於數個回復時間內進入**極限環**，此後每循環貢獻恆定 → 總劑量線性。欲在 1200 秒內維持飽和需失活在該尺度上近乎不可逆（$k_{ic}\ll10^{-3}$ /s），但 V5 要求 10 秒休息即能解除失活（$k_{ic}\approx0.1$ /s）。**單一失活時間尺度無法同時服務 V4 與 V5。**

> **v1.4 附錄 C5.3 宣稱「V4 由 $I$ 累積產生，從擬合變成預測」—— 此宣稱不成立，予以撤回。**

### C6.4 V5 幅值依賴方向與文獻相反

36 循環、1 Hz、插入 10 s 休息之增益：

| $\tau_{pk}$ [Pa] | 0.5 | 1.0 | 2.0 | 5.0 | 8.0 |
|---|---|---|---|---|---|
| 增益倍率 | 1.61 | 2.14 | 2.69 | 2.99 | 3.06 |

**增益隨幅值遞增**，Srinivasan (2002) 觀察為低幅值下才顯著。$k_{ic}\in\{0.01,0.1,0.5\}$ 全部同向。

機制上不可避免：低幅值累積的失活少 → 休息可解除者少 → 增益小。此即 v1.4 C5.3 預告之風險，現已證實且證明為結構性。

### C6.5 綜合影響：風險升級

**V4 與 V5 現在共同依賴同一個未經檢定的假說** ——「下游傳遞函數飽和」：高幅值／高循環數時 SOST 的 Hill 抑制與細胞族群反應已近上限，額外劑量無法轉譯為骨形成。

- 對 V4：劑量線性 + 下游飽和 → 反應遞減 ✓ 可行
- 對 V5：高幅值時無休息與有休息之劑量皆已越過飽和 → 觀察增益 ≈ 1；低幅值時位於陡峭段 → 增益顯著 ✓ 可行

但這使 $K_S, h_S, K_Y, n_Y$（**全部 `assumed`、`confidence=low`**）同時承擔 V4 與 V5 兩個標的的解釋責任。§9 風險 1（不可辨識）**顯著升高**。

**P3 必須執行的檢定**：以同一組下游參數，同時滿足
(a) V4 的 36→216→1200 遞減；
(b) V5 在低幅值下的 2–5 倍增益；
(c) V5 在高幅值下的增益消失（Yang 2017 反例）。
**三者任一失敗，則須引入第二個機制**（候選：骨細胞層級的適應／去敏化，時間尺度介於通道失活與細胞反應之間）。

此檢定應在 P3 生物模組完成後**立即**執行，早於任何全模型校正 —— 若失敗，M4 的結構須先修改。

### C6.6 其他實測發現

- **靜息開啟機率過高**：`k_tau_sig=0.3` 時 $k_{co}(0)$ 達 $k_{co}^{\max}$ 的 3.4%，靜息 $O=4.6\%$，使負荷僅令日劑量上升 **5.6%** —— 力學訊號被基線淹沒，V2 廢用流失不可能成立。已依「sedentary/bedrest 劑量比」錨點下修為 **0.12**（比值 8.4）。仍為佔位值，待 Fu 2025。
- **仿射週期算子**：日內積分改以單週期仿射映射精確迭代（`msicCycleOperator`），與逐步積分吻合至 **2.2e-15**，且使 2000 循環的日劑量計算由 O(N) 步降為 3 次單週期積分 —— E1 的大規模掃描因此可行。

---

---

## 附錄 C7：P3 實作後的修訂與 C6.5 檢定結果 (2026-07-24)

### C7.1 ✅ C6.5 三項聯合檢定 — **通過，風險解除**

C6.5 曾判定 V4 與 V5 共同押在未檢定的「下游傳遞函數飽和」假說上。M4–M7 實作後執行檢定（ms=3、疊加於 2000 循環/日的日常活動背景、8 週、量測 ΔBMC）：

**(a) V4 循環數報酬遞減 — PASS**

| cycles | 36 | 216 | 1200 |
|---|---|---|---|
| 淨 ΔBMC [%] | 0.0421 | 0.0724 | 0.1553 |
| **邊際效益 [%/cycle]** | **1.17e-3** | **3.35e-4** | **1.29e-4** |

邊際效益**單調遞減**；36 循環已引發明確成骨。與 Yang (2017) 之型態一致。

**(b)(c) V5 休息插入增益的條件性 — PASS**

| ms | 0.5 | 1.0 | 2.0 | 3.0 | 5.0 |
|---|---|---|---|---|---|
| $\varepsilon_p$ [με] | 381 | 762 | 1524 | 2285 | 3809 |
| 增益倍率 | 1.73 | **3.01** | 1.52 | 1.45 | 1.42 |

峰值增益 **3.01×** 落在 V5 要求的 2–5 倍內，且高幅值下衰減至 ~1.4（Srinivasan 正例與 Yang 反例同時滿足）。

> **結論**：下游飽和假說成立。M3 通道層級的劑量雖對循環數線性、且休息增益方向相反（C6.3、C6.4），但經 SOST Hill 抑制與細胞族群反應之後，**骨層級的反應同時重現 V4 與 V5 的條件性**。C6.5 所提「三者任一失敗須引入第二機制」的預案**不需啟動**。
>
> ⚠️ **但辨識性風險仍在**：$K_S, h_S, K_Y, n_Y$ 仍全部 `assumed`。上述通過是在佔位參數下取得，須於 P4 校正後複驗，並納入 `identifiability.m`。

**檢定設計的關鍵**：實驗負荷必須**疊加於日常活動背景**。首次執行時 probe 情境僅含實驗負荷，所有組別皆低於維持閾值（8 週流失 7%），測到的是廢用速率而非負荷反應，V4 指數呈超線性 1.33（假性失敗）。真實實驗（Yang、Srinivasan）皆為籠內活動之上加負荷。

### C7.2 結構上不存在靜止不動點（修正 P3 完成判準）

$\eta_p$（骨膜形成分配）恆大於 $\xi_p$（骨膜吸收分配），因為前者受應變梯度偏壓、後者受表面積主導。**故 $\eta=\xi$ 不可能，幾何無法完全靜止。** 骨膜持續外擴＋髓腔擴大是成人骨骼的真實行為，非模型缺陷。

自由度僅 $k_{form}/k_{res}$ 一個，無法同時零化三個表面。**正確的校正條件為成人骨量平衡**：

$$\frac{d}{dt}\big(A_g f_{bm}\big)=0\ \Longrightarrow\ k_{form}/k_{res}=0.97873$$

校正後：$dr_p=+0.09$、$dr_e=+1.12$ μm/yr，$df_{bm}=+0.025$ pp/yr；24 個月模擬之 BMC 漂移 **−0.027%/yr**、aBMD **−0.028%/yr**（判準 <0.1%/yr）。

> **附帶預測**：aBMD 以約 −0.03%/yr 下降而**骨量完全不變** —— 純粹來自骨膜外擴的 DXA 尺寸假影。此為模型自然產生的臨床已知現象，可作為 V6b 之外的第二個「幾何 vs 密度」佐證。

§8 之 P3 完成判準應由「E0 穩態」改為「**骨量漂移 < 0.1%/yr，且擾動後回復**」。實測：$f_{bm}$ 擾動 −3% 後 10 年回復 0.921→0.934（方向正確、速度緩慢，即 V11 不對稱性）。

### C7.3 M4–M6 改寫為基線相對式

計畫書之絕對式方程配上佔位速率常數（Lemaire/Pivonka 原文未到手），基線幾乎不可能是不動點，E0 會在第一天發散 —— 且發散原因與生物學無關。**故 M4–M6 全部改寫為基線相對式**：每條方程僅保留一個時間尺度常數，形狀函數（Hill 項）完全不變，基線為不動點 by construction。

實測基線 $dy/dt$：M4–M6 全部 $<10^{-14}$，僅結構方程有生理性漂移。

真實速率常數到手後，直接作為時間尺度 $k_R, k_B, k_C$ 代入即可，**無須改寫**。此舉同時減少參數，對 §9 辨識性為淨改善。

### C7.4 已修正的兩個實作缺陷

1. **形成分配漏掉表面積**（`surfaceAllocation`）。§4.2 M7(a) 明訂「由應變梯度**與可用表面積**決定」，但初版僅用劑量，使骨膜（約 5% 表面積）分到 35% 的形成量，產生失控的骨膜外擴而淹沒其他行為。修正為 $\eta_j\propto A_j\,D(\varepsilon_j)$ 後，$\eta/\xi=[1.071,\,0.952,\,1.036]$ —— 高應變表面獲得相對較多形成，**這才是 mechanostat 的正確表現**。
2. **`makeContext` 的正規化參考點錯誤**。原將 $D_{eff,0}$ 正規化到**該情境自己**的基線劑量，使每個情境都從 $\hat D=1$ 出發 —— 阻力訓練與臥床會產生完全相同的反應。此缺陷曾使 36 與 1200 循環的骨反應數值完全相同。已改為固定的標準情境（久坐、未適應幾何）。

---

*文件結束｜v1.7（P3 生物模組 + C6.5 檢定通過）｜2026-07-24*
