# Load Aliases
$profile_dir = Split-Path -path $profile
$python_init = [io.path]::Combine($profile_dir, ".pcode_python", ".pcode", ".init.ps1")
New-Alias code_python $python_init
Clear-Host

# .pcode autorun script if available
$project_dir = if (Test-Path env:PWD) {$env:PWD} else {Get-Location}
$pcode_autorun = [io.path]::Combine($project_dir, ".pcode", "autorun.ps1")
if ([System.IO.File]::Exists($pcode_autorun)) {
    . $pcode_autorun
}
