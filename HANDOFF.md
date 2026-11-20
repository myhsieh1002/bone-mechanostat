# HANDOFF — bone-mechanostat（0006 骨骼鈣質吸收相關研究）

> 最後更新：2026-11-20 12:10
> 專案路徑：`0001 臨床醫學研究/0006 骨骼鈣質吸收相關研究`
> 本檔為精簡版現況；2026-10-19 以前的 832 行完整工作紀錄（含 P5k–P5p 各輪、三次退稿、踩雷點、TriNetX 構想）原封保存在 `docs/HANDOFF_archive_2026-11-09.md`，決策理由見 `DECISIONS.md`，技術細節見 `PROJECT_PLAN_bone_mechanostat.md` 附錄 C1–C37。

## 目標
以八模組多尺度 ODE 模型（器官力學 → 孔彈性剪力 → 三態離子通道 → sclerostin–Wnt → RANK/RANKL/OPG 細胞族群 → 皮質幾何 → aBMD，加全身鈣–PTH–1,25D 雙向耦合）回答「鈣是許可性、負荷是指令性」，並檢定骨鬆是否為替代穩態。產出：Paper 1（模型與三個預測，P1 ✅／P2 ✅／P3 否證）正在投 Journal of Theoretical Biology；第二期（Paper 2–4）計畫已擬。主持人謝明諭；程式英文、討論與文件中文。

## 目前狀態

> ✅ **2026-11-18：v2.25 重現性落差已結案——根因是 MATLAB 版本，稿件不用改**。
>
> **對照結果**（21:49–21:50，R2026a Update 2，`matlab -batch`，0.9 分鐘）：R2026a **逐欄重現 2026-08-11 那次的九個標的**，包含 R2025b 跑不出來的四個——V8 12.459340、V8cort 2.329385、V10 −8.699081、chi² 4.811277。同行程跑兩次逐位元相同。
>
> **所以**：v2.25 的封存數字產生於 **R2026a**；R2025b 在本機會決定性地給出 V8 12.6892 等不同值。抗體（romosozumab）那一支對版本敏感，其餘路徑不敏感。非決定性、執行緒數、晶片架構、參數改動四個假說早先已排除（`docs/v2.25_重現性落差_2026-11-18.md` §6），版本假說現在獲得正面證實。
>
> **稿件：不用改，一字都不用。** Table 1 的 24 個數字 **24/24 重現**。早上提出的三處修改（+12.46 → +12.69 %、+2.33 → +2.32 %、5.3 → 5.5 倍）**全部撤回**——那是 R2025b 的產物。**§2.4 寫 R2026a 也是對的，不要改**（與早上的建議相反）。
>
> **錯的是本檔**：(a) 下面凍結清單的 V8cort 原寫 2.3241 是轉抄錯誤，正確值 2.3294（已更正）；(b) 執行環境欄原寫「本計畫用 R2025b」是錯的，正確是 **R2026a**（已更正，但牽動 iBioLab 版本政策與看板 `matlab` 欄位，**待 PI 確認**）。
>
> **待辦**：在 R2026a 重跑一次 `exportFiguresJTB`（約 12 分鐘）並與投稿包 `figures_tiff/` 逐檔 md5 比對，確認 10-12 那批圖出自 R2026a；比對相同則 B3 可直接推進。今天早上在 R2025b 產生的 Fig2–Fig8 **不可進投稿包**（它們只在結果目錄，投稿包仍是 10-12 那批，未被汙染）。`docs/zenodo_v2.26_準備清單.md` §4 的「§2.4 改成 R2025b」那一條要刪除，§7 release note 的測試版本要改 R2026a 並在 R2026a 下重跑測試套件。
>
> 完整分析與三欄對照見 `docs/v2.25_重現性落差_2026-11-18.md` §10。**沒有改任何參數、模型檔或稿件。** 結果在 `~/Documents/MATLAB/bone-mechanostat-results/`（`run_20261118.log`、`frozen_check_20261118.mat`、`xcheck_r2026a_20261118.log`、`xcheck_r2026a_20261118.mat`）；11-17 當機中斷那次的 27 個檔案保留在 `_interrupted_20261117T2347/`。r2026a 槽已於 21:51 交棒給 cnt-t1。

