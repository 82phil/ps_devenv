function code_alias{
    Param([string] $alias_name, [string] $script)
    $project_dir = if (Test-Path env:PWD) {$env:PWD} else {Get-Location}
    $script_path = [io.path]::Combine($project_dir, ".pcode", $script)
    if ([System.IO.File]::Exists($script_path)) {
        New-Alias $alias_name $script_path -Scope global
    }
    Write-Output "Python workspace alias $alias_name added"
}

code_alias -alias_name "build" -script "build_env.ps1"
code_alias -alias_name "clean" -script "clean_env.ps1"
