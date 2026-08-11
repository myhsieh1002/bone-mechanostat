# S1 Text. 模型方程式（Model equations）

> **中文校稿版。** 與 `S1_Text_model_equations.md` 逐段對應，供內容校對用，**非投稿檔案**。
> **數學式一律原樣保留**（那是記號，不是語言），只翻譯敘述，方便逐行對照。
> 關鍵術語首次出現時以括號附原文。

模組 M1–M8 依實作規格。符號與數值列於 **S1 Table**；以下每一個參數都在執行時從該表讀取，而原始碼中寫死的數值常數被視為缺陷，由自動化檢查攔截。

---

## 狀態向量（State vector）

每個骨骼部位十三個局部狀態，加上四個共用的全身狀態。

| 群組 | 狀態 | 模組 |
|---|---|---|
| 骨細胞訊號傳導 | $C_a$, $Y$, $S$, $T$, $n_{ot}$ | M4 |
| Wnt | $\beta$ | M5 |
| 細胞族群 | $R$, $B$, $C$ | M6 |
| 結構與礦物 | $r_p$, $r_e$, $f_{bm}$, $\bar\rho_{\min}$ | M7 |
| 全身（共用） | $\mathrm{Ca}_s$, $P$, $V_D$, $A_{reb}$ | M8, M4 |

單腔室：13 + 4 = 17 個狀態。雙腔室：13 × 2 + 4 = 30。訊號與細胞變數在基線被無因次化為 1；結構變數帶物理單位。

**每個部位的右手側只實作一次**，由單腔室與雙腔室兩個組裝器共同呼叫，因此兩者不可能分歧。

---

## M1 — 器官層級力學

**輸入是力，絕不是應變。** 情境提供每次負荷回合的峰值彎矩 $M_L$ 與峰值軸向力 $F_L$。應變是由當下幾何與材料狀態計算出的、**被調控的輸出**。指定應變會把模型由力控制變成應變控制，並剪斷 mechanostat 的回饋迴路；自動化檢查會拒絕任何帶有類應變欄位的情境。

理想化的中空圓形皮質截面：

$$A_g = \pi\left(r_p^2 - r_e^2\right), \qquad I_g = \frac{\pi}{4}\left(r_p^4 - r_e^4\right)$$

視在模數，將基質**數量**與基質**礦化**分離：

$$E_{\mathrm{app}} = E_{\mathrm{ref}}\, f_{bm}^{\,\kappa_E} \left(\bar\rho_{\min}/\bar\rho_{\min,0}\right)^{\nu_E}$$

骨膜與骨內膜表面的峰值應變，彎曲加軸向：

$$\varepsilon_p = \frac{M_L\, r_p}{E_{\mathrm{app}} I_g} + \frac{F_L}{E_{\mathrm{app}} A_g}, \qquad
\varepsilon_e = \frac{M_L\, r_e}{E_{\mathrm{app}} I_g} + \frac{F_L}{E_{\mathrm{app}} A_g}$$

其中 $\bar\varepsilon = \tfrac12(\varepsilon_p + \varepsilon_e)$。

*迴路增益。* 微分可得 $\partial \ln \varepsilon_p / \partial \ln f_{bm} = -\kappa_E$，數值驗證至**機器精度**（$4\times10^{-16}$，以有限區間上的比值形式計算，對冪次律而言為精確）。在薄壁極限下 $I_g \approx \pi r^3 t_c$，故 $\varepsilon \propto M_L / (E r^2 t_c)$：**骨膜外擴在力學上遠比皮質增厚有效率**（$r^2$ 對 $t_c$）。數值上 $\partial\ln\varepsilon/\partial\ln r_p = -4.27$，對 $f_{bm}$ 則為 $-3.13$。這就是為什麼負荷讓皮質骨**變大而非變密**，而它是由參數值湧現出來的，不是被寫死的規則。

*數值防護。* $E_{\mathrm{app}} \propto f_{bm}^{\kappa_E}$ 在 $f_{bm}\to 0$ 時發散；僅在本構律內部施加下限 $f_{bm,\min}$。

---

## M2 — 孔彈性骨小管剪應力

沿半徑 $a$ 的骨小管的一維 Biot 壓密：

