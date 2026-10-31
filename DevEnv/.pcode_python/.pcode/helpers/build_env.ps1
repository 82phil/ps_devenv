[CmdletBinding()]
Param(
    # Specify the specific Python Version to use
    [Parameter(Mandatory=$False,Position=1)]
    [string]$desiredVersion
)


# Returns Python Cores that are present in the Windows Registry
function Get-PythonFromRegistry {
    $install_paths = @(
        "hklm:\software\python\pythoncore\",
        "hkcu:\software\python\pythoncore\",
        "hklm:\software\wow6432node\python\pythoncore\")
    $python_cores = @()
    foreach ($path in $install_paths) {
        if (test-path -path $path) {
            foreach ($core in Get-ChildItem -path $path) {
                $exe_regpath = Join-Path $core.PSPath -ChildPath "InstallPath"
                if (test-path -path $exe_regpath) {
                    $py_core = Get-ItemProperty -Path $exe_regpath
                    if ($py_core.PSObject.properties.name -contains "ExecutablePath") {
                        if (Test-Path -path $py_core.ExecutablePath) {
                            # Python 3 provides ExecutablePath value that points to Python exe
                            $python_cores += $py_core.ExecutablePath
                        }
                    } else {
                        if (Test-Path -path (Join-Path $py_core."(default)" -ChildPath "python.exe")) {
                            # Python 2 default value contains the Path that the Python exe resides
                            $py_exe_path = Join-Path $py_core."(default)" -ChildPath "python.exe"
                            $python_cores += $py_exe_path
                        }
                    }
                }
            }
        }
    }
    return $python_cores
}

# Returns Python Cores that are Windows AppX Packages
function Get-PythonFromAppx {
    $python_cores = @()
    foreach ($python_appx in (Get-AppxPackage | Where-Object -Property "Name" -Like "*Python*")) {
        # Local AppData for Windows Appx should contain valid links
        $py_folder = [IO.Path]::Combine(
            $env:LOCALAPPDATA, "Microsoft", "WindowsApps", $python_appx.PackageFamilyName)
        if (Test-Path -path (Join-Path $py_folder -ChildPath "python.exe")) {
            $py_exe_path = Join-Path $py_folder -ChildPath "python.exe"
            $python_cores += $py_exe_path
        }
    }
    return $python_cores
}

# TODO: Add one more to just go through the paths var and look for python.exe

# Runs python.exe with info.py script to extract information
function Get-PythonInfo($python_paths) {
    $py_info = @()
    foreach ($python in $python_paths) {
        try {
            $info = & $python (Join-Path (Split-Path -Parent $PSCommandPath) -ChildPath info.py) | ConvertFrom-Json
            $info | Add-Member NoteProperty "FullPath" $python
            $py_info += $info
        } catch {

        }
    }
    return $py_info
}

function Get-PythonInstalls() {
    Param(
        # Specify the specific Python Version to use
        [Parameter(Mandatory=$False,Position=1)]
        [string]$desiredVersion
    )

    $python_cores = @()
    $python_cores += Get-PythonFromRegistry
    $python_cores += Get-PythonFromAppx

    $py_installs = @(Get-PythonInfo($python_cores))

    if ($desiredVersion) {
        $py_installs = @($py_installs | Where-Object { $_.versionInfo[0..2] -Join "." -Match $desiredVersion})
    }

    if ($py_installs.Count -lt 1) {
        if ($desiredVersion) {
            throw "Could not find a Python Installation matching version {0}" -f $desiredVersion
        } else {
            throw "Could not find a Python Installation!"
        }
        exit 1
    }
    return $py_installs | Sort-Object {$_.versionInfo[0]}, {$_.versionInfo[1]}, {$_.versionInfo[2]}, {$_.is64Bit} -Descending
}

# Returns the first configured dirname used when creating a venv
function Get-VenvCreateDirName {
    $venv_dirnames = Get-VenvDirNamesSetting
    if ($venv_dirnames.Count -gt 0 -and
        -not [string]::IsNullOrWhiteSpace($venv_dirnames[0])) {
        return [string]$venv_dirnames[0]
    }
    return 'venv'
}

# Returns dirnames searched for existing venvs
function Get-VenvDirNamesSetting {
    if ($null -ne $global:_DEVENV_SETTINGS -and
        $global:_DEVENV_SETTINGS.ContainsKey('venv_dirnames')) {
        return @($global:_DEVENV_SETTINGS['venv_dirnames'])
    }
    return @('venv', '.venv')
}


# Returns the path of an existing venv in the project, or $null if none exists
function Get-ProjectVenv([string]$SearchPath = (Get-Location).Path) {
    foreach ($name in Get-VenvDirNamesSetting) {
        $venv_path = Join-Path $SearchPath -ChildPath $name
        if (Test-Path (Join-Path $venv_path -ChildPath "Scripts\python.exe")) {
            return $venv_path
        }
    }
    return $null
}

function Get-PythonUsersChoice() {
    Param(
        # Specify the specific Python Version to use
        [Parameter(Mandatory=$False,Position=1)]
        [string]$desiredVersion
    )

    # TODO: Make a way to detect existing venv and add it to the choices
    [array]$py_installs = Get-PythonInstalls $desiredVersion

    if ($py_installs.count -gt 1) {
        $python = (dispMenu($py_installs))
    } else {
        $python = $py_installs[0]
    }

    return $python
}

function dispMenu {
    param($py_installs)
    Write-Output "========== Choose Python Version to use ==========" | Out-Host
    $entry = @()
    foreach ($install in $py_installs) {
        $entry += $install
        $is64 = If ($install.is64Bit -eq "True") {"64-bit"} else {"32-bit"}
        Write-Output (
            "$($entry.count):  Python {0}.{1}.{2} {3} {4}" -f  $($install.versionInfo + $is64)) | Out-Host
    }
    while ($True) {
        $selection = Read-Host "Make a selection"
        if ($selection -match "\d+") {
            $selection = [int]$selection - 1
            if ($selection -lt $py_installs.Count -and $selection -ge 0) {
                return $entry[$selection]
            }
        }
    }
}

function main {
    if (Test-Path env:PWD) {
        Set-Location $env:PWD
    } else {
        if ((Split-Path (Get-Location) -Leaf) -eq ".pcode") {
            # Stepping out of .pcode dir
        Set-Location ..
        }
    }
    $existing_venv = Get-ProjectVenv
    if ($existing_venv) {
        Write-Warning "An existing virtual environment was found at $existing_venv"
        $answer = Read-Host "Remove it? (y/N)"
        if ($answer -notmatch '^[yY]') {
            return
        }
        Remove-Item -Recurse -Force $existing_venv
        Write-Output "Removed existing virtual environment at $existing_venv"
    }
    $venv_dir = Get-VenvCreateDirName
    $python = Get-PythonUsersChoice $desiredVersion
    # Start building the env
    Write-Output "Building Virtual Environment..."
    try {
        if ($python.versionInfo[0] -eq "2") {
            # Python 2.7 virtualenv
            & $python.FullPath -m virtualenv $venv_dir --no-download
        } else {
            # Python 3 comes with venv, but desire to use virtualenv if available
            & $python.FullPath -m virtualenv $venv_dir --no-download
            if (-not $?) {
                Write-Output "Using Built-in venv instead..."
                & $python.FullPath -m venv $venv_dir
            }
        }

        # Run the activation script
        & (Join-Path $venv_dir "Scripts\activate.ps1")
    } catch {
        throw
        Write-Output "Failed to Create the Virtual Environment!"
        exit 1
    }
    # Install requirements
    if (Test-Path "requirements.txt") {
        Write-Output "Installing PIP packages listed in requirements"
        & (Join-Path $venv_dir "Scripts\python.exe") -m pip install -r requirements.txt
    }
    Write-Output "Virtual Env up"
}

if ($MyInvocation.InvocationName -eq "&") {
    main
}