- **模型 v2.25 凍結**：91 測試 0 失敗（2026-10-19 重跑確認，但**是在 R2025b 下跑的**；本計畫正式版本既然是 R2026a，發 v2.26 前應在 R2026a 下重跑一次，約 23 分鐘）；基準值 V1 7.3306、V2 1.2202、V7 0.6630（未達）、V8 12.4593、V8cort **2.3294**（2026-11-18 更正：原寫 2.3241 是轉抄錯誤；R2026a 與 2026-08-11 都給 2.329385，稿件的 +2.33 % 也對應它）、V16 1.1238（未達，帶為自訂）、V10 −8.6991（盲測）、V14 786.7704（盲測）、chi² 4.8113。Zenodo v2.25 `10.5281/zenodo.21784609`。
- **JTB 投稿包** `投稿Journal of Theoretical Biology/` 改寫完成、**尚未送出**。2026-10-19 新增 §4.4 一句（M6 時間尺度，C37）並重建 `manuscript.docx`；S1_Table 的 D_C/D_A 說明已同步。Highlights、cover letter、declaration docx 已備。
- **文獻庫** `Reference/`：32 筆、32 PDF、缺 0（F01 Spatz 2012 已於 2026-11-11 由 RapidILL 到件）；**32 篇全部有 `.summary.md`**（F01 的於 2026-11-17 補齊）。三則入庫通知（10-13、10-16、11-11）全部處理完畢，無未打勾項目。
- **文獻核對結果**：約 40 句準確、約 12 句需限定、4 處錯誤、1 個參數出處錯誤；全部列在 `文獻閱讀彙整與發表規劃報告_2026-10-18.md` §3（25 項）。**只做了 C37.6 第 2、3 點（D_C/D_A 出處、§4.4 一句）；其餘 23 項待 PI 裁定後修稿。**
- **投稿總覽**（Artifact 7GKp4s2F8xG59QUZSiZ8Ph，doc `bone`）：status `pending`、stage「拒稿（10-12，有外審），改寫中」、next「改投 JTB；投稿包已建，尚未送出」—— 與現況一致，送出 JTB 時改 `submitted`。
- 背景執行中／未 commit：無背景運算。**git 可用**（2026-11-18 實測：`~/.git-repos/iBioLab.git` 存在，本計畫已有 commit `1d3d683b`、`0ddcc14b`、`4ec2f50c` 並 push）——本檔舊版寫「本機沒有 git 紀錄」是錯的。iBioLab 是多 session 共用 repo：`git add` 只帶本計畫 pathspec，commit 後立刻 push，不用 `amend`／`rebase`／`reset --hard`。

