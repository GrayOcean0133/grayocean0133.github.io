<#
  AI-Link / incropai 站点 —— 服务器端部署脚本（在 Windows 服务器上运行）

  用法（在服务器 PowerShell）：
      powershell -ExecutionPolicy Bypass -File .\update-site.ps1
  指定某个 zip：
      powershell -ExecutionPolicy Bypass -File .\update-site.ps1 -Zip C:\path\to\xxx.zip

  防回滚设计：
    · 自动选用桌面上「最新的」ailink-site*.zip —— 解决上传产生 "ailink-site (1).zip" 副本、
      却仍解开旧 ailink-site.zip 导致回滚的问题。
    · 部署前把当前站点完整备份到 C:\www\_backups\，永不丢线上版本（保留最近 5 份）。
    · 校验 zip 根目录必须有 index.html。
    · 部署后对比新旧 index.html 大小，明显变小会高亮「疑似回滚」警告，并提示备份位置。
#>
[CmdletBinding()]
param(
    [string]$Zip,                       # 指定 zip；不填则自动找桌面最新的 ailink-site*.zip
    [string]$Web = 'C:\www\incropai'    # 站点根目录
)
$ErrorActionPreference = 'Stop'

function Fail($m) { Write-Host "X  $m" -ForegroundColor Red; exit 1 }
function Good($m) { Write-Host "OK $m" -ForegroundColor Green }
function Info($m) { Write-Host $m -ForegroundColor Cyan }

Add-Type -AssemblyName System.IO.Compression.FileSystem

# 1) 选 zip：优先 -Zip，否则取两个桌面下「修改时间最新」的 ailink-site*.zip
if ($Zip) {
    if (-not (Test-Path -LiteralPath $Zip)) { Fail "指定的 zip 不存在：$Zip" }
    $zipItem = Get-Item -LiteralPath $Zip
} else {
    $zipItem = @("$env:USERPROFILE\Desktop", "$env:PUBLIC\Desktop") |
        ForEach-Object { Get-ChildItem -LiteralPath $_ -Filter 'ailink-site*.zip' -ErrorAction SilentlyContinue } |
        Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if (-not $zipItem) { Fail "桌面没有找到 ailink-site*.zip，请先把打好的 zip 传到服务器桌面。" }
}
Info ("==> 选用 zip : {0}" -f $zipItem.FullName)
Info ("    大小     : {0:N2} MB" -f ($zipItem.Length / 1MB))
Info ("    修改时间 : {0}" -f $zipItem.LastWriteTime)

# 2) 校验 zip：根目录必须有 index.html
$z = [System.IO.Compression.ZipFile]::OpenRead($zipItem.FullName)
try {
    $idx = $z.Entries | Where-Object { $_.FullName -eq 'index.html' } | Select-Object -First 1
    if (-not $idx) { Fail "zip 根目录没有 index.html —— 这不是有效的站点包，已中止（未改动线上）。" }
    Info ("    包内 index.html : {0:N1} KB | 共 {1} 个文件" -f ($idx.Length / 1KB), $z.Entries.Count)
} finally { $z.Dispose() }

# 3) 记录当前线上 index.html 大小（用于回滚检测）
$liveIdx  = Join-Path $Web 'index.html'
$oldIdxKB = if (Test-Path $liveIdx) { [math]::Round((Get-Item $liveIdx).Length / 1KB, 1) } else { 0 }

# 4) 备份当前站点（永不丢线上版本，保留最近 5 份）
if (Test-Path $Web) {
    $backup = "C:\www\_backups\incropai_" + (Get-Date -Format 'yyyyMMdd_HHmmss')
    New-Item -ItemType Directory -Path $backup -Force | Out-Null
    Copy-Item -Path (Join-Path $Web '*') -Destination $backup -Recurse -Force -ErrorAction SilentlyContinue
    Good "已备份当前站点 -> $backup"
    Get-ChildItem 'C:\www\_backups' -Directory -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending | Select-Object -Skip 5 |
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
}

# 5) 清空旧站点 + 解压新包
New-Item -ItemType Directory -Path $Web -Force | Out-Null
Get-ChildItem $Web -Recurse -Force | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
Expand-Archive -LiteralPath $zipItem.FullName -DestinationPath $Web -Force

# 6) 部署后校验 + 回滚检测
if (-not (Test-Path $liveIdx)) { Fail "部署后站点根目录没有 index.html！zip 结构可能不对，请检查备份。" }
$newIdxKB = [math]::Round((Get-Item $liveIdx).Length / 1KB, 1)
Good ("部署完成。线上 index.html : {0:N1} KB（部署前 {1:N1} KB）" -f $newIdxKB, $oldIdxKB)

if ($oldIdxKB -gt 0 -and $newIdxKB -lt ($oldIdxKB - 5)) {
    Write-Host ("!! 疑似回滚：新 index.html({0:N1}KB) 明显比原来({1:N1}KB)小！" -f $newIdxKB, $oldIdxKB) -ForegroundColor Yellow
    Write-Host  "   可能解开了旧包。如需还原，备份在 C:\www\_backups\ 下。" -ForegroundColor Yellow
} else {
    Good "刷新 https://incropai.top （Ctrl+F5）即可。Caddy 即时生效，无需重启。"
}