$$\frac{\partial p}{\partial t} = c_p \frac{\partial^2 p}{\partial z^2} - \frac{1}{S_{\mathrm{stor}}}\frac{\partial \varepsilon}{\partial t}, \qquad c_p = \frac{k_{\mathrm{perm}}}{\mu\, S_{\mathrm{stor}}}$$

$$\tau_{\mathrm{oc}}(t) = \frac{a}{2}\left|\frac{\partial p}{\partial z}\right| \Gamma_{\mathrm{PCM}}$$

其中 $\Gamma_{\mathrm{PCM}}$ 為細胞周基質（pericellular matrix）放大因子。

**頻率相依性是精確的閉式解，不是擬合的代理函數。** 對簡諧負荷，該問題容許

$$\hat\tau_{\max}(\varepsilon_{\mathrm{peak}}, f) = K_\tau\, \varepsilon_{\mathrm{peak}}\, \Phi(f), \qquad \Phi(f) = \left|k \tanh(kL)\right|,\quad k = \sqrt{\mathrm{i}\,2\pi f / c_p}$$

低頻時 $\tau \propto f$，過渡到高頻時 $\tau \propto \sqrt{f}$，且**永不飽和**。這有兩個後果。它在 1–10 Hz 間給出 $\tau$ 對 $\ln f$ 的對數線性關係，$r = 0.99883$，**不含任何擬合參數**。而且它修正了先前一個會飽和的代理函數 —— 在那個形式下這種對數線性關係根本不可能達成，因為飽和形式會把高頻斜率壓成零。

*交叉驗證。* 完整 PDE 的 Crank–Nicolson 有限差分解與閉式解吻合，最大相對誤差 0.0029 %。

---

## M3 — 每日機械劑量

**通道只被建模一次。** 機械敏感離子通道閘控（Piezo1，$J_{\mathrm{alt}}$ 集總整合素、初級纖毛與 connexin-43 等平行路徑）具有關閉、開啟、失活三態，而**所有剪應力相依性都只存在於開啟速率**：

$$k_{co}(\tau) = k_{co}^{\max}\left[1 + \exp\!\left(-(\tau - \tau_{50})/k_\tau\right)\right]^{-1}$$

$$\frac{dO}{dt} = k_{co}(\tau)\,C_h - (k_{oc} + k_{oi})\,O, \qquad
\frac{dI}{dt} = k_{oi} O - k_{ic} I, \qquad C_h = 1 - O - I$$

次秒與每日兩個時間尺度之間的介面是**單一純量**，即開啟機率的每日積分：

$$D_{\mathrm{mech}}(d) = \int_{\mathrm{day}} O\big(t;\tau(t)\big)\, dt$$

其中 $\tau(t)$ 由當日的回合結構經 M1 與 M2 得出。

*已移除的唯象項。* 早期版本在三態模型之外，另外帶了一個具有參數 $a_r, \tau_r, p, \tau_{th}, q$ 的經驗劑量律，把同一批現象編碼了兩次；更糟的是，**那個本應跨越時間尺度邊界的純量根本沒有下游消費者**，所以力學訊號從未真正跨越過去。五個參數全數刪除，現象改由以下機制**湧現**：

| 現象 | 湧現機制 |
|---|---|
| 循環數的邊際報酬遞減 | 負荷期間 $I$ 累積，耗盡 $C_h$ |
| 休息插入增益 | 休息期間 $I \xrightarrow{k_{ic}} C_h$，恢復可用通道 |
| 閾值 | $k_{co}(\tau)$ S 形曲線的下肢；**沒有硬閾值**，故 $\tau\to0$ 時劑量小但非零 |
| 超線性 | S 形曲線的陡度 $k_\tau$ |

*交叉驗證。* 仿射逐循環算子與逐步積分吻合至 $2.2\times10^{-15}$。

*實作。* 由於幾何會適應，$\hat\tau$ 會漂移而 $D_{\mathrm{mech}}$ 必須重新求值；而以秒為解析度的日內積分不可能放進 ODE 的右手側。因此針對每一種回合結構，離線建立 $D_{\mathrm{mech}}$ 對 $\hat\tau_{\max}$ 的一維內插函數，慢系統只做查表。

---

## M4 — 骨細胞訊號傳導

鈣內流由每日平均開啟機率驅動，並受骨細胞感測容量調控：