## 下一步
0. **【最優先】重現性落差已結案，產圖比對也已完成；只剩兩件交 PI 確認**（`docs/v2.25_重現性落差_2026-11-18.md` §10、§12）：(a) ✅ **2026-11-19 21:53–22:06 已在 R2026a 重跑 `exportFiguresJTB` 並與投稿包逐像素比對**（`refigure_r2026a_20261119.log`）。結論：**投稿包 10-12 那批 Fig2–Fig8 出自 R2026a，資料與版面與重跑結果相同**——三方比對顯示它與 R2026a 的距離比與 R2025b 小一個數量級（面積 1/20、強度 1/7），平移 ±1 px 會讓差異由 0.30 % 暴增到 9.8 %（版面逐像素對齊），83–86 % 的殘差像素落在文字／線條邊緣。log 裡每個標的數值都與封存值相同（V8 小梁 12.459、V8 皮質 2.329、V10 −9.783、V16 1.124、V14 786.8）。⚠️ 但殘差 0.3–0.5 %（最大 25–37/255，反鋸齒點陣化差異）→ **不可宣稱圖檔位元可重現**；稿件 §2.4「每張圖由一支具名腳本重新產生」仍成立。**投稿包 `figures_tiff/` 不要更換**（10-12 那批已通過規格檢查且與數值同源，覆蓋只改位元無好處）；本次未動投稿包任何檔案。**B3 的「圖與數字同源」一項可以打勾**。今天的 R2026a 批次在 `~/Documents/MATLAB/bone-mechanostat-results/figures_jtb/`，11-18 的 R2025b 批次在 `figures_jtb_r2025b_20261118/`（版本差異的證據，勿覆蓋）。(b) ✅ **2026-11-19 主持人已確認正式版本登記為 R2026a**（見 `DECISIONS.md` 同日條目；HANDOFF 執行環境欄與看板 `matlab` 欄位均已登記）。(c) ✅ **2026-11-20 07:13–07:22 已在 R2026a 重跑 91 測試**（8.7 分鐘，`~/Documents/MATLAB/bone-mechanostat-results/runtests_r2026a_20261120.log`）：94 個 test case、**91 passed／0 failed／3 incomplete**，與 2026-10-19 的 R2025b 結果完全相同；三個 incomplete 仍是 `test_conservation`／`test_regression`／`test_steadystate` 的 `testPlaceholder`（Filtered by assumption，非失敗）。**v2.26 release note 可以寫「91 assertions, 0 failures (MATLAB R2026a Update 2)」**。腳本 `runtests_r2026a.m` 與 log 都在結果目錄。→ **發 v2.26 的技術前提已全部齊備，只等 PI 決定要不要發**（發布不可逆）。11-18 早上提的三處修改已撤回。(d) ✅ **2026-11-20 11:00–11:32 送出前三件裁定已由 PI 裁定並全部落稿**（甲(a)、乙(a)、丙(b)，見 `DECISIONS.md` 2026-11-20 條目與投稿檢查清單 B11）：V6e 改為部位誠實、hold-out **8/8 → 7/8**；§3.5 Schulte 整段改寫、§4.4 補 SOST-KO 一句；V7 帶改以全身 BMD（0.7–1.0）並寫明反向風險。**一個模型數字都沒改、沒重跑任何實驗**；`manuscript.docx`、`cover_letter.docx` 已用 docx@9.9.0 重建，新舊純文字逐段 diff 只有改寫的句子。摘要由 249 變 **250 字（JTB 上限）**。⚠️ Fig. 4A 未重畫（仍畫近端帶 +19 %），圖說已寫明，列為檢查清單 B12。
1. **PI 裁定 14 件中已決 3 件、剩 11 件**（清單在 `文獻閱讀彙整與發表規劃報告_2026-10-18.md` §6，同 `研究計畫_第二期_bone-mechanostat_2026-10-18.md` §6）。✅ 送出前必須先決定的三件已於 **2026-11-20** 裁定並落稿（V6e 部位誠實、§3.5 Schulte 改寫、V7 改全身 BMD；見上面第 0 點 (d)）。剩下 11 件是報告 §3.2–3.3 的措辭修改與 `00_reference_index.csv` 的 `why` 欄，**不阻擋送出**。
2. 其餘 11 件裁定後依報告 §3.2–3.3 修 `manuscript.md`（16 處措辭）、`parameters_literature.csv` 說明欄（tau_target、K_L3、kappa_E/nu_E、tau_50）、`00_reference_index.csv` 的 why（D04、D05、F04、B03），再重建 docx。⚠️ **`tools/reconcile_manuscript_numbers.py` 對 JTB 這一包不適用**：它比對 `manuscript.md` 與 `manuscript.tex`，而本包沒有 `.tex`（那是 PLOS 時代的檔）。等效檢查是：重建 docx 後把新舊 docx 的純文字逐段 diff（確認只有該改的句子動了），再 grep 整個投稿資料夾找過時語句。⚠️ **摘要已在 250 字上限**，再加字必須先刪字。
3. 檢查清單 `投稿Journal of Theoretical Biology/投稿檢查清單.md` B 節：**B3 發 v2.26 —— 內容已備妥，等 PI 決定發不發**（`docs/zenodo_v2.26_準備清單.md` 已於 2026-11-20 全面改寫，含 18 檔完整清單、CITATION.cff 五處修改、release note 定稿、三件待裁定）。⚠️ **發版是在獨立的公開 repo `github.com/myhsieh1002/bone-mechanostat`，本機沒有 clone**，不是在 iBioLab 這個 repo；公開 repo main 停在 `78c7fd7`（2026-09-26），距 tag `v2.25` 已 15 個 commit。測試不必重跑（`src/`、`tests/` 與 v2.25 逐位元相同，`data/` 只有說明欄變，11-20 那次 91 測試就是跑這一份）、B4 三位作者確認新標題／摘要／CRediT、B8 利益衝突 Word 檔、B9 郵寄地址核對 → 送出 → 更新投稿總覽為 `submitted`。
4. 送出後開第二期：先做子計畫 E（v3 重校正）第一項 **`D_R` 文獻化**（C37.5：7e-4 → Lemaire D_B/π_C0 ≈ 0.178 會使廢用流失 16 %/月，需重擬），再依計畫 B（第二路徑／頻率符號）→ C（感測喪失）→ D（藥理軌跡）。
5. 補文獻（報告 §5）：Fu 2025 Appendix／Mao 2022／Bae 2013、McClung S10、Spatz 2012、Cosman S3、Schulte Zenodo、Fyhrie 1995/1993、Silva & Gibson 1997、Srinivasan 2007、Robling 2001、Sasaki 2020。

