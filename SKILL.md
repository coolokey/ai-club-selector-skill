---
name: ai-club-selector
description: >-
  學校 AI 智慧社團選社與適性導航系統產生與部署技能。當使用者要求「製作智慧社團選社系統」、「建立校內 AI 選社網站」、「套用選社系統範本到新學校」或「客製化／部署 GAS + Gemini 選社系統」時啟動。
---

# 學校 AI 智慧社團選社系統建立指南 (`ai-club-selector`)

本 Skill 提供完整的「Google Apps Script + Google Sheets + Gemini 2.5 Flash + 單頁響應式前端」智慧社團選社系統標準作業流程與可複用範本（內含 31 項後端回歸測試）。

---

## 觸發條件

當使用者提出以下需求之一時啟用本 Skill：
* 要求「把智慧社團選社系統做成新專案」、「為某某學校建立社團選社系統」或「複製／客製這套選社網站」。
* 要求新增、擴充、除錯或重新部署現有 `Code.gs` / `index.html` 的選社功能（如雙軌選社、Gemini 2.5 顧問、導師管理、後台分發、點名冊匯出或主題樣式）。

---

## 執行流程

### 階段一：需求盤點（與使用者確認必要參數）

啟動新專案前，先向使用者確認以下參數（若為擴充既有專案則先檢查現有 `Code.gs` 與 `.clasp.json`）：
1. **學校全銜與簡稱**：例如 `桃園市立○○國民中學` / `○○國中`。
2. **選社制度與社團來源**：
   * 預設模式：即時搶額制 (`instant`) 或 三志願分發制 (`preferences`)。
   * 是否保留範本內建的 **6 大領域 28 個示範社團** (`CANONICAL_CLUBS`)，或替換為該校真實社團清單。
3. **Google 試算表 ID（可選）**：
   * 後台主試算表 ID（`DEFAULT_SPREADSHEET_ID`；若將程式直接綁定在該試算表的 Apps Script 內，亦可留空並配合 `getActiveSpreadsheet()`）。
   * 若另有「成績查詢系統」試算表需唯讀匯入學生／導師名冊，取得其唯讀 ID（無則留空）。
4. **Gemini API Key 與部署目標**：
   * 金鑰可於網站後台「訓育組管理 → 系統參數設定」輸入，或直接填入 Google 試算表「系統設定」分頁的 `GEMINI_API_KEY` 列。
   * 確認僅部署 Google Apps Script Web App，或同時發布至 GitHub Pages。

---

### 階段二：一鍵建立專案骨架 (`scripts/scaffold.ps1`)

執行本 Skill 附帶的 [scaffold.ps1](./scripts/scaffold.ps1) 將已驗證的基底範本複製至目標資料夾，並自動替換學校名稱與試算表常數：

```powershell
powershell -ExecutionPolicy Bypass -File "C:\Users\MAO YU REN\.gemini\config\skills\ai-club-selector\scripts\scaffold.ps1" `
  -TargetDir "<專案目標路徑>" `
  -SchoolFullName "<學校全銜>" `
  -SchoolShortName "<學校簡稱>" `
  -SpreadsheetId "<主試算表ID>" `
  -ScoreSpreadsheetId "<唯讀名單來源試算表ID，無可省略>" `
  -GasWebappUrl "https://script.google.com/macros/s/<DEPLOYMENT_ID>/exec"
```

* 若需深入了解試算表 7 分頁欄位規格、Session Token 資安隔離與 Gemini Schema，請閱讀 [architecture.md](./references/architecture.md)。

---

### 階段三：客製化調整要點

依學校需求微調目標資料夾內的檔案：
1. **社團目錄、分年級開放設定與 AI 探索方向**：
   * 後端社團清單位於 `Code.gs` 的 `CANONICAL_CLUBS`（9 欄格式：`[名稱, 上限, 已錄取, 教師, 地點, 簡介, 先備要求與材料費, 類別, 開放年級]`，`開放年級` 可設為 `'不限'` 或 `'7'`、`'7,8'`、`'8,9'` 等）。
   * 系統支援**舊版 8 欄工作表自動無痛升級為 9 欄**，並於首頁免登入預覽、學生選社（預設開啟「僅看本年級可選」並對跨年級社團灰階防呆鎖定）、Gemini 2.5 顧問、2D 志願分發與後台人工轉社全面執行年級資格檢核。
   * 若大幅更改社團種類，應同步調整 `index.html` 的 `AI_EXPLORATION_TAGS` 與 `Code.gs` 的 `ruleBasedRecommendFallback()` 關鍵字規則，確保 Gemini 備援排序準確。
2. **視覺與使用者體驗設計準則**：
   * **多主題支援**：維持 `index.html` 的 3 組校園主題（湛藍領航 `indigo` / 翠綠森活 `mint` / 晨曦書香 `amber`）CSS 變數。
   * **吸底確認列與響應式列表**：保留 `.club-list`（桌機雙欄、手機單欄）與 `.sticky-select-bar`（`overflow: clip` 容器內 `position: sticky`），確保學生選社後免滑到底部即可送出。
   * **低干擾讀取遮罩**：保留 `.loading-overlay` 深色輕透明底層＋主題小卡（避免全畫面反白）。
   * **內建使用手冊與防呆開關**：保留 `parseBoolSetting_()` 處理試算表大寫 `TRUE/FALSE`，以及後台「系統參數設定」中的 UI 開關與說明手冊分頁。

---

### 階段四：自動化測試與 Playwright 實機驗證

**每次修改程式碼或產生新專案後，必須執行以下雙重驗證，不可跳過：**

1. **後端業務邏輯與資安測試（應全數通過）**：
   ```powershell
   cd "<專案目標路徑>"
   node --test tests/club_backend.test.cjs
   ```
   檢查包含：免未登入列舉名冊、5 次錯誤鎖定、防抱團人數上限、2D 批次分發、PII 遮蔽、`TRUE` 布林解析、Gemini API Key 安全遮蔽與 28 社設定等所有項目皆為 PASS。

2. **Playwright 桌面 + 手機響應式與無錯誤檢查**：
   確認桌面（`1280x800`）與手機（`375x812`）載入無 `pageerror` / `console.error`，且無水平溢位 (`scrollWidth <= innerWidth`)：
   * 注意：本機開啟 `index.html` 若欲測離線／展示模式，須攔截 `https://script.google.com/**` 回傳 `{"ok":true,"result":{"dbConnected":false}}`。
   * 驗證重點：角色分頁切換、使用手冊分頁、26 個 AI 探索標籤複選、社團雙欄／單欄切換與 `.sticky-select-bar` 懸浮送出按鈕。

---

### 階段五：部署 Google Apps Script 與 GitHub

1. **部署 GAS Web App**（需先透過 `clasp create` 或綁定 `.clasp.json`）：
   ```powershell
   cd "<專案目標路徑>"
   clasp push -f
   clasp deploy --description "Initial release"
   ```
   取得輸出中的 Deployment ID 后，若前端同時託管於 GitHub Pages，記得將 `index.html` 內的 `DEFAULT_GAS_URL` 更新為正確的 `https://script.google.com/macros/s/<DEPLOYMENT_ID>/exec` 並重新 `clasp push -f`／`git push`。

2. **部署後線上健康實測**：
   以 `Invoke-RestMethod` 對 `<GAS_EXEC_URL>` 發送 `POST` JSON `{"fn":"getSystemSettings","args":[]}`，確認線上 `ok: true` 且 `aiAdvisorEnabled` 等參數與試算表一致，方可視為完成交接。
