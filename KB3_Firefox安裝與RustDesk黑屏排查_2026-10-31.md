# KB3 Firefox 安裝、網站測試與 RustDesk 黑屏排查紀錄

日期：2026-10-31，上午（Asia/Taipei）

對話：確認女媧KB3適用的瀏覽器

指定目錄：C:\eAi360-kb3-remote-control

用途：保存決策、授權、安裝驗證、故障處理、操作方法與今日對話，供 Kevin 後續重現、交接及向原廠詢問。

## 1. Kevin 先看這裡

Firefox Android 159.0 正式版已安裝到 KB3，官方 APK 已核對套件資訊與簽章，安裝暫存檔已刪除。

本次處理了兩個不同問題：

1. KB3 本機能正常播放，RustDesk 電腦端卻黑屏。異常時 VP8、VP9、H.264 都黑；重建 KB3 的 RustDesk 螢幕分享後，Firefox 首頁、eAi 網頁及一支 Google Drive MP4 畫面恢復。
2. 畫面恢復後，滑鼠不能點按。查到 Android 已啟用／已綁定的無障礙服務沒有 RustDesk Input；恢復後，服務重新出現在清單，並成功以電腦滑鼠操作 Drive 播放控制及暫停影片。

整理時已實際切回 VP8，右上角確認 Codec VP8，最後切換後觀察為 27 FPS、27 ms，影片畫面正常。這是當時瞬間值，不是保證值。

目前建議：先使用 Firefox 正式版搭配 VP8，沿用昨天的喚醒連線腳本。沒有證據顯示必須用 H.264 才能修復此次黑屏，也沒有充分證據支持增加頻寬就能解決。

先看第 7 節的操作方法，再看第 6 節比較。第 11 節保留可取得的今日使用者與助理對話。較早的未完成結論保留作為歷程，最終狀態以正文為準。

## 2. 記錄範圍與公開內容

本紀錄涵蓋約 08:46 起的瀏覽器研究、安裝、網站測試、黑屏排查、遠端輸入恢復、codec 比較及 MD／GitHub 交付要求。

逐則對話依工具回傳順序整理，確認問答轉為可讀文字，保留前後修正。每個回合的時間是回合開始時間，不是其中每則訊息的精確發送時間。工具指令與結果另作摘要，不貼內部推理、重複原始輸出或私人畫面。

公開版遮蔽密碼與完整裝置序號，不收錄 Google Drive 私人檔案連結、私人 MD、截圖、原始診斷日誌或伺服器私鑰。

## 3. 瀏覽器選擇與授權

Kevin 要在 KB3 使用大部分常用網頁，不要求完全相容，並比較 Chrome、Edge、Firefox。原廠曾提醒 Chrome 有問題，但未提供具體情況。

| 瀏覽器 | 當時建議理由 | 本次實測範圍 |
|---|---|---|
| Firefox Android | GeckoView 與 Chromium 系列不同；Mozilla 有官方 APK，適合先試 | 已安裝 159.0，完成下述部分測試 |
| Edge Android | 可作 Chromium 系列網站相容性對照 | 未安裝、未實測 |
| Chrome Android | 原廠問題原因未明，不能直接斷言不能使用 | 未安裝、未實測 |

Firefox、Edge、Chrome 的初始順序是試裝建議，不是三款在 KB3 的完整實測排行。

Kevin 明確選擇「先用 Firefox 正式版」，後來將「下載到 KB3 桌面」釐清為「直接安裝在 KB3，讓我能點開使用」，並指定沿用 Wi-Fi ADB。

Kevin 同意官方 APK 暫存到 C:\Nuwa-kebbi3\kb3-stand-squat\tools\firefox-159.0-arm64.apk，成功後刪除；已按此執行，成品是 KB3 上的 Firefox。

## 4. 安裝與核對結果

### 4.1 實機與工具

| 項目 | 已核對內容 |
|---|---|
| 裝置 | 女媧 Kebbi 3／KB3，AIR_H300／AIR-H300 |
| 系統／架構 | Android 15／arm64-v8a |
| 螢幕 | 1024 × 600 |
| 當次 Wi-Fi ADB | 192.168.1.108:8888，可能隨網路環境改變 |
| 裝置身分 | 已核對序號，公開版省略 |
| 本次診斷 ADB | C:\Nuwa-kebbi3\kb3-stand-squat\tools\platform-tools\adb.exe |
| 既有腳本選到的 ADB | C:\Nuwa-kebbi3\KB3_WiFi_ADB_Windows_37.0.1\platform-tools\adb.exe |
| RustDesk 版本 | 既有紀錄為 KB3 1.5.0、Windows 1.4.6+64；本次未升級 |
| 連線方式 | 筆電經 GCP 中繼到 KB3，狀態顯示加密中繼連線 TCP |

### 4.2 官方 APK

| 項目 | 結果 |
|---|---|
| 版本 | Firefox Android 159.0 正式版 |
| 套件 | org.mozilla.firefox |
| versionCode | 2016191882 |
| ABI | arm64-v8a |
| minSdk／targetSdk | 26／37 |
| 檔案大小 | 133,943,377 bytes |
| APK SHA-256 | F78E11ABC85C59DD7AAB03DD8F926AC62DF99731CCF62EC6EC937C18B3E33AA9 |
| 簽章 | APK Signature Scheme v2 通過 |
| 憑證 | Mozilla Corporation／release engineering |
| 憑證 SHA-256 | a78b62a5165b4494b2fead9e76a280d22d937fee6251aece599446b2ea319b04 |