## 卡住的問題／待決定事項
- 14 件 PI 裁定（上述）。
- `D_R = 7e-4/day` 是載重的佔位值（C37.5）：改成文獻值會翻掉 V2、V8；Paper 1 只在 §4.4 承認，重校正留第二期。
- Paper 2 與 Paper 3 先後順序（研究計畫 §6 第 13 項）。
- `manuscript.tex` 從未編譯（JTB 投 Word 版即可；走 LaTeX 前先在 Overleaf 跑）。

## 執行環境
- MATLAB：**本計畫用 R2026a**（`/Applications/MATLAB_R2026a.app/bin/matlab -batch`，本機為 26.1.0.3251617 Update 2）。2026-11-18 證實：v2.25 的封存數字與稿件 Table 1 都產生於 R2026a，R2025b 會在抗體那一支給出不同值（V8 12.6892 而非 12.4593）。本欄舊寫 R2025b、以及「兩版結果一致到 V8cort 第三位小數」都是錯的。**2026-11-19 主持人裁定：本計畫正式 MATLAB 版本登記為 R2026a**（看板 `projects/bone` 的 `matlab` 欄位已是 R2026a）。與 iBioLab 版本政策不衝突——該政策第一句就寫「版本以該計畫 HANDOFF 的執行環境欄為準」，「既有計畫繼續用 R2025b」只是預設值；本欄即是本計畫的登記處。（11-18 我把這描述成「政策衝突」是說重了。）⚠️ 但本計畫 11-18 曾在 R2025b 跑過，未來若有人只憑「既有計畫用 R2025b」判斷就會再踩同一個坑：**R2025b 會在抗體那一支給出對不上稿件的數字**。MATLAB MCP 連的就是 R2026a，但長模擬仍用 `-batch` 以保持與封存結果相同的執行模式。toolbox：Global Optimization（`surrogateopt`）、Parallel Computing（`parpool("Processes",3)` 上限）；`ode15s`。
- 啟動：`addpath('src'); setupPath(); maxNumCompThreads(4); runtests("tests")`（91 passed／3 incomplete 為預留檔，約 23 分鐘）；`evalTargets(getDefaultParams(reload=true), holdout=true)`。改 CSV 後**必須** `getDefaultParams(reload=true)`（persistent cache，C36.8）。
- 結果輸出：`getResultsDir()` → `~/Documents/MATLAB/bone-mechanostat-results/`（本機，不在 iCloud）。2026-11-18 的 E0–E7 輸出、Fig2–Fig8、`run_20261118.log`、`frozen_check_20261118.mat`、`xcheck_r2026a.m` 都在裡面；11-19 的 R2026a 產圖在 `figures_jtb/`，比對腳本與 log 為 `refigure_r2026a.m`／`refigure_r2026a_20261119.log`，11-20 的測試重跑為 `runtests_r2026a.m`／`runtests_r2026a_20261120.log`／`runtests_r2026a_20261119.mat`，11-18 的 R2025b 產圖保存在 `figures_jtb_r2025b_20261118/`；11-17 當機中斷那次保留在 `_interrupted_20261117T2347/`。
- Python 3.9.6：`tools/reconcile_manuscript_numbers.py`、`tools/gen_s1zh.py`（csv、re、difflib）；`fig1_schematic.py` 需 matplotlib。
- Node v24.21.0 + `docx@9.9.0`。⚠️ **2026-11-20 實測：`/usr/local/lib/node_modules` 底下只有 corepack 與 npm，沒有 docx**（本檔舊寫「全域 docx@9.9.0」已不成立，可能是後來被清掉）。重建 docx 前要先在一個暫存目錄 `npm install docx@9.9.0`，再 `NODE_PATH=<該目錄>/node_modules node build_docx.js <in.md> <out.docx> [字型]`。**版本要指定 9.9.0**：用 9.1.0 產生的檔內文完全相同但封裝位元不同（cover_letter 10,616 vs 12,788 bytes），9.9.0 才與 10-12 原檔同一量級。
- 文獻庫工具：`~/.claude/skills/ibiolab-reference-library/scripts/reflib.py index Reference "<標題>"`。
- 資料：無人體／動物資料；`data/` 只有參數與標的 CSV。純計算研究，無須 IRB（TriNetX 後續另案）。
- git：iBioLab 層級 `.git` 指向 `~/.git-repos/iBioLab.git`，**本機存在且可用**（2026-11-18 實測）。換到沒有它的機器才需要 `2_restore_on_new_mac.sh`。模型程式另有公開 repo `github.com/myhsieh1002/bone-mechanostat`（本資料夾不含其 `.git`）。

