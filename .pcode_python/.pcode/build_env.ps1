[CmdletBinding()]
Param(
    # Specify the specific Python Version to use
    [Parameter(Mandatory=$False,Position=1)]
    [string]$pythonVersion
)

# Returns Python Cores that are present in the Windows Registry
function PythonRegistry {
    $install_paths = @(
        "hklm:\software\python\pythoncore\",
        "hkcu:\software\python\pythoncore\",
        "hklm:\software\wow6432node\python\pythoncore\")
    $python_cores = @{}
    foreach ($path in $install_paths) {
        if (test-path -path $path) {
            foreach ($core in Get-ChildItem -path $path) {
                $exe_regpath = Join-Path $core.PSPath -ChildPath "InstallPath"
                if (test-path -path $exe_regpath) {
                    $py_core = Get-ItemProperty -Path $exe_regpath
                    if ($py_core.PSObject.properties.name -contains "ExecutablePath") {
                        if (Test-Path -path $py_core.ExecutablePath) {
                            # Python 3 provides ExecutablePath value that points to Python exe
                            $python_cores += @{$core.PSChildName=$py_core.ExecutablePath}
                        } 
                    } else {
                        if (Test-Path -path (Join-Path $py_core."(default)" -ChildPath "python.exe")) {
                            # Python 2 default value contains the Path that the Python exe resides
                            $py_exe_path = Join-Path $py_core."(default)" -ChildPath "python.exe"
                            $python_cores += @{$core.PSChildName=$py_exe_path}
                        } 
                    }
                }
            }
        }    
    } 
    return $python_cores
}

# Returns Python Cores that are Windows AppX Packages
function PythonAppx{
    $python_cores = @{}
    foreach ($python_appx in (Get-AppxPackage | Where-Object -Property "Name" -Like "*Python*")) {
        if (Test-Path -path (Join-Path $python_appx.InstallLocation -ChildPath "python.exe")) {
            $py_exe_path = Join-Path $python_appx.InstallLocation -ChildPath "python.exe"
            $full_version = $python_appx.version.Split(".")
            $short_ver = "$($full_version[0]).$($full_version[1])"
            if ($python_appx.Architecture -Eq "X64") {
                $python_cores += @{$short_ver=$py_exe_path}
            }
            if ($python_appx.Architecture -Eq "X32") {
                $short_ver = "$($short_ver)-32"
                $python_cores += @{$short_ver=$py_exe_path}
            }
        }
    }
    return $python_cores
}


function dispMenu {
    param($python_cores)
    Write-Host "========== Choose Python Version to use =========="
    $entry = @()
    foreach ($core in $python_cores.Keys) {
        $entry += $core
        Write-Host "$($entry.count):  $core"
    }
    while ($True) {
        $selection = Read-Host "Make a selection"
        if ($selection -match "\d+") {
            $selection = [int]$selection - 1
            return $entry[$selection]
        } 

    }
}

$python_cores = PythonRegistry
$python_cores += PythonAppx
if ($python_cores.Count -lt 1) {
    throw "Could not find a Python Installation!"
    exit 1
}
if (($pythonVersion) -and ($python_cores.contains($pythonVersion))) {
    $python_cores = @{$pythonVersion=$python_cores[$pythonVersion]}
}
if ($python_cores.count -gt 1) {
    $py_ver = (dispMenu($python_cores))
    $python = $python_cores[$py_ver]
} else {
    $py_ver = $python_cores.Keys
    $python = $python_cores[$py_ver]
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
    if ($py_ver -like "2.*") {
        # Python 2.7 venv
        & $python -m virtualenv venv --no-site-packages
    } else {
        & $python -m venv venv
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
