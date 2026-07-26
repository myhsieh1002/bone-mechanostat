# 骨重塑力學生物學多尺度數學模型
## Mechanotransduction-Coupled Multiscale Model of Bone Remodeling
### 研究計劃書 (Research Proposal & Implementation Plan for Claude Code)

**主持人**：謝明諭 (Ming-Yu Hsieh), MD, PhD
中山醫學大學醫學系副主任｜中山醫學大學附設醫院小兒外科主任、實證醫學中心主任
ORCID: 0000-0002-5797-3474｜myhsieh@me.com

**版本**：v2.8｜**日期**：2026-07-26｜**實作語言**：MATLAB (R2026a)｜**執行者**：Claude Code

> **v2.8 變更摘要（P5d 小樑腔室）**：新增 `trabecularParams.m` —— 由皮質參數集導出腰椎小樑腔室，**生物學完全不動**（`siteRHS` 仍單一真相源），僅覆寫結構／幾何／載荷。免費一致性檢核：共用的 `E_ref`、`kappa_E` 代入 BV/TV=0.12 得 **E_app=99.8 MPa**，正落在椎體小樑實測區間（50–300 MPa）。**發現兩個結構性約束**：(1) **共用訊號鏈強迫兩腔室坐落同一剪應力設定點** —— 椎體 2773 με vs 皮質 762 με，故 `K_tau` 必須不同（由匹配導出，非擬合）；(2) Frost 的 MES_m 是應變閾值，沿用皮質值會使 modeling 在小樑腔室永久開啟；(3) 周轉不校正則為 438 %/yr，故 `k_res` 校至小樑自身標的（20 %/yr），**V8/V10 仍為 hold-out**。**結果：3.6 倍放大確認（V8 皮質 +1.25% → 小樑 +4.47%），但未達 +11–14%。診斷推翻 P5d 前提 —— BV/TV 不是槓桿**（0.06–0.15 全區間 V8 平坦於 4.33–4.59%）。真正槓桿是 **`delta_ab`**（×2.5–3 可達標，**且同時使 V10 翻為正確負號**），而其現值正是 P4 對著 C14 已證為假影的 V8 擬合出來的 —— 重擬是修復已知缺陷，列為 **P5g（目前價值最高的單一動作）**。72 測試全過。詳見附錄 C19。
>
> **v2.7 變更摘要（E0–E6 實驗與論文圖）**：七支實驗腳本由骨架變為可執行，各產出一張論文圖（含新的 `houseColors.m`）。**P1 前兩句量化成立**（鈣邊際 +0.470% < 1%；負荷邊際 +5.565% > 4%；比值 11.8×），但**第三句「協同」的兩種框架符號相反** —— 絕對框架成立（缺鈣使負荷所能建的骨少 15%），差異中的差異框架反轉（−0.557 個百分點），因為缺鈣讓久坐比較組掉更快；**論文須採絕對框架並說明**。**V5 由否轉是**：休息插入增益隨幅值遞減（11.08×→1.07×），即 Srinivasan 方向，C6.4 的通道層級反向由下游飽和翻正，**風險解除**。**V5b 降級**：ln f 的形式傳到骨層級但**符號翻轉**（r=−0.998，等時長對照同號），機制為 `k_co(τ)` 飽和，與 Hsieh & Turner 相反 —— 只能宣稱到剪應力層級，列為 Fu 2025 首要複驗。**V9 弱形式成立、強形式不成立**；**V12 次相加 7.7%**（共用 SOST→Wnt 節點）；**V3 +48.8%** 首次定量成立；**V6e 髓腔方向相反**（M7 的 `r_e` 缺口）。E3 最小有效劑量：16 min/day 可防 48% 流失，但**預算內無處方能壓到 0.25 %/mo 以下**。E6 重製並標註 f_bm<0.391 為彈性域外。詳見附錄 C18。
>
> **v2.6 變更摘要（P5e：modeling 飽和界 ＋ 彈性有效域守衛）**：修掉 C15.4 的 99 mm 皮質假影（線性 modeling 項在病理態要求 **1513 mm/yr** 骨膜沉積）。modeling 改為飽和形式，新參數 `eps_model_sat=5.5e-3` 由**兩個獨立論證收斂**（半飽和處總應變＝降伏應變 7000 με；隱含速率上限 1.93 μm/day 落在編織骨 MAR 區間）。**V6 盲測在未重校下存活，且 BMC(+25.8%)、I_max(+31.8%) 反而落回 Haapasalo 原始區間**；校正情境低於閾值故逐字不變。**關鍵發現：飽和界必要但不充分** —— 它不移動不動點（20 年仍到 22.5 mm），故補上第二道防線 `out.validity`（`eps_elastic_max=7000 με` 線性彈性有效域）。守衛抓到兩個既有問題：bedrest 超過 ~7.5 個月塌到孔隙率地板（V2 的 180 天視窗仍有效）、**C15 分歧圖 f_bm<0.391 的深端超出自身有效域**。**成果：首次取得全程有效且不凍結幾何的遲滯探針 —— f_bm 0.95→0.40→0.9485（回復 99.8%），無遲滯，P3 否證獲第二條獨立佐證。** 67 測試全過（新增 `test_modeling.m` 6 項）。詳見附錄 C17。
>
> **v2.5 變更摘要（P3 敘事改寫，純文件）**：C15 判定 P3 否證後，計畫書的前瞻性章節仍寫著「模型**應**出現鞍結點分歧與雙穩態」，全文對 P3 有兩種相反說法。本版統一為單一說法：**P3 已否證；改寫後的預測是「骨鬆為單一平衡點對雌激素的陡峭但連續位移（臨界 E2≈0.92），非雙穩態；不可逆性來自結構／模板層級喪失」**。改動 §0 預測 3、§3 創新 N4、§4.2 M5 正回饋註、§5 E6、§6 V11 詮釋、§8 P6 判準、§10 論文敘事定調、附錄 C14 之 K_S 註。確立三條措辭紀律：**陡峭≠雙穩、速率不對稱≠動力學不可逆、否證入主論文**。不動程式碼，61 測試不受影響。詳見附錄 C16。
>
> **v2.4 變更摘要（P6 分歧分析）**：以凍結幾何之 f_bm nullcline + `steadyState`/`continuation` 做分歧分析。**P3（骨鬆為替代穩態）不成立 —— 模型單穩**：單一不動點隨雌激素陡峭但連續位移（臨界 E2≈0.92），無鞍結點/雙穩/遲滯。tau_50、beta_S 亦單穩。基線為穩定不動點（max Re λ<0）。過程中攔下一個 modeling 項幾何吹爆（皮質厚 99mm）的數值假影，差點誤判 P3 成立。三大預測：P1✅ P2✅ P3❌(否證)。61 測試全過。詳見附錄 C15。
>
> **v2.3 變更摘要（P5b+P5c 完成 — 里程碑）**：實作兩結構修正 —— intensive 礦化 ODE（rho_min 隨形成下降，狀態 17→16/31→29）＋ Frost modeling 項（劇烈負荷驅動骨膜外擴，有應變閾值，正常活動不啟動）。重校 2 參數（K_S, mu_turn_0）對 V1/V2/V7。**V6（網球，hold-out 盲測）湧現**：vBMD +1.28%、Tot.Ar +12%、Co.Ar +27%、I_max +36%、BMC +28% —— Haapasalo「幾何增益、密度不變」型態，未被擬合。**部位專一性 P2 定量成立**。V8/V10 重定位為小樑/脊椎範疇（舊「通過」為礦化假影）。58 測試全過。詳見附錄 C14。
>
> **v2.2.1 變更摘要（P5b 礦化診斷）**：研究修 M7 達 V6f。確立正確礦化模型（intensive rho_min ODE，rho_min 隨形成下降），實證其把 V6f 密度側由 +8.5% 降至 +0.7%（達標）。**但 V6f 需兩個獨立實質修正**：礦化 ODE（破壞 V8/V10，需併同開放礦化時間尺度重校）＋ 骨膜形成分配（需力學鏈不飽和的重新校正）。為維持 v2.2 已校正態（57 測試），探索性程式碼**已回退**，僅存診斷結論（附錄 C13）。分 P5b(續)/P5c 兩階段後續。
>
> **v2.2 變更摘要（P5 雙腔室）**：實作雙腔室網球模型驗證預測 P2。**P2 定性成立**：局部負荷造成部位差異（打球側 BMC +9.4%），全身介入不造成不對稱（−0.0000%）。抽 `siteRHS` 為單站生物學單一真相源，`rhsFull`/`rhsTwoSite` 共用。**V6f（幾何 vs 密度）未達 —— 揭露 M7 一個真問題**：負荷增益走密度而非幾何，追因為礦化耦合（rho_min 隨形成上升，方向錯誤）＋形成分配誤用吸收面。已試作修正因破壞單站校正而回退，列 P5b 專項。57 測試通過。詳見附錄 C12。
>
> **v2.1 變更摘要（辨識性分析）**：補實 §9 風險 1。以二維 χ² 圖分析相關對 (K_P_sost, lambda_P)、一維掃描其餘三參數。結果：**k_res/K_S/delta_ab 個別可辨識**（各由 V1/V2/V8 釘住）；**(K_P_sost, lambda_P) 為相關對**（脊相關 r=−0.89，個別觸界但聯合有界的對角帶）—— 正如 C10.5 所疑，但非病態：hold-out 通過證明校正點落於脊上有效位置。處置：由獨立文獻固定其一，或報告聯合信賴區。詳見附錄 C11 與 `results/figures/identifiability.png`。
>
> **v2.0 變更摘要（P4 正式校正 — 里程碑）**：完成 P4 正式校正 pass。5 個自由參數（k_res, K_S, K_P_sost, lambda_P, delta_ab；k_form 由骨量平衡導出）以 surrogateopt 對 V1/V2/V7/V8 擬合，**全數達標**。關鍵：**2 個 hold-out 盲測（V10 停藥回落、V14 湧現 ε\*）未參與擬合卻自動通過** —— 預測力的直接證據。**使用者的原始問題現在有完整量化解答**：補鈣使 aBMD +0.97% 且一年達平台（符合 Tai 2015），方向正確（PTH 經 RANKL 主導，與 Lemaire/Pivonka 一致）。53/53 測試通過。詳見附錄 C10。
>
> **v1.9 變更摘要（Tier 1 文獻回填）**：取得 Pivonka 2008（#2）與 Peterson & Riggs 2010（#3）全文，參數逐表轉錄於 `data/reference_parameters.md`。修正 M6 兩個嚴重錯誤的佔位速率（D_B 差 7600×、D_C 差 100×）。**植入真實速率後 V7 平台如 C8.2 診斷所預測地出現**（斜率 5 年衰減至 0.27%/yr）；**V7 方向可經 PTH→SOST/PTH→RANKL 平衡翻轉**，與兩篇原文「無 PTH→SOST 路徑、持續 PTH 為異化」一致，C8.3 解決路徑確立。測試維持 45/45。詳見附錄 C9。
>
> **v1.8 變更摘要（P4 系統耦合結構）**：M8 鈣–PTH–1,25D 實作並接上雙向耦合，M1–M8 全模型 45/45 測試通過，基線為精確不動點。**P4 結構完成且數值穩健，但 P4 的科學結論（V7）阻塞於 Tier 1 文獻**，與附錄 B0 預期一致。兩個結構性發現：血鈣恆定機制已修正（漂移 55%→7.7%，待校正收緊）；V7 平台結構上支援得了但力學回饋 vs PTH–SOST 增益尚未調平，且持續 PTH 的合成/異化方向待 Pivonka 2008 校正裁決。詳見附錄 C8。
>
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
3. **P3 — 骨質疏鬆的動力系統本質：陡峭連續轉變，而非替代穩態**（**v2.5 依 P6 結果改寫；原假說已否證**）。
   **原假說（v1.3–v2.4）**：以 Piezo1 力學敏感度 $\tau_{50}$、SOST 基礎分泌率 $\beta_S$ 與雌激素 $E_2$ 為分歧參數，模型應出現**鞍結點分歧 (saddle-node bifurcation)** 與雙穩態，對應臨床「骨質流失快、回補慢」的不對稱性；機制來源為兩個正回饋（$S_v\to0$、$n_{ot}\downarrow$）。
   **P6 的嚴格分歧分析否證了這個假說 —— 校正後的模型為單穩**（附錄 C15）。
   **改寫後的預測（這才是本計畫要發表的 P3）**：在完整的力學傳導 mechanostat 框架下，骨質疏鬆是**單一平衡點對雌激素的陡峭但連續的位移** —— $f_{bm}^*$ 隨 $E_2$ 由 0.98（健康）連續下移至 0.09（骨鬆），過渡集中於臨界 $E_2\approx0.92$，**無鞍結點、無雙穩、無遲滯**（$\tau_{50}$、$\beta_S$ 亦同）。其機制是：低 $f_{bm}$ → $E_{app}=E_{ref}f_{bm}^{\kappa}$ 驟降 → 應變暴增 → 力學劑量升高並啟動 Frost modeling → **強力恢復驅動壓過 $S_v$ 與 $n_{ot}$ 兩個正回饋**，故不存在自我維持的骨鬆吸引子。
   **由此導出的推論比原假說更強、也更可證偽**：臨床骨鬆的不可逆性**不能**由孔隙率重塑動力學的雙穩性解釋，必然來自本模型尚未涵蓋的機制 —— **小樑穿孔造成的模板喪失**（連續 $f_{bm}$ 描述在原理上無法捕捉）、**骨細胞死亡**、或**幾何退化**。這是一個明確界定 mechanostat 框架解釋力邊界的結果，並直接指向可檢驗的後續假說。