## 重要檔案地圖
| 檔案 | 用途 |
|---|---|
| `PROJECT_PLAN_bone_mechanostat.md` | 計畫書 v2.25＋附錄 C1–C37（每輪模型改動的主張／判準／比對） |
| `DECISIONS.md` | 決策歷史（2026-11-09 起；含回溯整理） |
| `docs/HANDOFF_archive_2026-11-09.md` | 2026-10-19 前的完整 handoff（踩雷點 §6、TriNetX 構想、三次退稿紀錄） |
| `README.zh-TW.md`／`README.md` | 中文工作紀錄／對外英文 README |
| `data/parameters_literature.csv` | 126 參數唯一來源（`getDefaultParams` 讀） |
| `data/validation_targets.csv` | V1–V16 標的與稽核註記 |
| `data/reference_parameters.md` | 文獻參數原始轉錄（D_OCp 已於 10-19 更正） |
| `src/model/simulate.m`、`src/analysis/evalTargets.m`、`calibrate.m` | 模擬、標的評估、五參數校正 |
| `experiments/E0–E7*.m` | 七支實驗腳本＝論文圖（JTB 圖號對照腳本目前在 `投稿Journal of Theoretical Biology/exportFiguresJTB.m`，發 v2.26 時搬進 `experiments/`） |
| `experiments/probes/C37_*.m` | D_C 量測（記憶體覆寫，不改 CSV） |
| `tools/reconcile_manuscript_numbers.py` | 稿件數字對帳（改參數後必跑） |
| `投稿Journal of Theoretical Biology/` | 現行投稿包：`manuscript.md/.docx`、`highlights`、`cover_letter`、`supporting_information/`、`投稿檢查清單.md` |
| `Reference/00_reference_index.csv`、`00_INDEX.md`、`*/*.summary.md` | 文獻庫索引與 31 份閱讀摘要 |
| `研究計畫_第二期_bone-mechanostat_2026-10-18.md` | 第二期六個子計畫、新標的 V5b′–V21 |
| `文獻閱讀彙整與發表規劃報告_2026-10-18.md` | 逐篇核對表、25 項修正清單、8 項可發表內容、14 件裁定 |
| `投稿PLOS ONE（Reject）/審稿回覆預案.md` | 審稿人原話與預案（B 節 9 處錯誤已併入 JTB 版） |

