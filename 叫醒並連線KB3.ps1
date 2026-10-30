#requires -Version 5.1
<#
.SYNOPSIS
經已設定的 RustDesk GCP 通道叫醒 KB3，再開啟遠端桌面。
.DESCRIPTION
先依 README 設好 GCP、KB3 權限、ADB 授權及 TCP 通道規則。
本腳本不安裝服務、不改防火牆、不公開 ADB。
若指定設備的通道規則為空，會補回本案的一條規則；不覆蓋其他通道。
密碼從同目錄的本機私人 MD 讀取；沒有該檔時以隱藏輸入詢問。
#>
[CmdletBinding()]
param(
    [ValidatePattern('^[0-9]+$')][string]$DeviceId = '1622305827',
    [ValidateRange(1024,65535)][int]$LocalPort = 18888,
    [ValidateRange(1,65535)][int]$RemoteAdbPort = 8888,
    [string]$ExpectedSerial = '',
    [string]$RustDeskPath = 'C:\Program Files\RustDesk\RustDesk.exe',
    [string]$AdbPath = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe",
    [Security.SecureString]$Password,
    [switch]$CheckOnly
)
Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'
$targetAddress = "127.0.0.1:$LocalPort"
$privateMd = Join-Path $PSScriptRoot 'KB3遠端喚醒與桌面控制_GCP中繼規格_v1.0.md'
$configRoot = Join-Path $env:APPDATA 'RustDesk\config'
$secret = $null
$madeAdbConnection = $false

function ConvertTo-NativeArgument([string]$Value) {
    # Windows CommandLineToArgvW 的引號與反斜線規則。
    $escaped = [regex]::Replace($Value, '(\\*)"', '${1}${1}\"')
    $escaped = [regex]::Replace($escaped, '(\\+)$', '${1}${1}')
    return '"' + $escaped + '"'
}

function Invoke-Adb([string[]]$CommandArgs, [int]$TimeoutSeconds = 12) {
    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = $AdbPath
    $startInfo.Arguments = (($CommandArgs | ForEach-Object { ConvertTo-NativeArgument $_ }) -join ' ')
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $child = New-Object System.Diagnostics.Process
    $child.StartInfo = $startInfo
    try {
        [void]$child.Start()
        $stdout = $child.StandardOutput.ReadToEndAsync()
        $stderr = $child.StandardError.ReadToEndAsync()
        if (-not $child.WaitForExit($TimeoutSeconds * 1000)) {
            $child.Kill()
            throw 'ADB 指令逾時。請確認 KB3 在線、TCP 通道已認證、ADB 授權仍有效。'
        }
        $output = $stdout.GetAwaiter().GetResult()
        $errorText = $stderr.GetAwaiter().GetResult()
        if ($child.ExitCode -ne 0) { throw "ADB 失敗：$errorText" }
        return ($output + $errorText).Trim()
    } finally { $child.Dispose() }
}

function Test-TunnelListener {
    $listeners = @(Get-NetTCPConnection -State Listen -LocalPort $LocalPort -ErrorAction SilentlyContinue)
    if ($listeners.Count -eq 0) { return $false }
    foreach ($listener in $listeners) {
        if ($listener.LocalAddress -ne '127.0.0.1') {
            throw "本機 $LocalPort 並非只綁定 127.0.0.1，請先檢查通道設定。"
        }
        $owner = Get-Process -Id $listener.OwningProcess -ErrorAction Stop
        if ($owner.ProcessName -ine 'rustdesk') {
            throw "本機 $LocalPort 已被其他程式占用，未執行喚醒。"
        }
    }
    return $true
}

function Start-RustDeskSession([string]$Mode) {
    # RustDesk CLI 會把密碼放入本機 URI；先編碼，避免 & 等字元被解析成參數。
    $sessionArgs = @($Mode, $DeviceId, '--password', [Uri]::EscapeDataString($secret), '--relay')
    $argumentLine = ($sessionArgs | ForEach-Object { ConvertTo-NativeArgument $_ }) -join ' '
    # 這是操作者要使用的遠端桌面／通道視窗，因此保留可見。
    Start-Process -FilePath $RustDeskPath -ArgumentList $argumentLine | Out-Null
}