（P3 的分析架構與主持人先前 HFpEF 動力系統研究 [bifurcation of HFpEF heterogeneity] 一脈相承，共用同一套 `steadyState`/`continuation` 程式基礎設施；本模型得到單穩結論，正說明該架構同時能給出正面與負面判決。）

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
| **N4（v2.5 依 P6 結果修訂）** | 對 mechanostat 設定點做**分歧分析**，並**檢定**（而非僅提出）「骨質疏鬆為替代穩態」的動力系統假說。結果為**否證**：模型單穩，力學負回饋壓過 $S_v$ 與 $n_{ot}$ 兩個正回饋。創新因此改為一個**帶界定的負結果**：首次在機制解析的 mechanostat 模型中證明，骨鬆的不可逆性**不可能**源自孔隙率重塑動力學的雙穩性，必來自結構層級的模板喪失。此判決在既有的現象學 mechanostat 模型中無法作出（它們沒有完整的力學回饋鏈可供檢定） |

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
>
> **⚠️ v2.4 實測裁決**：這場競爭已由 P6 分歧分析判出勝負 —— **在校正參數下力學負回饋壓過此正回饋，系統單穩**。掃描回饋強度 $\zeta\in[1.5,5]$ 亦未出現 S 型 nullcline。故本項機制**存在但不足以**造成雙穩態。詳見附錄 C15 與 §0 的 P3 改寫。

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
| **E6** | 分歧與靈敏度 | **分歧參數改為 $\tau_{50}$（Piezo1 半活化）、$\beta_S$（SOST 基礎分泌率）、$E_2$** 做 continuation；另掃描正回饋強度 $\zeta$；LHS + Sobol 全域靈敏度 (N=10,000) | ✅ **continuation 部分已完成（P6）：P3 否證，模型單穩**（$E_2$、$\tau_{50}$、$\beta_S$、$\zeta\in[1.5,5]$ 皆單穩），主要輸出改為**臨界 $E_2\approx0.92$ 的連續轉變曲線**與其陡度。⬜ Sobol/LHS 尚未實作。辨識關鍵參數 (預期 $\tau_{50}$, $k_\tau$, $K_S$, $\lambda_S$, $\zeta$、以及 M1 的 $\kappa$) |

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
| | **⚠️ v2.5 詮釋更正** | P3 否證後，此不對稱**不得再解釋為雙穩態的遲滯**。模型中它是**速率不對稱**（吸收快、形成慢，加上礦化的長時間常數），屬單一吸引子上的緩慢回歸。C7.2 實測（$f_{bm}$ −3% 後 10 年僅回 0.921→0.934）即此。論文須明確區分「速率不對稱」與「動力學不可逆」 | | |
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
| **P6 動力系統分析** | W19–24 | E6：continuation、Sobol、identifiability | ✅ **已完成（continuation + identifiability）**：明確回答 P3 —— **雙穩態不存在，模型單穩**（附錄 C15）。⬜ Sobol 全域靈敏度待補 |
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
   **v2.5 敘事定調**：三個預測依 P1✅／P2✅／P3❌（否證）如實呈現。P3 的否證**寫進主論文**而非隱去 —— 它是全文中唯一一個「模型推翻了自己的先驗假說」的結果，也是預測力（而非擬合力）最有說服力的證據之一。討論段的主軸：mechanostat 的力學負回饋在孔隙率尺度上足以自救，故骨鬆的不可逆性必來自**結構／模板層級**（小樑穿孔、骨細胞死亡、幾何退化），而這正是本模型的下一步（P5d 小樑腔室）。
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

---

## 附錄 C8：P4 系統耦合實作 (2026-07-24)

M8（鈣–PTH–1,25D）實作並接上雙向耦合，M1–M8 全模型可跑。45/45 測試通過。基線為精確不動點（$dCa_s=dP=dV_D=0$）。**但兩個結構性發現決定了 V7 的成敗，且都指向 P4 校正而非結構缺陷。**

### C8.1 血鈣恆定必須夠強（已修正）

初版 M8 讓血鈣在補鈣情境下漂移 **55%**，aBMD 隨之失控（±35%、無平台）。生理上血鈣被 CaSR/PTH 嚴格恆定在 **±2%**。修正的兩個機制：

- **腎排泄對血鈣陡峭**（$n_{renal}\approx8$）：超濾鈣負荷正比 $Ca_s$，加上可飽和小管重吸收，使血鈣略升即大幅清除。
- **副甲狀腺 Hill 陡峭**（$n_P=4$）：血鈣微變即大幅改變 PTH，PTH 再經腎重吸收防禦血鈣。

修正後血鈣漂移降至 **±7.7%**（400→1500 mg 近兩倍攝取範圍）。仍偏大（目標 <2%），但這取決於腸道被動吸收分率 $a_p$ 等**待 Peterson & Riggs 2010 校正**的參數（現值 $a_p=0.15$ 使 1500 mg 產生 225 mg 不受調節的被動吸收，偏高）。血鈣與 PTH 在 0.1 年內達穩態 —— **快子系統運作正確**。

### C8.2 ⚠️ V7 平台尚未出現 —— 力學回饋 vs PTH–SOST 耦合的增益失衡

**這是 P4 最重要的發現。** 血鈣與 PTH 秒級達穩態、細胞族群自限（B、C 有界），**但 aBMD 不平台：低鈣情境 5 年仍以 ~2.5%/yr 攀升**（0.5→5 年：+0.26%→+12.1%，斜率不降反升後緩降）。

機制已精確定位：持續的 PTH 偏移經 $f_{pth}$ 抑制 SOST，產生**持續的形成驅動**。唯一對抗它的是幾何變化的力學負回饋（骨量↑→應變↓→劑量↓→SOST↑），但 $k_{form}\sim10^{-7}$ m/day 使幾何回饋**太慢**，無法在 V7 要求的約 1 年內把應變拉回以 nullify PTH 偏移。B−C 的微小持續失衡遂積分成無止境的 $f_{bm}$ 上升。

$$\text{V7 平台的必要條件：力學回饋增益} \gtrsim \text{PTH→SOST 耦合強度，於 remodeling 時間尺度上}$$

此平衡由 $k_{form}, k_{res}$（V1 周轉率）、$K_{P\_sost}$（PTH→SOST）、$\lambda_P$（PTH→RANKL）共同決定 —— **全部待 Pivonka 2008 與 Peterson & Riggs 2010**。故 V7 的平台形態與幅度**結構上支援得了**（快子系統平衡、細胞自限、力學回饋存在），只是佔位參數下增益未調平。**不以佔位參數強行擬合。**

### C8.3 ⚠️ 持續 PTH 的合成/異化方向（結構性，需校正裁決）

低鈣（400 mg）使 PTH 升至 1.16（正確的續發性副甲狀腺亢進），但淨效果為**骨增益**（B=1.077 > C=1.003），生理上持續性 PTH 升高應為**異化主導**（續發副甲亢致骨流失）。

原因：PTH 經兩條路徑作用 —— (1) $g_P$：PTH↑→RANKL↑→吸收↑（異化，正確）；(2) $f_{pth}$：PTH↑→SOST↓→Wnt↑→形成↑（合成）。佔位參數下路徑 (2) 壓過 (1)。

