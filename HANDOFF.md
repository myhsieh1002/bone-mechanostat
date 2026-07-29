# HANDOFF — bone-mechanostat

**接手者請先讀這份，再讀 `PROJECT_PLAN_bone_mechanostat.md`（v2.19，含附錄 C1–C30）與 `README.zh-TW.md`（中文工作版；`README.md` 為對外英文版）。**

主持人：謝明諭 (Ming-Yu Hsieh)｜MATLAB R2026a｜語言：程式碼英文、討論與計畫書中文。

---

## 0. 現況與最重要的三件事（2026-07-28 更新）

**版本 v2.19｜84 測試 0 失敗｜稿件與 HEAD 完全一致（三格式 + 兩份 docx + 七張 TIFF 皆為當前值）**

V1–V16 全部標的都已用「主張／判準／誠實比對」過完（C24–C26）。此後 P5k→P5n 又動了四輪模型。

### ⚠️ 一、我們正在 shipping 一個已知錯六倍的參數

`s2_Sv = 3`，而 Lerebours 實測是 **0.5**（C30）。皮質坐在 f_bm = 0.95，正在他們量測的範圍內。

**改成 0.5 會讓 V2 變成無法達成** —— 流失降到 0.43 %/月，把 `K_S` 掃到下界也只飽和在 0.94 %/月。這是結構結論：**廢用流失有相當部分一直靠這個陡六倍的反應撐著**。

> 維持 3 是**工程上的保守選擇，不是科學判斷**。0.5 才是有依據的值。已寫入稿件 Limitations（連同「其他標的在該改動下反而都變好」這一點）。
>
> **待辦 P5n′**：先找出被誇大的 S_v 在代償什麼（候選：骨細胞凋亡對吸收的直接驅動、廢用時 `xi` 表面分配的偏移），補上後再採用 0.5 並重擬，複驗 V1／V2／**V11**／P3 與三組盲測。

### ⚠️ 二、取得全文後，第一件事是核對我們宣稱它說了什麼

這一輪四篇文獻，**三篇推翻了我們自己的引述**：

| | 我們原本寫的 | 原文實際上 |
|---|---|---|
| **Srinivasan** | V5 標的「2–5 倍」 | **是我們自己編的**。實測 5.8 倍 |
| **Wijenayaka** | V13「約 7 倍」拿去比 `pi_L` | 那 7 倍是**14 天共培養的吸收凹陷面積**，不是瞬時活化項。**我們比錯了量** |
| **Fu** | 「Awaits Fu 2025」四個速率常數 | Fu 只有**方程式**（六個 k₁–k₆），**數值在館際掃描不含的 Appendix**；原始出處還是 Mao 2022 的手指觸覺模型 |
| Marques | 支持對數形式 | ✅ 查核無誤 |

**只有一篇查核無誤。** 加上先前的 V10/V16（寫「文獻報告的」卻無出處）與 V1/V2/V3（無來源），這已是第五、六次。

> **規則**：「Awaits ⟨文獻⟩」必須寫明等的是**方程式、數值，還是量測**。抽參數之前先核對引述。

### 三、P5k–P5n 四輪的淨結果

| | 結果 |
|---|---|
| **P5k** 鈣模組兩半重建 | ✅ 血鈣擺動 15 %→**1.6 %**；廢用 PTH −0.01 %→**−19.9 %**（臨床 −24 %）。**代價**：V7 掉到區間下緣；新生 V7/V16 結構衝突（V16 = 1.183 未達） |
| **P5l** `nu_E` 1.0→**2.55** | ✅ 採用（Currey）。`kappa_E` 全域改 3.13 則**撤回** —— 小樑模數掉到 26 MPa、逸出彈性域 |
| **P5m** `kappa_E` 分腔室 | ✅ 皮質 3.13／小樑 2.00（Gibson–Ashby）。**零重擬**，盲測全存活 |
| **P5n** `s2_Sv` 分腔室 | ❌ **診斷完成但未採用**（見上） |

**三次結構改動後，V6a–f、V10、V14 三組盲測全數存活。** 這是全文預測力主張最強的支撐。

**副產品**：V5 由「過衝 2.4 倍」變成**吻合至 4 % 以內**（6.02 對實測 5.8），純粹是 Currey 指數帶來的，沒有為它調過任何參數。

### 送出前仍需

1. **CRediT 貢獻**（主持人自填）
2. **`manuscript.tex` 從未編譯** —— 本機無工具鏈，僅過靜態檢查。走 LaTeX 路線請先在 Overleaf 跑一次
3. 投稿系統 Funding 欄：`The authors received no specific funding for this work.`

### 尚未榨乾的文獻（全文都在 `Reference/`）

`a03` Haapasalo（`r_p_0`/`r_e_0` 的絕對值在長條圖裡，文字層抽不出，需目視讀圖）、`a04` Li、`a05` Weinbaum、`a06b` Martin、`a09` Cosman、`a11` Schulte。

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

**已知缺陷（v2.19 更新）**：

| | 狀態 |
|---|---|
| ~~血清鈣擺動 15 %~~ | ✅ **P5k 已修** → 1.6 % |
| ~~骨→血耦合可忽略~~ | ✅ **P5k 已修** → 廢用 PTH −19.9 %（臨床 −24 %） |
| **`s2_Sv` 比實測陡六倍** | ⚠️ **已知未修**，改了 V2 就達不成（C30，見 §0） |
| **V7/V16 結構衝突** | ⚠️ 同一個 `lambda_P` 兩邊拉，V16 = 1.183 未達（C27.5） |
| **V13 天花板 1.33 倍** | ⚠️ 但**標的本身被我們比錯量**了，需以吸收輸出重新定義（C30 前的 a02 查核） |
| **V5b 頻率符號** | ⚠️ 架在佔位通道常數上；Fu 未能解鎖 |
| **停經後骨膜不外擴（V15）** | ⚠️ 未修 |

四項未修者**全部已如實寫入稿件 Results 與 Limitations**。

---

## 2. 現況：v2.19，84 測試全過，已公開並取得 DOI

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
