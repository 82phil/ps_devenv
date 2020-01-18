function code_alias{
    Param([string] $alias_name, [string] $script)
    $project_dir = if (Test-Path env:PWD) {$env:PWD} else {Get-Location}
    $script_path = [io.path]::Combine($project_dir, ".pcode", $script)
    if ([System.IO.File]::Exists($script_path)) {
        New-Alias $alias_name $script_path -Scope global -Force
    }
    Write-Output "Python workspace alias $alias_name added"
}

# Workspace Aliases

code_alias -alias_name "build" -script "build_env.ps1"
code_alias -alias_name "clean" -script "clean_env.ps1"
code_alias -alias_name "idle" -script "idle.ps1"
code_alias -alias_name "lint" -script "pylint.ps1"

# Virtualenv Activate
& {
    $project_dir = if (Test-Path env:PWD) {$env:PWD} else {Get-Location}
    $virtualenv_script = [io.path]::Combine(
        $project_dir, "venv", "Scripts", "Activate.ps1")
    if ([System.IO.File]::Exists($virtualenv_script)) {
        & $virtualenv_script
        $env:PYTHONPATH=$project_dir
        Write-Output "`$env:PYTHONPATH=$project_dir"
    }
}
