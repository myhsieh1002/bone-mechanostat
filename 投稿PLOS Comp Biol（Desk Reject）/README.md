# 投稿 PLOS Computational Biology — 文件清單與狀態

主論文投稿資料夾。稿件版本對應模型 **v2.14**（84 測試全過），所有數字由 `experiments/E0–E6` 於 v2.11 最終參數下重跑產生。

---

## 檔案

| 檔案 | 內容 | 狀態 |
|---|---|---|
| **`manuscript.docx`** | **Word 版主稿（建議用這份投稿）**。Times New Roman 12 pt、雙倍行距、連續行號、頁碼、三位作者與上標單位編號 | ✅ 完稿並經 LibreOffice 轉 PDF 目視確認 |
| `manuscript.tex` | PLOS LaTeX 版主稿（替代方案）。內建 `thebibliography`，不需 `plos2015.bst` | ✅ 完稿（⚠️ 未經編譯驗證） |
| `references.bib` | BibTeX 版書目（選用；欲改用 BibTeX 請見 `manuscript.tex` 末段註解） | ✅ 完稿 |
| `manuscript.md` | Markdown 版主稿（內容與 .docx／.tex 相同，供閱讀／改稿） | ✅ 完稿 |
| **`manuscript_zh-TW.docx`** | **中文校稿版**（`.md` 亦附）。逐段對應英文版、數值完全一致、關鍵術語附原文。**非投稿檔案，僅供內容校對** | ✅ 完稿 |
| `build_docx.js` | 由 Markdown 產生 Word 的腳本（`node build_docx.js <in.md> <out.docx> [字型]`），可重現上述兩份 .docx | ✅ |
| `cover_letter.md` | 投稿信 | ✅ 完稿 |
| **`figures_tiff/Fig1–Fig7.tif`** | **投稿用圖檔**：2250 px × 7.50 in、300 dpi、LZW、文字 ≥8 pt —— 全部符合 PLOS 規格 | ✅ 由 `experiments/exportFiguresPLOS.m` 產生 |
| `figures/Fig1–Fig7.{png,pdf}` | 同樣七張圖的 PNG／向量 PDF（閱讀與投影片用；**尺寸超過 PLOS 上限，勿直接投稿**） | ✅ |
| `supporting_information/S1_Text_model_equations.md` | M1–M8 完整方程式、小樑腔室、有效性域、數值方法 | ✅ 完稿 |
| `supporting_information/S1_Table_parameters.csv` | 全參數（值、單位、上下界、模組、出處、信心度） | ✅ **v2.13 全表改為英文**（PLOS 要求），`data/` 已同步為同一份 |
| `supporting_information/S2_Table_validation_targets.csv` | V1–V16 標的（範圍、容差、對應實驗、hold-out 狀態、**執行結果**） | ✅ **v2.13 全表改為英文**並補上 V7b/V11/V13/V15 的評估結果 |
| `supporting_information/S1_Fig_identifiability.png` | 辨識性分析（相關對二維 χ² + 三參數一維剖面） | ✅ 已產生 |
| `references_verified.md` | **22 筆參考文獻逐筆查證紀錄**（PubMed + Consensus）、查證中發現的更正、全文取得優先序 | ✅ 完稿 |

---

## 圖對照表

| 稿件 | 產生腳本 | 內容 |
|---|---|---|
| Fig 1 | `E0_baseline.m` | 基線穩態 + **湧現設定點 761.8 με**（hold-out） |
| Fig 2 | `E1_doseResponse.m` | 劑量–反應：循環數（V4）、頻率（V5b，**兩層符號相反**）、休息插入（V5） |
| Fig 3 | `E2_calciumLoading.m` | **P1**：鈣 × 負荷因子設計，BMC 為主、aBMD 並列顯示 DXA 稀釋 |
| Fig 4 | `E3_unloading.m` | 廢用（V2/V3）＋ 最小有效對策 |
| Fig 5 | `E4_pharmacology.m` | Romosozumab 四臂、V9 自限、小樑 vs 皮質（V8/V10） |
| Fig 6 | `E5_siteSpecificity.m` | **P2**：V6a–f 盲測六項全過 ＋ 全身介入對照 |
| Fig 7 | `E6_bifurcation.m` | **P3 否證**：凍結幾何分支 ＋ 不凍結幾何的遲滯探針 |

