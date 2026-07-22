# bone-mechanostat

**Mechanotransduction-Coupled Multiscale Model of Bone Remodeling**

謝明諭 (Ming-Yu Hsieh), MD, PhD ｜ ORCID [0000-0002-5797-3474](https://orcid.org/0000-0002-5797-3474)

> 鈣決定「能不能蓋」，負荷決定「要不要蓋」。

MATLAB R2026a ｜ 計畫書：[PROJECT_PLAN_bone_mechanostat.md](PROJECT_PLAN_bone_mechanostat.md)（v1.4）

---

## 現況

| 階段 | 內容 | 狀態 |
|---|---|---|
| **P1** | 目錄骨架、參數 CSV、單位測試、`simulate` 介面 | ✅ 檔案完成，**尚未在 MATLAB 執行驗證** |
| P2 | M1–M3 力學模組 | ⬜ |
| P3 | M4–M7 生物模組 | ⬜ |
| P4 | M8 鈣恆定 + 全模型校正 | ⬜ 阻塞於 Tier 1 文獻 |
| P5–P7 | 核心實驗、動力系統分析、論文 | ⬜ |

**已實作**：`projectRoot` `getResultsDir` `setupPath` `getDefaultParams` `paramBounds`
`scenarioLibrary` `crossSection` `organMechanics` `densitometry` `stateVector`
`baselineState` `simulate` `rhsFull`(stub)

其餘 `src/**` 皆為**簽章 + 單位註解骨架**，呼叫會拋 `boneMechanostat:notImplemented`
並指出所屬階段。

## 快速開始

```matlab
cd('/path/to/骨骼鈣質吸收數學模型')
addpath('src'); setupPath();

runtests("tests/test_units.m")
runtests("tests/test_closedloop.m")
runtests("tests/test_noPhenomParams.m")

s   = scenarioLibrary("sedentary", durationDays = 730);
out = simulate(s);
plot(out.t/365, out.dens.aBMD); xlabel("years"); ylabel("aBMD [kg/m^2]");
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
- `data/validation_targets.csv` — V1–V15。`holdout=TRUE` 者（V6a–V6f 網球、V10 停藥、
  V14 湧現 ε\*）為**盲測**，不得進入校正目標函數。

## 輸出路徑

`results/` **不在此目錄**。本專案位於 iCloud Drive，`.mat` 會被同步甚至 evict 成佔位檔
而使 `load` 失敗。一律經 `getResultsDir()` 寫到
`~/Documents/MATLAB/bone-mechanostat-results/`。

## 待辦（P2 之前）

- [ ] 在 MATLAB 中實際執行三支測試（本機負載過高時暫緩）
- [ ] 取得 Tier 1 文獻 #1 Lemaire 2004、#2 Pivonka 2008、#3 Peterson & Riggs 2010
- [ ] 取得 #5 Fu 2025（MSIC 三態速率常數）、#4 Weinbaum 1994、#6b Martin 1984
- [ ] 以 Haapasalo 2000 全文替換 `r_p_0` / `r_e_0` 的推算值
