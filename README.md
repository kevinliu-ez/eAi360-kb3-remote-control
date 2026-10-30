# eAi360 KB3 遠端喚醒與桌面控制

本專案使用現成 RustDesk Server OSS 與客戶端，讓 Windows 筆電經 GCP 操作 KB3。針對這台 KB3 熄屏後原版 RustDesk 會停在「等待畫面」的情況，加上一支 PowerShell 腳本：先經 RustDesk TCP 通道送出 ADB 喚醒，再開啟 RustDesk 桌面。

目前已驗證單台 KB3 的 GCP 桌面控制、無人接受登入、通道喚醒，以及關閉桌面／通道、熄屏超過六分鐘後重新執行腳本。Kevin 也已確認實際操作成功。這不是純 RustDesk 自動喚醒，也沒有改版 APK。

## Kevin 現在怎麼用

在這台已設定好的筆電，開啟 PowerShell 執行：

```powershell
powershell.exe -NoProfile -File "C:\eAi360-kb3-remote-control\叫醒並連線KB3.ps1"
```

也可以在檔案總管對該 PS1 按右鍵，選「使用 PowerShell 執行」。腳本沒有要求系統管理員權限；若機構政策禁止執行，依該機構核准方式處理，不修改全機安全政策。

1. 腳本建立或沿用 RustDesk TCP 通道。
2. 在通道內核對 KB3 序號，送出 Android KEYCODE_WAKEUP。
3. 確認 Android 為 Awake，再開啟 RustDesk 桌面。
4. 自動斷開本次建立的 ADB 連線，保留桌面供操作。

執行結果視窗會保留，顯示綠色「完成」或紅色錯誤原因，按 Enter 才結束腳本。看到完成後，切到有 KB3 畫面的 RustDesk 視窗，不是 TCP 通道視窗。自動化呼叫可加 `-NoPause`；`-CheckOnly` 本身不暫停。

本機完整規格 MD 保留 Kevin 指定的測試密碼，腳本會讀取該檔；它不在 GitHub 裡。其他筆電沒有該 MD 時，腳本會詢問設備序號及隱藏輸入的 RustDesk 密碼。請勿把密碼寫進公開腳本或 README。

只檢查程式與設定、不連線也不寫入：

```powershell
.\叫醒並連線KB3.ps1 -CheckOnly
```

## 進入 KB3 的程式圖示

這些操作是在 RustDesk 的 KB3 畫面內執行，不是在旁邊黑色留白處。

| 想做什麼 | 筆電滑鼠操作 |
|---|---|
| 回到機器人的眼睛首頁 | 按一下滑鼠中鍵，也就是按下滾輪 |
| 從眼睛畫面進入程式清單 | 游標放在右眼附近，按住左鍵拖到左眼附近，再放開；方向是右眼 → 左眼 |
| 找到其他頁的程式 | 在清單繼續往左拖；反向拖可回上一頁 |
| 開啟程式 | 左鍵點一下圖示 |
| 回上一個畫面 | 滑鼠右鍵 |

本輪已看到「設定、檔案管理、我的下載」等內建圖示，以及另一頁的 eAi360姿態小工具、eAi360站蹲量測、eAi360助理、RustDesk、LINE；已實際點開內建設定。不要用 KB3 頭頂實體按鍵代替滑鼠中鍵，原廠頭頂按鍵在部分畫面會進入睡眠。

只有觸控板、沒有中鍵時，可先使用 App 內的「返回機器人」或返回按鈕。RustDesk Android 導覽列的顯示方式依客戶端版本而異，尚未把觸控板全流程列為本輪驗收。

