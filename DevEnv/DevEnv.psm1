function create_workspace_aliases {
    Param([System.Array] $file_list)
    foreach ($alias_file in $file_list) {
        New-Alias $alias_file.BaseName $alias_file.FullName -Scope Global -Force
        $user_str = "Workspace alias " + ($alias_file).BaseName + " added"
        Write-Output $user_str
    }
}

function remove_workspace_aliases {
    Param([System.Array] $file_list)
    foreach ($alias_file in $file_list) {
        Remove-Alias -Name $alias_file.BaseName -Scope Global
        $user_str = "Workspace alias " + ($alias_file).BaseName + " removed"
        Write-Output $user_str
    }
}

function Get-Code {
    # Returns the current code template path
    param(
        [Parameter(Mandatory=$false)][string] $code_type,
        [Parameter(Mandatory=$false)][bool] $use_user_templates = $true
    )
    $module_path = Get-Variable PSScriptRoot -Scope Script -ValueOnly
    $code_type = $code_type.ToLower()
    $pcode_dirs = @()
    $pcode_dirs += (
        Get-ChildItem -Path $module_path -Directory | Where-Object Name -like ".pcode_*")
    if ($use_user_templates) {
        $pcode_dirs += (
            Get-ChildItem -Path (Join-Path $env:APPDATA PSDevEnv) -Directory | Where-Object Name -like ".pcode_*"
        )
    }
    $pcode_pref_dirs = @{}
    foreach ($pcode in $pcode_dirs) {
        $pcode_pref_dirs[$pcode.Name] = $pcode
    }
    $match = $pcode_pref_dirs.GetEnumerator() | Where-Object -Property key -Match ".pcode_$($code_type)"
    if ($match.count -lt 1) {
        throw "Could not find a match for '{0}'`nThese options are available:`n{1}" -f (
            $code_type, (($pcode_pref_dirs.Keys-replace ".pcode_") -Join "`n"))
    }
    # TODO BUGFIX: Check for an exact match before failing for multiple matches
    if ($match.count -gt 1) {
        throw "Found multiple matches, use one of these:`n{0}" -f (
            ($match.Name -replace ".pcode_") -Join "`n")
    }
    return $match.Value
}

function Set-Code {
    param([Parameter(Mandatory=$false)][string] $code_type)
    # Creates Code template for user, copies over defaults
    # TODO for the future:
    # -Force - Force copying over the defaults if the directory already exists
    # -Empty - Only create the directory if it does not exist, do not copy items
    # Also should think about items that do not have existing templates
    
    # Create the directory if it does not exist, otherwise error
    $pcode_user_path = New-Item -Path (
        [IO.Path]::Combine($env:APPDATA, "PSDevEnv", ".pcode_$($code_type)")) -ItemType Directory

    # See if there is a default template to copy over
    $match = find_code(match)

    # Copy the template over to the project
    Write-Output "Copying default project template over..."
    Copy-Item -Path $match.FullName\* -Destination $pcode_user_path.FullName -Recurse -Force

    return $pcode_user_path
}

function New-Code {
    param(
        [Parameter(Mandatory=$true)][string]$code_type,
        [Parameter(Mandatory=$false)][string]$option
    )
    $match = Get-Code($code_type)

    # Copy the template over to the project
    Write-Output "Copying project template over..."
    Copy-Item -Path (Join-Path $match.FullName "*") -Destination . -Recurse -Force

    # Start the initialization script for the environment
    $init_script = [io.path]::Combine($match.FullName, ".pcode", "..init.ps1")
    if (Test-Path $init_script) {
        . $init_script $option
    }
    # Enter the new environment
    Enter-Code
}

function Enter-Code {
    # Run enterance script
    $project_dir = if (Test-Path env:PWD) {$env:PWD} else {Get-Location}
    $on_enter_script = [io.path]::Combine($project_dir, ".pcode", "..enter.ps1")
    if (Test-Path $on_enter_script) {
        . $on_enter_script
    }

    # Create project aliases
    $alias_files = (Get-ChildItem -Path ([io.path]::Combine($project_dir, ".pcode")) -File
        ) | Where-Object { $_.Name -notlike ".*" -and $_.Name -like "*.ps1"}
    create_workspace_aliases($alias_files)
}

function Exit-Code {
    # Run exit script
    $project_dir = if (Test-Path env:PWD) {$env:PWD} else {Get-Location}
    $on_enter_script = [io.path]::Combine($project_dir, ".pcode", "..exit.ps1")
    if (Test-Path $on_enter_script) {
        . $on_exit_script
    }

    # Remove project aliases
    $alias_files = (Get-ChildItem -Path ([io.path]::Combine($project_dir, ".pcode")) -File
        ) | Where-Object { $_.Name -notlike ".*" -and $_.Name -like "*.ps1"}
    create_workspace_aliases($alias_files)
}
