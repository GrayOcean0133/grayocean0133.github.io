<#
.SYNOPSIS
    AI-Link / incropai 站点 —— 本地打包脚本（在你的开发机上跑）。

.DESCRIPTION
    收集"真正要上线的文件"，压成 ailink-site.zip：
      - git 已跟踪的文件
      - 未跟踪但属于站点内容的文件（除非 -NoUntracked）
    自动剔除开发用文件：.m 脚本、README、.gitignore、.vscode、本脚本、
    knowledge/Chapter#* 草稿目录、根目录散落的 png/jpg/zip 等。

    打包完成后，把 ailink-site.zip 传到服务器桌面，
    再在服务器上运行 update-site.ps1 即可完成部署。

.PARAMETER OutDir
    zip 输出目录。默认输出到仓库根目录。
    例：-OutDir "$env:USERPROFILE\Desktop" 直接打到桌面方便上传。

.PARAMETER NoUntracked
    只打包 git 已跟踪的文件（忽略尚未 git add 的新内容）。

.PARAMETER DryRun
    只列出将被打包的文件清单，不生成 zip。

.EXAMPLE
    .\pack.ps1                                  # 打到仓库根目录
    .\pack.ps1 -OutDir "$env:USERPROFILE\Desktop"   # 直接打到桌面
    .\pack.ps1 -DryRun                          # 先看清单
#>

[CmdletBinding()]
param(
    [string]$OutDir,
    [switch]$NoUntracked,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

$Root = $PSScriptRoot
if (-not $Root) { $Root = (Get-Location).Path }
$ZipName = 'ailink-site.zip'
if (-not $OutDir) { $OutDir = $Root }
$ZipPath = Join-Path $OutDir $ZipName

Write-Host "==> 仓库根目录: $Root" -ForegroundColor Cyan

# 不应上线的文件/目录（相对路径，正斜杠，正则匹配）
$ExcludePatterns = @(
    '\.m$',                      # MATLAB 生成脚本
    '\.ipynb$',                  # Jupyter 原始 notebook（内容已转成知识库章节）
    '^README\.md$',
    '^\.gitignore$',
    '^\.vscode/',
    '^\.github/',
    '^\.git/',
    '^pack\.ps1$',               # 本脚本
    '^update-site\.ps1$',        # 服务器脚本
    '^deploy\.ps1$',
    '^knowledge/Chapter#',       # 章节草稿目录（线上用 knowledge/chapters/）
    ([regex]::Escape($ZipName) + '$'),
    '^[^/]+\.(png|jpe?g|zip)$'   # 根目录散落的图片/压缩包（站点图片在 knowledge/ 或为已跟踪 svg）
)

function Test-Excluded([string]$path) {
    foreach ($pat in $ExcludePatterns) { if ($path -match $pat) { return $true } }
    return $false
}

Push-Location $Root
try {
    # core.quotepath=false：让 git 直接输出 UTF-8 路径，不把中文转成八进制并加引号
    # （否则 "knowledge/Chapter#4/中文.md" 带引号，排除规则会漏掉它）
    $tracked = @(git -c core.quotepath=false ls-files)
    if ($LASTEXITCODE -ne 0) { throw "git ls-files 失败，请确认在 git 仓库内、且已安装 git。" }

    $untracked = @()
    if (-not $NoUntracked) { $untracked = @(git -c core.quotepath=false ls-files --others --exclude-standard) }
}
finally { Pop-Location }

$all = @($tracked + $untracked) | Where-Object { $_ } | Sort-Object -Unique
$files = $all | Where-Object { -not (Test-Excluded $_) }

# 提示：哪些"站点内容"尚未 git add
$newSite = @($untracked) | Where-Object { $_ -and -not (Test-Excluded $_) }
if ($newSite.Count -gt 0) {
    Write-Host "==> 注意：以下文件已打包但尚未提交到 git：" -ForegroundColor Yellow
    $newSite | ForEach-Object { Write-Host "      + $_" -ForegroundColor Yellow }
}

Write-Host "==> 将打包 $($files.Count) 个文件" -ForegroundColor Cyan

if ($DryRun) {
    $files | ForEach-Object { Write-Host "    $_" }
    Write-Host "==> DryRun 结束（未生成 zip）。" -ForegroundColor Green
    return
}

# 打包到临时目录，再压缩（保持目录结构、index.html 位于 zip 根）
$Stage = Join-Path $env:TEMP ("ailink_pkg_" + [guid]::NewGuid().ToString('N').Substring(0,8))
New-Item -ItemType Directory -Path $Stage -Force | Out-Null
try {
    foreach ($f in $files) {
        $src = Join-Path $Root $f
        if (-not (Test-Path $src)) { Write-Warning "缺失，跳过: $f"; continue }
        $dest = Join-Path $Stage $f
        $destDir = Split-Path $dest -Parent
        if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
        Copy-Item $src $dest -Force
    }
    if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir -Force | Out-Null }
    Compress-Archive -Path (Join-Path $Stage '*') -DestinationPath $ZipPath -CompressionLevel Optimal -Force
}
finally { Remove-Item $Stage -Recurse -Force -ErrorAction SilentlyContinue }

$sizeMB = (Get-Item $ZipPath).Length / 1MB
Write-Host ("==> 打包完成: {0}  ({1:N1} MB)" -f $ZipPath, $sizeMB) -ForegroundColor Green
Write-Host "==> 下一步：把该 zip 传到服务器桌面，运行 update-site.ps1" -ForegroundColor Green