生理上這正是「PTH 悖論」：**間歇性** PTH 合成主導（teriparatide），**持續性** PTH 異化主導。Pivonka (2008) 明確以參數區分二者，故此方向由 $K_{P\_sost}$ 與 $\lambda_P$ 的相對大小決定，**待 B1 #2 校正裁決**。本模型無間歇/持續之時間區分，若校正後仍無法重現持續 PTH 的異化，則須考慮加入 PTH 暴露時間的區辨機制（列為 P4 校正的檢查項）。

### C8.4 P4 之現況小結

| 項目 | 狀態 |
|---|---|
| M8 結構、雙向耦合 | ✅ 完成，全模型 45/45 測試通過 |
| 基線不動點 | ✅ 精確（<1e-9） |
| 血鈣恆定機制 | ✅ 運作（±7.7%，待校正收緊至 <2%） |
| 快子系統（Ca_s, PTH, 1,25D）穩態 | ✅ 0.1 年內達成 |
| **V7 平台形態** | ⚠️ 結構支援，增益待校正（C8.2） |
| **V7 效應幅度與方向** | ❌ 阻塞於 Pivonka 2008 + Peterson & Riggs 2010 |
| 持續 PTH 異化方向 | ⚠️ 待校正裁決（C8.3） |

**結論**：P4 的**結構**完成且數值穩健，但 P4 的**科學結論（V7）阻塞於 Tier 1 文獻**，與計畫書附錄 B0 的預期一致。取得 Pivonka 2008 與 Peterson & Riggs 2010 後方能校正並裁決 C8.2、C8.3。

---

---

## 附錄 C9：Tier 1 文獻參數回填 — Pivonka 2008 與 Peterson & Riggs 2010 (2026-07-25)

取得 #2 Pivonka 2008 與 #3 Peterson & Riggs 2010 全文（存於 `Reference/02.pdf`、`03.pdf`）。逐張表轉錄於 `data/reference_parameters.md`。#1 Lemaire 2004 仍在館際服務中，但 Pivonka 為其擴充版，多數 M6 速率常數已可由 Pivonka Table 3 取得。

### C9.1 M6 速率常數修正（Pivonka Table 3）

| CSV | Pivonka 符號 | 舊佔位 | **新值** | 誤差 |
|---|---|---|---|---|
| `D_B` | D_OBp | 7.0e-4 | **5.348** | **~7600×** |
| `D_C` | D_OCp | 2.1e-3 | **0.210** | **100×** |
| `D_R` | D_OBu | 7.0e-4 | 7.0e-4 | ✓ |
| `D_A` | A_OCa | 0.7 | 0.7 | ✓ |
| `k_B` | A_OBa | 0.189 | 0.189 | ✓ |
| `C_s_TGF` | K_D1,TGF-β | 5.0e-3 | 4.545e-3 | 近似 |

**兩個佔位值嚴重錯誤**：responding osteoblast 分化（D_B）與 osteoclast precursor 分化（D_C）都比實際慢了 2–4 個數量級。因基線相對式中這些是**時間尺度常數**，不影響不動點，故基線仍精確靜止（實測 M4–M6 dy/dt = 0），但**大幅改變系統響應速度**。

### C9.2 ✅ C8.2 平台問題確認並解決

C8.2 曾診斷「V7 不平台，因力學回饋（幾何變化）太慢，無法在 1 年內對抗持續 PTH 的形成驅動」。植入真實 M6 速率（細胞動力學快 ~7600×）後，**平台如診斷所預測地出現**：

| 時間 | 0.5 yr | 1 yr | 2 yr | 3 yr | 5 yr |
|---|---|---|---|---|---|
| 低鈣 aBMD 斜率 [%/yr] | 15.4 | 8.5 | 2.1 | 0.87 | **0.27** |

斜率單調衰減趨零 —— **C8.2 的診斷正確，佔位速率確為平台被阻的主因。**

### C9.3 ✅ C8.3 方向問題 — 解決路徑確立

**兩篇原文一致**：Lemaire/Pivonka 模型中 PTH **僅經 PTH→RANKL 一條路徑**（無 PTH→SOST），故持續 PTH 必為異化；Peterson & Riggs 正文亦明載「constantly elevated PTH → bone loss... intermittent → anabolic」。

本模型 C8.3 方向錯誤（低鈣→骨增益）的根源即在於 M4 額外加的 PTH→SOST 抑制路徑（`f_pth`）在持續 PTH 下過強。實測削弱該路徑（提高 `K_P_sost`）即翻轉方向：

| K_P_sost | 1.0 | 3.0 | 10 | **30** | 100 |
|---|---|---|---|---|---|
| 低鈣 ΔBMC(2yr) [%] | +17.0 | +8.3 | +1.8 | **−0.81** | −1.83 |

K_P_sost ≥ 30 時低鈣正確產生骨流失，且 K_P_sost=30 之幅度（−0.8%）接近 V7 生理值。**C8.3 的解決路徑確立**：PTH→SOST 須遠弱於 PTH→RANKL（與原文無此路徑一致），確切值待正式校正（連同 V7 幅度）。

### C9.4 Peterson & Riggs（M8）可提取量

M8 全模型為 28-ODE PK/PD，與本模型簡化 M8 非 1:1。已提取並記錄（`reference_parameters.md`）：血清總鈣基線 2.35 mmol/L（游離 ~1.2，與 `Ca_s_0` 相容）；骨鈣庫 25000 mmol ≫ 血管 32.9 mmol（比值 760×，佐證 C8.1 收緊血鈣恆定之決定）；PTH 半衰期 5.8 min（`delta_P` 由 48 上修為 171/day）；GFR 6 L/h。

### C9.5 現況

| 標的 | v1.8 | **v1.9** |
|---|---|---|
| V7 平台形態 | ⚠️ 增益待校正 | ✅ **出現**（C9.2） |
| V7 效應方向 | ❌ 阻塞 | ✅ **可翻轉**，路徑確立（C9.3） |
| V7 效應幅度 | ❌ 阻塞 | ⚠️ 待正式校正（K_P_sost, lambda_P, k_form/k_res） |
| 持續 PTH 異化 | ⚠️ 待裁決 | ✅ **機制與資料確認**（C9.3） |

**測試維持 45/45。** 尚待：#1 Lemaire 2004 全文（R/B/C 基線穩態、π 函數解離常數）；正式校正 pass（開放 4–6 個自由參數對 V1/V7/V8 擬合，hold-out V6/V10/V14）。

---

---

## 附錄 C10：P4 正式校正 — 全模型通過所有標的（含盲測）(2026-07-25)

**里程碑：首個完整校正的模型，53/53 測試通過，5 個校正標的與 2 個 hold-out 盲測全數達標。**

### C10.1 校正設計（遵 §9 紀律）

- **自由參數僅 5 個**（§9 上限 4–6）：`k_res`（V1 周轉）、`K_S`（V2 力學敏感度）、`K_P_sost`（V7 方向/幅度）、`lambda_P`（V7）、`delta_ab`（V8）。`k_form` **非自由**，由 `balanceBoneFormation(p)` 依成人骨量平衡導出（隨 k_res 連動）。
- **校正標的**：V1、V2、V7（幅度＋平台）、V8。
- **Hold-out 盲測**（不入目標函數）：V6（雙腔室，待 P5）、**V10**（停藥回落）、**V14**（湧現 ε\*）。
- **最佳化**：`surrogateopt`（Global Optimization Toolbox），`rng(20260722)`，pool 上限 3 worker（§7.3）。fval = 2.3e-5（實質全部落在容差帶內）。

### C10.2 校正結果

| 自由參數 | 校正值 | 定何標的 |
|---|---|---|
| `k_res` | 3.744×10⁻⁷ m/day | V1 |
| `K_S` | 2.13 | V2 |
| `K_P_sost` | 31.34 | V7 方向/幅度 |
| `lambda_P` | 3.684 | V7 |
| `delta_ab` | 0.0918 /day | V8 |
| `k_form`（導出） | 3.664×10⁻⁷ m/day | 骨量平衡 |

| 標的 | 值 | 目標 | |
|---|---|---|---|
| V1 骨轉換率 | 7.19 %/yr | 5–10 | ✅ |
| V2 廢用流失 | 1.15 %/mo | 1.0–1.5 | ✅ |
| **V7 鈣效應** | **+0.97 %** | 0.7–1.8 | ✅ |
| **V7 平台斜率** | +0.036 %/yr | \|·\|<0.3 | ✅ |
| V8 romosozumab@12mo | +12.8 % | 11–14 | ✅ |
| **V10 停藥回落**（盲測） | **−5.8 %** | <0 | ✅ |
| **V14 湧現 ε\***（盲測） | **762 με** | 100–1500 | ✅ |

### C10.3 為何 hold-out 通過是關鍵

V10 與 V14 **未參與擬合**，卻自動落在正確範圍：

- **V10（停藥回落）**：校正只用了 romosozumab 給藥期的 V8。停藥後 BMD 回落是模型自身的負回饋預測，−5.8% 方向正確 —— 這是 romosozumab 自限性（N2）的直接驗證。
- **V14（湧現 ε\*）**：762 με 落在 Frost 100–1500 με 帶內。ε\* 是閉環的**輸出**而非輸入，模型不經擬合即預測出 Frost 純由觀察提出的設定點。

**兩個盲測通過，是本模型具備預測力（而非過度擬合）的直接證據。** 這正是 §9 保留 hold-out 的用意。

### C10.4 回答使用者的原始問題 — V7 現在完整成立

**鈣是許可、負荷是指令**的核心命題（P1）現在有量化支撐：

- 補鈣（800→1500 mg）使 aBMD **+0.97%**，且**一年後即達平台**（斜率 0.036 %/yr）—— 與 Tai 2015 統合分析的「非漸進式、+0.7–1.8%」完全吻合。
- 方向正確：低鈣→續發性副甲亢→骨流失；高鈣→PTH↓→骨吸收略降→小幅骨增益。此方向源於 PTH 僅經 PTH→RANKL 主導（K_P_sost=31.3 使 PTH→SOST 弱），與 Lemaire/Pivonka 一致（C9.3）。
- 對照：同期適當負重的效應遠大於此（E2 的 2×2 因子分析待 P5 完整量化，但單軸已見負荷效應為 %/yr 級 vs 補鈣的一次性 <1%）。

### C10.5 遺留事項

- **辨識性**：`K_P_sost` 與 `lambda_P` 皆作用於 V7，可能互償。`identifiability.m`（P6）須對此對做 profile likelihood。hold-out 通過雖強烈支持非病態，但正式辨識性分析仍必要。
- **`delta_P`**：C9 上修為 171/day 後，本次校正未重新檢視其對 PTH 動態的影響，屬固定參數，列入 P6 靈敏度。
- Lemaire 2004（#1）到手後可用 R/B/C 基線穩態濃度複核 M6。