原廠手勢依據：[NUWA 基礎操作](https://support.nuwarobotics.com/en/docs/kebbiairs/start/basic_operation/)。

## 實際連線路線

```text
桌面：筆電 RustDesk → GCP hbbr → KB3 RustDesk → 畫面／觸控

喚醒：筆電 ADB → 本機 127.0.0.1:18888
     → 已認證的 RustDesk TCP 通道 → GCP hbbr
     → KB3 localhost:8888 → KEYCODE_WAKEUP
```

本案第一輪強制使用 GCP 中繼。筆電不需要知道 KB3 所在 Wi-Fi 的 IP，不依賴 eAi360 網頁登入是否逾時。GCP、家庭路由器均不需要公開 ADB 的 8888 埠；本機通道只綁定 127.0.0.1。

初次啟用 KB3 的 ADB 與信任這台筆電仍需現場完成。這條已驗證路線包含筆電上的 ADB；手機單獨從 Asleep 叫醒 KB3 尚未驗證，不能將筆電結果當成手機結果。

## 每個 RustDesk 客戶端怎麼填

Windows：「設定 → 網路 → ID／中繼伺服器」。Android：「設定 → ID／中繼伺服器」。Windows 若要求解鎖網路設定，由操作者完成授權。

| 欄位 | 此實驗環境的值 |
|---|---|
| ID 伺服器 | `35.229.172.16:21116` |
| 中繼伺服器 | `35.229.172.16:21117` |
| API 伺服器 | 留白 |
| Key，伺服器公開金鑰 | `zJJGKCM9xJi33ARGO0sbqzW5QF6evgZ+uvF3fKA2e7o=` |
| 本輪 KB3 RustDesk ID | `1622305827` |

公開金鑰最後的 `=` 要保留。它不是遠控密碼；伺服器私鑰不在本專案。換成另一台新伺服器時，要使用新部署產生的公鑰。

同一客戶端可連其他伺服器上的設備：

- 本案 GCP 的 KB3：輸入 `1622305827`。
- 官方公用伺服器上的設備：輸入 `對方ID@public`。
- 其他預設伺服器的控制端要連本案 KB3：輸入 `1622305827@35.229.172.16:21116?key=zJJGKCM9xJi33ARGO0sbqzW5QF6evgZ+uvF3fKA2e7o=`。

每台被控端仍只向一套預設伺服器登記。`@public` 是發起跨伺服器連線，不是雙重登記；另一台仍使用公用服務的實際設備尚未另測。

## 初次設定另一台筆電或 KB3

已測組合：Windows RustDesk 1.4.6+64、KB3 AIR-H300／Android 15／RustDesk 1.5.0、Server OSS 1.1.16。其他機型須逐台驗證。

1. KB3 持續接電、開機、連 Wi-Fi，不設 PIN／圖形鎖屏。保持 RustDesk 背景執行。
2. KB3 開啟 RustDesk 的畫面分享及 Input Control 無障礙服務，設定固定密碼；允許已認證的 TCP 通道。
3. 現場啟用 KB3 ADB，確認其實際連接埠，並在 KB3 授權操作者筆電的 ADB 金鑰。本機實驗埠為 8888；不是每台 Android 的固定預設。
4. 兩端填入上述 GCP 欄位，先連進 KB3 一次，確認桌面與輸入可用，建立 RustDesk 的 peer 設定。
5. 在 Windows RustDesk 對這台 KB3 開啟「TCP 通道／Port Forward」，新增：本機連接埠 `18888`、遠端主機 `localhost`、遠端連接埠 `8888`。
6. 筆電備妥 Android platform-tools。腳本會依序檢查本機已驗證的 KB3 工具包 `C:\Nuwa-kebbi3\KB3_WiFi_ADB_Windows_37.0.1\platform-tools\adb.exe`、本專案下的 platform-tools、ANDROID_SDK_ROOT／ANDROID_HOME、使用者 Android SDK 目錄、PATH。每個候選都先執行 `adb version`，通過才採用，並在視窗顯示選到的路徑。仍可用 `-AdbPath` 明確指定；明確指定錯誤時不會悄悄改用其他檔案。
7. 先執行 `-CheckOnly`。正式執行時，如此 peer 的通道規則變成空白，腳本會補回一條指定規則；遇到其他規則則停止，不覆蓋。

其他設備用法，將示例中的序號改成該 KB3 的真實序號：

```powershell
.\叫醒並連線KB3.ps1 -DeviceId '該設備數字ID' -ExpectedSerial '該設備序號' -AdbPath 'C:\你的工具位置\adb.exe'
```

沒有本機私人 MD 時，程式會隱藏詢問密碼。新筆電未被 KB3 授權 ADB 時，仍需完成一次現場信任；不能靠 GCP 越過該授權。

### 本台 KB3 已做的畫面擷取修正

本輪發現 `PROJECT_MEDIA` 為 ignore，畫面擷取在熄屏後失效。於 Kevin 授權下，針對 RustDesk 套件設定 allow，重新啟動畫面分享；之後 Asleep 測試仍保有投影。另加入 RustDesk 的電池最佳化白名單。這些是本台實測設定，不宣稱所有 Android 15 都相同。

在已授權的 ADB 連線上執行一次；把 `已授權的ADB位址` 換成實際序號或位址：

```text
adb -s 已授權的ADB位址 shell cmd appops set com.carriez.flutter_hbb PROJECT_MEDIA allow
adb -s 已授權的ADB位址 shell dumpsys deviceidle whitelist +com.carriez.flutter_hbb
```

第一次設定後仍要在 KB3 啟動 RustDesk 畫面分享並確認桌面。腳本不會自動繞過新設備授權、修復所有投影失效或處理重開機。

依據：[RustDesk FAQ](https://github.com/rustdesk/rustdesk/wiki/FAQ)、[Android 官方使用說明](https://rustdesk.com/docs/en/client/android/)。

## GCP 已部署內容

沿用原 4 vCPU／約 16 GB RAM VM；沒有新購 VM，也沒有改動 eAi360 的程式、nginx、資料庫或既有容器。安裝位置為 `/opt/eai-kb3-remote`。本倉庫的 `compose.yaml` 與 `.env.example` 是已部署配置的可公開版本，不含 data 或私鑰。

| 項目 | 配置 |
|---|---|
| 版本 | RustDesk Server OSS 1.1.16，映像 digest 固定在 Compose |
| CPU 硬上限 | hbbs 0.25、hbbr 0.75，合計相當於原主機的 1 vCPU 配額 |
| RAM 硬上限 | 各 256 MiB，合計 512 MiB |
| 初期中繼流量參數 | TOTAL_BANDWIDTH=20、SINGLE_BANDWIDTH=4、LIMIT_SPEED=2 |
| 日誌 | 每容器 10 MB × 3 |
| 原生客戶端埠 | TCP 21115–21117、UDP 21116 |
| 未使用埠 | TCP 21114、21118–21119 專屬 deny 規則阻擋 |

空載 Docker 記憶體讀值合計約 2～3 MiB；這不是上限或 600 台實測。總 512 MiB 限制已生效。流量參數的單位按此版本原碼為 1024² bit/s，20 約為十進位 20.97 Mbps；它是 relay 應用層限制，不是整張網卡硬上限，限速效果尚未壓測。

規劃最多 600 台設備池、先以 5 路同時一般桌面操作為目標。5 路以每路平均約 2 Mbps 作估算；每路接近 4 Mbps 時，先降為 2～3 路。600 台待命與 5 路並發尚未壓測，這也不是自動拒絕第六路的限制。

### 維護已上線的服務

在 GCP 上執行；以下只針對本案 Compose：

```bash
sudo docker compose --project-directory /opt/eai-kb3-remote ps
sudo docker compose --project-directory /opt/eai-kb3-remote logs --tail 50
sudo docker stats --no-stream eai-kb3-remote-hbbs-1 eai-kb3-remote-hbbr-1
```

需要停止本案實驗時：

```bash
sudo docker compose --project-directory /opt/eai-kb3-remote stop
```

恢復時：

```bash
sudo docker compose --project-directory /opt/eai-kb3-remote up -d
```

保留原 data 與私鑰，不用 `down -v`，不釋放現有共用固定 IP，不重啟 Docker daemon 或整台 VM。不要為了更新說明文件再次部署。

### 全新主機部署時

先確認獨立目錄、固定 IP、Docker、上述埠及既有服務占用；再把本倉庫的 Compose 與 `.env.example` 放進核准目錄，將後者設為 `.env` 並改填該主機 IP。以 `docker compose up -d` 啟動。只讀取產生的 `data/id_ed25519.pub` 給客戶端；`data/id_ed25519` 私鑰留在伺服器。備份 data 要使用另經核准的私密位置，不上傳公開 GitHub。

來源：[官方 Server OSS](https://github.com/rustdesk/rustdesk-server)、[官方 Docker 部署](https://rustdesk.com/docs/en/self-host/rustdesk-server-oss/docker/)。

## 測試結果與待測範圍

日期：2026-10-30 夜間至 2026-10-31 凌晨，Asia/Taipei。

| 測試 | 結果 |
|---|---|
| GCP 服務、資源限制、外部原生 TCP 埠 | 通過 |
| GCP 中繼桌面、固定密碼無人接受 | 通過 |
| 中鍵首頁、拖曳選單、點開內建設定 | 通過，ADB 斷開後仍可操作 |
| 純 RustDesk 從 Asleep 自動恢復畫面 | 本機未通過；曾停在等待畫面 |
| 手動 GCP TCP 通道喚醒 | 通過，Asleep → Awake，畫面恢復 |
| 腳本自動補回規則、喚醒、開啟桌面 | 第一輪通過 |
| 關閉桌面與通道、熄屏五分鐘後執行腳本 | 通過；23:53:37 確認 Asleep，23:59:54 重新建立 GCP 通道，喚醒前仍為 Asleep，之後 Awake 並恢復桌面 |
| 喚醒後操作與本人驗收 | 已再次右往左拖入 eAi360 程式清單；Kevin 回覆「測試成功了，可以了」 |
| eAi360 存活檢查 | 部署後及本輪收尾三個健康端點 HTTP 200，四個既有容器與 eai-360.service 未重啟 |
| 手機行動網路操作／手機單獨喚醒 | 未測 |
| 兩小時、隔夜、KB3 重開機恢復 | 未測 |
| 600 台待命、5 路並發、尖峰負載影響 | 未測 |

本輪成功條件是：KB3 持續接電、已開機、Wi-Fi 可出站、RustDesk 與已授權 ADB 仍在執行、擷取有效、不需 PIN 解鎖。完全關機不在這條軟體喚醒路線內。

## 常見問題

- 右鍵執行後 PowerShell 視窗一閃就關：已於 2026-10-31 改為預設保留結果、按 Enter 才結束；請使用此目錄更新後的 PS1。原先視窗關閉本身不能判定連線成功或失敗。
- 顯示找不到原 Android SDK 的 adb.exe：新版會自動尋找並驗證現有 ADB，不只依賴單一路徑。先按 Enter 關閉舊結果視窗，再重新執行原 PS1；新版開頭會顯示「自動尋找 ADB」與實際路徑。如果所有候選都失敗，會保留檢查清單，不會自動安裝或更動權限。
- 有畫面卻不知道怎麼開 App：中鍵回眼睛首頁，再左鍵從右往左拖，不需要先打開 eAi360 後台。
- 腳本說序號不符：停止操作，核對 DeviceId、通道規則及 ExpectedSerial。腳本在這種情況不送喚醒。
- 通道視窗開了但 ADB 連不上：核對 KB3 ADB 埠、這台筆電的 ADB 信任及 RustDesk TCP 通道權限。腳本不會改走區網 IP。
- Awake 但仍等待畫面：檢查 KB3 的畫面分享與 MediaProjection；Awake 只代表電源狀態，不代表擷取必定有效。
- 設定檔通道變成空白：本輪有發生，腳本會在通道未開啟時補回空白規則；既有其他規則不覆寫。

RustDesk 客戶端與 Server OSS 是有著作權的 AGPL-3.0 開源專案，依其授權使用；自架 OSS 不需要 Pro 授權碼。GCP 的 VM、IP 與傳輸仍按實際帳單計費。本倉庫不散布 RustDesk 二進位或私鑰。