$$\frac{dC_a}{dt} = k_C\left[(1 - f_{\mathrm{alt}})\, \hat{D}_{\mathrm{eff}} + f_{\mathrm{alt}} - C_a\right], \qquad
\hat{D}_{\mathrm{eff}} = \frac{D_{\mathrm{mech}}\,(n_{ot}/n_{ot,0})^{\zeta}}{D_{\mathrm{eff},0}}$$

$D_{\mathrm{eff},0}$ 是在一個**固定的標準參考**下的劑量 —— 未適應幾何下的久坐負荷 —— 而**絕不是**當前情境自己的基線。若以情境自身狀態正規化，會使每一種方案的 $\hat{D}_{\mathrm{eff}}$ 都等於 1，那麼任何介入都無法與其他介入有所區別。

YAP/TAZ 核內比例：

$$\frac{dY}{dt} = k_Y\left[\frac{h_Y(C_a)}{h_Y(1)} - Y\right], \qquad h_Y(c) = \frac{c^{n_Y}}{K_Y^{n_Y} + c^{n_Y}}$$

硬化蛋白，具有力學、PTH 與 TNF-α 三個輸入：

$$S_{\mathrm{set}} = \frac{f_{\mathrm{mech}}(Y)\, f_{\mathrm{PTH}}(P)\, f_{\mathrm{TNF}}(T)}{f_{\mathrm{mech}}(1)\, f_{\mathrm{PTH}}(1)\, f_{\mathrm{TNF}}(1)}$$

$$f_{\mathrm{mech}}(y) = \frac{1}{1 + (y/K_S)^{h_S}}, \quad
f_{\mathrm{PTH}}(x) = \frac{1}{1 + x/K_{P,\mathrm{sost}}}, \quad
f_{\mathrm{TNF}}(t) = 1 + \frac{\lambda_T t}{K_T + t}$$

$$\frac{dS}{dt} = \delta_S\, S_{\mathrm{set}}\,(1 + A_{reb}) - \left(\delta_S + \delta_{ab}\, u_{\mathrm{romo}}\right) S$$

抗硬化蛋白抗體增加的是**清除**（$\delta_{ab} u_{\mathrm{romo}}$），因而降低設定點並縮短時間常數。

**停藥反彈。** 持續的抗體暴露同時會**上調 *SOST* 轉錄**；$A_{reb}$ 承載該代償，並以自己的時鐘而非抗體的時鐘鬆弛：

$$\frac{dA_{reb}}{dt} = \frac{\sigma_{reb}\, u_{\mathrm{romo}} - A_{reb}}{\tau_{reb}}$$

在任何未接觸藥物的模擬中 $A_{reb} = 0$，故此項**不可能擾動任何無藥結果**。無需額外假設即可導出兩個後果：治療期間該代償逐步抵銷抗體，故游離硬化蛋白爬回基線、合成代謝效應自我限制；而停藥時清除項消失、被提高的生成卻沒有，故硬化蛋白過衝、吸收暴增。

**骨細胞密度**（正回饋：骨流失 → 感測器變少 → 訊號變弱 → 更多流失）：

$$\frac{dn_{ot}}{dt} = k_{ot}\, \hat{v}_{\mathrm{form}}\left(n_{ot,\max} - n_{ot}\right) - \left[\gamma_{\mathrm{eff}}\, \hat{v}_{\mathrm{res}} + \delta_{ot}(E_2, \hat D)\right] n_{ot}$$

其中 $\hat v$ 對基線正規化，且

$$\delta_{ot}(E_2, \hat D) = \delta_{ot,0}\, \frac{E_{2,0}}{E_2}\left[1 + \lambda_{ot,\mathrm{mech}} \max\!\left(0,\, 1 - \hat D\right)\right]$$

**$k_{ot}$ 是*導出*的，不是擬合的。** 基線平衡由它決定 $\gamma_{\mathrm{eff}}$，所以 $k_{ot}$ 實際設定的是**整個骨細胞族群的周轉率** —— 而那並不自由，因為骨細胞是在其所在的骨被吸收時離開組織的。反解該平衡：

$$\gamma_{\mathrm{eff}} \equiv \frac{\text{turnover}}{100 \times 365}, \qquad
k_{ot} = \frac{\left(\gamma_{\mathrm{eff}} + \delta_{ot,0}\right) n_{ot,0}}{n_{ot,\max} - n_{ot,0}}$$

