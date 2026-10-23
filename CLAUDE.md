# CLAUDE.md

個人技術筆記 blog，使用 Hugo + Blowfish theme（submodule 在 `themes/blowfish`，需要 Hugo extended）。安裝與 WSL2 的注意事項見 `README.md`。

## 常用指令
- 本機預覽：`./dev.sh`（port 8080，會包含 draft）
- 檢查能否 build：`hugo --minify`（和 CI 相同）
- 新增文章：`hugo new content post/<category>/<name>.md`

## 結構
- 文章放在 `content/post/<category>/`，例如 `riscv`、`leetcode`、`c-language`、`xv6-riscv`；不屬於任何主題的放 `uncategorized/`
  - 不要把文章直接放在 `content/post/` 底下
  - `dsa/` 目前還沒有文章，`_index.md` 設為 `draft: true` 隱藏
- 每個 category 都有 `_index.md` 當作 section 首頁
- 新增 category 時，要在 `config/_default/menus.en.toml` 的「筆記」(`parent = "notes"`) 底下加一個子選單
- 移動文章會改變網址，要在 front matter 加 `aliases` 保留舊網址
- 站內連結用 `{{< ref >}}`，不要寫 `/xxx/` 開頭的絕對路徑（正式網站有 `/blog/` 前綴）
- Front matter：`title`、`date`、`draft`、`description`、`tags`、`categories`
  - archetype 預設為 `draft: true`，要發布前需改成 `false`
  - `date` 是發布日期，發布後不要再改
  - 修改文章內容時，要把 front matter 的 `lastmod` 設成當天日期（格式 `YYYY-MM-DD`，沒有就新增在 `date` 下一行）
    - `params.toml` 已開啟 `showDateUpdated`，文章頁會顯示更新日期
- 自訂 template 放在 `layouts/`（覆蓋 Blowfish），例如 `layouts/archive/single.html` 產生 Archive 頁
- 搜尋使用 Blowfish header 上的放大鏡（`enableSearch`），不需要另外建 search 頁面
- `public/`、`resources/` 是 build 產物，不要 commit
- push 到 `main` 後，GitHub Actions（`.github/workflows/hugo.yml`）會自動 build 並部署

## 寫作慣例
- 內文使用繁體中文，技術名詞保留英文（interrupt、privilege mode、hart⋯⋯）
- 中英文之間加空格
- register、CSR 欄位、指令名稱用 code 格式，例如 `xtvec.mode`、`xstatus.xie`
- 規格閱讀筆記的寫法：先用 `>` 引用規格原文，再用 bullet 寫中文解讀
  - 筆記內容以規格原文為準；從其他文件補充的背景要另外註明

## Review 筆記時
- 對照原始規格（例如 `~/文件/riscv/*.pdf`）檢查翻譯有沒有意思偏差或漏掉的內容
- 從 PDF 或其他編輯器貼上的內容常見以下問題，要特別檢查：
  - 被跳脫的 `\*\*`，會直接顯示成星號
  - 句子中間斷行、還沒翻譯的英文殘句
  - 被切成好幾段的粗體、多餘的反引號
- 先列出 review 意見，等使用者同意後再修改

## Git
- Commit 訊息格式：`content: <動詞> ...`（文章）、`fix: ...`（修正設定或 build）或 `docs: ...`（README、CLAUDE.md 等 repo 文件），用英文、祈使句
  - 例如：`content: add CLIC spec notes and tidy PLIC title`
- 一個 commit 只放相關的檔案，不要順手把其他還沒追蹤的草稿加進去