try {
    foreach ($requiredFile in @($RustDeskPath, $AdbPath)) {
        if (-not (Test-Path -LiteralPath $requiredFile -PathType Leaf)) {
            throw "找不到必要程式：$requiredFile。請依 README 完成安裝，或指定正確路徑。"
        }
    }
    $networkConfig = Get-Content -LiteralPath (Join-Path $configRoot 'RustDesk2.toml') -Raw
    foreach ($entry in @(
        @('custom-rendezvous-server', '35.229.172.16:21116'),
        @('relay-server', '35.229.172.16:21117'),
        @('key', 'zJJGKCM9xJi33ARGO0sbqzW5QF6evgZ+uvF3fKA2e7o=')
    )) {
        $settingPattern = '(?m)^' + [regex]::Escape($entry[0]) + '\s*=\s*[''"'']' + [regex]::Escape($entry[1]) + '[''"'']\s*$'
        if ($networkConfig -notmatch $settingPattern) {
            throw "RustDesk 的 $($entry[0]) 尚未符合本案 GCP 設定，請先依 README 填入。"
        }
    }
    $peerFile = Join-Path $configRoot "peers\$DeviceId.toml"
    if (-not (Test-Path -LiteralPath $peerFile)) { throw '請先在 RustDesk 為此設備新增 TCP 通道，參照 README。' }
    $peerConfig = Get-Content -LiteralPath $peerFile -Raw
    $forwardPattern = '(?s)port_forwards\s*=\s*\[(?:\s*\[.*?\],?\s*)*?\[\s*' + $LocalPort + '\s*,\s*[''"''](?:localhost|127\.0\.0\.1)[''"'']\s*,\s*' + $RemoteAdbPort + '\s*,?\s*\]'
    $needsTunnelRule = $peerConfig -notmatch $forwardPattern
    $emptyForwardPattern = '(?m)^port_forwards\s*=\s*\[\s*\]\s*$'
    if ($needsTunnelRule -and $peerConfig -notmatch $emptyForwardPattern) {
        throw "現有通道不是本案的 $LocalPort → localhost:$RemoteAdbPort，也不是空白規則；未覆蓋設定，請依 README 檢查。"
    }
    $privateText = ''
    if ($DeviceId -eq '1622305827' -and (Test-Path -LiteralPath $privateMd)) {
        $privateText = Get-Content -LiteralPath $privateMd -Raw -Encoding UTF8
        if (-not $ExpectedSerial -and $privateText -match '序號\s*`([A-Za-z0-9]+)`') { $ExpectedSerial = $Matches[1] }
    }
    if ($CheckOnly) {
        [void](Test-TunnelListener)
        Write-Host '檢查通過：程式路徑、GCP 設定符合。此模式未寫入設定、連線或喚醒 KB3。'
        if ($needsTunnelRule) { Write-Host '正式執行時會補回空白的 TCP 通道規則。' }
        return
    }
    if (-not $ExpectedSerial) { $ExpectedSerial = Read-Host '輸入這台 KB3 的序號（用於防止叫醒錯誤設備）' }
    if ($ExpectedSerial -notmatch '^[A-Za-z0-9-]+$') { throw '未取得有效 KB3 序號，未執行喚醒。' }
    if ($Password) {
        $secret = [Net.NetworkCredential]::new('', $Password).Password
    } elseif ($privateText -match '\| 兩端預定共用的 RustDesk 固定密碼 \| `([^`]+)` \|') {
        $secret = $Matches[1]
    } else {
        $Password = Read-Host '輸入 KB3 RustDesk 固定密碼' -AsSecureString
        $secret = [Net.NetworkCredential]::new('', $Password).Password
    }
    $privateText = $null
    if ([string]::IsNullOrWhiteSpace($secret)) { throw '密碼不可空白。' }
    if ($needsTunnelRule -and -not (Test-TunnelListener)) {
        if ((Get-Content -LiteralPath $peerFile -Raw) -cne $peerConfig) {
            throw 'RustDesk 設定正在變動，未寫入；請關閉此 KB3 的桌面／通道視窗後重試。'
        }
        $newRule = "port_forwards = [[$LocalPort, 'localhost', $RemoteAdbPort]]"
        $updatedPeer = [regex]::Replace($peerConfig, $emptyForwardPattern, $newRule)
        [IO.File]::WriteAllText($peerFile, $updatedPeer, (New-Object Text.UTF8Encoding $false))
        Write-Host '已補回此 KB3 的 TCP 通道規則。'
    }
    Write-Host '[1/4] 建立經 GCP 的 RustDesk TCP 通道……'
    if (-not (Test-TunnelListener)) {
        Start-RustDeskSession '--port-forward'
        $deadline = [DateTime]::UtcNow.AddSeconds(45)
        while (-not (Test-TunnelListener)) {
            if ([DateTime]::UtcNow -ge $deadline) { throw '45 秒內未建立通道。請查看 RustDesk 通道視窗的連線訊息。' }
            Start-Sleep -Milliseconds 700
        }
    }
    $beforeDevices = Invoke-Adb -CommandArgs @('devices')
    $wasConnected = $beforeDevices -match ('(?m)^' + [regex]::Escape($targetAddress) + '\s+device\s*$')
    if (-not $wasConnected) {
        $madeAdbConnection = $true
        $connectionResult = Invoke-Adb -CommandArgs @('connect', $targetAddress)
        if ($connectionResult -notmatch '(already )?connected to') {
            throw "通道已開但 ADB 未連上：$connectionResult"
        }
    }
    Write-Host '[2/4] 核對 KB3 裝置身分……'
    $actualSerial = Invoke-Adb -CommandArgs @('-s', $targetAddress, 'shell', 'getprop', 'ro.serialno')
    if ($actualSerial -cne $ExpectedSerial) { throw '裝置序號不符，已停止，沒有送出喚醒指令。' }
    Write-Host '[3/4] 叫醒 KB3，確認 Android 已清醒……'
    $beforePower = Invoke-Adb -CommandArgs @('-s', $targetAddress, 'shell', 'dumpsys', 'power')
    if ($beforePower -match 'mWakefulness=(\w+)') { Write-Host "喚醒前狀態：$($Matches[1])" }
    [void](Invoke-Adb -CommandArgs @('-s', $targetAddress, 'shell', 'input', 'keyevent', '224'))
    $isAwake = $false
    for ($attempt = 0; $attempt -lt 5; $attempt++) {
        $powerState = Invoke-Adb -CommandArgs @('-s', $targetAddress, 'shell', 'dumpsys', 'power')
        if ($powerState -match 'mWakefulness=Awake') { $isAwake = $true; break }
        Start-Sleep -Milliseconds 500
    }
    if (-not $isAwake) { throw '已送喚醒指令，但未驗證為 Awake；請勿當作喚醒成功。' }
    Write-Host '[4/4] KB3 已 Awake，開啟 RustDesk 桌面……'
    Start-RustDeskSession '--connect'
    Write-Host '完成。桌面出現後，中鍵回眼睛首頁；按住左鍵由右往左拖，進入 App 圖示清單。'
    Write-Host '此處確認 Android 已喚醒；畫面擷取及觸控仍以遠端桌面實際顯示為準。'
} finally {
    if ($madeAdbConnection) {
        try { [void](Invoke-Adb -CommandArgs @('disconnect', $targetAddress) -TimeoutSeconds 5) } catch { Write-Warning '本次 ADB 連線未能自動斷開，請執行 adb disconnect 127.0.0.1:18888。' }
    }
    $secret = $null
    $privateText = $null
}