如此**既**使 $n_{ot} = n_{ot,0}$ 在建構上成為不動點，**又**強制骨細胞周轉率等於骨周轉率。放任它自由時並非如此：模型以每天 $1.93\times10^{-4}$ 的速率吸收骨，卻以每天 $9.9\times10^{-2}$ 的速率移除骨細胞，**相差 514 倍**，此事已在正文討論。

力學凋亡係數 $\lambda_{ot,\mathrm{mech}}$ 是三個「已建成、已量測、以 **0 值出貨**」的廢用機制之一（三者全部設為零）；見 Limitations。

**雌激素與 TNF-α：** $E_2$ 撤除會提高 $T$，而 $T$ 使吸收偏向骨內膜（M7）並提高硬化蛋白。

---

## M5 — Wnt / β-catenin

$$W_{\mathrm{eff}} = \frac{W(S)}{W(1)}, \qquad W(x) = \frac{K_W^{m_W}}{K_W^{m_W} + x^{m_W}}, \qquad
\frac{d\beta}{dt} = k_\beta\left(W_{\mathrm{eff}} - \beta\right)$$

---

## M6 — 細胞族群

標準的 RANK/RANKL/OPG 結構，作用於反應性成骨細胞前驅 $R$、活化成骨細胞 $B$ 與活化破骨細胞 $C$，速率常數取自文獻。**硬化蛋白作用兩次** —— 抑制 Wnt 並上調 RANKL —— 這正是抗硬化蛋白治療的**合成代謝**與**抗吸收**兩個成分都能被重現的原因：

$$g_S(S) = 1 + \frac{\lambda_S S}{K_L + S}, \quad
g_P(P) = 1 + \frac{\lambda_P P}{K_{PL} + P}, \quad
g_E(E_2) = 1 - \lambda_E E_2, \quad
g_B(\beta) = 1 + \frac{\lambda_\beta \beta}{K_\beta + \beta}$$

$$L_{\mathrm{RANKL}} = \frac{g_S(S) g_P(P) g_E(E_2) g_A(n_{ot})}{g_S(1) g_P(1) g_E(E_{2,0}) g_A(n_{ot,0})}, \qquad
O_{\mathrm{OPG}} = \frac{g_B(\beta)}{g_B(1)}$$

$$g_A(n) = 1 + \lambda_{\mathrm{apop}} \max\!\left(0,\, 1 - \frac{n}{n_{ot,0}}\right)$$

$g_A$ 是**瀕死骨細胞直接釋出 RANKL**。它寫在*缺口*上，因此 $g_A(n_{ot,0}) = 1$ 為精確，**無論 $\lambda_{\mathrm{apop}}$ 取何值，都不可能擾動任何基線或非廢用結果**。以 0 值出貨；見 Limitations。

$$\pi_L = \frac{L_{\mathrm{RANKL}}}{K_{L3} + L_{\mathrm{RANKL}} + \kappa_{\mathrm{OPG}} O_{\mathrm{OPG}}} \Big/ \left.\phantom{x}\right|_{\text{baseline}}$$

---

## M7 — 結構與礦化

**表面分配。** 形成依循跨壁的應變梯度，並以可用表面積加權：

$$\eta \propto A \odot \left[D(\varepsilon_p),\, D(\varepsilon_e),\, D(\bar\varepsilon)\right], \qquad
A = \left[\xi_{p,0},\, \xi_{e,0},\, \xi_{i,0}\right]$$

正規化使其總和為 1。**面積加權是必要的**：單以劑量分配會讓骨膜拿到全部形成的約 35 %，儘管它只佔約 5 % 的表面。吸收依面積分配，並帶有**兩個作用在不同表面、由不同訊號驅動的偏移** —— TNF-α 偏向骨內膜，機械劑量缺口偏向皮質內：

$$\xi \propto A \odot \left[1,\; 1 + \frac{\lambda_\xi (T-1)}{K_T + T},\; 1 + \lambda_{\xi,\mathrm{mech}} \max\!\left(0,\, 1 - \hat D\right)\right]$$

雌激素撤除使吸收偏向骨內膜，即停經後「更寬但更薄」的皮質；卸載使吸收偏向皮質內，即長期固定不動所量測到的皮質孔隙度上升。**兩個因子在參考狀態下都恰為 1**（$T = 1$, $\hat D = 1$），因此無論係數取何值，基線分配都不受影響。$\lambda_{\xi,\mathrm{mech}}$ 以 0 值出貨；見 Limitations。

