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

## Lemaire et al. 2004, *J Theor Biol* 229(3):293–309（`Reference/10.pdf`）

全文於 2026-07-28 取得（館際借閱，RapidILL #-27166587）。以下逐字抄自附錄 A.2 與 A.3 之參數表。

### A.2 模型變數與參考值（穩態）

| 符號 | 單位 | 參考值 | 說明 |
|---|---|---|---|
| R | pM | **0.0007734** | Responding osteoblasts |
| B | pM | **0.0007282** | Active osteoblasts |
| C | pM | **0.0009127** | Active osteoclasts |

### A.3 參數表（節錄與本模型相關者）

| 符號 | 單位 | 值 | 說明 |
|---|---|---|---|
| C^s | pM | 5 × 10⁻³ | Value of C to get half differentiation flux |
| D_A | day⁻¹ | **0.7** | Rate of osteoclast apoptosis caused by TGF-β |
| d_B | day⁻¹ | 0.7 | Differentiation rate of responding osteoblasts |
| D_C | pM·day⁻¹ | **2.1 × 10⁻³** | Differentiation rate of osteoclast precursors |
| D_R | pM·day⁻¹ | **7 × 10⁻⁴** | Differentiation rate of osteoblast progenitors |
| f₀ | 無因次 | 0.05 | Fixed proportion |
| K | pM | 10 | Fixed concentration of RANK |
| k₁ | pM⁻¹day⁻¹ | 10⁻² | OPG–RANKL binding |
| k₂ | day⁻¹ | 10 | OPG–RANKL unbinding |
| k₃ | pM⁻¹day⁻¹ | 5.8 × 10⁻⁴ | RANK–RANKL binding |
| k₄ | day⁻¹ | 1.7 × 10⁻² | RANK–RANKL unbinding |
| k₅ | pM⁻¹day⁻¹ | 0.02 | PTH binding with its receptor |
| k₆ | day⁻¹ | 3 | PTH unbinding |
| k_B | day⁻¹ | **0.189** | Rate of elimination of active osteoblasts |
| k_O | day⁻¹ | 0.35 | Rate of elimination of OPG |
| k_P | day⁻¹ | 86 | Rate of elimination of PTH |

其中 `D_B = f₀ · d_B = 0.05 × 0.7 = 0.035`（A.3 定義 `DB = f0·dB`）。

### 對本模型的三項結論

**1. `R_0` 是抄錯的（已於 v2.15 更正）。** CSV 原寫 7.0 × 10⁻⁴，原文是 **7.734 × 10⁻⁴**，差 10.5 %。7 × 10⁻⁴ 正好是同表 `D_R` 的值 —— 幾乎可以確定是抄成隔壁那一列。`B_0` 與 `C_0` 原為四捨五入值（7.3e-4、9.1e-4），現改為原文精確值。

> ⚠️ **但這三個參數在程式碼中從未被任何地方讀取**（`grep -rn "p\.R_0\|p\.B_0\|p\.C_0" src/` 無結果）。M6 的 R/B/C 是基線相對式（基線恆為 1），故絕對濃度只作為出處紀錄。**因此這個更正不改變任何數值結果**，但它與 `renal_k`/`renal_Ca_th`（P5k 前）同屬「宣告了卻沒被讀」的一類，值得一併記住。

**2. `D_A = 0.7` 與 `k_B = 0.189` 由「佔位值與原文相符」升級為對照原文查證無誤。**

**3. `D_B`、`D_C`、`C_s_TGF` 的 Lemaire 值與我們採用的 Pivonka 值不同，這是預期的，不要「修正」。**

| | Lemaire 2004 | Pivonka 2008（本模型採用） |
|---|---|---|
| D_B | 0.035（= f₀·d_B） | 5.348 |
| D_C | 2.1 × 10⁻³ | 0.210 |
| C_s | 5 × 10⁻³ | 4.545 × 10⁻³ |

Pivonka 2008 是 Lemaire 的擴充版，改用不同的無因次化與 TGF-β 顯式式，故速率常數不可逐項對應。**v1.9 曾把 D_B 由 7e-4 改為 5.348、D_C 由 2.1e-3 改為 0.210，兩者都是刻意改用 Pivonka 的參數化，不是修正筆誤。** 若日後有人拿 Lemaire 原文來「訂正」這兩個值，會把模型改壞。

