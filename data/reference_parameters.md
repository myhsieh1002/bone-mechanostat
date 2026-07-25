# 文獻參數抽取紀錄

從 `Reference/` 的原文 PDF 逐一抽取。**這是原始轉錄，供 CSV 回填與日後高保真版本參考。**
本模型（M4–M8 為基線相對式）之結構較原文簡化，故並非所有參數都能 1:1 對應 —— 對應關係在每節說明。

---

## Pivonka et al. 2008, *Bone* 43(2):249–263（`Reference/02.pdf`）
### Table 3 — Model parameters used for bone-cell dynamic model

| 符號 | 值 | 單位 | 說明 |
|---|---|---|---|
| D_OBu | 7.000×10⁻⁴ | [pM OBu]/day | Differentiation rate of OB progenitors |
| D_OBp | **5.348×10⁰** | [pM OBp]/day | Differentiation rate of responding OB |
| A_OBa | 1.890×10⁻¹ | [pM OBa]/day | Rate of elimination of active OB |
| D_OCp | **2.100×10⁻¹** | [pM OCp]/day | Differentiation rate of OC precursor |
| A_OCa | 7.000×10⁻¹ | [pM OCa]/day | Rate of OC apoptosis caused by TGF-β |
| K_D1,TGF-β = K_D3,TGF-β | 4.545×10⁻³ | pM | Activation coeff, TGF-β binding on OBu and OCa |
| K_D2,TGF-β | 1.416×10⁻³ | pM | Repression coeff, TGF-β binding on OBp |
| K_D4,PTH = K_D5,PTH | 1.500×10² | pM | Activation coeff, RANKL production ← PTH binding |
| K_D6,PTH = K_D7,PTH | 2.226×10⁻¹ | pM | Activation coeff, RANK production ← RANKL binding |
| K_D8,RANKL | 1.306×10¹ | pM | Activation coeff, RANKL binding to RANK |
| RANK | 1.000×10¹ | pM | Fixed concentration of RANK |
| R1_RANKL, R2_RANKL | 3.000×10⁶ | – | Max # RANKL per cell surface (scaled to MS1) |
| β_RANKL | 1.684×10⁴ | [pM RANKL]/[pM cell] | Production rate of RANKL per cell |
| D_RANKL | 1.013×10¹ | [pM RANKL]/day | Rate of degradation of RANKL |
| D_OPG | 3.500×10⁻¹ | [pM OPG]/day | Rate of degradation of OPG |
| β_1,OPG, β_2,OPG | 1.464×10⁸ | [pM OPG]/[pM cell] | Min production rate of OPG per cell (MS1) |
| OPG_max | 2.000×10⁸ | pM OPG | Max possible OPG concentration |
| K_A1,RANKL | 1.000×10⁻³ | [pM OPG]⁻¹ | Association binding constant RANKL–OPG |
| K_A2,RANKL | 3.412×10⁻² | [pM RANKL]⁻¹ | Association binding constant RANKL–RANK |
| D_PTH | 8.600×10¹ | [pM PTH]/day | Rate of degradation of PTH |
| β_PTH | 2.500×10² | [pM PTH]/day | Rate of synthesis of systemic PTH |
| D_TGF-β | 1.000×10⁰ | /day | Rate of degradation of TGF-β |
| α | 1.000×10⁰ | % | TGF-β content stored in bone matrix |
| K_res | 1.000×10⁰ | % | Relative rate of bone resorption (normalised) |
| K_form | 1.571×10⁰ | % | Relative rate of bone formation (normalised) |

**對應到本模型 M6（`boneCellPopulation`）**：M6 為 Lemaire 結構的基線相對式，D_R/D_B/D_C 為 R/B/C 的時間尺度常數。

| 本模型 CSV | Pivonka 符號 | 舊佔位值 | 新值 | 說明 |
|---|---|---|---|---|
| `D_R` | D_OBu | 7.0e-4 | 7.0e-4 | ✓ 相符 |
| `D_B` | D_OBp | 7.0e-4 | **5.348** | ⚠️ 差 ~7600×，佔位值嚴重錯誤 |
| `D_C` | D_OCp | 2.1e-3 | **0.210** | ⚠️ 差 100×，佔位值嚴重錯誤 |
| `D_A` | A_OCa | 0.7 | 0.7 | ✓ 相符 |
| `k_B` | A_OBa | 0.189 | 0.189 | ✓ 相符 |
| `C_s_TGF` | K_D1,TGF-β | 5.0e-3 | 4.545e-3 | 近似，改用原文活化係數 |

> **結構性重點（解決 C8.3）**：Pivonka/Lemaire 模型中，PTH **只經 PTH→RANKL 一條路徑**作用（K_D4,PTH），**沒有 PTH→SOST 抑制路徑**。故持續性 PTH 在原文模型中必然為異化（osteoclast 主導）。本模型 M4 額外加了 PTH→SOST 抑制（`f_pth`），這條路徑使持續 PTH 變合成 —— 這正是 C8.3 方向錯誤的來源。修法：PTH→SOST 的強度（`K_P_sost`）必須遠弱於 PTH→RANKL（`lambda_P`），或僅在間歇性 PTH 下生效。