---

---

## 附錄 C11：辨識性分析 — 補實 §9 風險 1 (2026-07-25)

C10.5 標記「`K_P_sost` 與 `lambda_P` 皆作用於 V7，可能互償」，欠一個正式辨識性分析。本節補上。

### C11.1 方法

- **相關對 (`K_P_sost`, `lambda_P`)**：二維 χ² 圖（其餘三參數固定於校正值），13×13 網格。二者皆只經 V7 作用，若互償則圖上出現低 χ² 的**對角谷**（等效擬合的脊）。這比兩條獨立的一維 profile 更誠實地呈現聯合結構。
- **其餘三參數 (`k_res`, `K_S`, `delta_ab`)**：一維條件掃描（各由 V1/V2/V8 一對一約束，預期可辨識）。
- χ² 為 `evalTargets` 的平滑「對區間中點標準化偏差平方和」（非校正用的帶狀目標，後者帶內平坦、profile 無資訊）。Δχ²=1 為信賴區間門檻。
- **效能**：`buildDoseSurrogate` 加記憶化（快取鍵含所有影響它的 M2/M3 參數與 bout 結構；5 個校正自由參數皆不影響它，故快取全中）。每次 `evalTargets` 由 ~7s 降至積分主導的 ~4s，網格以 3-worker 平行（§7.3），全分析約 4 min。

### C11.2 結果（圖存於 `results/figures/identifiability.png`）

| 參數 | 分類 | 條件 CI（Δχ²≤1） |
|---|---|---|
| `k_res` | ✅ 可辨識 | 明確 V 形極小，由 V1 釘住 |
| `K_S` | ✅ 可辨識 | 由 V2 釘住 |
| `delta_ab` | ✅ 可辨識 | 由 V8 釘住 |
| **(`K_P_sost`, `lambda_P`)** | ⚠️ **相關對** | 脊相關 r = **−0.89**；聯合信賴區內佔 35/169 格 |

**二維圖清楚顯示一條負斜率的對角低 χ² 谷** —— `K_P_sost` 與 `lambda_P` 確實互償（如 C10.5 所疑）。二者的**邊際** profile 各自觸及搜尋框上界（K_P_sost CI ≈ [20, ≥100]、lambda_P CI ≈ [0.9, ≥10]），即**個別不可辨識**；但沿脊的垂直方向有界，**聯合為一條有界的對角帶**。

### C11.3 判讀與處置

這是教科書式的**相關參數對**，非病態：

1. **預測仍可信**：hold-out 盲測（V10, V14）通過，證明校正點落在脊上的**有效位置** —— 個別參數值雖不唯一，模型預測不受影響。
2. **機制詮釋一致**：脊的存在正因二者作用於同一標的（V7 = PTH→骨的淨效應）。`K_P_sost` 大（PTH→SOST 弱）可由 `lambda_P` 大（PTH→RANKL 強）補償，兩者都使「持續 PTH 淨異化」，與 Lemaire/Pivonka 無 PTH→SOST 路徑一致（C9.3）。
3. **收緊之道**（列入待辦，需獨立資料）：
   - 由獨立文獻**固定其一** —— `lambda_P` 可取 PTH→RANKL 劑量反應（Pivonka K_D4,PTH 相關），或 `K_P_sost` 取 Bellido 之 SOST–PTH 資料 —— 另一個即變可辨識。
   - 或於論文中**報告聯合信賴區**（對角帶）而非個別點估計，並明示相關性。

**§9 風險 1 現已量化**：3/5 校正參數個別可辨識，1 對相關但聯合有界。這是誠實且可發表的辨識性狀態。論文須附此圖並說明處置。

### C11.4 順帶交付

- `evalTargets` 新增平滑 χ² 度量；`identifiability.m`（二維圖＋一維掃描＋分類）；`plotIdentifiability.m`、`exportFigure.m`（house style 圖輸出）；`balanceBoneFormation` 於此串接。
- `buildDoseSurrogate` 記憶化：對校正／辨識性／未來 E6 Sobol 的大量重複呼叫是通用加速，且快取鍵設計無 stale 風險（鍵含實際參數值）。

---

---

## 附錄 C12：P5 雙腔室模型 — 部位專一性 (2026-07-25)

實作雙腔室（site A 打球側／site B 對側），驗證預測 **P2**（創新 N3）：局部負荷造成部位差異，全身介入不能。

### C12.1 架構

- **`siteRHS`**（重構）：把單站 M1–M7 抽成單一函數，`rhsFull`（單站）與 `rhsTwoSite` 共用同一份生物學（避免分歧）。重構為行為保持，53 測試不變。
- **`rhsTwoSite`**：31 狀態（14 局部 ×2 + 3 共用系統）。兩站各自 M1–M7，**共用一組 M8**（血鈣/PTH）。M8 由兩站骨活性的平均驅動（單一肱骨對全身鈣周轉貢獻極小，故兩站是共用池的「探針」而非驅動者）。
- **`makeContextTwoSite`**：兩站各建劑量代理，共用同一固定參考情境正規化。

### C12.2 ✅ P2 定性成立

| 檢定 | 結果 |
|---|---|
| 局部負荷（網球，site A 打球）5 年 | 打球側 BMC **+9.4%** 高於對側 |
| **系統介入對照**（兩站同負荷 + 全身低鈣） | A/B = **−0.0000%** |

**這是 P2 的鑑別性claim**：局部負荷造成部位差異，全身介入（補鈣、任何全身藥物）因兩站共用 PTH 而**不可能**製造部位不對稱。以 `test_twosite.m` 鎖定。

### C12.3 ⚠️ V6f（幾何 vs 密度）未達 — 揭露 M7 一個真問題

雙腔室的受控對照（同一人、同一鈣池、僅局部力學不同）正是檢驗 V6f 的最佳設計。結果暴露一個單站校正看不出的 M7 問題：

- **實測**：打球側增益走**密度**（vBMD +8.5%）而非**幾何**（Tot.Ar/Co.Ar/I_max ~0–2%）。Haapasalo 為相反（幾何 +16–67%、vBMD ~0，V6f 為硬性標的）。
- **診斷**（兩個層次）：
  1. **形成分配用了吸收面加權**：`surfaceAllocation` 以 `xi`（吸收面分數）加權形成，骨膜僅得 5%，故形成灌向皮質內（密化）。修法應為包膜周長（∝ r_p, r_e，恆可用）+ 孔壁面（∝ S_v，f_bm→1 時消失）。**已試作 `c_form_i` 修正，骨膜升至 ~38%，但仍不足。**
  2. **更根本 —— 礦化耦合**：追查 vBMD +8.5% 主要來自 **rho_min 上升**（1200→1283），但新生骨應為**低礦化**（初級礦化 ~60%），rho_min 應**下降**。M7 礦化池在淨形成下讓 rho_min 上升，方向錯誤。且 w_wall 的放大使 f_bm 對 rho_min 過度敏感。
- **處置**：此為 M7 礦化模型的實質修訂（rho_min 須隨形成下降、密化須在 f_bm→1 硬性飽和、幾何 vs 密度分配須重平衡），**且會需要重新校正**。已試作的分配修正因破壞單站基線平衡（漂移 1%/yr）而**回退**，以維持已校正的 53 測試態。**列為 P5b 的專項後續**，附完整診斷。

> **誠實定位**：雙腔室模型正確交付 P2 的**定性**鑑別預測（這是三個可發表預測之一，且是全身介入無法複製部位差異的關鍵論證）。**幾何 vs 密度的定量分割（V6f）未達**，且此不足是雙腔室對照才能揭露的 M7 真問題 —— 這本身是有價值的發現，而非隱藏的失敗。`test_twosite.m` 只斷言模型確實做對的部分，不誇稱 V6f。

### C12.4 交付

- `src/model/siteRHS.m`（單站生物學，單一真相源）、`rhsTwoSite.m`、`makeContextTwoSite.m`；`rhsFull` 重構共用 `siteRHS`；`simulate` 接上雙站。
- `tests/test_twosite.m`：P2 定性檢定（局部不對稱、系統對稱、共用 M8）。
- **P5b 待辦**：M7 礦化修訂（rho_min 隨形成下降）+ 形成分配（包膜周長 vs 孔壁面）+ 重新校正 → 達 V6f 全套（V6a–V6f）。

---

---

## 附錄 C13：P5b 礦化修訂研究 — V6f 需要兩個獨立修正 (2026-07-25)

嘗試修 M7 達成 V6f。**研究確立了正確的礦化模型並證實其修正 V6f 的密度側，但完整達標需兩個獨立且各自實質的修正，其一會破壞既有校正。** 為維持 v2.2 的已校正態（57 測試全過），本次探索性程式碼**已回退**，僅保留診斷結論。

### C13.1 礦化模型的正確形式（已驗證方向正確）

原 M7 以兩個面積礦物池 m1, m2 除以 f_bm，淨形成下 rho_min **上升** —— 方向錯誤。正確模型為 intensive 平均礦化度 ODE：

$$\frac{d\rho_{min}}{dt} = \mu_{turn}\,v_{form}\,(\rho_{prim}-\rho_{min}) + \kappa_m\,(\rho_{ref}-\rho_{min})$$

新生骨為初級礦化（~60%），故周轉越快 → 越多年輕低礦化骨 → **rho_min 下降**。$\rho_{ref}$（完全成熟密度）由基線不動點導出。

**實測（單一 rho_min 狀態取代 m1,m2）**：
- 基線 rho_min 完美穩定（漂移 −0.005%/yr，優於原模型）。
- **網球打球側 rho_min 正確下降**（1198.2 < 1200，年輕骨稀釋）。
- **vBMD 部位差 由 +8.5% 降至 +0.69%** —— **V6f 密度側基本達標**（容差 ±2%）。

### C13.2 但 V6f 需要兩個獨立修正，且互相衝突

**修正 A（密度不膨脹）= 礦化模型**：如上，有效。但引入**次級礦化延遲**，衝擊藥物反應：
- V8（romosozumab）BMD 增益被礦化緩衝而變小（新生骨低礦化）。
- **V10（停藥回落）方向翻正** —— 停藥後累積的年輕骨成熟（rho_min 經 kappa_m 上升），BMD 續升而非回落。
- 重新校正（僅開 5 個細胞參數）無法同時滿足 V8/V10：需**併同開放礦化時間尺度** $\mu_{turn}, \kappa_m$ 擬合（超出 §9 的 4–6 自由參數，或需更細緻的聯合校正）。

