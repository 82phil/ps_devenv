function New-Code {
param(
    [Parameter(Mandatory=$true)][string]$code_type,
    [Parameter(Mandatory=$false)][string]$option
)
    $code_type = $code_type.ToLower()
    $pcode_dirs = (Get-ChildItem -Path $PSScriptRoot -Directory
        ).Name -like ".pcode_*"
    $match = $pcode_dirs | Where-Object { $_ -Match ".pcode_$($code_type)" }
    if ($match.count -lt 1) {
        throw "Could not find a match for {0}\nThese options are available:\n{1)" -f ($code_type, $pcode_dirs -replace ".pcode_")
    }
    if ($match.count -gt 1) {
        throw "Found too many matches\nPerhaps one of these:\n{0}" -f $match -replace ".pcode_"
    }
    $init_script = [io.path]::Combine(
        $PSScriptRoot, $match, ".pcode", ".init.ps1")
    if (Test-Path $init_script) {
        . $init_script $option
    }
}

function Enter-Code {
    # .pcode autorun script if available
    $project_dir = if (Test-Path env:PWD) {$env:PWD} else {Get-Location}
    $pcode_autorun = [io.path]::Combine($project_dir, ".pcode", "autorun.ps1")
    if ([System.IO.File]::Exists($pcode_autorun)) {
        . $pcode_autorun
    }
}