來源：[Mozilla 版本資料](https://product-details.mozilla.org/1.0/mobile_versions.json)、[本次官方 ARM64 APK](https://ftp.mozilla.org/pub/fenix/releases/159.0/android/fenix-159.0-android-arm64-v8a/fenix-159.0.multi.android-arm64-v8a.apk)。

APK 摘要用來辨識本次檔案；本紀錄未將它寫成「已與另一份獨立取得的官方 SHA-256 清單比對」。使用本機 aapt／apksigner 核對資訊及簽章，標準 ADB install 回傳 Success。

org.mozilla.firefox/.App 可啟動到 org.mozilla.fenix.HomeActivity。完成首次使用導引，沒有設為系統預設瀏覽器。助理初次網站測試停在登入入口，沒有代輸入 Google 密碼；後續登入及選擇影片由 Kevin 操作。

### 4.3 安裝與重啟曾受阻的記錄

記憶體串流安裝曾被自動核准審查回覆「blocked by policy」，沒有具體理由。後來改為 Kevin 核准的暫存、核對及標準安裝流程。

Firefox 的強制停止／啟動組合曾受阻，Kevin 明確同意「只重啟 Firefox」後，強制停止成功；帶網址的啟動步驟又曾受阻，最後以一般 App 元件啟動完成重啟。未把被阻擋的步驟記為成功。

## 5. 網站測試與黑屏證據

### 5.1 網站驗證程度

| 內容 | 已觀察 | 限制 |
|---|---|---|
| e-ai.tw 初次測試 | 專家登入頁正常、帳號欄位可叫出鍵盤 | 不代表後台所有功能正常 |
| Google Drive 初次測試 | 官網與 Google 登入入口正常 | 當時未驗證登入後檔案操作 |
| Kevin 使用 Drive MP4 | Kevin 確認 KB3 本機能播放、筆電異常 | 不是已證實的整機當機 |
| 分享重建後 eAi | 首頁、管理主頁、姿態小工具能傳回筆電 | 相機、姿態計算、報告未全面測試 |
| 分享重建後 Drive | Kevin 開啟的上斜方肌拉伸 MP4 封面及後續圖卡能顯示，遠端滑鼠能操作播放控制 | 未完成完整音畫同步、長時間穩定性或所有影片驗收 |

後續短測與最初足趾／姿勢影片不是已證實的同一檔案。原始故障影片尚未做完全相同條件的重現測試。

### 5.2 黑屏當下

- ADB 可連線，Android UI 結構仍可讀。
- Firefox 直接用 ADB screencap 擷取也黑，只剩 RustDesk 浮動圖示。
- 相同 RustDesk 連線能顯示系統設定。
- 一般空白新分頁也黑；不是只遮住影片區域。
- 當時是一般分頁，未證實是隱私瀏覽造成。
- 重啟 Firefox 成功但未解除黑屏。
- 未清除 Firefox 資料、Drive 檔案，未重開整台 KB3。

直接 ADB 截圖黑，並不等於 Firefox 自己畫不出內容；Android 在有效螢幕分享期間的視窗保護也可能影響擷取。後續停止／重建分享的對照才提供更強證據。

### 5.3 系統與網路檢查

| 檢查 | 結果 | 不能過度推論之處 |
|---|---|---|
| ANR | since boot 無 ANR | 不代表沒有任何相容性問題 |
| 記憶體 | 總量約 7.48 GB，Available 約 1.79 GB | 不能只看低 Free 值判斷耗盡 |
| CPU | 8 核，抽樣約 389% idle／800% 總量 | 背景有負載，未證實全機 CPU 全滿 |
| Wi-Fi | 2.4 GHz／2412 MHz／11n，RSSI 約 -64，link rate 52 Mbps | Link rate 不是實際網際網路頻寬 |
| 筆電到 KB3 ping | 6 次成功，約 3–22 ms | 樣本短，未涵蓋 GCP 中繼 |
| RustDesk | 加密中繼 TCP，黑屏仍收到幀與數十毫秒延遲 | 黑圖流量低不能證明頻寬充足 |
| 投影 | com.carriez.flutter_hbb 的 TYPE_SCREEN_CAPTURE 有效 | 有效投影不保證每個視窗可擷取 |

觀察期間也曾出現約 1.2 秒延遲瞬間值，網路波動不能完全排除。但本次持續黑屏在相同網路下，透過重建分享解除，較支持擷取／分享狀態問題。

### 5.4 恢復對照

| 動作 | 結果 |
|---|---|
| 重啟 Firefox | 仍黑 |
| VP8 改 VP9 | 確認 VP9 生效，Firefox 仍黑，系統設定正常 |
| 改 H.264 | 確認 H264 生效，Firefox 仍黑，系統設定正常 |
| 停止 KB3 RustDesk | MediaProjection 變 null，Firefox 首頁立即可擷取 |
| 重開 RustDesk、啟動分享 | 投影再次有效，Firefox 首頁仍可擷取 |
| 既有腳本重連 | 筆電可看到 eAi 與影片頁 |
| 恢復 RustDesk Input | 電腦滑鼠可操作影片控制 |

黑屏階段 Firefox 圖層資料曾含 SENSITIVE_FOR_PRIVACY，重建分享後該標記消失。一般視窗旗標未列 FLAG_SECURE，不能只憑單一旗標判斷全部保護狀態。

Android 15 官方說明會在分享期間隱藏密碼等敏感內容，App 也能用 setContentSensitivity 標示視窗。這與本次結果相符，但尚未證實最初由哪個登入頁、通知、Firefox 行為或 KB3 韌體互動觸發；也未證實是 DRM。

來源：[Android 15 螢幕分享保護](https://developer.android.com/about/versions/15/behavior-changes-all#screenshare-protection)、[MediaProjection](https://developer.android.com/media/grow/media-projection)。

## 6. VP8 與 H.264 的現場比較

Firefox 對 MP4 的解碼，與 RustDesk 對 Android 整體畫面的編碼，是兩段不同流程。切換 RustDesk H.264 不會改變 Drive 原始影片，也不是調整網站 HTTPS 或 WebRTC 協定。

| 項目 | VP8 | H.264 |
|---|---|---|
| 異常時單靠切換能否解除黑屏 | 不能 | 不能 |
| 分享重建後 eAi／Drive 圖卡 | 可顯示 | 可顯示 |
| 影片頁常見瞬間 FPS | 約 27–30 | 約 28–31 |
| 正常時段延遲樣本 | 約 24–41 ms | 約 27–41 ms |
| 顯示目標碼率 | 常見 428 kb，自適應時更低 | 常見約 1,822–2,144 kb |
| 低動態圖卡流量例子 | 約 6–8 kB/s，切換瞬間也見 22.84 kB/s | 約 10–13 kB/s |
| RustDesk 程序 CPU 抽樣 | 約 44.4–50.0% | 約 39.2–44.4% |
| 整理時設定 | 已實際切回 VP8 | 留作後續比較候選 |

VP9 用於排查黑屏，未完成它的日常效能驗收。

這不是同碼率、同播放秒數、同內容的受控測試；期間有 Kevin 與助理交互操作，影片多為圖卡，兩種 codec 的自動目標碼率不同。CPU 是 Android top 的單核 100% 計法，不是整台 8 核的使用率。UI 無障礙樹曾連續回報相同統計值，因此沒有將那幾筆當作獨立樣本計算平均延遲。實際流量、目標碼率、可用頻寬不可混為一談。

建議先留 VP8：目前可用，沒有足以證明 H.264 必然更適合的差距。若主要用途是連續運動影像，再以相同片段、畫質、幀率與網路比較細節、CPU、流量及長時間穩定性。H.264 仍是合理候選，本次沒有判定它不相容。

參考：[RustDesk 官方進階設定與 codec](https://rustdesk.com/docs/en/self-host/client-configuration/advanced-settings/)。

## 7. 日常操作與恢復方法

### 7.1 沿用昨天的無人值守方案

昨天「研究 KB3 遠端喚醒與操作方案」已記錄 Kevin 授權這台筆電隨時控制這台 KB3，並完成固定密碼及 GCP 通道測試。

方案是讓腳本從本機私人 MD 讀取已設定的固定密碼，進行正常認證；不是取消密碼，也不是只憑筆電身分自動放行。

1. 開啟 C:\eAi360-kb3-remote-control。
2. 對「叫醒並連線KB3.ps1」按右鍵，選「使用 PowerShell 執行」。
3. 保留 TCP 通道視窗，切到有 KB3 畫面的桌面視窗。
4. 確認畫面後，實際點按或切換分頁，補驗輸入控制。

本次一開始直接按 RustDesk「連線」，所以再次出現密碼視窗。助理先要求 Kevin 輸入；Kevin 指示查昨天紀錄後，才改回既有腳本。關閉手動建立的未認證桌面視窗，再執行腳本後成功連入。沒有修改固定密碼，不需重新設定無人值守。

### 7.2 再次黑屏

1. 先確認本機是否正常，並用系統設定畫面作對照。
2. 本機正常、Firefox 黑、系統設定可投影時，檢查並重新建立 KB3 RustDesk 螢幕分享。
3. 優先使用 App「螢幕分享」頁的停止／啟動服務。本次實際排查曾用強制停止後重開。
4. 檢查「畫面錄製」和「輸入控制」是否都有效。
5. RustDesk Input 關閉時，恢復已授權的服務。只有畫面可見不能算完成。
6. 關閉失效桌面連線，使用既有腳本重連，再驗證畫面與點按。
7. 若只在登入／密碼／敏感頁變黑，先完成正常登入或離開該頁，再測一般網頁。

本次沒有停用 Android 全域分享保護，沒有修改 Firefox 隱私截圖設定，也沒有清除瀏覽資料或重設機器。

### 7.3 診斷指令

以下為本次查核紀錄，當次位址與裝置仍須先核對。

~~~powershell
$adb = 'C:\Nuwa-kebbi3\kb3-stand-squat\tools\platform-tools\adb.exe'
$kb3 = '192.168.1.108:8888'
& $adb devices -l
& $adb -s $kb3 shell dumpsys media_projection
& $adb -s $kb3 shell dumpsys activity lastanr
& $adb -s $kb3 shell settings get secure enabled_accessibility_services
& $adb -s $kb3 shell dumpsys accessibility
& $adb -s $kb3 shell am start -W -n org.mozilla.firefox/.App
& $adb -s $kb3 shell am start -W -n com.carriez.flutter_hbb/.MainActivity
powershell.exe -NoProfile -File 'C:\eAi360-kb3-remote-control\叫醒並連線KB3.ps1' -NoPause
~~~

本次用過 am force-stop com.carriez.flutter_hbb 重建分享，其後 RustDesk Input 不在已啟用清單。恢復後的元件是 com.carriez.flutter_hbb/com.carriez.flutter_hbb.InputService，已列為 Bound，未列為 Binding／Crashed。強制停止後必須補驗輸入，不宜直接宣告完成。

## 8. 完成與尚待驗證

已完成：官方 APK 核對與安裝、刪除暫存檔、eAi／Drive 登入入口、三種 codec 黑屏對照、重建分享恢復、既有腳本認證重連、RustDesk Input 恢復、電腦滑鼠操作影片控制、eAi／Drive 影片圖卡顯示、切回 VP8。

尚待驗證：

- 原廠所說 Chrome 的具體問題與推薦版本。
- Chrome、Edge 在本台 KB3 的實機表現。
- 原始故障影片以完全相同條件重現。
- 敏感標記最初由哪個頁面、通知或系統步驟觸發。
- 長時間播放、音畫同步、網路波動、熄屏後重新分享的完整驗收。
- 相同片段／碼率／畫質的嚴格 VP8／H.264 效能比較。
- eAi 相機、麥克風、姿態辨識、正式量測與報告，以及 Drive 上下載的全面驗收。

## 9. 處理過程的修正

1. 重啟 Firefox 未解決後，助理曾只給出相容性判斷便結束。Kevin 指出應繼續研究，後續才完成 codec、分享重建與恢復對照。
2. 重連未先沿用昨天腳本，造成再次要求輸入密碼。查紀錄後改用既有方案成功。
3. 畫面恢復後沒有立即補驗滑鼠，Kevin 回報不能點按才查到 RustDesk Input 關閉；恢復後才實測。
4. 曾說要保留 VP8，但下一次檢查見 H.264，最後重新操作選單切成 VP8，以狀態欄確認。
5. 自動輸入 Drive 網址曾漏字／錯置，出現找不到網址；後來逐字輸入並核對。這是輸入問題，不能記為 Drive 相容性故障。後續影片驗證使用 Kevin 開啟的頁面。

之後同類驗收至少分別確認：畫面可見、滑鼠可點、既有認證能重連、影片頁能呈現；其餘未測功能另外列明。

## 10. 來源與 GitHub 管理

- [女媧 Kebbi 3 官方規格](https://www.nuwarobotics.com/ja/zh-hant/products/kebbi-3)
- [Mozilla GeckoView 架構](https://firefox-source-docs.mozilla.org/mobile/android/geckoview/contributor/geckoview-architecture.html)
- [Edge Android 核心說明](https://blogs.windows.com/msedgedev/2017/10/05/microsoft-edge-ios-android-developer/)
- [Chrome 系統要求](https://support.google.com/chrome/a/answer/7100626?hl=en)
- [Firefox 官方 Android 安裝說明](https://support.mozilla.org/en-US/kb/install-firefox-your-phone-or-tablet)
- [RustDesk Android 文件](https://rustdesk.com/docs/en/client/android/)
- [RustDesk 進階設定](https://rustdesk.com/docs/en/self-host/client-configuration/advanced-settings/)
- [Android 15 螢幕分享保護](https://developer.android.com/about/versions/15/behavior-changes-all#screenshare-protection)
- [Android MediaProjection](https://developer.android.com/media/grow/media-projection)

研究時找到隱私分頁截圖及其他平台黑屏回報，但條件不同，沒有直接當成本次根因。

依 Kevin 要求，本檔新增在指定專案並推送既有 [GitHub 專案](https://github.com/kevinliu-ez/eAi360-kb3-remote-control)。原本含密碼的私人 MD 維持 .gitignore 規則，不加入提交。commit 與推送結果以 Git 紀錄及交付回覆為準，不預先宣稱成功。

## 11. 今日對話文字紀錄

以下保留可取得的 Kevin 與 Codex 對話文字，已遮蔽敏感內容及轉換確認問答格式。較早說法若被後續證據更新，以正文及後續訊息為準。

### 11.1 回合開始：2026/10/31 08:46:31

#### 對話 1：Kevin

> 我需要在女娲KB3上面安装浏览器。你帮我确定，应该要安装 Google 的 Chrome，或者微软的 Edge，或者 Firefox。先能够完成大部分的网页，不需要完全相容。听原厂讲，Chrome 好像有些问题。总之你先帮我研究确认，给我建议。

#### 對話 2：Codex（進度說明）

> Kevin，我會先確認女媧 KB3 的系統與原廠瀏覽器限制，再比較 Chrome、Edge、Firefox，重點看哪個能開啟大多數常用網頁、安裝上也較可行。最後直接給你安裝優先順序與理由；這次先研究，不安裝或建立檔案，避免只憑桌面版瀏覽器的印象做判斷。

#### 對話 3：Codex（進度說明）

> 已確認官方的新一代 Kebbi 3 使用 Android 15，不能套用舊款凱比 Android 9 的限制。目前還沒找到原廠公開說明「Chrome 有什麼問題」；我會再核對安裝來源與瀏覽器核心，判斷換成 Edge 或 Firefox 是否有實際幫助。

#### 對話 4：Codex（回覆／確認事項）

> 原廠說 Chrome 有問題時，有提到是哪一種情況嗎？這會影響 Edge 能否避開同樣問題；不確定也沒關係。
> - 不確定，只說有問題
> - 無法安裝、打不開或會閃退
> - 網頁、影片或登入功能異常

#### 對話 5：Codex（回覆／確認事項）

> Kevin，我建議：先試裝 Firefox 的 Android 正式版，Edge 作為第二選擇，Chrome 暫時排第三。
>
> 這是根據官方資料做出的安裝優先順序；目前沒有找到女媧公開的 KB3 瀏覽器實測報告，因此還不能保證哪一款在你的機器上一定正常。
>
> 我把你說的 KB3 按照官方 Kebbi 3（第三代）查核。它使用 Android 15，並非舊款的 Android 9，因此不能直接套用舊機型的瀏覽器限制。[女媧官方規格](https://www.nuwarobotics.com/ja/zh-hant/products/kebbi-3)
>
> | 瀏覽器 | 我的建議 | 主要理由 |
> |---|---|---|
> | Firefox | 第一個試裝 | 使用與 Chrome 不同的網頁核心，適合在 Chrome 原因不明的情況下先嘗試；也有官方 APK 安裝來源。 |
> | Edge | 第二選擇、補充相容性 | 與 Chrome 同屬 Chromium／Blink 系列，適合拿來測試 Firefox 顯示或操作不正常的網站。 |
> | Chrome | 暫緩優先安裝 | Android 15 符合目前 Chrome 的系統要求，但你已收到原廠的問題提醒，值得先查清楚。 |
>
> Firefox 使用 Mozilla 的 GeckoView；Edge Android 使用 Chromium 的 Blink。這個差異代表：如果 Chrome 的問題出在共同核心或其與機器系統的互動，換 Edge 仍可能遇到；如果只是 Chrome 本身的安裝或特定功能問題，Edge 就可能正常。這是技術上的判斷，並非已證實的 KB3 故障原因。[Mozilla 核心說明](https://firefox-source-docs.mozilla.org/mobile/android/geckoview/contributor/geckoview-architecture.html)、[Microsoft 核心說明](https://blogs.windows.com/msedgedev/2017/10/05/microsoft-edge-ios-android-developer/)、[Chrome 系統要求](https://support.google.com/chrome/a/answer/7100626?hl=en)
>
> Firefox 還有一個實際優點：Mozilla 官方提供 Android APK。假如你的 KB3 沒有可用的 Google Play，仍有官方安裝檔來源；但機器是否允許安裝，以及應選哪個套件，需依實機確認。[Mozilla 官方安裝說明](https://support.mozilla.org/en-US/kb/install-firefox-your-phone-or-tablet)
>
> 以你「先能使用大部分網頁，不追求完全相容」的需求，我會這樣做：
>
> 1. 先用 Firefox 正式版，測試你最常用的 5～10 個網站。
> 2. 確認文字圖片、按鈕表單、登入、影片聲音，以及關閉後重新開啟是否正常；需要相機或麥克風的網站另外測。
> 3. 只有遇到重要網站無法使用，再用 Edge 比較。兩者都正常時，選你操作較順的一款即可。
>
> 目前最需要原廠補充的是「Chrome 究竟出了什麼問題，以及哪個瀏覽器版本已在 KB3 測試通過」。若原廠能提供已驗證的 Edge 版本，我會優先採用那個實機結果；在尚無這項資訊前，Firefox 是我建議的第一個試裝選擇。

### 11.2 回合開始：2026/10/31 08:51:46

#### 對話 6：Kevin

> 確認事項：原廠說 Chrome 有問題時，有提到是哪一種情況嗎？這會影響 Edge 能否避開同樣問題；不確定也沒關係。
> Kevin 回覆：不確定，只說有問題

#### 對話 7：Codex（回覆／確認事項）

> 了解，那目前只能確認「原廠提醒 Chrome 有問題」，還無法判定原因，也不能確定換成 Edge 就能解決。
>
> 我的建議維持：先試裝 Firefox Android 正式版，用你常用的網站確認是否夠用；遇到重要網站不相容，再測 Edge。
>
> 這是目前較合理的試裝順序，尚不是 KB3 實機驗證結果。你不需要先查清楚 Chrome 的所有問題，才能開始測試 Firefox。

### 11.3 回合開始：2026/10/31 08:52:43

#### 對話 8：Kevin

> 先用 Firefox 正式版

#### 對話 9：Codex（進度說明）

> Kevin，就先用 Firefox 正式版。我會先確認這台電腦能否連到 KB3，再決定透過商店或 APK 安裝，最後測試網頁能否正常開啟。這樣可以把選擇落實成可用的瀏覽器；若需要下載 APK，我會先確認存放位置。

#### 對話 10：Codex（進度說明）

> 電腦已有 KB3 的連線工具，但目前沒有偵測到已連線的機器。接下來需要確認連線方式；若要用 APK 安裝，也要依你的檔案儲存規則先確認下載位置。

#### 對話 11：Codex（回覆／確認事項）

> Firefox 正式版 APK 要下載到哪裡？依你的儲存規則，確認位置後我才會寫入檔案。
> - 實體桌面 C:\Users\kevin\Desktop
> - 我另外指定資料夾
> - 先不下載
>
> KB3 準備用哪種方式連到這台電腦？目前連線工具沒有偵測到裝置。
> - USB 連線，我接好後告訴你
> - 同一個 Wi-Fi，我提供 KB3 的 IP
> - 先準備安裝檔，稍後再連機器

#### 對話 12：Codex（回覆／確認事項）

> 好，確定使用 Firefox Android 正式版。
>
> 電腦已有 KB3 連線工具，但目前未連到機器，尚未安裝。接下來請確認：
>
> 1. APK 是否下載到實體桌面 `C:\Users\kevin\Desktop`？
> 2. KB3 要用 USB、Wi-Fi 連線，還是先只準備安裝檔？
>
> 依你的儲存規則，下載位置需先由你確認，我才會寫入檔案。

### 11.4 回合開始：2026/10/31 08:54:13

#### 對話 13：Kevin

> 直接帮我下载到KB3的桌面。

#### 對話 14：Codex（進度說明）

> Kevin，我會先確認能否連到 KB3，以及它是否有桌面資料夾，再把 Firefox 正式版 APK 直接下載到你指定的位置。完成後會核對檔案；如果 KB3 沒有一般電腦那種桌面，我會先釐清位置，避免存錯地方。

#### 對話 15：Codex（進度說明）

> 已透過 Wi-Fi 連上 KB3，確認它是 Android 15、支援 ARM64，也尚未安裝 Firefox。不過機器上沒有「桌面」檔案資料夾，只有 Android 的 App 主畫面；我需要釐清你是要能點開的 Firefox 圖示，還是只存放 APK，避免擅自改變你指定的交付方式。

#### 對話 16：Codex（回覆／確認事項）

> 你說「下載到 KB3 的桌面」，是指直接把 Firefox 裝好，讓你能從 App 主畫面點開使用嗎？KB3 沒有桌面檔案資料夾。
> - 對，直接安裝 Firefox，讓我能點開使用
> - 只下載 APK，存放位置我另外指定

#### 對話 17：Kevin

> 確認事項：你說「下載到 KB3 的桌面」，是指直接把 Firefox 裝好，讓你能從 App 主畫面點開使用嗎？KB3 沒有桌面檔案資料夾。
> Kevin 回覆：對，直接安裝 Firefox，讓我能點開使用

#### 對話 18：Kevin

> 应该说就是直接安装在KB3。 用Wi‑Fi ADB，你查一下之前的聊天都有。

#### 對話 19：Codex（進度說明）

> 收到，你要的是直接安裝在 KB3。Wi‑Fi ADB 已連上 `192.168.1.108:8888`，不用再提供連線資料。我會查看先前的 KB3 聊天，並用 Mozilla 官方正式版完成安裝，再確認 Firefox 能啟動並開啟網頁。

#### 對話 20：Codex（進度說明）

> 先前紀錄確認了這台 KB3 的 Wi‑Fi ADB 位址。已找到 Mozilla 官方 Firefox 159.0 正式版的 ARM64 安裝包，我會直接傳入 KB3 安裝，不另存到電腦桌面。

#### 對話 21：Codex（進度說明）

> 剛才取得安裝包時逾時，尚未開始安裝。KB3 連線正常，我會換個下載方式繼續從 Mozilla 官方來源取得安裝包。

#### 對話 22：Codex（進度說明）

> Wi‑Fi ADB 已連好，但安裝尚未開始。我可以改用先核對 APK 檔、再執行標準 ADB 安裝的流程；這需要先確認一個暫存位置，成功後刪除暫存檔。
>
> 自動核准審查拒絕了剛才「從記憶體串流安裝 Firefox」的指令，只回傳「blocked by policy」，沒有提供具體原因。

#### 對話 23：Codex（回覆／確認事項）

> 可否將 Mozilla 官方 APK 暫存到既有工具資料夾 `C:\Nuwa-kebbi3\kb3-stand-squat\tools\firefox-159.0-arm64.apk`，核對後用標準 Wi‑Fi ADB 安裝，成功後刪除暫存檔？成品仍只有 KB3 上的 Firefox。
> - 可以，安裝成功後刪除暫存 APK
> - 我另外指定暫存位置

#### 對話 24：Codex（回覆／確認事項）

> 已連上 KB3 的 Wi‑Fi ADB，Firefox 尚未安裝。
>
> 請確認能否暫存 APK 到 `C:\Nuwa-kebbi3\kb3-stand-squat\tools\firefox-159.0-arm64.apk`，供核對後安裝；成功後會刪除，Firefox 只安裝在 KB3。
>
> 自動核准審查拒絕了記憶體串流安裝指令，僅回傳「blocked by policy」，未提供具體原因，因此需要改用可逐步檢查的安裝流程。

### 11.5 回合開始：2026/10/31 09:01:45

#### 對話 25：Kevin

> 確認事項：可否將 Mozilla 官方 APK 暫存到既有工具資料夾 `C:\Nuwa-kebbi3\kb3-stand-squat\tools\firefox-159.0-arm64.apk`，核對後用標準 Wi‑Fi ADB 安裝，成功後刪除暫存檔？成品仍只有 KB3 上的 Firefox。
> Kevin 回覆：可以，安裝成功後刪除暫存 APK

#### 對話 26：Codex（進度說明）

> Kevin，我會把官方 APK 暫存到你剛同意的位置，核對檔案後透過 Wi‑Fi ADB 安裝，再確認 Firefox 能啟動。完成後會刪除暫存 APK，讓你直接在 KB3 上點開使用；分步處理也能清楚確認下載與安裝是否成功。

#### 對話 27：Codex（進度說明）

> 安裝包已下載約三分之二，KB3 仍保持連線。下載完成後會先核對套件名稱、版本與簽章，再執行安裝。

#### 對話 28：Codex（進度說明）

> APK 已通過簽章驗證，套件名稱、159.0 版本及 ARM64 架構都符合預期。現在正透過 Wi‑Fi 傳送到 KB3 安裝，接著會確認啟動與網頁顯示。

#### 對話 29：Codex（進度說明）

> Firefox 已安裝成功，也能正常啟動。我正在完成首次使用畫面並測試網頁，完成後會清掉暫存 APK。

#### 對話 30：Kevin

> [https://e-ai.tw/](https://e-ai.tw/) 你测试一下这个，还有Google Drive。

#### 對話 31：Codex（進度說明）

> Kevin，我會直接在 KB3 的 Firefox 測試 `e-ai.tw` 和 Google Drive，檢查頁面、點選操作及登入入口是否正常，最後分別回報可用程度與卡住的位置。這樣能確認你實際要用的網站；如果 Drive 需要帳號登入，我會先測到登入入口。

#### 對話 32：Codex（進度說明）

> `e-ai.tw` 已正常顯示「專家登入」頁，點選帳號欄位也能叫出鍵盤；Google Drive 官網及 Google 帳號登入頁都能開啟。目前兩者都需要登入，還不能據此確認 eAi 後台或 Drive 檔案操作是否正常。

#### 對話 33：Codex（回覆／確認事項）

> Firefox 159.0 正式版已安裝到 KB3，暫存 APK 已刪除。
>
> 實機測試結果：
>
> | 網站 | 結果 |
> |---|---|
> | [e-ai.tw](https://e-ai.tw/) | 專家登入頁正常顯示，帳號欄位與鍵盤可操作。 |
> | [Google Drive](https://drive.google.com/) | 官網及 Google 帳號登入頁正常開啟。 |
>
> 目前尚未登入，所以 eAi 後台、Drive 檔案清單與上下載功能還沒驗證。
>
> KB3 現在停在 eAi 登入頁，Google Drive 登入頁保留在上方分頁，可直接切換登入。

### 11.6 回合開始：2026/10/31 09:16:10

#### 對話 34：Kevin

> 你帮我看一下现在画面呈现整个当机状况，到底是频宽的问题还是什么。我刚操作了一个云端播放，从我的 Google Drive 去跑内建的 MP4，但画面没有办法传过来桌面，然后就整个当机了。看如何帮我解释清楚，跟采取必要的手段恢复一下。

#### 對話 35：Codex（進度說明）

> Kevin，我會先確認 KB3 是否還有回應，再查看 Firefox、影片播放與投放畫面的狀態，分辨是網路載入卡住、瀏覽器當掉，還是畫面傳輸出問題。接著會先用影響最小的方式恢復，必要時重啟卡住的 App；最後把查到的原因、恢復結果與避免再發生的做法講清楚。

#### 對話 36：Codex（進度說明）

> KB3 的 Wi‑Fi ADB 仍有回應，表示它還沒有完全失去連線。我也會使用 computer-use 技能查看電腦上的 RustDesk 視窗，對照 KB3 本機畫面，確認是影片卡住，還是只有遠端畫面停住。

#### 對話 37：Codex（進度說明）

> 目前沒有系統「無回應」紀錄，記憶體也還有約 1.7 GB 可用；RustDesk 能顯示通知面板，所以暫時不像整台 KB3 當機。我會先退出影片畫面，確認瀏覽器能否恢復，再檢查網路延遲與遠端傳輸狀態。

#### 對話 38：Codex（進度說明）

> 區域網路測到的延遲約 3～22 毫秒，這 6 次測試都成功；目前沒有證據能把黑畫面歸因於頻寬不足。切回一般網頁仍是黑畫面，我先重啟 Firefox 的執行程序，保留帳號與網站資料，確認是否是播放後的顯示狀態卡住。

#### 對話 39：Codex（進度說明）

> 重啟 Firefox 的指令被擋下，尚未執行。我會先改用開啟系統設定這種不關閉程序的方式，確認黑畫面是否也影響其他 App。
>
> 自動核准審查拒絕了「強制停止並重新啟動 Firefox」的指令，只回傳「blocked by policy」，未提供具體原因。

#### 對話 40：Codex（回覆／確認事項）

> 目前 KB3 本機螢幕也黑掉或卡住，還是只有電腦上的 RustDesk 畫面異常？這能幫我區分影片顯示與遠端傳輸問題。
> - KB3 本機也黑掉或卡住
> - KB3 本機能播放，只有電腦畫面異常
> - 現在不在機器旁邊，無法確認

#### 對話 41：Kevin

> 確認事項：目前 KB3 本機螢幕也黑掉或卡住，還是只有電腦上的 RustDesk 畫面異常？這能幫我區分影片顯示與遠端傳輸問題。
> Kevin 回覆：KB3 本機能播放，只有電腦畫面異常

#### 對話 42：Kevin

> 你检查一下现在 Rust Desk 的画面是黑的。 剛才又恢復了，感覺是頻寬問題。

#### 對話 43：Codex（進度說明）

> 有可能是頻寬造成延遲，但現在還不能直接下這個結論。你剛看到恢復的時間點，正好是我切到 KB3 的系統設定；而 Firefox 黑畫面也出現在直接從 KB3 取得的截圖中。我會再用同一條連線對照設定頁與 Firefox，並查看 RustDesk 的傳輸狀態。

#### 對話 44：Codex（進度說明）

> 對照結果很明確：同一條連線顯示系統設定正常，一切回 Firefox 就黑；黑畫面時 RustDesk 仍顯示約 40 毫秒延遲、16 FPS。加上 KB3 本機能播放，較像 Firefox／影片畫面在「擷取成遠端影像」這一段出了問題，不能只用頻寬解釋。接下來我會先嘗試退出影片分頁，避免重開整台機器。

#### 對話 45：Codex（進度說明）

> 目前可確認：KB3 本機能播放，問題集中在 Firefox 畫面被擷取、傳到電腦的這段流程。系統設定頁能正常傳過來，Firefox 的直接截圖卻是黑的，所以即使增加頻寬，也不一定能解決這次問題。
>
> 我會先把畫面留在可操作的系統設定頁。下一步是只重啟 Firefox，再驗證一般網頁與影片；先前這個重啟指令被自動核准審查拒絕，僅回傳「blocked by policy」，因此需要你明確確認後再嘗試。

#### 對話 46：Codex（回覆／確認事項）

> 是否同意只強制關閉並重新啟動 KB3 上的 Firefox，再檢查投影是否恢復？這會中止目前播放，但不清除帳號、網站資料或 Google Drive 檔案。先前此指令被自動核准審查攔截，需要你明確確認後再嘗試。
> - 同意，只重啟 Firefox
> - 我在 KB3 手動關閉並重開 Firefox

#### 對話 47：Kevin

> 確認事項：是否同意只強制關閉並重新啟動 KB3 上的 Firefox，再檢查投影是否恢復？這會中止目前播放，但不清除帳號、網站資料或 Google Drive 檔案。先前此指令被自動核准審查攔截，需要你明確確認後再嘗試。
> Kevin 回覆：同意，只重啟 Firefox

#### 對話 48：Codex（進度說明）

> 收到，我現在只重啟 Firefox，再對照 KB3 截圖與 RustDesk 畫面，確認一般網頁是否恢復；帳號與網站資料會保留。

#### 對話 49：Codex（進度說明）

> Firefox 已完成重啟，但遠端仍是黑畫面，因此不是單純重新啟動就能排除的問題。我再確認一下：若連 Firefox 的空白新分頁也無法擷取，就能把問題進一步縮小到瀏覽器與 KB3 的畫面擷取相容性，而不是 Google Drive 影片本身。

#### 對話 50：Codex（進度說明）

> 目前 Firefox 重啟後仍然黑屏，但 KB3 的系統設定畫面能正常傳回來。這表示整台機器沒有當機；問題比較集中在 Firefox 的畫面擷取。我會再用空白新分頁確認一次，這能判斷是否連沒有影片的畫面也受影響。

#### 對話 51：Codex（回覆／確認事項）

> 已完成 Firefox 重啟，但黑畫面尚未恢復。沒有清除帳號、網站資料或 Google Drive 檔案。
>
> 目前比較像 Firefox 與 KB3 的畫面擷取相容性問題，不能只歸因於頻寬，因為：
>
> - KB3 本機能播放，系統設定也能正常投影，沒有整台當機。
> - 繞過 RustDesk、直接用 ADB 擷取，Firefox 仍是黑畫面。
> - 連沒有影片的空白新分頁也黑，問題不只發生在 Google Drive 播放。
>
> 網路波動可能造成卡頓，但不足以解釋這次全部現象。接下來應查 Firefox 的擷取相容性；目前沒有足夠證據支持升級頻寬就能解決。

### 11.7 回合開始：2026/10/31 09:30:08

#### 對話 52：Kevin

> 你这样太不负责了，你没有继续往下研究。你看是不是 Redisco Desk 的 codec 的设定问题，还是去查一下 Firefox 的协议的问题，怎么可以这样就停在这里呢。

#### 對話 53：Codex（進度說明）

> Kevin，你說得對，我剛才停在判斷，沒有把排查做完。這次我會繼續確認 RustDesk 的編解碼器設定，再查 Firefox／Android 對螢幕分享的處理，並用可還原的測試找出黑屏發生在哪一段。最後會交代測試結果、實際修復情況和剩下的原因，讓你能決定怎麼穩定使用 KB3。

#### 對話 54：Codex（進度說明）

> 我已確認 RustDesk 現在使用 VP8，黑屏時仍持續收到約 30 FPS 的畫面，延遲約 30 毫秒。這還不能證明編解碼器正常；我會實際切換另一種編碼比較。Firefox 這邊也會區分「影片解碼」和「Android 擷取畫面」兩段，避免把兩種 codec 混在一起。

#### 對話 55：Codex（進度說明）

> VP9 已經實際套用，畫面仍然全黑，且連線持續更新。因此「原本選 VP8 導致黑屏」這個原因已經過對照測試，沒有得到支持。我會再比對系統設定畫面，接著重建 RustDesk 的擷取連線，確認是否是播放影片後留下的擷取狀態異常。

#### 對話 56：Kevin

> use h264 codec?

#### 對話 57：Codex（進度說明）

> 可以，我現在改測 H.264，並確認右上角顯示的實際編碼是否真的切換成功。它走的編碼路徑和 VP8／VP9 不同，這個對照有價值。

#### 對話 58：Codex（進度說明）

> 我看到已切成 H.264，右上角也確認實際使用 H.264，系統設定畫面正常。現在切回 Firefox 做同一條連線的對照，這一步才能確認 H.264 是否解決瀏覽器黑屏。

#### 對話 59：Codex（進度說明）

> H.264 也已測到：系統畫面正常，切回 Firefox 就黑，延遲約 30 毫秒。現在三種編碼的結果一致。我接著重新建立 KB3 的 RustDesk 螢幕分享，讓 Android 重新建立擷取畫面；這會短暫斷開遠端畫面，但不會清除 Firefox 或 Drive 的資料。

#### 對話 60：Codex（進度說明）

> 找到一個關鍵差異：一停止 RustDesk 螢幕分享，Firefox 的首頁立刻能正常擷取，畫面與分頁都還在。這把原因明顯縮小到「Android 啟用螢幕分享時的處理」，不是 Firefox 自己畫不出畫面。我正在重新啟動分享，確認是舊連線狀態卡住，還是每次分享都會觸發。

#### 對話 61：Codex（進度說明）

> 重新啟動 RustDesk 的螢幕分享後，Firefox 首頁已能在「分享仍開啟」的狀態下正常擷取，這是實際恢復的跡象。我正在讓電腦端重新連上，並保留 H.264，再確認 eAi 網頁也能正常顯示。

#### 對話 62：Codex（進度說明）

> KB3 端的 Firefox 已恢復正常擷取，但電腦重新連線時要求 RustDesk 密碼驗證。
>
> [電腦操作技能](C:/Users/kevin/.codex/plugins/cache/openai-bundled/computer-use/26.1021.31345/skills/computer-use/SKILL.md)明確要求「Do not automate user authentication dialogs.」，所以這一步需要你親自輸入；不必把密碼貼到聊天。我會同時繼續驗證 KB3 上的網頁與擷取狀態。

#### 對話 63：Codex（回覆／確認事項）

> 請在電腦上的 RustDesk 密碼視窗親自完成驗證，完成後告訴我，我就能確認電腦端的 H.264 畫面。
> - 已完成驗證
> - 目前無法驗證

#### 對話 64：Kevin

> 奇怪，我记得我们已经……我并没有特别设定密码，当初已经设定成随时这一台笔电可以永远控制KB3。你赶快检查昨天的聊天记录。

#### 對話 65：Codex（進度說明）

> 我會查昨天設定 KB3 遠端控制的聊天，核對當時是儲存密碼、信任這台筆電，還是用其他免重複確認的方式，再比對現在的狀態。先前已授權的連線設定應該沿用，我會先找出這次為什麼又要求驗證。

#### 對話 66：Codex（進度說明）

> 查到了，你記得沒錯。昨天的「研究 KB3 遠端喚醒與操作方案」已完成無人值守設定：固定密碼保存在本機私人文件，由「叫醒並連線KB3.ps1」自動讀取。
>
> 剛才我直接按 RustDesk 的連線按鈕，沒有沿用這支腳本，才又跳出密碼視窗。這是我的疏漏；不需要你重新設定或提供密碼，我現在改用昨天已驗證的連線方式。

#### 對話 67：Codex（進度說明）

> 已沿用昨天的腳本成功連回，不需要你輸入密碼。電腦端現在已顯示 Firefox 裡的 eAi 姿態工具，實際編碼是 H.264，約 30 FPS、37 毫秒延遲。
>
> 這次有效的恢復動作是重啟 KB3 上的 RustDesk 螢幕分享，再用既有腳本重連；單獨切換 codec 或重啟 Firefox 都沒有解除黑屏。

#### 對話 68：Codex（進度說明）

> 我再補最後一個驗證：確認影片播放時投影也能維持，避免只恢復了靜態網頁就結束。查到的 Android 官方說明也指出，螢幕分享期間會隱藏被標記為敏感的視窗；這次重建分享後，Firefox 原先的敏感標記已消失，但最初由哪個畫面觸發，還不能直接認定。

#### 對話 69：Kevin

> C:\eAi360-kb3-remote-control 请你把今天早上关于安装 Firefox 的浏览器的相关聊天尽量完整地记录到这个目录之下，另外存成 MD档案，并且 push 到 GitHub。

#### 對話 70：Codex（進度說明）

> 我會把今天早上 Firefox 安裝、eAi／Google Drive 測試、黑屏排查、三種 codec 比較，以及最後恢復連線的過程，盡量完整整理成一份新的 MD，存到你指定的 `C:\eAi360-kb3-remote-control`，再推送到現有 GitHub 專案。
>
> 文件會保留重要對話、指令與實測結果，清楚區分已確認和仍待驗證的部分；公開版會遮蔽密碼，方便你之後重現、交接或詢問原廠。

#### 對話 71：Kevin

> 剛才我在 Firefox 的主頁要點選，滑鼠點選卻沒有辦法，必須在 KB3上面手動。

#### 對話 72：Codex（進度說明）

> 這表示畫面雖然恢復，遠端點按還沒有恢復，還不能算修好。我會先檢查 RustDesk 的「輸入控制」服務是否在重啟後重新連上，再分別測試系統畫面與 Firefox 的點按。這個新問題和修復結果也會一起寫入剛才指定的 MD，再推送 GitHub。

#### 對話 73：Kevin

> 好像你把 Right Desk 設定成某一種顯示格式，所以就沒辦法去操控。

#### 對話 74：Codex（進度說明）

> 查到具體原因了：Android 的已啟用無障礙服務清單裡，現在少了 RustDesk，所以它能傳畫面，卻不能把滑鼠點按送進 KB3。H.264 本身只影響影像編碼。
>
> 這很可能是剛才重啟 RustDesk 時輸入控制被停用。我會依昨天已有的遠端控制授權，把 RustDesk 的輸入控制恢復，再實際用電腦滑鼠驗證。

#### 對話 75：Kevin

> 请你现在切换成 VP8 格式试试看，不见得要用 H264。你比较一下，我们应该用哪一个比较恰当。

#### 對話 76：Codex（進度說明）

> 可以，會改回 VP8，並和 H.264 在同一個網頁、相同操作下比較延遲、流量與順暢度，再決定保留哪一個。我先完成正在進行的輸入控制恢復，否則滑鼠不能操作會干擾比較；這次不把 H.264 預設成最佳選擇。

#### 對話 77：Codex（進度說明）

> RustDesk Input 現在已重新啟用並連上系統。畫面也已到你的 MP4 清單，正好可以做動態比較。接下來我會短暫操作 RustDesk 上方工具列切換 VP8；這段請先讓我操作滑鼠，避免兩邊同時點選讓測試中斷。

#### 對話 78：Codex（進度說明）

> 現在已確認切回 VP8，Google Drive 的 MP4 畫面正常，播放器也在往前播放。初步看 VP8 約 29 FPS、41 毫秒延遲；我會再取幾個樣本，和同一段影片的 H.264 結果比較。黑屏已解除，接下來比較的是日常操作與播放效率。

#### 對話 79：Codex（進度說明）

> 電腦滑鼠已能直接控制 Drive 影片，我剛才成功點出播放控制並暫停影片，遠端輸入已恢復。
>
> 目前 VP8、H.264 都能顯示這支影片，也都觀察到接近 30 FPS。這段內容以圖卡為主，還不足以證明 H.264 在快速動作影片上更好；我會先保留 VP8。它目前可用，而黑屏真正解除是在重建螢幕分享後，不是靠換成 H.264。這些限制會如實寫進比較紀錄。

#### 對話 80：Codex（進度說明）

> 已切回並確認目前是 VP8，Drive 影片畫面正常，剛才觀察到 27 FPS、27 毫秒延遲。兩種格式在這支圖卡影片上沒有明顯到足以換用 H.264 的差距，先用 VP8 合理。
>
> 我現在把今天的完整對話與實測整理進 MD，特別補上兩個容易混淆的原因：黑屏要重建螢幕分享；不能點按則要恢復 RustDesk Input。接著檢查公開內容並推送 GitHub。
