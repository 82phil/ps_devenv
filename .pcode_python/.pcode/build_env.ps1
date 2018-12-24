[CmdletBinding()]
Param(
    # Specify the specific Python Version to use
    [Parameter(Mandatory=$False,Position=1)]
    [string]$pythonVersion
)

# Builds a virtual enviornment
# Also would be cool if an argument could be added for py2,py3 for code_python command
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
                    $py_exe_path = "" 
                    if ($py_core.PSObject.properties.name -contains "ExecutablePath") {
                        if (Test-Path -path $py_core.ExecutablePath) {
                            # Python 3 provides ExecutablePath value that points to Python exe
                            $py_exe_path = $py_core.ExecutablePath
                        }
                    } else {
                        if (Test-Path -path (Join-Path $py_core."(default)" -ChildPath "python.exe")) {
                            # Python 2 is more complicated, if virtualenv has not been run
                            # then the default value contains the Path that the Python exe resides
                            $py_exe_path = Join-Path $py_core."(default)" -ChildPath "python.exe"
                        }
                    }
                    $python_cores += @{$core.PSChildName=$py_exe_path}
                }
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
if ($python_cores.Count -lt 1) {
    throw "Could not find a Python Installation!"
}
if ($python_cores.contains($pythonVersion)) {
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
if ($py_ver -like "2.*") {
    & $python -m virtualenv venv --no-site-packages
} else {
    & $python -m venv venv
}
# Python 2.7 venv
# $python_venv venv --no-site-packages
& .\venv\Scripts\activate.ps1

# Install requirements
Write-Output "Installing PIP packages listed in requirements"
& pip install -r .\requirements.txt
Write-Output "Virtual Env up"
# SIG # Begin signature block
# MIIGlwYJKoZIhvcNAQcCoIIGiDCCBoQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUhaKeuMXQU9aQisWPcWJ5XJig
# cV6gggPOMIIDyjCCArKgAwIBAgIQTP3uDUHglaREeCKNEB56ujANBgkqhkiG9w0B
# AQUFADB9MSwwKgYDVQQLDCNodHRwczovL2dpdGh1Yi5jb20vODJwaGlsL3BzX2Rl
# dmVudjEgMB4GCSqGSIb3DQEJARYRODIucGhpbEBnbWFpbC5jb20xFzAVBgNVBAoM
# DlBoaWxpcCBIb2ZmbWFuMRIwEAYDVQQDDAlwc19kZXZlbnYwHhcNMTgxMDI5MDQy
# OTM5WhcNMjExMDI5MDQzOTM5WjB9MSwwKgYDVQQLDCNodHRwczovL2dpdGh1Yi5j
# b20vODJwaGlsL3BzX2RldmVudjEgMB4GCSqGSIb3DQEJARYRODIucGhpbEBnbWFp
# bC5jb20xFzAVBgNVBAoMDlBoaWxpcCBIb2ZmbWFuMRIwEAYDVQQDDAlwc19kZXZl
# bnYwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDBe3XlB9fSC7zg8tPI
# vwsZumH2GgGVvz68Z1KSMLTXsny9bSgBo/K3B2r3j4V76u7SxLxkX4qMn1C5siQ5
# 5CLytUxOx+DKaQuynDonlmR9XV+EkEnwSYoxQK3wCHqlTvX2fuYyzCl8YppT5Ao6
# BfI8aRCHqGIjla2fu/pUR+MLroz10ikG0HPYxDyT29MOwh5UgIhtVG1lLVdtwhzk
# OqaiKCZBz9qsAZ4cCHJcS0BJ0NxsEsmvvWsgiBY9DljEn2RDByshqJz+TZJ6pakX
# iVTkJI2HtkkApL/DQSAfcF2JHgipspGP3129eTdyBBy9rnHG3qDxNWCJozoM7ky8
# DwzxAgMBAAGjRjBEMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggrBgEFBQcD
# AzAdBgNVHQ4EFgQUHtGBHiQ2iwZKRlOw+jyEmKsLiwEwDQYJKoZIhvcNAQEFBQAD
# ggEBAKj+aoAfiysWmdnbuEIeF7aEG7L7/enfB8kzxIfgTKVWlXOneD+lY/jRbwfa
# o/q30pWY7x+t6k13kacqNbgOIS09ni8i6ZTdgkzjErwfxRKU/iReGAUvDeg2ixFx
# p1GIn/Kh3x8JagPoWAqwIwW2hdEHZgupP42UBC8zFG+FYIhAx/s/4YBLHJFnkgHC
# gc9quDMlKsmLZXMaL01z/5PdwskHPjk+p8Q6GMrWQcO2xbHdlxMvCIZ/UaA5CCVE
# lQ6fIOG94HQQtKJTK1YfQksbYM/J7Ix3cFlYx13JLXAz6kH2/R6phh0YRuEwpSaF
# rqeFP4EjhKEOw/cJjhT4zO8jXpUxggIzMIICLwIBATCBkTB9MSwwKgYDVQQLDCNo
# dHRwczovL2dpdGh1Yi5jb20vODJwaGlsL3BzX2RldmVudjEgMB4GCSqGSIb3DQEJ
# ARYRODIucGhpbEBnbWFpbC5jb20xFzAVBgNVBAoMDlBoaWxpcCBIb2ZmbWFuMRIw
# EAYDVQQDDAlwc19kZXZlbnYCEEz97g1B4JWkRHgijRAeerowCQYFKw4DAhoFAKB4
# MBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQB
# gjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkE
# MRYEFKlu6jZjbwv4RFkHqyCYJYG8AimrMA0GCSqGSIb3DQEBAQUABIIBAEVX8QDS
# FUgD4QvEgicA8AipSYrA/kdMk5eJXC0MPSsiV462dADty+rYei9JZW3CbLitwVox
# SZxC/Wbu0jumbkokaX2kCjUFMUHNoko0kven7I7HrGrLTKOKDyhgSOLgFTyS+68y
# JdoOlw4BNTN7z1KobtNvqa0AYci1fkxH5BNFtyay5T2lOVOOBubkL2Z6vdCCnYMS
# q9zNWJcK4nhKGlWiP+S/okva3iCTOjI72+tHZJ4DNn3Yp2+2ehQH0VPgUvjLp9Xr
# JozjQVkdI2F2+caNkOYKGiYWIvBvHEjBnjU9+3C8V58fOVTW0W9HxN4U1l5Jipco
# AZZ2GCas//RqCTg=
# SIG # End signature block