**表面演化。** $r_e$ 增加代表骨內膜吸收，亦即皮質變薄；分別追蹤 $r_p$ 與 $r_e$，正是骨在生長的同時髓腔仍能擴大的原因。

$$\frac{dr_p}{dt} = v_{\mathrm{form}} \eta_p - v_{\mathrm{res}} \xi_p + \mathcal{M}, \qquad
\frac{dr_e}{dt} = v_{\mathrm{res}} \xi_e - v_{\mathrm{form}} \eta_e + \chi_{\mathrm{drift}} \mathcal{M}$$

$$\frac{df_{bm}}{dt} = \frac{\hat{S}_v(f_{bm})}{w_{\mathrm{wall}}}\left(v_{\mathrm{form}} \eta_i - v_{\mathrm{res}} \xi_i\right)$$

其中 $v_{\mathrm{form}} = k_{\mathrm{form}} B$、$v_{\mathrm{res}} = k_{\mathrm{res}} C$。比表面積 $\hat S_v(f_{bm})$ 承載**第二個正回饋**：$f_{bm}$ 下降時，可供重建的表面也逐步減少。

**Frost 塑形漂移。** 劇烈負荷驅動直接的骨膜沉積，與劑量／重塑路徑不同，並帶有應變閾值（塑形的最小有效應變），使其在正常日常活動與**每一個校正情境**中都保持沉默：

$$\mathcal{M} = k_{\mathrm{model}}\, \frac{\Delta\varepsilon}{1 + \Delta\varepsilon/\varepsilon_{\mathrm{sat}}} \left(\frac{n_{ot}}{n_{ot,0}}\right)^{\zeta}, \qquad
\Delta\varepsilon = \max\!\left(0,\, \varepsilon_p - \varepsilon^*_{\mathrm{model}}\right)$$

有兩項特徵是承重的。**飽和**把速率上界訂在 $k_{\mathrm{model}}\varepsilon_{\mathrm{sat}} = 1.93\ \mu\mathrm{m/day}$；沒有它，該項對應變超額為線性且無上界，在病理性骨體積分率下會要求每年 1513 mm 的沉積，產生一個假的 99 mm 皮質。所選的 $\varepsilon_{\mathrm{sat}}$ 把半飽和反應放在皮質骨的降伏應變（7000 με）—— 超過該值組織是損傷而非適應 —— 並且獨立地把速率上限放進快速礦物沉積的文獻範圍內（1–5 μm/day）。**漂移耦合** $\chi_{\mathrm{drift}} = 1$ 使該項成為皮質的**純平移**、保存壁厚，這正是塑形漂移應有的行為；$\chi_{\mathrm{drift}} = 0$ 則會使皮質膨脹並在負荷下**收縮髓腔**，與觀察相反。

**礦化。** 平均組織礦物密度是單一的**強度量**狀態，隨新的低密度基質沉積而下降、隨既有基質成熟而上升：

$$\frac{d\bar\rho_{\min}}{dt} = \mu_{\mathrm{turn}}\left(\rho_{\mathrm{prim}} - \bar\rho_{\min}\right) + \text{maturation}$$

早期的雙池**外延量**表述會使 $\bar\rho_{\min}$ 在形成期間**上升** —— 方向錯誤 —— 而那個假影正是一項未能通過修正的 romosozumab 表面結果的來源。

**骨密度計量。**

$$\mathrm{BMC}/L = A_g f_{bm} \bar\rho_{\min}, \qquad
\mathrm{aBMD} = \frac{A_g f_{bm} \bar\rho_{\min}}{2 r_p}, \qquad
\mathrm{vBMD} = f_{bm} \bar\rho_{\min}$$

**兩者都報告，而面積尺寸假影是刻意保留的。** 除以投影寬度重現了雙能量 X 光吸收儀中骨大小與骨密度的著名混淆：即使體積密度不變，骨膜外擴仍會提高面積密度。保留它，正是同一個模型能同時對照骨密度儀文獻（鈣、romosozumab）與周邊定量電腦斷層文獻（球拍運動不對稱）的原因，也是正文所報告 **61 % 負荷反應稀釋**的來源。

