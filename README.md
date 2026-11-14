# 🤖 AI 智慧社團選社系統產生器 (`ai-club-selector` Skill)

一套專為 **Antigravity / AI Coding Agent** 設計的標準化技能套件（Skill），可協助各級國中小／高中快速建立、客製化、測試與部署具備 **Gemini 2.5 Flash 適性導航**、**Google Apps Script + Google Sheets 後端**、**導師查核**與 **學務處分發管理** 的智慧社團選社網站。

---

## ✨ 套件特色

* **雙軌制選社引擎**：支援「⚡ 即時搶額制（先選先錄取）」與「📋 多志願 AI 公平適性分發制（2D 批次分發＋抽籤序號追蹤）」，並內建**單一社團各班人數上限（防抱團機制）**。
* **Gemini 2.5 Flash 適性選社顧問**：
  * 內建 **26 個跨領域興趣探索與上課偏好標籤**（科技創客、美術工藝、音樂舞台、運動戶外、策略語文 + 室內冷氣／免額外費用／新手友善等條件）。
  * 具備 **PII 個資遮蔽**、**白名單防幻覺校驗** 與 **本地規則引擎備援**（無 API Key 時仍可精準排序）。
* **貼心師生與行政 UX**：
  * **三校園佈景主題一鍵切換**（湛藍領航 / 翠綠森活 / 晨曦書香）與精緻低干擾讀取卡片。
  * **桌機雙欄社團網格 + 懸浮吸底選社確認列**，選好任一社團不用滑到頁面最底就能直接送出。
  * **內建使用說明手冊視窗**（分學生家長／導師／訓育組／試算表對照四頁籤）。
  * 一鍵產生各社團點名簽到單（含健康警示與保留前置 0）及社團成果報告書（Google Docs）。
* **完整 25 項自動化回歸測試**：內含 Node.js GAS 沙盒測試腳本（`tests/club_backend.test.cjs`），生成新學校專案即可驗證權限隔離、防呆密碼鎖定與分發演算法。

---

## 📁 檔案結構

```text
ai-club-selector/
├── SKILL.md                      # AI Agent 執行 SOP（需求盤點 → 建置 → 測試 → 部署）
├── README.md                     # 本說明文件
├── references/
│   └── architecture.md           # 7 大 Google 試算表分頁規格、資安防護與設計準則
├── scripts/
│   └── scaffold.ps1              # 一鍵建置新學校選社專案腳本
└── resources/
    └── template/                 # 乾淨且學校無關的黃金程式碼範本
        ├── Code.gs               # Google Apps Script 後端程式
        ├── index.html            # 單頁式前端（支援 GAS Web App 與 GitHub Pages）
        ├── appsscript.json       # GAS 權限與 V8 執行設定
        ├── .claspignore          # clasp 上傳白名單
        └── tests/
            └── club_backend.test.cjs  # 25 項後端自動化回歸測試
```

---

## 🚀 安裝本 Skill

將本套件複製到 Antigravity 的全域 Skill 目錄（所有專案共用）或單一專案的 `.agents/skills/` 目錄：

### 方法一：安裝至個人全域 Skills（推薦，所有專案皆可喚起）

```powershell
git clone https://github.com/coolokey/ai-club-selector-skill.git "$HOME\.gemini\config\skills\ai-club-selector"
```

### 方法二：僅安裝至單一專案工作區

```powershell
git clone https://github.com/coolokey/ai-club-selector-skill.git ".\.agents\skills\ai-club-selector"
```

---

## 💡 使用方式

### 方式 A：在 Antigravity 對話中直接下指令

安裝完成後，只要在對話中告訴 AI：
> 「請幫我用 `ai-club-selector` 技能，為『○○國民中學』製作一套智慧社團選社系統。」

AI 會自動讀取 `SKILL.md`，詢問貴校名稱、試算表 ID、選社模式與社團清單後，自動完成建置、測試與部署。

### 方式 B：手動執行腳手架腳本建立新專案

```powershell
powershell -ExecutionPolicy Bypass -File "$HOME\.gemini\config\skills\ai-club-selector\scripts\scaffold.ps1" `
  -TargetDir "D:\my-school-club" `
  -SchoolFullName "桃園市立○○國民中學" `
  -SchoolShortName "○○國中" `
  -SpreadsheetId "<您的 Google 試算表 ID>" `
  -GasWebappUrl "https://script.google.com/macros/s/<您的 DEPLOYMENT_ID>/exec"
```

建置完成後即可執行驗證與部署：

```powershell
cd D:\my-school-club
node --test tests/club_backend.test.cjs
clasp push -f
clasp deploy --description "Initial release"
```

---

## 🔑 Gemini API Key 設定位置

新系統部署後，**無須修改程式碼**即可啟用 Gemini 2.5 選社顧問，以下任一方式皆可：
1. 登入網頁 **「⚙️ 訓育組管理」→「系統參數設定」**，勾選 **「✨ 啟用 Gemini AI 智慧選社顧問」** 並貼上 API Key 儲存。
2. 直接在後台 Google 試算表的 **`系統設定`** 分頁，填入 `GEMINI_API_KEY` 列（`AI_ADVISOR_ENABLED` 設為 `true` / `TRUE`）。

---

## 📄 授權與實作參考

* 實戰範例系統參考：[dsjh-ai-club-selector](https://github.com/coolokey/dsjh-ai-club-selector)
* 採用開源授權供各級學校教育行政與教學資訊推廣自由複用與客製。