**修正 B（幾何而非密度增益）= 形成分配**：Haapasalo 的增益是骨膜外擴（幾何）。但：
- 形成分配改用包膜周長（∝ r_p, r_e）+ 孔壁面（∝ S_v）後，骨膜分配由 5% 升至 40%；
- **卻破壞基線穩定**：骨膜以 ~1%/yr 生長、皮質掏空。根因為**通道劑量在正常活動即飽和**（$k_{co}(1.5\text{Pa})\approx0.985$），無「基線之上的餘裕」讓負荷把分配推向骨膜。
- **完全靜止的分配唯有 eta=xi**（每腔室自平衡），與「骨膜受負荷主導」互斥，除非分配為應變依賴 —— 而應變依賴需劑量餘裕（力學鏈重新校正）。

### C13.3 結論與後續分工

| V6 子標的 | 需要 | 狀態 |
|---|---|---|
| V6f（vBMD ~0，密度不膨脹） | 修正 A（礦化 intensive ODE） | ✅ 方向驗證（+8.5%→+0.7%），待聯合重校 V8/V10 |
| V6a–e（幾何增益 +14–67%） | 修正 B（骨膜分配 + 劑量餘裕） | ⚠️ 需力學鏈重新校正（通道不飽和） |

**兩者皆為實質修訂，非參數微調**：
- **P5b（續）**：以 intensive 礦化 ODE 取代 m1/m2，**併同開放 $\mu_{turn}, \kappa_m$ 做完整重新校正**（V1/V2/V7/V8/V10），使 V6f 密度側與藥物動態並存。
- **P5c**：重新校正力學鏈（$\tau_{50}, k_{tau\_sig}$）使正常活動不飽和，讓負荷可將形成推向骨膜 → V6a–e 幾何增益。

**目前不誇稱 V6**。v2.2 的 `test_twosite.m` 僅斷言 P2 定性（局部不對稱、系統對稱），此仍為三大可發表預測之一的堅實交付。V6 完整達標為明確界定的兩階段後續。

> **方法論註**：這是「雙腔室對照揭露單站校正看不見的問題」的價值範例 —— 正因為有同一人、同一鈣池、僅局部力學不同的受控對照，才能分離出「密度膨脹（礦化）」與「幾何 vs 密度分配」兩個獨立缺陷。這本身是模型迭代的正確產出。

---

---

## 附錄 C14：P5b + P5c 完成 — V6 以盲測湧現 (2026-07-25)

**里程碑：三大可發表預測的 P2（部位專一性）現在定量成立。V6（網球肱骨不對稱）以 hold-out 盲測湧現，呈 Haapasalo 之「幾何增益、密度不變」型態。58 測試全過。**

### C14.1 兩個結構修正（依 C13 診斷）

**修正 A — intensive 礦化 ODE**（取代 m1/m2 兩池）：
$$\frac{d\rho_{min}}{dt} = \mu_{turn}\,v_{form}\,(\rho_{prim}-\rho_{min}) + \kappa_m\,(\rho_{ref}-\rho_{min})$$
新生骨低礦化 → 周轉快則 rho_min **下降**。狀態向量 m1,m2 → 單一 rho_min（單站 17→16、雙站 31→29）。基線 rho_min 完美穩定（−0.005%/yr）。$\kappa_m$ 放慢至 5e-4（次級礦化本為數年）。

**修正 B — Frost modeling 項**（`boneStructure`）：
$$\dot r_p \mathrel{+}= k_{model}\,\max(0,\ \varepsilon_p-\varepsilon^*_{model})\,(n_{ot}/n_{ot,0})^\zeta$$
劇烈負荷驅動**直接骨膜外擴（modeling，非 remodeling）**，有 Frost 最小有效應變閾值（$\varepsilon^*_{model}=1500$ με）。**正常活動（762 με）低於閾值 → modeling=0 → 所有校正情境不受影響**。負荷（tennis 2850 με）之上啟動 → 幾何外擴，且自限（$r_p\uparrow\to I_g\uparrow\to\varepsilon_p\downarrow$）。

> **為何 modeling 而非劑量梯度**：原擬用劑量的骨膜/骨內膜梯度驅動分配，但日劑量被 2000 循環/日的 ADL 背景主導（通道對循環數線性，V4），梯度被淹沒。Frost 的 modeling/remodeling 二分才是正確機制（附錄 C13 診斷後確立）。

### C14.2 ✅ V6 盲測湧現（未參與校正）

僅重校 2 個參數（K_S 2.13→1.27、mu_turn_0 新增 1e-4），對 V1/V2/V7 校正，**V6 仍為 hold-out**：

| V6 子標的 | 模型 | Haapasalo | |
|---|---|---|---|
| **vBMD**（V6f，硬性） | **+1.28%** | ~0 | ✅ ±2% |
| Tot.Ar（V6b） | +12% | +16–21 | ✅ ±10 |
| Co.Ar（V6c） | +27% | +12–32 | ✅ |
| I_max（V6d） | +36% | +27–67 | ✅ |
| BMC（V6a） | +28% | +14–27 | ✅ ±10 |

**增益走幾何、密度不變 —— Haapasalo 的核心結果，且模型未被擬合到 V6。** $k_{model}$ 只縮放**幅度**；**型態**（幾何 vs 密度、面積比、$I_{max}>Tot.Ar$）是結構性湧現，與 $k_{model}$ 大小無關。這是預測力的直接證據。

### C14.3 校正標的（重校後）

| 標的 | 值 | | 標的 | 值 | |
|---|---|---|---|---|---|
| V1 周轉 | 7.19 %/yr | ✅ | V7 鈣 | +1.14 % | ✅ |
| V2 廢用 | 1.15 %/mo | ✅ | V7 平台 | −0.24 | ✅ |
| V14 湧現 ε\*（盲測） | 762 με | ✅ | V6（盲測） | 見上 | ✅ |

> **K_S 高敏感（辨識性註記）**：正確礦化後，V2 對 K_S 在設定點附近陡變（K_S 1.25→V2 1.28；1.30→1.00 %/mo）。此非缺陷，而是**mechanostat 設定點的直接表現**（SOST 之 Hill 抑制在 Y≈K_S 處陡峭），與 P3/E6 的雙穩態結構同源。K_S 因此**緊密可辨識但敏感**；E6 須以之為關鍵參數。
> **⚠️ v2.5 更正**：「與 P3/E6 的雙穩態結構同源」一語在 P6 後**不成立** —— 系統單穩，並無雙穩態結構。此陡峭性是**單一不動點附近的高增益**（Hill 抑制陡峭），也正是 C15 所見「臨界 E2≈0.92 陡但連續過渡」的同一來源。陡峭 ≠ 雙穩，兩者須嚴格區分。K_S 的辨識性結論本身不受影響。

### C14.4 ⚠️ V8/V10 重新定位為小樑/脊椎範疇

**重要科學釐清**：舊模型 V8（romosozumab 腰椎 BMD +11–14%）與 V10（停藥回落）之「通過」**係倚賴 C13 已修正的礦化膨脹假影**（舊模型 rho_min 於形成時錯誤上升、廢用時錯誤下降）。正確礦化後：

- V8 目標為**腰椎（小樑骨，f_bm 低、有致密空間）**，本模型為**皮質截面（肱骨幹，f_bm≈0.95 近天花板）**。皮質模型無法在不靠密度膨脹假影下重現 +11–14%。實測 romosozumab 皮質 aBMD +1.25%（方向正確、量級屬皮質而非脊椎）。
- V10 同理為小樑現象。

**這是更誠實的模型**：V8/V10 現明確標為需**小樑腔室**的範疇外標的（列 P5d），`test_calibration` 僅斷言方向。舊「通過」為假影，修正後如實揭露 —— 與 C13 揭露 V4/V5 機制、C9 揭露 D_B/D_C 錯誤同屬「修正使模型更誠實」之例。

### C14.5 現況與後續

三大可發表預測：**P1（鈣許可/負荷指令）量化成立｜P2（部位專一性）定量成立（V6 盲測）｜P3（雙穩態）待 P6**。

- **P5d（後續）**：加小樑腔室（低 f_bm）以定量重現 V8/V10 脊椎 romosozumab。
- **P6**：`continuation` 分歧分析驗證 P3（K_S 之設定點敏感性已預示雙穩態結構）。

---

---

## 附錄 C15：P6 分歧分析 — P3（雙穩態）**不成立**，模型為單穩 (2026-07-25)

**第三個可發表預測 P3（骨質疏鬆為替代穩態／鞍結點分歧）經嚴格分歧分析後 —— 不成立。校正模型為單穩。這是一個誠實的否證結果，且過程中攔下一個差點誤判為「P3 成立」的數值假影。**

### C15.1 方法（凍結幾何以隔離孔隙率動力學）

孔隙率/重塑雙穩態的問題屬**月–年**尺度；包膜幾何演化屬**數十年**尺度，且在病理性低 f_bm 下 Frost modeling 項超出有效範圍（見 C15.4）。故凍結包膜幾何（`ctx.freezeGeom`）以乾淨隔離孔隙率動力學。以 **f_bm nullcline**（固定 f_bm、平衡其餘狀態、算 df_bm）之過零點數判定單/雙穩；`steadyState` 給不動點 Jacobian 特徵值。

### C15.2 結果：單穩

- **基線為穩定不動點**：$\max\mathrm{Re}(\lambda)=-2.0\times10^{-4}<0$（E0 通過）。
- **E2（雌激素/停經）continuation**：**單穩**。單一不動點隨 E2 由 f_bm\*=0.98（E2=1.0 健康）**連續**下移至 0.09（E2=0.65 骨鬆），於 E2≈0.92 附近**陡但連續**過渡。**無鞍結點、無雙穩、無遲滯。** 圖存 `results/figures/bifurcation_E2.png`。
- **tau_50、beta_S continuation**：亦單穩（最大穩態數=1）。

**故 P3 不成立**：骨質疏鬆在本框架中是單一平衡點對雌激素的**陡峭連續位移**（臨界雌激素 E2≈0.92），**非**具遲滯的災難性雙穩態跳變。

### C15.3 為何單穩 — 機制意義

低 f_bm → $E_{app}=E_{ref}f_{bm}^\kappa$ 驟降 → 應變暴增 → 力學劑量高 ＋ Frost modeling 啟動（應變 >1500 με）→ 強力恢復。此**力學＋modeling 的恢復驅動壓過 n_ot 與 S_v 正回饋**，使不存在自我維持的骨鬆吸引子。掃 zeta（n_ot 回饋強度）1.5–5、E2、beta_S 皆未現 S 型 nullcline。