**骨量平衡。** 由於恆有 $\eta_p > \xi_p$，不存在靜止的幾何不動點；唯一站得住的基線條件是**骨量守恆**。因此 $k_{\mathrm{form}}$ 在每一組參數下都由 $d(A_g f_{bm})/dt = 0$ 導出而非擬合，如此在任何影響 $\eta$ 或 $\xi$ 的參數改變時，基線都在建構上保持平衡。周轉幅度則由 $k_{\mathrm{res}}$ 單獨承載。$k_{ot}$（M4）依同一精神、同一理由導出，來源是 $k_{\mathrm{res}}$ 所設定的周轉率：**兩個由基線狀態已然決定的常數，因此也是兩個不得再被擬合的常數。**

---

## M8 — 全身鈣、PTH 與 1,25(OH)₂D

血清鈣、PTH 與 1,25-二羥維生素 D，含腸道吸收、腎臟處理與骨通量，**雙向耦合**：骨細胞活性從血清池提取並釋回，而 PTH 經硬化蛋白與 RANKL 兩條路徑回饋進 M4。在雙腔室模型中，全身池由兩個部位骨細胞活性的**平均**驅動 —— 因為單一肱骨在全身鈣周轉中佔比可忽略；這些部位是共用池的**探針**，不是它的驅動者。

以下每一項都是以 mg/day 計的鈣通量。

$$\frac{d\mathrm{Ca}_s}{dt} = \frac{\kappa_{\mathrm{Ca}}}{k_{\mathrm{ren}}}\left[\mathrm{Abs}(I_{\mathrm{Ca}}, V_D) + \phi_{\mathrm{res}} v_{\mathrm{res}} - \phi_{\mathrm{form}} v_{\mathrm{form}} - \mathrm{Renal}(\mathrm{Ca}_s, P)\right]$$

$$\frac{dP}{dt} = \delta_P\left(P_{\mathrm{set}}(\mathrm{Ca}_s) - P\right), \qquad
\frac{dV_D}{dt} = \delta_{VD}\left(V_{D,\mathrm{set}}(P) - V_D\right)$$

**吸收**含一個對攝取量呈線性、不受調控的細胞旁路（paracellular）臂，以及一個對攝取量飽和、由骨化三醇（calcitriol）調控的跨細胞（transcellular）臂。第二條臂承載大部分的基線通量，而它正是緩衝飲食鈣變化的機制：攝取增加 → 血清鈣上升 → PTH 下降 → $V_D$ 下降 → 跨細胞臂關閉。

$$\mathrm{Abs} = a_p I_{\mathrm{Ca}} + a_a I_{\mathrm{Ca},0}\,\frac{I_{\mathrm{Ca}}}{K_I + I_{\mathrm{Ca}}}\,\frac{V_D}{K_{VD} + V_D}$$

**腎臟排泄**是小管未能回收的部分：血清鈣超出某個由 PTH 提高的閾值的部分。它的陡度**不是自由參數**，而是閾值位置的後果 —— 把閾值放在比 $\mathrm{Ca}_{s,0}$ 低約 2 % 之處，會使排泄成為兩個大數之差，這與「約 98 % 的濾過鈣被再吸收」是同一個陳述。增益則由閉合基線平衡得出，因此該模組只有**一個自由的生理選擇**，而不是一個被擬合的指數。

$$\mathrm{Renal} = k_{\mathrm{ren}}\max\left(\mathrm{Ca}_s - \mathrm{Ca}_{\mathrm{th}}, 0\right), \qquad
\mathrm{Ca}_{\mathrm{th}} = \mathrm{Ca}_{\mathrm{th},0} + \lambda_{P}^{\mathrm{ren}}\,\Delta\,(P - 1)$$

$$\Delta = \mathrm{Ca}_{s,0} - \mathrm{Ca}_{\mathrm{th},0}, \qquad
k_{\mathrm{ren}} = \frac{\mathrm{Abs}_0 + \phi_{\mathrm{res}} - \phi_{\mathrm{form}}}{\Delta}$$

**骨骼交換**取 $\phi_{\mathrm{res}} = \phi_{\mathrm{form}}$，故在基線消失，並在受擾動時承載真實的骨骼鈣通量。其量級為成人骨骼鈣周轉的量級，而這正是卸載得以抑制 PTH 的原因。

