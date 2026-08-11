# hs (home server) - quick power control for NAS (glnas) and NUC (glnuc)
# Underlying scripts live in D:\Personale\HomeServer (one-time setup: GESTIONE-ENERGIA.md)
param(
    [Parameter(Position = 0)][string]$Action = "status",
    [Parameter(Position = 1)][string]$Target = "all",
    [switch]$f
)

$scriptDir = "D:\Personale\HomeServer"
$nasIp = "192.168.1.17"
$nucIp = "192.168.1.171"
$nasSsh = "root@$nasIp"
$nucSsh = "luca@$nucIp"

function Test-Online([string]$ip) {
    Test-Connection -ComputerName $ip -Count 1 -Quiet
}

function Show-Status {
    $nas = if (Test-Online $nasIp) { "UP" } else { "down" }
    $nuc = if (Test-Online $nucIp) { "UP" } else { "down" }
    Write-Host ""
    Write-Host ("  NAS (glnas, {0}): {1}" -f $nasIp, $nas)
    Write-Host ("  NUC (glnuc, {0}): {1}" -f $nucIp, $nuc)
    Write-Host ""
    Write-Host "  hs help for usage"
}

function Show-Help {
    Write-Host "STATUS:              hs"
    Write-Host "POWER ON ALL:        hs on          (NAS first, then NUC)"
    Write-Host "POWER ON ONE:        hs on nas      / hs on nuc"
    Write-Host "POWER OFF ALL:       hs off         (NUC first, then NAS)"
    Write-Host "POWER OFF ONE:       hs off nuc     / hs off nas"
    Write-Host "SSH INTO ONE:        hs conn nas    / hs conn nuc"
    Write-Host ""
    Write-Host "hs on nuc requires the NAS to be up; hs off nas requires the NUC to be down."
    Write-Host "Add -f to skip these checks."
}

function Invoke-Script([string]$scriptName, [bool]$withForce) {
    $path = Join-Path $scriptDir $scriptName
    if (-not (Test-Path $path)) {
        Write-Host "Script not found: $path"
        return 2
    }
    if ($withForce) { & $path -Force | Out-Host } else { & $path | Out-Host }
    $code = $LASTEXITCODE
    if ($null -eq $code) {
        Write-Host "Script $scriptName did not return an exit code (execution error?)"
        return 2
    }
    return $code
}

switch ($Action.ToLower()) {
    "status" { Show-Status; exit 0 }
    "help"   { Show-Help; exit 0 }
    "h"      { Show-Help; exit 0 }
    "conn" {
        switch ($Target.ToLower()) {
            "nas"   { $sshTarget = $nasSsh; $ip = $nasIp }
            "nuc"   { $sshTarget = $nucSsh; $ip = $nucIp }
            default { Write-Host "Pick one host: hs conn nas / hs conn nuc"; exit 2 }
        }
        if (-not (Test-Online $ip)) {
            Write-Host ("{0} ({1}) is down - start it with 'hs on {2}'" -f $Target.ToUpper(), $ip, $Target.ToLower())
            exit 1
        }
        ssh $sshTarget
        exit $LASTEXITCODE
    }
    "on" {
        switch ($Target.ToLower()) {
            "nas" { exit (Invoke-Script "sveglia-nas.ps1" $false) }
            "nuc" { exit (Invoke-Script "sveglia-nuc.ps1" $f.IsPresent) }
            "all" {
                if ($f.IsPresent) { Write-Host "Note: -f only applies to a single host (e.g. 'hs on nuc -f'); ordering checks stay active here." }
                if ((Invoke-Script "sveglia-nas.ps1" $false) -ne 0) {
                    Write-Host "NAS did not come up: stopping here (won't start the NUC without the NAS)."
                    exit 1
                }
                exit (Invoke-Script "sveglia-nuc.ps1" $false)
            }
            default { Write-Host "Unknown target '$Target' (use: nas, nuc, or nothing for all)"; exit 2 }
        }
    }
    "off" {
        switch ($Target.ToLower()) {
            "nuc" { exit (Invoke-Script "spegni-nuc.ps1" $false) }
            "nas" { exit (Invoke-Script "spegni-nas.ps1" $f.IsPresent) }
            "all" {
                if ($f.IsPresent) { Write-Host "Note: -f only applies to a single host (e.g. 'hs off nas -f'); ordering checks stay active here." }
                if ((Invoke-Script "spegni-nuc.ps1" $false) -ne 0) {
                    Write-Host "NUC did not shut down: stopping here (won't power off the NAS while the NUC is using it)."
                    exit 1
                }
                exit (Invoke-Script "spegni-nas.ps1" $false)
            }
            default { Write-Host "Unknown target '$Target' (use: nas, nuc, or nothing for all)"; exit 2 }
        }
    }
    default { Show-Help; exit 2 }
}