## 近期工作紀錄（最近 5 次）
- 2026-11-20 12:10：**v2.26 發版內容備妥，未發布**。查清發版是在獨立公開 repo（本機無 clone，main 停在 `78c7fd7`，距 v2.25 已 15 個 commit），在暫存區實際組好 18 檔並驗證 diff：`src/`／`tests/` 與 v2.25 **逐位元相同**，`data/` 三檔**只有 description／notes 欄變**（逐欄比對，值／帶／容差／holdout 全未動）。改了 CITATION.cff 五處（原清單只列三處，漏了 preferred-citation 的舊標題與 `status: submitted`）、兩份 README 的狀態列（還寫「已投稿 PLOS Comp Biol」）。`docs/zenodo_v2.26_準備清單.md` 全面改寫，§9 列出原清單七處與事實不符之處（含 release note 會印到公開版本說明上的「data/ tools/ byte-identical」那句）。**沒有 tag、沒有 push、沒有發布。** 待 PI 裁定三件：JTB 投稿包要不要進公開封存（建議不要）、`E6_bifurcation.m:37` 寫死常數（建議這版不動）、PLOS 時代的 `docs/submission_checklist.md`（建議加標頭註明是歷史文件）。
- 2026-11-20 11:32：**送出前三件裁定全部落稿**（PI 裁定甲(a)／乙(a)／丙(b)）。V6e 改為部位誠實，hold-out **8/8 → 7/8**（摘要、§2.3、§3.1、§3.3、Fig. 4 圖說、§4.5、cover letter、兩份 S2/validation CSV 同步）；§3.5 Schulte 整段改寫（BV/TV additive vs strength synergistic、機制方向相反、三個跨域落差），§4.4 補 *SOST*-KO 一句；V7 帶改以全身 BMD 0.7–1.0、狀態改「missed by 0.037; inside the 95 % CI」，並寫明反向風險（前臂飲食鈣 0.0–0.1 n.s.）。**模型輸出一個數字都沒改、沒重跑任何實驗、`evalTargets.m` 的 0.7–1.8 刻意不動**（它進 pass／殘差／chi²，改了要重新校正）。docx 以 docx@9.9.0 重建並逐段 diff 核對。三件都先回 C01／E03／G01 原始摘要核對過，不採信 10-18 報告的轉述。摘要 249 → **250 字（上限）**。Fig. 4A 未重畫（B12）。
- 2026-11-20 07:22：**91 測試在 R2026a 重跑通過**（8.7 分鐘）：94 個 case、91 passed／0 failed／3 incomplete，與 2026-10-19 的 R2025b 結果完全相同，三個 incomplete 仍是原本那三個 `testPlaceholder`。v2.26 release note 的「91 assertions, 0 failures (R2026a Update 2)」成立；`docs/zenodo_v2.26_準備清單.md` 的 ⚠️ 警告已解除。**發版技術前提全部齊備，只等 PI 決定**。槽 07:23:13 交棒 cnt-t1。
- 2026-11-19 22:06：**產圖比對完成**（R2026a，11.8 分鐘，`refigure_r2026a_20261119.log`）。投稿包 10-12 那批 Fig2–Fig8 **出自 R2026a**：三方比對顯示它與 R2026a 的距離比與 R2025b 小一個數量級，平移檢定證實版面逐像素對齊，log 內每個標的數值與封存值相同。殘差 0.3–0.5 % 為反鋸齒點陣化差異，**不可宣稱圖檔位元可重現**。投稿包未更動；B3「圖與數字同源」可打勾。腳本的 `FIGURES DIFFER` 判定被推翻，依據是不含門檻的三方比對與位移／邊緣檢定（詳見發現文件 §12.5）。槽 22:06:58 交棒 aroma-icu。
- 2026-11-18 21:49：R2026a 對照測試完成（PI 核可的換版診斷）。**R2026a 逐欄重現 2026-08-11 的九個標的，根因確定是 MATLAB 版本**；稿件 24/24 重現、不用改，早上提的三處修改撤回。更正本檔凍結清單 V8cort（2.3241 → 2.3294）與執行環境版本（R2025b → R2026a）。槽 21:51 交棒 cnt-t1。
- 2026-11-18 20:27：PI 裁定做 R2026a 對照測試；備妥 `xcheck_r2026a.m`，排進 `queue/bone__r2026a`（同組第 6，未開跑，因 r2025b 佔住整組）；修正本檔三處過時敘述（git 不可用、結果目錄為空、兩版結果一致）。
- 2026-11-18：E0–E7 在 r2025b 重跑完成（11.6 分鐘），Fig2–Fig8 產出且合規；發現並定位 v2.25 重現性落差（決定性探針三次逐位元相同 → 環境相依）；Table 1 逐項核對，23/24 重現。
- 2026-11-17：處理 F01 Spatz 2012 入庫通知（稿件無需修改，一項建議交裁定）；修正 C37 probes 寫死的家目錄路徑；備妥 Zenodo v2.26 發版清單。
- 2026-11-09：建立精簡 HANDOFF 與 DECISIONS.md；舊 handoff 存檔到 `docs/`。
- 2026-10-19：C37.6 第 3 點 —— `manuscript.md` §4.4 補 M6 時間尺度一句並重建 docx；檢查清單 B3 註明 v2.26 須含 probes。
- 2026-10-19：C37.6 第 2 點 —— D_C/D_A 出處說明改進兩份 CSV 與 `reference_parameters.md`（值未動）。
- 2026-10-19：附錄 C37 —— D_C 量測：轉錄錯誤屬實但 2.1e-3 是錯的修法；相對式正解 0.7 與出貨值差 ≤ 3 %；`D_R` 為載重佔位值。
- 2026-10-18：31 篇文獻全文核讀、28 份 summary、第二期研究計畫與發表規劃報告；兩則入庫通知處理完畢。

