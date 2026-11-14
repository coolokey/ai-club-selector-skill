# AI 智慧社團選社與適性導航系統：架構與資料表規格參考

## 1. 三權限單頁應用架構 (`index.html` + `Code.gs`)

* **雙部署通道**：
  * **Google Apps Script Web App (`doGet` + `google.script.run`)**：校內單一網址免外部空間即可運行。
  * **GitHub Pages + GAS API 閘道 (`doPost` 白名單路由 + `fetch`)**：支援公開自訂網域／快速展示，並內建無網離線展示模式（Showcase Mock + 一鍵體驗導覽）。
* **三大權限分流**：
  1. **學生與家長端**：班級＋座號免清單洩漏登入、即時搶額／三志願分發雙軌切換、**Gemini 2.5 智慧適性選社顧問（26 個探索方向與上課偏好標籤）**、雙欄社團網格＋**吸底懸浮選社確認列**、錄取電子票券憑證與 Email 自動通知。
  2. **導師端**：個人帳號密碼登入（首次登入強制改密 + 5 次失敗鎖定 15 分鐘）、班級選社進度即時統計、點名名單與一鍵複製 LINE／家長催繳提醒文案。
  3. **學務處訓育組管理者端**：後台 Session Token（2 小時效期）、系統參數設定（標題＋Google 試算表同步更名、`AI_ADVISOR_ENABLED`、`EMAIL_NOTIFICATION_ENABLED`、`GEMINI_API_KEY` 唯寫遮蔽保護）、社團 CRUD 與重設 28 社、兩段式高敏異動保護之抽籤分發預覽與套用、人工轉社／退選／超額特案、點名簽到單（含健康警示）與行政成果報告書匯出、試算表分頁健檢整理與欄寬格式化。

---

## 2. Google 試算表資料庫 Schema（7 大核心分頁）

| 分頁名稱 | 用途 | 關鍵欄位 |
| :--- | :--- | :--- |
| `社團設定` | 全校開放社團目錄與餘額 | 社團名稱、人數上限、已錄取人數、授課教師、活動地點、社團簡介、先備要求與材料費、社團類別 |
| `學生名單` | 學生學籍與選社志願/結果 | 學號、姓名、班級、座號、身分證後四碼、出生月日、密碼、學生Email、第一~三志願、錄取社團、選填時間、分發備註、保障身分鎖定、健康安全提醒 |
| `導師名單` | 各班導師帳號與狀態 | 教師帳號、教師姓名、負責班級、密碼、首次登入標記、公務信箱 |
| `管理者名單` | 訓育組後台帳號密碼 | 帳號、姓名、密碼、說明（與 `系統設定` 的 `ADMIN_PASSWORD` 雙向同步） |
| `系統設定` | 系統參數與金鑰儲存 | `SYSTEM_TITLE`、`SELECTION_MODE`、`OPEN_TIME`、`CLOSE_TIME`、`AI_ADVISOR_ENABLED`、`MAX_PREFERENCES`、`MAX_PER_CLASS_PER_CLUB`、`EMAIL_NOTIFICATION_ENABLED`、`GEMINI_API_KEY`、`ADMIN_PASSWORD` |
| `社團點名簽到冊` | 各社團正式點名表（匯出含健康警示） | 班級（保留前置0）、座號、姓名、學號、簽到格、健康安全提醒 |
| `異動紀錄` | 管理端調社／退選／特案稽核 | 時間、操作者、異動類型、目標學生、原社團、新社團、備註 |

---

## 3. 安全防護與實務防踩雷設計

1. **試算表布林值大小寫相容 (`parseBoolSetting_`)**：Google Sheets 將未格式化布林值 `true` 回傳為 `'TRUE'`，`parseBoolSetting_()` 同時相容 `true / TRUE / 1 / yes / on / 是 / 開啟 / 啟用`。
2. **Gemini API Key 唯寫遮蔽**：後台 `getSystemSettings()` 僅回傳 `hasGeminiApiKey: boolean`，絕不將 `GEMINI_API_KEY` 明文回傳前端。管理者亦可直接將金鑰貼在「系統設定」試算表分頁。
3. **防幻覺落地校驗 + 規則引擎備援**：`aiConsultantRecommend()` 會遮蔽學生輸入中的姓名／電話／身分證 (`scrubPII_`)，強制 Gemini 2.5 Flash 輸出 Schema JSON，過濾不在學校社團名單中的名稱；若無金鑰或配額異常則自動切換 `ruleBasedRecommendFallback()`（支援全部 28 個社團類別與避暑／免材料費／零基礎／安靜／團隊等條件）。
4. **預設密碼阻斷敏感操作**：若管理者仍使用預設密碼 `admin888` 或導師為首次登入，敏感查詢與分發操作會回傳錯誤要求先更改密碼。
5. **跨試算表唯讀隔離**：`syncDirectoryFromScoreDb_()` 僅對來源成績系統執行 `getDisplayValues()` 唯讀讀取，寫入端僅更新本站 `學生名單`／`導師名單`，同時保留既有的選社志願、錄取結果與前置 0。