> **RANKL/OPG 軸**：Pivonka 用顯式結合動力學（K_A1, K_A2, β_RANKL, D_RANKL...），本模型 M4 將其收攏為 Hill 函數（`lambda_S`, `K_L`, `kappa_OPG`, `K_L3`）。**非 1:1 對應**，不直接回填；接回完整 RANKL/OPG 軸需俟 Lemaire 2004（#1）原文與模型重構，屬 P5+ 選擇性工作。

---

## Peterson & Riggs 2010, *Bone* 46(1):49–63（`Reference/03.pdf`）
### Table 1 — Initial conditions（set-points / baseline）

28-ODE PK/PD 模型（Berkeley Madonna, RK4）。與骨相關者以相對（unitless）表示。

| Site | Compartment | Eq# | 初值 | 單位 |
|---|---|---|---|---|
| Gut | Ca | 1 | 1.3 | mmol |
| | Calcitriol-dependent Ca absorption | 2 | 0.5 | unitless |
| | PO4 | 3 | 0.839 | mmol |
| Vasculature | **Ca** | 4 | **32.9** | mmol |
| | PO4 | 5 | 16.8 | mmol |
| | Calcitriol | 6 | 1260 | mmol |
| | **PTH** | 7 | **53.9** | mmol |
| Intracellular | PO4 | 8 | 3226 | mmol |
| Kidney | 1-alpha-OH | 9 | 126 | mmol/h |
| PT gland | PT pool | 10 | 0.5 | unitless |
| | PT max capacity | 11 | 1 | unitless |
| Bone | **Ca immediately exchangeable (IC)** | 12 | **100** | mmol |
| | **Ca non-IC** | 13 | **24900** | mmol |
| | PO4 IC / non-IC | 14/15 | equimolar to Ca | mmol |
| | Responding osteoblast | 16 | 0.00104122 | unitless |
| | Osteoblast | 17 | 0.00501324 | unitless |
| | Osteoclast | 18 | 0.001154 | unitless |
| | Latent / Active TGF-β | 19/20 | 228.1 / 0.2281 | unitless |
| | RANK / RANKL / OPG | 21/22/23 | 10 / 0.4 / 4 | unitless |

### Table 2 — 非 Hill 參數（節選與 M8 相關者）

| 參數 | 值 | 單位 | | 參數 | 值 | 單位 |
|---|---|---|---|---|---|---|
| k_3-4 | 0.0495 | h⁻¹ | | k_7D (PTH 降解) | 7.143 | h⁻¹ |
| k_3-5 | 0.365 | h⁻¹ | | k_9D | 0.05 | h⁻¹ |
| k_4-12 | 3.667 | mmol/h | | GFR | 6.0 | L/h |
| k_5-8 | 51.8 | h⁻¹ | | V_vasc | 14 | L |
| k_6-5 | 0.01927 | h⁻¹ | | V_ic | 32.3 | L |
| k_6D | 0.1 | h⁻¹ | | V_bone | 46.4 | L |
| D(1) 腸 Ca 攝入 | 1.0 | mmol | | F_1 | 0.7 | – |

**對應到本模型 M8（`calciumPTHvitD`）**：本模型 M8 為簡化的基線相對式（血鈣 QSSA + 正規化 PTH/1,25D），與 28-ODE 全模型非 1:1。可提取的量：

- **血清總鈣基線** = 32.9 mmol / V_vasc 14 L = **2.35 mmol/L**（游離鈣約其半，1.2 mmol/L，與本模型 `Ca_s_0=1.2` 相容）。
- **骨鈣庫巨大**：immediately-exchangeable 100 mmol + non-IC 24900 mmol ≫ 血管 32.9 mmol（比值 ~760×）。**這是血鈣被嚴格恆定的物理根源** —— 支持本模型 v1.8 收緊血鈣恆定的決定（C8.1）。
- **PTH 週轉快**：k_7D = 7.143 h⁻¹ → 半衰期 ln2/7.143 = 5.8 min。本模型 `delta_P=48/day` (t½≈21 min) 偏慢，可上修。
- **GFR = 6 L/h = 144 L/day**：腎過濾量，供 renal 項校準。

> **結構性重點（確認 C8.3）**：正文明確記載 —— *"constantly elevated PTH is known to lead to bone loss because of markedly elevated osteoclast function relative to osteoblast function, whereas [intermittent PTH]... anabolic bone formation."* 兩篇原文一致確認：**持續 PTH = 異化，間歇 PTH = 合成。** 本模型須以參數重現此差異（見上 Pivonka 節）。

---

## 待補：Lemaire et al. 2004（#1，館際服務中）

Pivonka 2008 為 Lemaire 2004 的擴充版，多數 M6 速率常數已可由 Pivonka Table 3 取得（見上）。Lemaire 原文尚需用於：
- 確認 R/B/C 的**基線穩態濃度**（本模型基線相對式已繞過，但接回絕對式時需要）；
- π 反應函數的原始解離常數與 f₀（Pivonka 用 TGF-β 顯式式取代）。

**取得後補**：Lemaire Table 1 之 $C^s$、$k_1..k_6$、RANK 固定濃度、以及 R/B/C 穩態值。

---

*抽取者：Claude（Opus 4.8）｜2026-07-25｜原文 PDF 存於 `Reference/`*
