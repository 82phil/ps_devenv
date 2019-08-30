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
            return $entry[$selection]
        }
    }
}

function main {
    $python_cores = Get-PythonFromRegistry
    $python_cores += Get-PythonFromAppx
    $py_installs = @(PythonInfo($python_cores) | Sort-Object -Property versionInfo)

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
    if ($py_installs.count -gt 1) {
        $python = (dispMenu($py_installs))
    } else {
        $python = $py_installs[0]
    }
    # Start building the env
    Write-Output "Building Virtual Environment..."
    if (Test-Path env:PWD) {
        Set-Location $env:PWD
    } else {
        if ((Split-Path (Get-Location) -Leaf) -eq ".pcode") {
            # Stepping out of .pcode dir
        Set-Location ..
        }
    }
    try {
        if ($python.versionInfo[0] -eq "2") {
            # Python 2.7 virtualenv
            & $python.FullPath -m virtualenv venv --no-site-packages
        } else {
            # Python 3 comes with venv, but desire to use virtualenv if available
            & $python.FullPath -m virtualenv venv --no-site-packages
            if (-not $?) {
                Write-Output "Using Built-in venv instead..."
                & $python.FullPath -m venv venv
            }
        }

        # Run the activation script
        & .\venv\Scripts\activate.ps1
    } catch {
        throw
        Write-Output "Failed to Create the Virtual Environment!"
        exit 1
    }
    # Install requirements
    Write-Output "Installing PIP packages listed in requirements"
    & python -m pip install -r .\requirements.txt
    Write-Output "Virtual Env up"
}

if ($MyInvocation.InvocationName -eq "&") {
    main
}