*本模組在 v2.14 被重建。* 先前的形式**同時在兩個方向失敗**：跨細胞臂被寫成分率而非通量，因而貢獻不到吸收的 0.1 %，使血清鈣在飲食範圍內擺動達 15 %；同時 $\phi_{\mathrm{res}}$ 與 $\phi_{\mathrm{form}}$ 比它們所正規化的通量低了三個數量級，因而**骨根本無法移動血清鈣**。兩者都已在正文報告。

---

## 小樑腔室

椎體小樑腔室由皮質參數集導出，**只覆寫**結構、幾何與負荷 —— 生物學是共用的，因為每個部位的右手側是共通的。幾何與骨體積分率取自椎體文獻；小樑厚度取代皮質壁厚。

有兩項覆寫是**被逼出來的而非選擇的**，且兩者都值得陳明，因為它們可推廣到任何多腔室擴充。

1. **共用的訊號鏈迫使兩個腔室落在同一個湧現剪應力設定點上。** 椎體在真實負荷與骨體積分率下承載約 **961 με** 的組織應變，對照皮質的 **787 με**，因此孔彈性傳遞係數 $K_\tau$ 必須不同。這是站得住的 —— $K_\tau$ 是微結構性質，而小樑骨包並非骨單位皮質 —— 而且它是由**匹配基線剪應力**設定的，不是由擬合任何結果設定的。
2. **Frost 的塑形最小有效應變是一個應變閾值，必須同樣按比例調整**，否則塑形會在小樑腔室永久啟動，椎體將無限制擴張。

$k_{\mathrm{res}}$ 是對**小樑**周轉標的校正的（文獻 15–30 %/yr，對照皮質的 5–10），正如它對皮質是以皮質周轉校正一樣；若放任不管會是 438 %/yr，因為同樣的絕對表面速度作用在少八倍的骨、隔著薄 7.7 倍的壁，周轉會快約 60 倍。romosozumab 的標的仍保持為盲測。

*指數是腔室專屬的，而那是第三項被逼出來的覆寫。* 直到 v2.16 為止，單一的 $\kappa_E = 2.5$ 同時服務兩個腔室，而它在跨兩個數量級孔隙度上所產生的一致性，曾在此被當作一項**免費的**一致性檢查報告。**它並不免費**：2.5 是一個假定值，而取用實測值恰恰暴露了它為何看似有效。Currey 對 18 個物種緻密骨的冪次律給出 $\kappa_E = 3.13$；在骨體積分率 0.12 處套用，會把視在模數乘上 $0.12^{0.63} = 0.26$，使椎體落在 26 MPa —— **低於實測的 50–300 MPa 範圍**，且數月內就逸出線性彈性域。小樑骨是**細胞性固體**而非緻密骨，Gibson–Ashby 開孔標度給出指數 2。因此我們在皮質用 $\kappa_E = 3.13$、在椎體用 2.00，使椎體視在模數為 **288.0 MPa**，落在實測範圍內。依此解讀，先前的單一值**對兩個腔室都不正確**：它在緻密骨指數與細胞性固體指數之間取了折衷。修訂後的定律在兩端各有一個量測作為依據，而不是在中間取一個妥協 —— 這是更強的立場，但也不再是「單一指數可橫跨整個孔隙度範圍」的主張。

---

## 有效域（Validity domain）

每一個力學層 —— 冪次律模數、Euler–Bernoulli 截面、Biot 解 —— 都假設線性彈性。皮質骨在約 7000 με 附近降伏；超過該值，組織是**損傷**而非適應，而走到那裡的軌跡已不是一根緩慢重塑的骨。因此每一次模擬都會回報峰值應變對此上限的比較，**超出者的結果不予解讀**。

此項檢查辨識出正文所報告的兩項範圍限制：卸載超過約 7.5 個月會把模型推到孔隙率地板並逸出彈性域；而雌激素延續分析中 $f_{bm} \approx 0.47$ 以下的深分支屬於外推。

---

## 數值方法

`ode15s`，相對容差 $10^{-6}$、絕對容差 $10^{-9}$，所有狀態強制非負。分岔分析**凍結包膜幾何**以隔離孔隙率動力學，因為包膜演化是數十年尺度的過程，而雙穩態問題是數月到數年尺度；幾何自由的完整系統暫態僅在其停留於彈性域內時，用作獨立檢查。
