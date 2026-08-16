param(
    [string]$OutFile = "$env:TEMP\PraySelection.txt",
    [string]$LaunchPath,
    [string]$Filter
)

$ErrorActionPreference = 'Stop'

# Collect every folder under the two roots
$roots = 'D:\Progetti', 'D:\Personale', 'D:\CODE'
$all = @()
foreach ($root in $roots) {
    if (Test-Path -LiteralPath $root) {
        foreach ($d in (Get-ChildItem -LiteralPath $root -Directory | Sort-Object Name)) {
            $all += [PSCustomObject]@{
                Name  = $d.Name
                Label = '[{0}] {1}' -f (Split-Path $root -Leaf), $d.Name
                Path  = $d.FullName
            }
        }
    }
}

if ($all.Count -eq 0) {
    Write-Host 'No folders found' -ForegroundColor Red
    exit 1
}

# Decide which entries to offer
$items = @()
if ($Filter) {
    # Prefix match (case-insensitive) on the folder name
    $matched = @($all | Where-Object {
        $_.Name.StartsWith($Filter, [System.StringComparison]::OrdinalIgnoreCase)
    })
    if ($matched.Count -eq 1) {
        # Exactly one match: select it directly, skip the interactive picker
        Set-Content -LiteralPath $OutFile -Value $matched[0].Path -Encoding ASCII
        exit 0
    } elseif ($matched.Count -eq 0) {
        # No match: fall back to the full list
        $items = $all
    } else {
        $items = $matched
    }
} else {
    # No filter: offer the launch directory first, then every folder
    if ($LaunchPath -and (Test-Path -LiteralPath $LaunchPath)) {
        $items += [PSCustomObject]@{
            Name  = ''
            Label = '[here] {0}' -f $LaunchPath
            Path  = (Resolve-Path -LiteralPath $LaunchPath).Path
        }
    }
    $items += $all
}

[Console]::CursorVisible = $false
$prevTreatCtrlC = [Console]::TreatControlCAsInput
[Console]::TreatControlCAsInput = $true
$selected = 0

try {
    [Console]::Clear()
    Write-Host ''
    Write-Host '  Pick a folder ' -ForegroundColor Black -BackgroundColor White
    Write-Host '  Up/Down to move, Enter to confirm, Esc/Ctrl+C to cancel' -ForegroundColor DarkGray
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
        if (($key.Modifiers -band [ConsoleModifiers]::Control) -and $key.Key -eq 'C') {
            [Console]::CursorVisible = $true
            Write-Host ''
            exit 1
        }
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
    [Console]::TreatControlCAsInput = $prevTreatCtrlC
}