**科學意涵**（值得發表）：在此力學傳導框架下，骨質疏鬆**不是**孔隙率動力學的簡單替代吸引子 —— mechanostat 會「救回」低骨量。臨床上骨鬆的不可逆性因此必來自**模型未涵蓋的機制**：小樑結構穿孔（連續 f_bm 描述無法捕捉的「模板喪失」）、骨細胞死亡、或幾何退化。這是一個明確、可證偽、且指向後續方向的結果。

### C15.4 ⚠️ 攔下的數值假影（方法論警示）

初期全系統遲滯測試（E2=0.1 崩潰→復原 E2）顯示 f_bm 停在 0.02 達 40 年「不可逆」，**差點誤判 P3 成立**。查證發現該「崩潰態」皮質厚度達 **99 mm**（荒謬）—— **Frost modeling 項在病理性低 f_bm/高應變下無界，把 r_p 吹爆**。此非真實骨鬆態，故全系統暫態**不是**有效的雙穩態探針。凍結幾何的孔隙率分析才是乾淨結論。

> **教訓**：一個看似戲劇性的正面結果（40 年不可逆）竟是數值假影。分歧分析必須檢查狀態的物理合理性。此亦揭示 modeling 項需在極端應變下加界（列 P5e）。

### C15.5 三大預測總結

| 預測 | 結果 |
|---|---|
| **P1** 鈣許可／負荷指令 | ✅ 量化成立（V7 平台，附錄 C10） |
| **P2** 部位專一性 | ✅ 定量成立（V6 盲測湧現，附錄 C14） |
| **P3** 骨鬆為替代穩態 | ❌ **不成立 —— 模型單穩**（本附錄）；骨鬆為對雌激素之陡峭連續位移，不可逆性須另尋機制 |

**P3 的否證是有價值的科學結果**，非失敗：它精確界定了 mechanostat 框架能與不能解釋的範圍，並指向「不可逆性來自結構/架構喪失而非動力學雙穩」的可檢驗假說。

- **P5e（後續）**：Frost modeling 項於極端應變加飽和界（避免 r_p 吹爆），使全系統病理模擬有效。
- **P6 交付**：`steadyState`、`continuation`、`fbmNullcline`、`test_bifurcation`、`bifurcation_E2.png`。

---

## 附錄 C16：P3 敘事改寫定案 — 從「假說」改為「否證結果」(2026-07-26)

**C15 記錄了 P6 的發現，但計畫書的前瞻性章節仍寫著「模型應出現鞍結點分歧與雙穩態」。本附錄記錄把這個不一致清乾淨的定案，使全文對 P3 只有一種說法。**

### C16.1 問題：文件內部不一致

C15（v2.4）已判定 P3 否證，但下列位置仍以「待驗證的假說」語氣描述雙穩態，讀者若只讀前半部會得到相反結論：

| 位置 | 原文問題 |
|---|---|
| §0 預測 3 | 「模型**應**出現鞍結點分歧與雙穩態」—— 未來式假說 |
| §3 創新 N4 | 「**提出**『骨質疏鬆為替代穩態』的動力系統假說」—— 創新宣稱建立在已否證的假說上 |
| §4.2 M5 註（$n_{ot}$ 正回饋） | 「兩者的相對強度**決定**系統是單穩態或雙穩態」—— 懸而未決語氣 |
| §5 E6 | 主要輸出「**驗證 P3**」 |
| §6 V11 | 流失–回復不對稱**隱含**以遲滯解釋 |
| §8 P6 判準 | 「明確回答 P3（雙穩態存在與否）」—— 未標示已完成 |
| §10 產出 | 論文敘事未定調 |
| 附錄 C14 K_S 註 | 「與 P3/E6 的**雙穩態結構同源**」—— 現已不成立 |

### C16.2 定案：全部改為「已否證 + 改寫後的預測」

**論文對 P3 的唯一說法**（各處措辭統一於此）：

> 在機制解析的力學傳導 mechanostat 框架下，骨質疏鬆是**單一平衡點對雌激素的陡峭但連續的位移**（$f_{bm}^*$：0.98 → 0.09，臨界 $E_2\approx0.92$），**不是**具遲滯的雙穩態跳變。$\tau_{50}$、$\beta_S$、以及正回饋強度 $\zeta\in[1.5,5]$ 皆同。機制上，低 $f_{bm}$ 造成的應變暴增使力學劑量與 Frost modeling 同時強力恢復，壓過 $S_v$ 與 $n_{ot}$ 兩個正回饋。**推論**：臨床骨鬆的不可逆性不能由孔隙率重塑動力學解釋，必來自結構／模板層級的喪失（小樑穿孔、骨細胞死亡、幾何退化）。

**三個必須守住的措辭紀律**：

1. **陡峭 ≠ 雙穩**。K_S 對 V2 的高敏感、E2≈0.92 的陡過渡，都是**單一不動點附近的高增益**，不得寫成雙穩態的證據。C14 的 K_S 註已據此更正。
2. **速率不對稱 ≠ 動力學不可逆**。V11（回復 ≫ 流失）在本模型是吸收快／形成慢＋礦化長時間常數所致，屬單一吸引子上的緩慢回歸，非遲滯。
3. **否證要放在主論文，不放補充材料**。這是全文唯一一個模型推翻自身先驗假說的結果，是預測力的直接證據。

### C16.3 為何這是更強的敘事

原假說若成立，本模型只是又一個「複雜系統有雙穩態」的例子（此類結果在文獻中甚多，且常因數值假影而不可靠 —— C15.4 差點就是一例）。否證後的敘事反而給出**三項既有工作做不到的貢獻**：

- **一個界定**：mechanostat 框架的解釋力邊界被精確畫出（孔隙率動力學解釋得了漸進流失，解釋不了不可逆）。
- **一個可證偽的後續假說**：不可逆性來自模板喪失 → 直接預測小樑腔室（低 $f_{bm}$、高 $S_v$、穿孔後 $S_v\to0$）才會出現雙穩，皮質不會。此即 P5d 的科學動機，並使 P5d 從「補一個標的」升格為「檢定一個假說」。
- **一個方法論警示**：C15.4 的 99 mm 皮質假影，示範了分歧分析必須檢查狀態的物理合理性。

### C16.4 尚未改、且刻意不改的

附錄 C1（§709 表）、C7、C12–C14 內對雙穩態的表述**保留原樣**，因為附錄是**帶日期的決策紀錄**，追溯改寫會抹去推理軌跡。僅在 C14 的 K_S 註加了指向性更正（因其為一個具體且現已錯誤的科學論斷，非單純歷史敘述）。C15/C16 為此議題的最終效力來源。

**本次改寫不動任何程式碼，61 測試不受影響。**

---

## 附錄 C17：P5e — Frost modeling 項飽和界 ＋ 彈性有效域守衛 (2026-07-26)

**C15.4 攔下的 99 mm 皮質假影，本階段修掉。結果：飽和界必要但不充分，補上有效性守衛後，才首次得到一條「全程有效且不凍結幾何」的遲滯探針 —— 它獨立佐證了 C15 的單穩結論。**

### C17.1 假影的量化重現

v2.3 的 modeling 項對應變超額為**線性且無界**：`k_model * max(0, eps_p - eps_model_star) * sensing`。實測其在病理態的行為：

| f_bm | eps_p | modeling 速率 |
|---|---|---|
| 0.95（基線） | 762 με | 0（低於閾值，故校正情境完全不受影響） |
| 0.50 | 3,790 με | 0.29 mm/yr |
| 0.20 | 37,458 με | 4.59 mm/yr |
| 0.05 | 1,198,665 με | 152.9 mm/yr |
| **0.02** | **11,845,350 με** | **1,513 mm/yr** |

E2=0.1、20 年之全系統模擬：r_p 由 10.50 mm →**第 1 年就到 23.60 mm**（13 mm/yr 骨膜沉積）→ 20 年 86.72 mm，皮質厚 77.5 mm。

**排除過的兩個替代解法**（先查證再動手）：
- **耦合到骨母細胞供給**（modeling ∝ B）：實測崩潰態 **B/B₀ = 681**（骨母細胞爆量），此法會讓假影**更嚴重**。
- **倚賴既有的 `sensing` 閘控**：實測崩潰態僅衰減 **32.6%**，不足以抵銷 6 個數量級。

**應變超額本身才是正確的飽和對象。**

### C17.2 定案：飽和形式與參數

$$\text{modeling}=k_{model}\cdot\frac{\Delta\varepsilon}{1+\Delta\varepsilon/\varepsilon_{sat}}\cdot\text{sensing},\qquad \Delta\varepsilon=\max(0,\varepsilon_p-\varepsilon^*_{model})$$

新參數 `eps_model_sat = 5.5e-3`（`source=derived, confidence=medium`）。**由兩個互相獨立的論證收斂於同一數值**：

1. **半飽和處的總應變** = $\varepsilon^*_{model}+\varepsilon_{sat}$ = 1500 + 5500 = **7000 με = 皮質骨降伏應變**。超過降伏後組織進入損傷而非適應，Frost 的線性關係不可外推。
2. **隱含速率上限** $v_{max}=k_{model}\varepsilon_{sat}$ = **1.93 μm/day**，落在快速 modeling／編織骨礦化沉積率（MAR ~1–5 μm/day）的文獻區間。

`k_model` **未動**（V6 為 hold-out，調它等於污染盲測）。

### C17.3 對已驗證結果的影響 — V6 盲測在未重校下存活

校正情境（762 με）全部低於閾值，modeling 恆為 0，故 **V1/V2/V7 與 V10/V14 盲測逐字不變**。V6（網球，hold-out，未重新擬合）：

| 指標 | 飽和前 | 飽和後 | Haapasalo 原始區間 |
|---|---|---|---|
| BMC | +28.48% | **+25.75%** | 14–27 ✅ **改為落在原始區間內** |
| Tot.Ar | +12.01% | +10.66% | 16–21（±10 → 通過） |
| Co.Ar | +26.86% | +24.16% | 12–32 ✅ |
| I_max | +35.80% | **+31.80%** | 27–67 ✅ **原本就在，更居中** |
| vBMD (V6f 硬性) | +1.277% | +1.277% | −2–0，±2 ✅ |

**盲測經歷一次結構性修改而未重新校正仍成立，且兩項指標反而更貼近文獻中心** —— 這比原本的通過更有說服力。

測試：**67 通過 / 0 失敗**（新增 `test_modeling.m` 6 項）。

