param([string]$OutFile = "$env:TEMP\PraySelection.txt")

$ErrorActionPreference = 'Stop'

# Collect every folder under the two roots
$roots = 'D:\Progetti', 'D:\Personale'
$items = @()
foreach ($root in $roots) {
    if (Test-Path -LiteralPath $root) {
        foreach ($d in (Get-ChildItem -LiteralPath $root -Directory | Sort-Object Name)) {
            $items += [PSCustomObject]@{
                Label = '[{0}] {1}' -f (Split-Path $root -Leaf), $d.Name
                Path  = $d.FullName
            }
        }
    }
}

if ($items.Count -eq 0) {
    Write-Host 'No folders found in D:\Progetti or D:\Personale' -ForegroundColor Red
    exit 1
}

[Console]::CursorVisible = $false
$selected = 0

try {
    Write-Host ''
    Write-Host '  Pick a folder ' -ForegroundColor Black -BackgroundColor White
    Write-Host '  Up/Down to move, Enter to confirm, Esc to cancel' -ForegroundColor DarkGray
    Write-Host ''

    $listTop    = [Console]::CursorTop
    $maxVisible = [Math]::Max(3, [Console]::WindowHeight - $listTop - 2)
    $offset     = 0

    while ($true) {
        # Keep the highlighted item inside the visible window
        if ($selected -lt $offset) { $offset = $selected }
        if ($selected -ge $offset + $maxVisible) { $offset = $selected - $maxVisible + 1 }

        [Console]::SetCursorPosition(0, $listTop)
        $width = [Console]::WindowWidth - 1

        for ($row = 0; $row -lt $maxVisible; $row++) {
            $i = $offset + $row
            if ($i -lt $items.Count) {
                $text = $items[$i].Label
                if ($text.Length -gt $width - 4) { $text = $text.Substring(0, $width - 4) }
                $marker = if ($i -eq $selected) { '>' } else { ' ' }
                $line = ('{0} {1}' -f $marker, $text).PadRight($width)
                if ($i -eq $selected) {
                    Write-Host $line -ForegroundColor Black -BackgroundColor Cyan
                } else {
                    Write-Host $line
                }
            } else {
                Write-Host (' ' * $width)
            }
        }

        $key = [Console]::ReadKey($true)
        switch ($key.Key) {
            'UpArrow'   { if ($selected -gt 0) { $selected-- } else { $selected = $items.Count - 1 } }
            'DownArrow' { if ($selected -lt $items.Count - 1) { $selected++ } else { $selected = 0 } }
            'Home'      { $selected = 0 }
            'End'       { $selected = $items.Count - 1 }
            'Enter'     {
                Set-Content -LiteralPath $OutFile -Value $items[$selected].Path -Encoding ASCII
                [Console]::CursorVisible = $true
                Write-Host ''
                exit 0
            }
            'Escape'    {
                [Console]::CursorVisible = $true
                Write-Host ''
                exit 1
            }
        }
    }
}
finally {
    [Console]::CursorVisible = $true
}
