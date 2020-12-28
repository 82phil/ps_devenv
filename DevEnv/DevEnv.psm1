function getProjectPath {
    if ($null -ne $_DEVENV_PROJECT_PATH -and (Test-Path $_DEVENV_PROJECT_PATH)) {
        return $_DEVENV_PROJECT_PATH
    } else {
        return (Get-Location).Path
    }
}

function getProjectSettings {

    function ConvertTo-Hashtable {
        param ($suspect_object)
    
        $conv_hash_table = @{}
        foreach ($property in $suspect_object.PSObject.Properties) {
            if ($property.Value -is [psobject]) {
                $conv_hash_table[$property.Name] = ConvertTo-Hashtable $Property.Value
            } else {
                # Null values are placeholders in settings, not used
                if ($null -ne $property.Value) {
                    $conv_hash_table[$property.Name] = $Property.Value
                }
            }
        }
        $conv_hash_table
    }

    # Defaults used to guarantee expected settings exist
    $defaults = Join-Path (Split-Path -Parent $PSCommandPath) -ChildPath defaults.json
    $default_settings = ConvertTo-Hashtable(
        (Get-Content $defaults -Encoding UTF8) | ConvertFrom-Json)
    
    # Attempt to merge the settings from the project if they exist
    $project = [io.path]::Combine((getProjectPath), ".pcode", ".settings.json")
    if (Test-Path -Path $project) {
        $project_settings = ConvertTo-Hashtable(
            (Get-Content $project -Encoding UTF8) | ConvertFrom-Json)
        return $default_settings + $project_settings
    } else {
        return $default_settings
    }
}

function updatePwshPrompt {
    New-Variable -Scope global -Name _DEVENV_SETTINGS -Force -Value (getProjectSettings)

    function global:_DEVENV_OLD_PROMPT {
        ""
    }
    $function:_DEVENV_OLD_PROMPT = $function:prompt

    function global:_DEVENV_PROMPT {
        $curr_loc = [string]($executionContext.SessionState.Path.CurrentLocation)
        $in_project = $curr_loc.StartsWith($_DEVENV_PROJECT_PATH)
        if (-not $in_project) {
            Exit-Code | Out-Null
            $function:prompt = $function:_DEVENV_OLD_PROMPT
            # Overwrite currently written prompt so user does not have to hit enter again
            Write-Host -nonewline "`r"
            return
        }
        if ($null -eq $_DEVENV_PROJECT_PATH) {
            $function:prompt = $function:_DEVENV_OLD_PROMPT
            return
        }
        $prompt_settings = $_DEVENV_SETTINGS.prompt
        Write-Host -nonewline @prompt_settings
    }

    function global:prompt {
        & $function:_DEVENV_PROMPT
        return & $function:_DEVENV_OLD_PROMPT
    }
}

function createWorkspaceAlias {
    Param([System.Array] $file_list)
    foreach ($alias_file in $file_list) {
        New-Alias $alias_file.BaseName $alias_file.FullName -Scope Global -Force
        $user_str = "Workspace alias " + ($alias_file).BaseName + " added"
        Write-Output $user_str
    }
}

function removeWorkspaceAlias {
    Param([System.Array] $file_list)
    foreach ($alias_file in $file_list) {
        Remove-Item "alias:\$($alias_file.BaseName)"
        $user_str = "Workspace alias " + ($alias_file).BaseName + " removed"
        Write-Output $user_str
    }
}

function aliasFileList {
    $project_dir = getProjectPath
    if (-not (Test-Path (Join-Path $project_dir ".pcode"))) {
        return $null
    }
    $files = (Get-ChildItem -Path ([io.path]::Combine($project_dir, ".pcode")) -File
        ) | Where-Object { $_.Name -notlike ".*" -and $_.Name -like "*.ps1"}
    return $files
}

function execProjectScript {
    Param([string] $script)
    $script_filepath = [io.path]::Combine((getProjectPath), ".pcode", $script)
    if (Test-Path $script_filepath) {
        . $script_filepath
    } else {
        throw "Did not find script file {0} in .pcode" -f ($script)
    }
}

function getEnvVar {
    Param([string] $env_var)
    return [Environment]::GetEnvironmentVariable($env_var)
}

function templateDirs {
    param(
        [Parameter(Mandatory=$false)][bool] $user_template_dirs = $true
    )
    $template_dirs = @()
    # Path where module is installed (varies based on how user installed it)
    $module_path = Get-Variable PSScriptRoot -Scope Script -ValueOnly
    $template_dirs += $module_path
    if ($user_template_dirs) {
        if (Test-Path (Join-Path (getEnvVar "APPDATA") "PSDevEnv")) {
            $template_dirs += (Join-Path (getEnvVar "APPDATA") "PSDevEnv")
        }
    }
    return $template_dirs
}

function Get-Code {
    # Returns the current code template path
    param(
        [Parameter(Mandatory=$false)][string] $code_type,
        [Parameter(Mandatory=$false)][bool] $use_user_templates = $true
    )
    $code_type = $code_type.ToLower()
    $pcode_dirs = @()
    foreach ($template in (templateDirs $use_user_templates)) {
        $pcode_dirs += (Get-ChildItem -Path $template -Directory | Where-Object Name -like ".pcode_*")
    }
    if ($pcode_dirs.count -lt 1) {
        throw "Could not find template directories (.pcode_*) in the expected locations:\n{0}" -f (
            (templateDirs $use_user_templates) -Join "`n"
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
    if ($match.count -gt 1) {
        $exact = $pcode_pref_dirs.GetEnumerator() | Where-Object -Property key -Eq ".pcode_$($code_type)"
        if ($exact.count -eq 1) {
            return $exact.Value
        }
        # Determine if there is an exact match
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
        [IO.Path]::Combine((getEnvVar APPDATA), "PSDevEnv", ".pcode_$($code_type)")) -ItemType Directory

    # See if there is a default template to copy over
    try {
        $match = Get-Code -code_type $code_type -use_user_templates $false
    } catch {
        $match = $null
    }
    if ($match) {
        # Copy the template over to the project
        Write-Information "Copying default project template over..."
        Copy-Item -Path "$($match.FullName)\*" -Destination "$($pcode_user_path.FullName)" -Recurse -Force
    }

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

    # Update the prompt
    updatePwshPrompt
    # Start the initialization script for the environment
    execProjectScript("..init.ps1")
    # Enter the new environment
    Enter-Code -update_prompt $false
}

function Enter-Code {
    param(
        [Parameter(Mandatory=$false)][bool] $update_prompt = $true,
        [Parameter(Mandatory=$false)][bool] $raise_on_failure = $false
    )
    try {
        # Add project path to Global Project Path variable
        New-Variable -Scope global -Name _DEVENV_PROJECT_PATH -Force -Value (getProjectPath)
        # Update the prompt
        if ($update_prompt) {
            updatePwshPrompt
        }
        # Run enterance script
        execProjectScript("..enter.ps1")
        # Create project aliases
        createWorkspaceAlias(aliasFileList)
    } catch {
        if ($raise_on_failure) {
            throw $_
        }
    }
}

function Exit-Code {
    # Run exit script
    execProjectScript("..exit.ps1")
    # Remove project aliases
    removeWorkspaceAlias(aliasFileList)
    # Reset Global Project Path variable
    New-Variable -Scope global -Name _DEVENV_PROJECT_PATH -Force -Value $null
}