### C17.4 ⚠️ 飽和界**必要但不充分** —— 這是本階段最重要的發現

飽和只縮放速率，**完全不移動不動點**。modeling 項的零點仍在「應變回落至 1500 με」，在病理性 f_bm 下這仍需 r_p ≈ 94 mm。實測 E2=0.1、20 年：r_p 由 86.72 mm 降為 **22.49 mm** —— 好很多（且積分快 4 倍），但**仍非生理值**，只是以上限速率 0.70 mm/yr 緩慢逼近同一個荒謬吸引子。

> **若只做計畫書 §C15.5 字面所寫的「加飽和界」就收工，會留下一個 22 mm 的靜默假影。** 故補上第二道防線。

### C17.5 第二道防線：彈性有效域守衛

模型的整條力學堆疊（$E_{app}=E_{ref}f_{bm}^{\kappa_E}$、Euler–Bernoulli 截面、Biot 孔彈性解）**全部假設線性彈性**。新增 `eps_elastic_max = 7.0e-3`（皮質骨降伏應變，`source=literature`）——**這不是模型參數，是有效性邊界**。`simulate` 現回傳 `out.validity`（`.ok .maxStrain .limit .firstExceededDay .site`）。

實測（730 天）：sedentary 762 με ✅｜resistance 2,236 με ✅｜tennis 2,851 με ✅ —— 所有已驗證情境都遠在域內。

**守衛立刻抓到兩個既有問題**（皆非本次改動造成）：

1. **bedrest 超過約 7.5 個月會塌到孔隙率地板**：第 231 天起 f_bm → 0.02，24 個月 aBMD 掉 97.5%。V2 是在 **180 天**視窗評估的（該視窗內 f_bm 0.950→0.887、應變 18 με、完全有效，V2=1.153 %/mo 照常通過），故校正無誤 —— 但**「完全卸載」的宣稱只在 6 個月尺度內有效**。真實臥床／脊髓損傷的骨流失會減速並在 30–50% 處達平台，本模型不會。列為範疇限制（P5f 候選：加一個不依賴力學的基礎形成率）。
2. **C15 分歧圖的深骨鬆分支落在自身有效域之外**：有效域要求 f_bm > 0.391。而 E2 過渡極陡 —— E2=0.945 → f_bm 0.402（有效，6,295 με）；**E2=0.940 → f_bm 0.258（已無效，26,775 με）**。亦即 `bifurcation_E2.png` 中 f_bm 低於 0.39 的整段（C15 所報的一路降到 0.09）**超出線性彈性假設**。單穩結論不受影響（過零點數與分支形狀是孔隙率動力學的性質），但該圖的深端須標註為域外外推。

### C17.6 成果：首次得到有效且不凍結幾何的 P3 複驗

**(a) 原假影的直接證偽。** 重跑 C15.4 那條「40 年不可逆」軌跡（E2=0.1 五年 → 恢復 E2）：f_bm 由 0.036 **在 3 年內回升至 0.75**。當初的「不可逆」完全是 modeling 吹爆所致。（此軌跡仍被標記 invalid，僅作對照。）

**(b) 全程有效的遲滯探針** —— 這是 P5e 真正的交付：

| 階段 | f_bm | max 應變 | valid |
|---|---|---|---|
| 下行 E2 1.0 → 0.945，10 年 | 0.9500 → **0.4018** | 6,295 με | ✅ |
| 上行 E2 0.945 → 1.0，20 年 | 0.4018 → **0.9485** | 6,565 με | ✅ |

**恢復至基線的 99.8%。無遲滯、完全可逆。** 這是**在完整模型上、不凍結幾何、全程留在有效域內**得到的結論，與 C15 凍結幾何的判決一致 —— **P3 的否證因此由兩條獨立路徑佐證。**

**(c) 附帶發現：骨膜棘輪 (periosteal ratchet)。** 上述循環後 r_p 淨增 **+0.208 mm** 且不回復 —— modeling 只加不減，幾何是單向變數。這**不是**動力學雙穩（f_bm 完全回復），而是一個物理上真實的結構記憶（活體骨膜沉積本就大致不可逆）。論文須明確區分二者，此即 C16.2 措辭紀律第 2 條的具體案例。

### C17.7 交付與後續

- 改動：`boneStructure.m`（飽和形式）、`simulate.m`（`out.validity`）、CSV 新增 `eps_model_sat`、`eps_elastic_max`、新測試 `tests/test_modeling.m`（6 項）。
- **`results/figures/bifurcation_E2.png` 須重製並標註 f_bm < 0.391 為域外**（待辦）。
- **P5f 候選**：bedrest 長期崩潰 —— 缺一個不依賴力學的基礎形成率，使完全卸載收斂到 30–50% 流失而非歸零。

---

## 附錄 C18：E0–E6 實驗實作與論文圖 (2026-07-26)

**七支實驗腳本由骨架變為可執行，各自產出一張論文圖。過程中得到四個新的實測結果 —— 兩個修正既有判定（一好一壞），兩個是先前未檢定的標的首次得到答案。**

### C18.1 交付

| 腳本 | 產出圖 | 標的 |
|---|---|---|
| `E0_baseline` | `E0_baseline.png` | V1、V14（盲測）、基線平坦 |
| `E1_doseResponse` | `E1_doseResponse.png` | V4、V5、V5b |
| `E2_calciumLoading` | `E2_calciumLoading.png` | **P1** |
| `E3_unloading` | `E3_unloading.png` | V2、V3、最小有效劑量 |
| `E4_pharmacology` | `E4_pharmacology.png` | V8 方向、V9、V10、V12 |
| `E5_siteSpecificity` | `E5_siteSpecificity.png` | **P2**、V6a–f（盲測） |
| `E6_bifurcation` | `E6_bifurcation.png` | **P3**（重製，含有效域標註） |

另新增 `src/viz/houseColors.m`（§7.2 配色單一真相源）。所有腳本 `checkcode` 零問題，且每支都斷言／回報 `out.validity.ok`。

### C18.2 P1（E2）—— 前兩句成立，第三句**取決於度量，且預先寫定的那個度量是錯的**

24 個月，鈣 100/400/800/1500 mg/day × {久坐, 阻力訓練}：

| | 值 | P1 預測 | |
|---|---|---|---|
| 鈣邊際效益（800→1500，久坐） | **+0.470%** | < 1% | ✅ |
| 負荷邊際效益（久坐→阻力，鈣充足） | **+5.565%** | > 4% | ✅ |
| 負荷／鈣 效應比 | **11.8×** | | |

**第三句（協同、非相加）的兩種框架給出相反符號**：

- **絕對框架**（一個有運動的人實際達成多少）：嚴重缺鈣 +4.937% vs 補充 +5.831%，**缺鈣使負荷所能建的骨少 15%** → **命題成立**。
- **差異中的差異框架**（負荷組減久坐組，同鈣量）：交互作用 **−0.557 個百分點** → **命題反轉**。

原因不是機制問題，是**比較組的地板效應**：缺鈣使久坐組掉更快（+0.450% → −1.185%），把差值撐大。100→1500 mg/day 全區間單調，無例外。

> **論文須明確採用絕對框架並說明理由。** 若照 §0 原本寫定的交互作用項報告，會得到與自身機制相反的結論。這與 C16.2 措辭紀律同類：**度量的選擇會翻轉結論，必須先講清楚。**

### C18.3 V5 **獲得平反**，V5b 的**符號在骨層級翻轉**（E1）

兩個都是先前只在通道層級判定、現在首次在骨層級判定的標的，結果一好一壞：

- **V5（休息插入，✅ 由否轉是）**：增益隨幅值**遞減**（×1.5 時 11.08 倍 → ×4.5 時 1.07 倍）—— 這正是 Srinivasan 的方向。C6.4 在通道層級測到相反方向並列為風險；**下游飽和把它翻正**，與 C6.5／C7.1 的預案完全一致。**C6.4 的風險據此解除。**
- **V5b（頻率，⚠️ 由是轉否）**：剪應力層級 τ 4.47→19.38 Pa，對 ln f 之 r = **+0.999**（C6.1 成立）。但**骨層級** ΔaBMD +2.899%→+2.738%，r = **−0.998** —— **ln f 的形式一路傳到骨，符號沒有**。等時長對照（固定 bout 時長、循環數隨 f 調整）給出同樣符號，故**非場次長度假影**。機制：`k_co(τ)` 對 τ 飽和，高頻縮短每循環受載時間的損失大於峰值剪應力提高的獲益。幅度小（0.161 個百分點，佔平均反應 5.7%），但**方向與 Hsieh & Turner 2001「高頻更具成骨性」相反**。
  - **處置**：V5b 只能宣稱到剪應力層級，不得宣稱到 BMD。這是 MSIC 速率常數（現為佔位，待 Fu 2025）最直接的一個可證偽後果 —— **列為 Fu 2025 到手後的首要複驗項**。

**V4 成立**：邊際報酬單調遞減，18→1200 循環間降 42 倍。

### C18.4 V9 弱形式成立、強形式不成立；V12 略呈次相加（E4）

四臂 24 個月（romosozumab 12 個月後停藥）：對照 −0.019%、藥 +1.393%、負荷 +5.546%、藥＋負荷 +6.423%。

- **V8 方向** ✅ +1.254%（脊椎 +11–14% 的量值屬小樑範疇，見 C14，不宣稱）。
- **V9 自限性**：**強形式（12 個月療程內形成標記見頂回落）未重現** —— 骨母細胞到第 12 個月仍在上升。**弱形式（上升減速）成立**：前半段 +0.2021、後半段 +0.0232，減速 8.7 倍。應報告弱形式。
- **V10**：皮質截面於停藥後 +0.146%（不跌）。與 C14 一致，脊椎回落屬小樑範疇。
- **V12**：組合 +6.442% vs 嚴格相加 +6.978%，**次相加 7.7%**。定性主張（合成代謝藥與負荷可疊加，與雙磷酸鹽不同）成立，**嚴格相加性不成立** —— 兩者共用同一個 SOST→Wnt 節點，會部分互相佔用。

### C18.5 V3、最小有效劑量（E3）與 V6e（E5）

