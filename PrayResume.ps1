param([string]$OutFile = "$env:TEMP\PrayResume.txt")

$ErrorActionPreference = 'Stop'

# Find the most recently used Claude session across all projects
$root = Join-Path $env:USERPROFILE '.claude\projects'
if (-not (Test-Path -LiteralPath $root)) { exit 1 }

$last = Get-ChildItem -LiteralPath $root -Recurse -Filter *.jsonl -File |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1
if (-not $last) { exit 1 }

$id = $last.BaseName

# Read the working directory from the first transcript entry that carries it
$cwd = $null
foreach ($line in (Get-Content -LiteralPath $last.FullName -TotalCount 20)) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    try { $obj = $line | ConvertFrom-Json } catch { continue }
    if ($obj.cwd) { $cwd = $obj.cwd; break }
}
if (-not $cwd) { exit 1 }

# cwd|sessionId  (pipe never appears in a Windows path or a session UUID)
Set-Content -LiteralPath $OutFile -Value ('{0}|{1}' -f $cwd, $id) -Encoding ASCII
exit 0
