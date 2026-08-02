import csv, sys, importlib.util
def load(p, n):
    s=importlib.util.spec_from_file_location(n,p); m=importlib.util.module_from_spec(s); s.loader.exec_module(m); return m.ZH
ZH = {**load('s1zh_part1.py','p1'), **load('s1zh_part2.py','p2')}

CSV = "/Users/myhsieh/Library/Mobile Documents/com~apple~CloudDocs/03 研究文件/iBioLab/骨骼鈣質吸收數學模型/data/parameters_literature.csv"
rows = list(csv.DictReader(open(CSV, encoding='utf-8')))

missing = [r['name'] for r in rows if r['name'] not in ZH]
extra   = [k for k in ZH if k not in {r['name'] for r in rows}]
if missing or extra:
    print("缺譯:", missing); print("多餘:", extra); sys.exit(1)

MOD = {"IN":"共用／無因次化基準","M1":"M1 — 器官層級力學","M2":"M2 — 孔彈性骨小管剪應力",
       "M3":"M3 — 每日機械劑量","M4":"M4 — 骨細胞訊號傳導","M5":"M5 — Wnt / β-catenin",
       "M6":"M6 — 細胞族群","M7":"M7 — 結構與礦化","M8":"M8 — 全身鈣、PTH 與 1,25(OH)₂D"}
SRC = {"assumed":"假定","calibrated":"校正","derived":"導出","fixed":"定義用常數",
       "literature":"文獻","superseded":"已退役"}
CONF = {"high":"高","medium":"中","low":"低"}

out = ["""# S1 Table. 參數表（Parameters）

> **中文校稿版。** 與 `S1_Table_parameters.csv` 逐列對應，供內容校對用，**非投稿檔案**。
> **數值、單位、上下界、模組、出處、信心等級一律由 CSV 原樣帶出**（語言中性，不經人手轉錄），只翻譯 `description` 欄。
> ⚠️ **這不是程式讀的檔案。** 模型只讀 `data/parameters_literature.csv`（英文），此處為單向複本。

**出處欄語彙**：`assumed` 假定｜`calibrated` 校正｜`derived` 導出｜`fixed` 定義用常數｜`literature` 文獻｜`superseded` 已退役｜其餘為文獻代號。
**信心等級**：high 高｜medium 中｜low 低。
**上下界**：供 LHS/Sobol 抽樣與校正使用；上下界相等者為定義用常數，不參與抽樣。
"""]
for mod in ["IN","M1","M2","M3","M4","M5","M6","M7","M8"]:
    sub=[r for r in rows if r['module']==mod]
    if not sub: continue
    out.append(f"\n---\n\n## {MOD[mod]}（{len(sub)} 項）\n")
    for r in sub:
        src = SRC.get(r['source'], r['source'])
        if r['source'] in SRC: src = f"{src}（{r['source']}）"
        unit = r['unit'] if r['unit'] != '-' else '無因次'
        out.append(f"### `{r['name']}`　符號 {r['symbol']}\n")
        out.append(f"| 值 | 單位 | 下界 | 上界 | 出處 | 信心 |\n|---|---|---|---|---|---|\n"
                   f"| **{r['value']}** | {unit} | {r['lower']} | {r['upper']} | {src} | {CONF.get(r['confidence'], r['confidence'])} |\n")
        out.append(f"\n{ZH[r['name']]}\n")

DEST = "/Users/myhsieh/Library/Mobile Documents/com~apple~CloudDocs/03 研究文件/iBioLab/骨骼鈣質吸收數學模型/投稿PLOS Comp Biol/supporting_information/S1_Table_parameters_zh-TW.md"
open(DEST,'w',encoding='utf-8').write("\n".join(out))
print(f"已寫出 {len(rows)} 項，{sum(len(x) for x in out):,} 字元")