- **V2** 1.153 %/mo ✅、**V3** 硬化蛋白 180 天 **+48.8%** ✅（首次定量檢定）。
- **最小有效劑量**：30 min/day 預算內最佳處方為峰值力矩 ×4.5、80 循環、0.5 Hz、循環間休息 10 s，共 16.0 min/day，**防止 48% 的流失**。**預算內無任何處方能把流失壓到 0.25 %/mo 以下** —— 一個誠實且臨床相關的否定結果。所有 E3 run 均為 180 天（C17.5 的有效視窗）且 `validity.ok=1`。
- **V6（盲測）六項中五項在容差內**；未達者為 **V6e 髓腔面積**：Haapasalo 實測打球側髓腔**也擴大** +19%（骨膜外擴超過骨內膜變化），模型卻使其**縮小 −2.88%**。缺的是 M7 的 `r_e` 對負荷的反應。**V6b–d 的幾何主張不受影響。**
- **P2 乾淨成立**：單側負荷 +25.75%，全身補鈣 +0.0000%、全身 romosozumab −0.0000%。

### C18.6 E6 重製，並修掉一個讀取錯誤

`bifurcation_E2.png` 重製為 `E6_bifurcation.png`，兩面板：(a) 凍結幾何分支（f_bm\* 0.985→0.087，全程單穩，**陰影標出 f_bm < 0.391 的線性彈性域外區**，即 C17.5 的待辦）、(b) C17.6 的全模型有效遲滯探針。

> **實作備忘**：`continuation` 回傳的 `branch.stable{k}` 是**對 `branch.fps{k}` 的邏輯遮罩**，不是不動點值。誤讀會讓整條分支變成常數 1.0（初版即如此，經與 C15 已知值比對而抓到）。取值須用 `fps(find(st,1))`。

### C18.7 標的總表更新

| 標的 | 層級 | 狀態 |
|---|---|---|
| V1 V2 V3 V4 V7 V7b V13 V14 | — | ✅ |
| **V5** 休息插入 | 骨 | ✅ **本次由否轉是**（C6.4 風險解除） |
| **V5b** 頻率 | 剪應力 ✅／**骨 ❌ 符號相反** | ⚠️ **本次降級**，待 Fu 2025 |
| V6a–d, V6f | 骨（盲測） | ✅ |
| **V6e** 髓腔 | 骨（盲測） | ❌ 方向相反，M7 之 `r_e` 缺口 |
| V8 V10 | 皮質 | 方向 ✅／量值屬小樑範疇（C14），待 P5d |
| **V9** 自限性 | 骨 | 弱形式 ✅／強形式 ❌ |
| **V12** 交互作用 | 骨 | 定性 ✅／嚴格相加 ❌（次相加 7.7%） |
| V11 V15 | — | 待 E3/E6 專項分析 |

### C18.8 後續

- **Fu 2025 到手後首要複驗 V5b 骨層級符號**（C18.3）。
- **M7 的 `r_e` 對負荷反應**（V6e）—— 與 P5d 小樑腔室同屬 M7 結構工作，可併案。
- Sobol／LHS 全域靈敏度仍未實作（`sensitivityLHS`、`sobolIndices` 仍為骨架）。
- `plotDoseSurface` / `plotTrajectories` / `plotStructure` / `plotBifurcation` 仍為骨架 —— 圖形目前直接寫在各實驗腳本內，尚不需要抽象層。

---

## 附錄 C19：P5d 小樑腔室 —— 機制確認、標的未達，**且缺口不在腔室** (2026-07-26)

**小樑腔室做出來了，也確實給出 3.6 倍放大 —— 但 V8 停在 +4.5%，未達 +11–14%。診斷結果推翻了 P5d 的前提：BV/TV 不是槓桿。真正的缺口是 `delta_ab`，而它現值的來源正是 C14 揭露為假影的那個 V8。**

### C19.1 建了什麼

`src/params/trabecularParams.m`：由皮質參數集導出腰椎小樑腔室。**生物學完全不動** —— 所有訊號、細胞族群、全身參數共用（`siteRHS` 仍是單一真相源），只覆寫結構、幾何、載荷，以及被這兩者**強迫**改變的兩個參數。

| 覆寫 | 值 | 來源 |
|---|---|---|
| `r_p_0` / `r_e_0` | 17.0 / 1.0 mm | L2 椎體（Tot.Ar ≈ 900 mm²）；管狀模型需 r_e < r_p |
| `f_bm_0` | 0.12 | 椎體 BV/TV（成人 0.07–0.15） |
| `w_wall` | 0.13 mm | Tb.Th ≈ 130 μm，非皮質壁 1 mm |
| `M_L_0` / `F_L_0` | 0.30 N·m / 180 N | 脊椎以軸向為主，非彎曲 |
| `eps_model_star` | 3.0e-3 | 見 C19.2 |
| `K_tau` | 549.3（皮質 2000） | 見 C19.2，**由匹配導出，非擬合** |
| `k_res` | 1.71e-8（皮質 3.74e-7） | 校至**小樑周轉標的**，見 C19.2 |

**一項免費的一致性檢核**：`E_ref` 與 `kappa_E` 與皮質共用未動，代入 BV/TV=0.12 得 **E_app = 99.8 MPa** —— 正落在椎體小樑骨的實測區間（50–300 MPa）。彈性律本身跨兩個數量級的孔隙率仍成立，無人調參。

### C19.2 過程中發現的兩個**結構性約束**（本附錄最有價值的部分）

**(1) 共用訊號鏈強迫兩個腔室坐落在同一個剪應力設定點。**
`siteRHS` 的訊號參數共用，故 mechanostat 的湧現設定點也共用。但椎體在真實載荷與 BV/TV 下承受約 **2773 με** 的組織應變，皮質只有 **762 με**。若不處理，小樑站根本不在穩態、會立刻漂移。解法是讓孔彈性傳遞係數 `K_tau` 不同 —— 這**可辯護而非湊數**：`K_tau` 是微結構性質（滲透率、小管幾何），小樑骨包不是骨單位皮質骨。**設定方式是匹配基線剪應力，不是擬合任何結果**（`test_trabecular` 斷言兩者相等至 1e-6）。

> **這是 P5d 最重要的一般性發現**：任何多腔室擴充都必須先處理「共用訊號鏈 vs 各腔室不同組織應變」的相容性，否則新腔室不會有穩態。

**(2) Frost 的 MES_m 是應變閾值，故也必須隨腔室調整。** 沿用皮質的 1500 με 會讓 modeling 項在小樑腔室**永久開啟**（基線 2773 με > 1500），使椎體無限外擴。設為 3.0e-3（高於小樑基線）。

**(3) 周轉率必須各自校正。** 同樣的絕對表面速率，作用在少 8 倍的骨量與薄 7.7 倍的壁上，周轉快約 60 倍 —— 放著不管是 **438 %/yr**。故 `k_res` 校至**小樑自身的周轉標的**（文獻 15–30 %/yr，取 20），完全類比於皮質 `k_res` 校至 V1。**V8/V10 因此仍是 hold-out。**

校正後：周轉 20.00 %/yr、24 個月漂移 **−0.000%**、`validity.ok=1`（最大應變 2777 με，遠低於 7000 με 上限）。

### C19.3 結果：機制確認，標的未達

同一藥物、同一生物學、同一 `delta_ab`，只有結構不同：

| | 皮質 | 小樑 | 標的 |
|---|---|---|---|
| **V8** @12 mo | +1.254% | **+4.471%** | +11 ~ +14 ❌ |
| **V10** 停藥後 | +0.146% | +0.920% | < 0 ❌ |
| 放大倍率 | — | **3.6×** | — |

**低 f_bm 腔室確實放大藥效 3.6 倍 —— 但仍差 2.5–3 倍。**

### C19.4 ⚠️ 診斷：**P5d 的前提不成立 —— BV/TV 不是槓桿**

掃 BV/TV（各自重校周轉至 20 %/yr）：

| BV/TV | 0.15 | 0.12 | 0.10 | 0.08 | 0.06 |
|---|---|---|---|---|---|
| V8 @12 mo | +4.355 | +4.368 | +4.330 | +4.458 | +4.594 |

**V8 對 BV/TV 幾乎完全不敏感**（整段 4.33–4.59%）。亦即「腔室要夠稀疏才有空間致密化」這個 P5d 的核心論證，**在周轉被釘住之後就不再是限制因素**。3.6 倍的放大來自周轉（20 vs 7.19 %/yr）而非 BV/TV。（注：BV/TV ≤ 0.08 時 `validity.ok=0`，已逸出彈性域，不可採信。）

**真正的槓桿是 `delta_ab`**（硬化蛋白抗體效力）：

| `delta_ab` | ×1（現值 0.0918） | ×2 | ×4 | ×8 |
|---|---|---|---|---|
| V8 @12 mo | +4.471 | +9.086 | +18.450 | +31.704 |
| V10 停藥 | +0.920 | +1.864 | **−0.013** | −6.527 |

近線性，**標的 +11–14% 落在 ×2.5–3 之間；且 `delta_ab` 夠大到滿足 V8 時，V10 也自動翻為正確的負號** —— 兩個標的由同一個參數控制，這是內部一致的圖像，不是兩個獨立的湊合。

**為何這是合理而非開後門**：`delta_ab = 0.0918` 是 P4 校正時**對著 V8 擬合**出來的，而 **C14 後來證明那次 V8「通過」倚賴礦化膨脹假影**。亦即現值是對一個已知被污染的標的擬合的產物，本來就該重估。在正確的腔室（小樑）與正確的礦化模型（v2.3）下重擬 `delta_ab`，是修復一個已知缺陷，不是新增自由度。

### C19.5 未做、且刻意不做的

- **未重擬 `delta_ab`**。`delta_ab` 是**共用**參數，動它會同時影響皮質結果，須走完整校正流程（`calibrate` + V1/V2/V7 複驗 + V6/V14 盲測複驗），非本階段可草率為之。**列為 P5g，且是目前價值最高的單一動作**（一個參數同時解決 V8 與 V10）。
- **未建雙腔室管線**（皮質站 + 小樑站共用鈣池）。**刻意先做科學再做結構**：上述探針顯示即使建好管線，在現行 `delta_ab` 下 V8 仍達不到，故管線不是瓶頸。管線的價值在於「同一個體內皮質與小樑對同一介入的不同反應」，屬 N3 的延伸，應在 `delta_ab` 重擬之後再做。所需改動已勘察清楚：`makeContextTwoSite` / `rhsTwoSite` / `baselineState` / `simulate` 的每站 `p` 覆寫（各站 `D_eff_0` 亦須以自身基線正規化）。

### C19.6 交付

`src/params/trabecularParams.m`、`tests/test_trabecular.m`（5 項）、`E4_pharmacology` 新增小樑臂與第三面板。**72 測試全過。**

---

*文件結束｜v2.8（P5d 小樑腔室：3.6× 放大確認，V8 未達；缺口診斷為 delta_ab 而非 BV/TV）｜2026-07-26*
