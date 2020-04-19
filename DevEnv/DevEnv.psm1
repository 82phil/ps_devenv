function create_workspace_aliases{
    Param([System.Array] $file_list)
    foreach ($alias_file in $file_list) {
        New-Alias $alias_file.BaseName $alias_file.FullName -Scope Global -Force
        $user_str = "Workspace alias " + ($alias_file).BaseName + " added"
        Write-Output $user_str
    }
}

function New-Code {
    param(
        [Parameter(Mandatory=$true)][string]$code_type,
        [Parameter(Mandatory=$false)][string]$option
    )
    $module_path = Get-Variable PSScriptRoot -Scope Script -ValueOnly
    $code_type = $code_type.ToLower()
    $pcode_dirs = (Get-ChildItem -Path $module_path -Directory | Where-Object Name -like ".pcode_*").Name
    $match = $pcode_dirs | Where-Object { $_ -Match ".pcode_$($code_type)" }
    if ($match.count -lt 1) {
        throw "Could not find a match for {0}\nThese options are available:\n{1)" -f ($code_type, $pcode_dirs -replace ".pcode_")
    }
    if ($match.count -gt 1) {
        throw "Found multiple matches\nPerhaps one of these:\n{0}" -f $match -replace ".pcode_"
    }
    # Start the initialization script for the environment
    $init_script = [io.path]::Combine(
        $module_path, $match, ".pcode", "..init.ps1")
    if (Test-Path $init_script) {
        . $init_script $option
    }
    # Enter the new environment
    $on_enter_script = [io.path]::Combine(
        $module_path, $match, ".pcode", "..enter.ps1")
    if (Test-Path $on_enter_script) {
        . $on_enter_script
    }
}

function Enter-Code {
    # Run enterance script
    $project_dir = if (Test-Path env:PWD) {$env:PWD} else {Get-Location}
    $on_enter_script = [io.path]::Combine($project_dir, ".pcode", "..enter.ps1")
    if (Test-Path $on_enter_script) {
        . $on_enter_script
    }
    $alias_files = (Get-ChildItem -Path ([io.path]::Combine($project_dir, ".pcode")) -File
        ) | Where-Object { $_.Name -notlike ".*" -and $_.Name -like "*.ps1"}
    create_workspace_aliases($alias_files)
}