**4. π 反應函數的原始形式已取得**：`p_C = (C + f₀·C^s)/(C + C^s)`、`p_L = K_dL/K`，其中 `K_dL/K = (k₃/k₄)·…`。本模型的 `pi_L = L/(K_L3 + L + κ_OPG·O)` 是 Pivonka 的形式，非 Lemaire 的，故 `K_L3` 與 `κ_OPG` 仍須取自 Pivonka 原文（全文已有，見上）。

---

## 附記：v2.15 從既有全文結清的五個參數

以下五個參數的說明原本寫著「Awaits …」或「Must be taken from the source full text」，暗示只是還沒去查。實際查完之後，**只有一個真的是查得到的數，另外四個都是問錯了問題**。

| 參數 | 原本狀態 | 結清後 |
|---|---|---|
| `K_VD` | Awaits Peterson & Riggs 2010 | ✅ **確認 = 1.0**。P&R Table 1 的「Calcitriol-dependent Ca absorption」基線為 **0.5 (unitless)**；本模型的吸收閘為 `V_D/(K_VD + V_D)`，在 `V_D_0 = 1`、`K_VD = 1` 時恰為 0.5。**原值由假設升格為文獻確認** |
| `P_max` | Awaits Peterson & Riggs 2010 | ❌ **問題本身無效**。`Pset` 已正規化為基線 = 1，整體分泌尺度是規範自由度（gauge），無可觀測後果；而且**程式從未讀取它** |
| `k_VD` | Awaits Peterson & Riggs 2010 | ❌ 同上。`VDset` 正規化、趨近速率由 `delta_VD` 承擔，此尺度亦為 gauge，**程式從未讀取** |
| `K_L3` | Must be taken from the source full text | ⚠️ **收斂到「只剩一個未知數」，但未解**（見下） |
| `kappa_OPG` | 同上 | ⚠️ 同上 |

### K_L3 與 kappa_OPG：為何全文在手仍解不出來

本模型 M4 用集總 Hill 式：

```
pi_L = L / (K_L3 + L + kappa_OPG · O)      （L、O 皆基線正規化為 1）
```

Pivonka 與 Lemaire 都用**顯式競爭結合**，其佔有率為

```
[L] / (1/K_A2 + [L] + (K_A1/K_A2)·[O])
```

兩篇的結合常數**互相吻合**（Pivonka 的 K_A1、K_A2 就是 Lemaire 的 k₁/k₂ 與 k₃/k₄）：

| | 值 | 來源 |
|---|---|---|
| K_A2（RANKL–RANK 結合） | **3.412 × 10⁻² pM⁻¹** | Pivonka Table 3；Lemaire k₃/k₄ = 5.8e-4 / 1.7e-2 |
| K_A1（RANKL–OPG 結合） | **1.0 × 10⁻³ pM⁻¹** | Pivonka Table 3；Lemaire k₁/k₂ = 1e-2 / 10 |

故以 pM 計，`1/K_A2 = 29.31 pM`。但我們的 L、O 是**基線正規化**的，換算為

```
K_L3      = 1 / (K_A2 · L₀)
kappa_OPG = K_L3 · K_A1 · O₀
```

**兩篇的表都沒有給出可相容單位的基線 RANKL 濃度 L₀ 與 OPG 濃度 O₀**（P&R Table 1 給 RANKL = 0.4、OPG = 4，但標為 unitless；Pivonka Table 3 不列穩態值）。

**因此這不是「還沒去查」，而是「剩一個未知數」。** 文獻真正約束住的是**比值**：

```
kappa_OPG / K_L3 = K_A1 · O₀
```

現行值 `K_L3 = kappa_OPG = 1` 等於在主張 **O₀ ≈ 1000 pM**。這是一個具體、可被未來文獻檢驗的宣稱 —— 日後若取得任何給出基線 OPG 絕對濃度的來源，直接對照這個數即可。