---

## 稿件中的關鍵數字（v2.11 重跑值）

| | 值 | 標的 | |
|---|---|---|---|
| V1 骨轉換 | 7.03 %/yr | 5–10 | ✅ |
| V2 廢用流失 | 1.196 %/mo | 1.0–1.5 | ✅ |
| V3 硬化蛋白（廢用） | +61.2 % | 上升 | ✅ |
| V7 鈣效應 | +0.323 % 且達平台 | < 1 %（P1 子句 1） | ✅ |
| V8 romosozumab（小樑） | +12.160 % | 11–14 | ✅ |
| V16 停藥 CTX 過衝 | 1.184 × | 1.2–1.4 | ❌ **未達**（差 0.016，容差 0.15；V7/V16 結構衝突，見 C27.5） |
| **V10 停藥 BMD（hold-out）** | **−11.471 %** | < 0（僅方向） | ✅ 方向；**幅度過衝**：吐回增益 111.8 %，24 個月低於基線 1.47 %，臨床為「趨近」基線 [23] |
| **V14 湧現 ε\*（hold-out）** | **761.8 με** | **300–1500**（Frost lazy zone，v2.12 收緊） | ✅ |
| **V6a–f（hold-out）** | 六項全在容差內 | Haapasalo | ✅ |
| P1 子句 2（BMC @2949 με） | **+4.633 %** | > 4 % | ✅ |
| P1 負荷／鈣比 | 14.3× | | |
| P2 局部 vs 全身 | +12.48 % vs ±0.0000 % | | ✅ |
| P3 全模型遲滯探針 | 回復 100.4 %，無遲滯 | | ❌ **否證** |
| V5b 骨層級頻率符號 | r = −0.998 | 應為正 | ❌ 未達 |
| V11 流失–回復不對稱 | 25.8 倍 | > 3 | ✅（v2.13 首次執行） |
| V7b 血清鈣 MR | +0.124 % | 不應上升 | ❌ 符號錯（v2.13 首次執行） |
| V13 硬化蛋白雙重作用 | 1.42 倍 | 約 7 倍 | ❌ 幅度不足（v2.13 首次執行） |
| V15 停經幾何 | 骨膜 −0.0022 mm | 應外擴 | ❌ 後半失敗（v2.13 首次執行） |

> **v2.13 更正**：先前寫「V5b 唯一未達」是錯的 —— V7b/V11/V13/V15 當時根本沒有被任何實驗執行過。跑完之後共四項未達。詳見附錄 C24 與稿件 Results 新節。

---

## 送出前仍需補齊

- [x] ✅ **參考文獻**：22 筆全數查證為真（無杜撰），已依 Vancouver 格式排入 `manuscript.md`。查證紀錄見 `references_verified.md`
- [x] ✅ **三筆卷期／文章號已補齊**：Fu 2025 = 286:109931｜Marques 2023 = 11:1140673｜Schulte 2026 = 17:3759。**參考文獻段已完成，可直接投稿**
- [x] ✅ **V14 標的已依原文收緊**：100–1500 → **300–1500 με**。Frost 的 lazy zone 嚴格介於 remodelling 閾值上緣（300）與 modelling 閾值下緣（1500）之間；舊下界 100 是 remodelling 區間的**下**緣，把 hold-out 放寬了。收緊後 761.8 με 仍通過，84 測試全過
- [ ] **Funding statement**：稿件與 `cover_letter` 均留空待填
- [x] ✅ **圖檔已轉 TIFF**：`figures_tiff/`，全部 2250 px × 7.50 in、300 dpi、LZW、≥8 pt。由 `experiments/exportFiguresPLOS.m` 可重現
- [x] ✅ **Repository / DOI 已填入**：https://github.com/myhsieh1002/bone-mechanostat｜concept DOI **10.5281/zenodo.21592303**｜v2.25 version DOI **10.5281/zenodo.21784609**（Zenodo 出 release 後補填）
- [ ] **作者貢獻（CRediT）**：三位作者，須於投稿系統逐項勾選各人貢獻
- [x] ✅ **兩處筆誤已確認**：第二作者 email 為 `purplering@icloud.com`；單位名稱為 "Center for Evidence-Based Medicine"。稿件內皆用正確版本
- [ ] **CRediT 貢獻**：主持人自行填寫。稿件 Declarations 已留帶分類清單的空位（`[roles]`），投稿系統內另需逐項勾選
- [x] ✅ **LaTeX 轉換完成**：`manuscript.tex`
- [ ] **⚠️ 編譯驗證**：本機無 LaTeX 工具鏈，`manuscript.tex` **僅通過靜態檢查**（環境配對、括號平衡、cite↔bibitem、label↔ref 全數一致），**尚未實際編譯**。請在 Overleaf 或本機 TeX 環境跑一次 pdflatex 確認
- [x] ✅ **Funding 已填入**："The author received no specific funding for this work."