## 新文獻入庫通知（2026-11-11）

> 自 2026-10-16 之後，本計畫文獻庫（`Reference/`）新增 1 篇全文。**請接手者先閱讀下列文獻，評估是否需要修正研究問題、假說、方法、參數或稿件內容**，完成後在該列打勾並於下方註記處理結果。書目以 `00_reference_index.csv` 的 `citation` 欄為準。

文獻庫現況：共 32 筆｜PDF 32｜僅文字版 0｜缺 0

**F_Disuse-unloading-bone-loss**

- [x] **F01** P2｜Spatz JM 2012｜Serum sclerostin increases in healthy adult men during bed rest（PDF）｜used_by: Paper1
  - 用途：90 天頭低位臥床：負重部位每月流失 1–2%（V2）、sclerostin 升高軌跡與 PTH 下降，為廢用模擬的定量比對來源｜注意：PMC3431567 可在 PMC 網站免費閱讀，但無可下載的 OA 全文 XML；請手動自 PMC 下載 PDF；已送 RapidILL 2026-11-10；RapidILL 到件 2026-11-11

處理結果（接手者填寫）：

- **F01 Spatz 2012（2026-11-17 讀畢，已寫 `F01_...summary.md`）**：**稿件與標的 CSV 無需修改**。逐項核對結果：V2 的「負重部位每月流失 1–2 %」、V3 的 sclerostin +29／+42／+22 %（d28／d60／d90，d90 P = .07 不顯著）、PTH −17 %／−24 %，與 `data/validation_targets.csv` 的 V2／V3 註記、`manuscript.md` 第 76、94、95、131 行**完全一致**，包括已誠實寫出「模型重現上升但不重現 d90 的適應性回落」。
  - **新發現 1（建議交 PI）**：本文 Table 1 明載血清 soluble RANKL、OPG、RANKL/OPG 在 90 天臥床中**全程無變化**（作者解釋為該軸主要在細胞層次作用）。稿件 §4.3（第 203 行）主張廢用流失完全經 sclerostin → RANKL，補一句承認此人類觀測會**強化**既有的「單一路徑是侷限」論述。屬稿件措辭變更 → 併入既有的 PI 裁定清單。
  - **新發現 2、3、4（第二期候選，非 Paper 1 改動）**：血清骨形成標記（BSAP、osteocalcin）90 天無變化；1,25(OH)₂D 於 BR-28 降 13 %；前臂 BMD 不變（可佐證 E5 部位專一性）。三者目前都不是驗證標的，已記在 summary 的「待辦」。
  - 其餘未改動任何檔案。 

