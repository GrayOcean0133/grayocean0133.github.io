<#
  把第六章在线运行所需的 Pyodide 运行时 + 科学计算包下载到本目录，实现自托管。
  只下载用到的包及其依赖（解析 pyodide-lock.json），不是整包 200MB+。
  用法：在本目录直接运行  ./fetch-pyodide.ps1
  下完后这些文件会随站点部署到 incropai.top，访客即从你自己的服务器加载，不依赖外网 CDN。
#>
$ErrorActionPreference = 'Stop'
$ver = 'v0.26.4'
$base = "https://cdn.jsdelivr.net/pyodide/$ver/full/"
$dst = $PSScriptRoot
$want = @('numpy', 'pandas', 'matplotlib', 'scikit-learn', 'scipy', 'pillow')

# 核心运行时文件
$core = @('pyodide.js', 'pyodide.mjs', 'pyodide.asm.js', 'pyodide.asm.wasm', 'python_stdlib.zip', 'pyodide-lock.json')

function Get-File($name) {
    $out = Join-Path $dst $name
    if ((Test-Path $out) -and (Get-Item $out).Length -gt 0) { Write-Host "  skip  $name"; return }
    for ($i = 1; $i -le 3; $i++) {
        try { Invoke-WebRequest -Uri ($base + $name) -OutFile $out -UseBasicParsing; Write-Host ("  ok    {0}  ({1:N1} MB)" -f $name, ((Get-Item $out).Length / 1MB)); return }
        catch { if ($i -eq 3) { throw } Start-Sleep 1 }
    }
}

Write-Host "== 下载核心运行时 =="
foreach ($f in $core) { Get-File $f }

Write-Host "== 解析依赖闭包 =="
$lock = Get-Content (Join-Path $dst 'pyodide-lock.json') -Raw | ConvertFrom-Json
$pkgs = $lock.packages
$resolved = [System.Collections.Generic.HashSet[string]]::new()
$queue = [System.Collections.Generic.Queue[string]]::new()
foreach ($w in $want) { [void]$queue.Enqueue($w) }
while ($queue.Count -gt 0) {
    $name = $queue.Dequeue()
    $key = $pkgs.PSObject.Properties.Name | Where-Object { $_ -ieq $name } | Select-Object -First 1
    if (-not $key) { Write-Warning "包未在 lock 中找到: $name"; continue }
    if (-not $resolved.Add($key)) { continue }
    foreach ($dep in $pkgs.$key.depends) { [void]$queue.Enqueue($dep) }
}
Write-Host ("需要 {0} 个包" -f $resolved.Count)

Write-Host "== 下载包 wheel =="
foreach ($key in $resolved) { Get-File $pkgs.$key.file_name }

$total = (Get-ChildItem $dst -File | Measure-Object Length -Sum).Sum / 1MB
Write-Host ("`n完成。共 {0} 个文件，合计 {1:N1} MB。" -f (Get-ChildItem $dst -File).Count, $total)
Write-Host "现在 runner.js 会自动优先使用本地 knowledge/vendor/pyodide/。"