---

## 作者

| | 姓名 | 單位 | ORCID |
|---|---|---|---|
| 第一作者 | Hsiang-Lin Lee, M.D., Ph.D. | Institute of Medicine, CSMU；Department of Surgery, CSMU Hospital | 0000-0003-1422-1042 |
| 第二作者 | Tzu-Ling Wang, MSN | School of Nursing, CSMU | 0000-0003-3520-0531 |
| **通訊作者** | **Ming-Yu Hsieh, M.D., Ph.D.** | School of Medicine, CSMU；Division of Pediatric Surgery 與 Center for Evidence-Based Medicine, CSMU Hospital | 0000-0002-5797-3474 |

通訊信箱：cshy1392@csh.org.tw ｜ 第二作者：purplering@icloud.com ｜ 第一作者：s31079@gmail.com

---

## 資金與資料聲明（建議用語）

**Funding**（作者無經費來源，PLOS 要求仍須填寫）：

> The authors received no specific funding for this work.

**Data availability**（PLOS 要求「Data Availability Statement」）：

> All model code, parameter tables, validation target definitions, experiment
> scripts and the automated test suite are available at
> https://github.com/myhsieh1002/bone-mechanostat and archived at Zenodo
> (concept DOI: 10.5281/zenodo.21592303; this version: 10.5281/zenodo.21784609). No empirical data were generated; all
> validation targets are drawn from published literature and are listed with
> sources in S2 Table.

---

## ⚠️ 用語紀律：不得宣稱「pre-registered」

三個預測確實是在**任何參數被擬合之前**就寫進計畫書的，時序如下且可由版本歷史查核：

| | |
|---|---|
| 假說寫定（含完整 P1/P2/P3） | 2026-07-23，首個 commit |
| 模型校正 | 2026-07-25 |
| P3 否證 | 2026-07-25 |
| **首次公開** | **2026-07-26** |

**但這不是 pre-registration。** 從未在 OSF、AsPredicted 或任何公開登記平台登錄；程式庫在 2026-07-26 之前都是私有的；且當日曾因移除稿件而重寫歷史（author date 保留，SHA 全變），使 git 時間戳的證據力弱於登記平台。

稿件現在的寫法是陳述事實順序並明確聲明不主張正式預先登記。**改稿時不得把「in advance of calibration」升級為「pre-registered」** —— 審稿人若追問登記編號，我們拿不出來，那比不提更傷。

（若未來研究想取得真正的預先登記，須在執行前於 OSF 等平台登錄；無法追溯補辦。）

---

## 敘事紀律（撰稿與改稿時務必維持，來源見計畫書附錄）

1. **P3 的否證寫進主論文，不放補充材料**（C16）。它是全文唯一「模型推翻自身先驗假說」的結果。
2. **陡峭 ≠ 雙穩；速率不對稱 ≠ 動力學不可逆**（C16.2）。E2≈0.92 的陡過渡與 V11 的回復慢，都不得寫成雙穩態證據。
3. **P1 三個子句各自帶度量**（C23）：子句 1 用 aBMD、子句 2 用 **BMC 且負荷 ≈2900 με**、子句 3 用**絕對框架**。換度量會翻轉子句 2 與 3 的結論。
4. **hold-out 就是 hold-out**：V6a–f、V10、V14 從未進入目標函數，敘述時須明確標示，這是全文預測力主張的基礎。
5. **假影要如實交代**（C15.4、C17）：99 mm 皮質假影與其修正已寫入 Results，不隱去。
