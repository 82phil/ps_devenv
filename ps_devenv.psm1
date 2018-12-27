function New-Code {
param(
    [Parameter(Mandatory=$true)][string]$code_type,
    [Parameter(Mandatory=$false)][string]$option
)
    $code_type = $code_type.ToLower()
    if ($code_type -Eq "Python") {
        $python_init = [io.path]::Combine($PSScriptRoot, ".pcode_python", ".pcode", ".init.ps1")
        . $python_init $option
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
