# 投稿檢查清單 — PLOS Computational Biology

狀態日期 2026-07-31｜模型 v2.25｜91 測試 0 失敗
稿件檔案在 `投稿PLOS Comp Biol/`（**已 gitignore，只在本機**）。

> **⚠️ 用法**：`✅` 是我實際查過的；`⬜` 是你要做的；`❓` 是我**無法**代查、必須以 PLOS 當前的 Submission Guidelines 為準的（規範會改版，我不從記憶引用具體數字上限）。

---

## A. 檔案清單

| | 檔案 | 狀態 |
|---|---|---|
| ✅ | `manuscript.docx` | **建議投稿用**。由 `manuscript.md` 產生，Times New Roman 12 pt、雙倍行距、連續行號、頁碼 |
| ✅ | `manuscript.md` | Word 的來源。**改內容改這份** |
| ⬜ | `manuscript.tex` | LaTeX 版，**從未編譯過**。走 LaTeX 路線必須先在 Overleaf 跑一次 |
| ✅ | `figures_tiff/Fig1–7.tif` | 2250 px 寬 × 7.50 in、300 dpi、LZW、字級 ≥ 8 pt。由 `exportFiguresPLOS.m` 產生並自檢 |
| ✅ | `supporting_information/S1_Text_model_equations.md` | 模型方程式（v2.25 已與程式碼同步） |
| ✅ | `supporting_information/S1_Table_parameters.csv` | 參數表（`data/` 的複本） |
| ✅ | `supporting_information/S2_Table_validation_targets.csv` | 標的表（`data/` 的複本） |
| ✅ | `supporting_information/S1_Fig_identifiability.png` | 由 `exportS1FigIdentifiability.m` 產生 |
| ✅ | `cover_letter.md` / `cover_letter.docx` | v2.25 已全面對帳。**投稿用英文版** |
| ✅ | `cover_letter_zh-TW.md` / `.docx` | 中文校稿版，**非投稿檔案**。數值與英文版逐項對過 |
| ✅ | `references.bib` / `references_verified.md` | 29 筆，逐筆查證紀錄齊 |
| ❓ | SI 檔案格式 | PLOS 對 SI 可接受的格式與命名有規定。`.md` 的 S1 Text **可能需要轉成 PDF 或 DOCX** —— 依當前規範確認 |

---

## B. 稿件內容（PLOS 特有）

| | 項目 | 狀態 |
|---|---|---|
| ✅ | **Author summary** | 有。PLOS Comp Biol 必要，非技術性讀者取向 |
| ✅ | Abstract（Background / Methods / Results / Conclusions） | 有 |
| ✅ | Introduction / Results / Discussion / **Materials and methods** | 齊（PLOS 用 "Materials and methods"，不是 "Methods"） |
| ✅ | Figure captions | 七張全在正文的 Figure captions 節 |
| ✅ | Supporting information captions | 四份全在正文，與檔名對應 |
| ✅ | **Short title** | v2.25 新增：*A mechanotransduction-resolved multiscale model of bone adaptation*（正標題 121 字元太長）。❓ 字數上限依當前規範確認 |
| ✅ | 引註連續、無斷號 | 三份格式均為 1–29 全用到、無超範圍 |
| ✅ | 三格式數值一致 | `tools/reconcile_manuscript_numbers.py` 逐段比對，殘差僅標記假影 |

---

## C. 投稿系統要填的欄位

| | 欄位 | 內容 |
|---|---|---|
| ⬜ | **Financial Disclosure** | `The authors received no funding for this work.` |
| ⬜ | **Competing Interests** | `The authors have declared that no competing interests exist.` |
| ✅ | **Data Availability** | 全部程式碼、參數表、標的表、實驗腳本與測試已公開：GitHub + Zenodo concept DOI `10.5281/zenodo.21592303` |
| ⬜ | **Ethics** | 純計算研究，不涉人體或動物受試者，無須 IRB |
| ⚠️ | **CRediT 貢獻** | 見 D 節 —— **Lee 與 Wang 兩位是我草擬的，送出前必須由你確認** |
| ⬜ | 通訊作者 ORCID | 0000-0002-5797-3474 |
| ⬜ | 建議／排除審稿人 | 選填 |
| ❓ | 預印本（bioRxiv） | PLOS 允許，是否先掛預印本由你決定 |