> **教訓**：「Awaits <文獻>」這種註記本身要定期複查。五筆裡只有一筆是真的在等文獻；兩筆問的是規範自由度（不可能有答案），兩筆需要的是原文沒提供的量。**寫下待辦時要寫清楚缺的到底是什麼。**

---

## v2.15 新到全文：a02–a11（2026-07-28）

主持人取得 10 篇，依 `docs/literature_to_obtain.md` 的編號命名（`Reference/aNN.pdf`）。**目前只缺 a01（Fu 2025）與 a06b（Martin 1984）。**

### 已據以修正標的定義的兩篇

**a02 = Wijenayaka 2011（PMID 21991382）—— V13 的「約 7 倍」被我們比錯對象**

原文摘要與 Results 明載：該 7 倍是**破骨吸收**（100 ng/ml rhSCL、骨細胞–脾細胞共培養 14 天後的吸收凹陷面積），另有凹陷平均大小增加 2–2.6 倍。**那不是我們拿去比對的瞬時 `pi_L` 活化項。**

- 直接可比的分子量是 **RANKL:OPG 比值**，原文報告其隨劑量上升；本模型給 **2.9 倍**（RANKL 1.00→1.29、OPG 1.00→0.44）。
- `pi_L` 的 1.33 倍硬性天花板是真的算術，但它回答的是原文沒問的問題。
- **這是「拿錯對比」，而且是我們自己犯的** —— 與 C24/C25 抓到的同一類。標的須改以吸收輸出評分（待辦）。

**a07 = Srinivasan 2002（PMID 12211431）—— V5 的「2–5 倍」是我們自己編的**

原文（火雞尺骨，峰值應變 820–830 με）：插入休息者骨膜標記表面 **21.9 %**，未插入者 **3.8 %**，即 **5.8 倍**（p = 0.03）。

我們一直用的 2–5 倍區間**從來不是原文的數字**。模型的 13.99 倍仍然過衝，但是對 5.8 倍過衝 **2.4 倍**，而非對一個虛構上界過衝 2.8 倍。

### 已取得、尚未榨乾的八篇

| 檔案 | 文獻 | 待抽取 | 備註 |
|---|---|---|---|
| `a03.pdf` | Haapasalo 2000 | `r_p_0`、`r_e_0` | ⚠️ **六項 V6 百分比區間已確認與我們的標的完全相符**（BMC 14–27 %、Tot.Ar 16–21 %、Co.Ar 12–32 %、I_max 27–67 %、M.Cav.Ar 19 %、Co.Dn −2 %）。但**絕對的 Tot.Ar / M.Cav.Ar 值在 Figure 1 的長條圖裡，文字層抽不出來** —— 需目視讀圖，故 `r_p_0`/`r_e_0` 仍為推算值 |
| `a04.pdf` | Li 2019 | `tau_50`、`k_tau_sig` | 未抽取 |
| `a05.pdf` | Weinbaum 1994 | `k_perm`、`S_stor`、`a_canal`、`Gamma_PCM` | 未抽取（22 頁）。可望把 `K_tau` 由標定改推導 |
| `a06a.pdf` | Lerebours 2015 | `S_v(f_bm)` 真形式 | 未抽取。**最關鍵**：皮質與小樑不可共用一條曲線 |
| `a08.pdf` | Currey 1988 | `kappa_E`、`nu_E` | 未抽取。`kappa_E` 是 E6 關鍵參數 |
| `a09.pdf` | Cosman 2016 | romosozumab 逐月軌跡 | 未抽取。對現在未達的 V16 有用 |
| `a10.pdf` | Marques 2023 | V5b 定量頻率曲線 | 未抽取 |
| `a11.pdf` | Schulte 2026 | V12 定量交互作用 | 未抽取 |

> **教訓（第三次）**：a02 與 a07 都顯示，**我們自己寫下的標的可能誤述了原文**。「取得全文」的第一件事不是抽參數，而是**核對我們宣稱該文獻說了什麼**。V5 的區間是憑空的，V13 比的是不同的量 —— 兩者都在原文到手後五分鐘內就露餡。

---

*抽取者：Claude（Opus 4.8）｜2026-07-25｜原文 PDF 存於 `Reference/`*