---

## D. ⚠️ CRediT —— 我草擬的部分必須確認

**我沒有任何關於 Lee 與 Wang 實際做了什麼的資訊。** 以下是依「職稱＋版本庫顯示的分工」推的**草稿**，不是事實陳述：

| 作者 | 草擬角色 | 推的依據 |
|---|---|---|
| **Hsiang-Lin Lee**（MD PhD，醫學研究所／外科部） | Conceptualization; Investigation; Supervision; Validation; Writing – review & editing | 第一作者、臨床背景 → 臨床問題設定與臨床合理性把關 |
| **Tzu-Ling Wang**（MSN，護理學系） | Data curation; Investigation; Resources; Writing – review & editing | 保守取一組不與 Hsieh 重疊的角色 |
| **Ming-Yu Hsieh**（通訊） | Conceptualization; Data curation; Formal analysis; Investigation; Methodology; Project administration; Software; Validation; Visualization; Writing – original draft; Writing – review & editing | 你自己確認過的 |

> **兩點要你自己衡量，我只陳述事實不做判斷：**
>
> 1. **版本庫顯示程式碼全部由 Hsieh 撰寫**（`CITATION.cff` 的 `authors:` 只有 Hsieh），計畫書與 handoff 全程記載 Hsieh 為主持人。若 CRediT 如上草稿，**第一作者的角色不含 Software / Formal analysis / Writing – original draft**。這在計算類論文中不是不可能，但編輯有可能注意到「第一作者的貢獻組合」與作者順序的關係。
> 2. **PLOS 要求每位作者都符合作者資格條件**，且投稿時每位作者都要在系統中確認自己的貢獻。這件事只有你們三位知道實情。

---

## E. 送出前最後一次跑（順序不能顛倒）

```bash
# 1. 模型全綠
#    MATLAB: runtests("tests")  -> 應為 91 passed / 0 failed
# 2. 若動過任何模型參數，重跑實驗與圖
#    MATLAB: run(fullfile(projectRoot(),'experiments','exportFiguresPLOS.m'))
# 3. 三格式數值對帳
cd "投稿PLOS Comp Biol" && python3 ../tools/reconcile_manuscript_numbers.py
# 4. 最後才重建 Word
node build_docx.js ".../manuscript.md"       ".../manuscript.docx"
node build_docx.js ".../manuscript_zh-TW.md" ".../manuscript_zh-TW.docx" "PingFang TC"
```

> 這個順序是 v2.24 學到的：那一輪先改稿件、後對帳，結果對完帳又發現兩個實質結果已經變了（C35.8）。

---

## F. 這篇稿件會被問到的地方（先想好答案）

依證據強弱排，全部已寫進 Results 或 Limitations，不是隱藏項：

| | 審稿人可能問 | 稿件現在怎麼回答 |
|---|---|---|
| 1 | **六個校正標的有兩個未達**（V7 = 0.663、V16 = 1.124） | 兩者都以宣告容差報告、`pass` 保持 false。V7 的方向被論證為**強化** P1（鈣是許可性的）；V16 的 1.2–1.4 帶是我們自訂的，原文只說「above baseline」，而模型 1.124 > 1 |
| 2 | **`s2_Sv` 已知比實測陡六倍卻照樣出貨** | Limitations 明寫，並報告三個補救機制全部失敗、各敗在不同環節 |
| 3 | **V5b 頻率符號與實驗相反** | 明寫為模型與實驗不符，且指出這是佔位通道常數最尖銳的可證偽後果 |
| 4 | **V5 休息插入短少 21 %** | 明寫，並用它當「不要把接近的吻合當成驗證」的反例 |
| 5 | **`delta_ab` 不可辨識** | 明寫，並聲明報告的值滿足帶但不是點估計 |
| 6 | 四個質性標的三敗（V7b、V13、V15） | 獨立一節「Four targets we had specified but never run」，不移到 SI |
| 7 | **不得寫 "pre-registered"** | 稿件僅陳述順序，並明確聲明不主張正式預先登記。**不要在 cover letter 或回覆審稿時升級這個說法** |

**最強的三項**（回覆審稿時先講這些）：八項盲測全過（V6a–f 六項 + V10 + V14）、Frost 設定點 787 με 湧現且從未擬合、P3 自我否證寫在正文。
