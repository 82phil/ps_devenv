if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

if (-not $ENV:BHModulePath) {
    $module_path = [IO.Path]::Combine($PSScriptRoot, "..", "..", "DevEnv")
} else {
    $module_path = $ENV:BHModulePath
}

$pcode_module =  [IO.Path]::Combine(".pcode_python", ".pcode", "helpers", "build_env.ps1")
$module_under_test = Join-Path $module_path $pcode_module

Import-Module $module_under_test -Force

Describe "Python Installations using the Registry" {

    Context "No Python in Registry" {

        Mock Test-Path { return $false }

        $registry = Get-PythonFromRegistry

        It "Python Registry query returns 0 items" {
            $registry.Count | Should Be 0
        }

    }

    Context "Python 2.7 32-bit in Registry (Win 64)" {

        Mock Test-Path { return $true } -ParameterFilter {
            $Path -eq "hklm:\software\wow6432node\python\pythoncore\"}
        Mock Test-Path { return $true } -ParameterFilter {
            $Path -eq "Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\software\wow6432node\python\pythoncore\2.7\InstallPath"}
        Mock Test-Path { return $true } -ParameterFilter {
            $Path -eq "C:\Python27\python.exe"}
        Mock Test-Path { return $false }

        Mock Get-ChildItem { return [PSCustomObject]@{
            PSPath = "Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\software\wow6432node\python\pythoncore\2.7"
        }} -ParameterFilter {$Path -eq "hklm:\software\wow6432node\python\pythoncore\"}
        Mock Get-ChildItem { return @() }

        Mock Get-ItemProperty { return [PSCustomObject]@{
            "(default)" = "C:\Python27\"
        }} -ParameterFilter {
            $Path -eq "Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\software\wow6432node\python\pythoncore\2.7\InstallPath"}
        Mock Get-ItemProperty { return @{} }

        $registry = Get-PythonFromRegistry

        It "Python Registry query returns 1 items" {
            $registry.Count | Should Be 1
        }

        It "Python Registry query item is Python 2.7 exe path" {
            $registry | Should Be "C:\Python27\python.exe"
        }
    }

    Context "Python 3.7 32-bit in Registry (Win 64)" {

        Mock Test-Path { return $true } -ParameterFilter {
            $Path -eq "hklm:\software\wow6432node\python\pythoncore\"}
        Mock Test-Path { return $true } -ParameterFilter {
            $Path -eq "Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\software\wow6432node\python\pythoncore\3.7-32\InstallPath"}
        Mock Test-Path { return $true } -ParameterFilter {
            $Path -eq "C:\Program Files (x86)\Python37-32\python.exe"}
        Mock Test-Path { return $false }

        Mock Get-ChildItem { return [PSCustomObject]@{
            PSPath = "Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\software\wow6432node\python\pythoncore\3.7-32"
        }} -ParameterFilter {$Path -eq "hklm:\software\wow6432node\python\pythoncore\"}
        Mock Get-ChildItem { return @() }

        Mock Get-ItemProperty { return [PSCustomObject]@{
            "ExecutablePath" = "C:\Program Files (x86)\Python37-32\python.exe"
        }} -ParameterFilter {
            $Path -eq "Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\software\wow6432node\python\pythoncore\3.7-32\InstallPath"}
        Mock Get-ItemProperty { return @{} }

        $registry = Get-PythonFromRegistry

        It "Python Registry query returns 1 items" {
            $registry.Count | Should Be 1
        }

        It "Python Registry query item is Python 3.7 exe path" {
            $registry | Should Be "C:\Program Files (x86)\Python37-32\python.exe"
        }
    }
}

Describe "Python Installations from Windows Store" {

    Context "No Windows Store Python installs" {

        Mock Get-AppxPackage { return $null }

        $appx = Get-PythonFromAppx

        It "Windows Store Python query returns 0 items" {
            $appx.Count | Should Be 0
        }
    }

    context "Windows Store Python 3.7 Installed" {

        Mock Get-AppxPackage { return [PSCustomObject]@{
            "Name" = "PythonSoftwareFoundation.Python.3.7"
            "PackageFamilyName" = "PythonSoftwareFoundation.Python.3.7_qbz5n2kfra8p0"
        }} 

        Mock Test-Path { return $true }

        $appx = Get-PythonFromAppx

        It "Windows Store Python query returns 1 item" {
            $appx.Count | Should Be 1
        }

        It "Python Windows Store query item is Python 3.7 exe path" {
            $appx | Should Be ([IO.Path]::Combine(
                $env:LOCALAPPDATA,
                "Microsoft",
                "WindowsApps",
                "PythonSoftwareFoundation.Python.3.7_qbz5n2kfra8p0",
                "python.exe"))
        }
    }

    context "Get-PythonInstalls with one Python installation" {

        # Have just one install from the Windows Store
        Mock Get-AppxPackage { return [PSCustomObject]@{
            "Name" = "PythonSoftwareFoundation.Python.3.7"
            "PackageFamilyName" = "PythonSoftwareFoundation.Python.3.7_qbz5n2kfra8p0"
        }}

        Mock Test-Path { return $true }

        # Disables Get-PythonFromRegistry so it won't detect local installs
        Mock Get-PythonFromRegistry { return $null }

        Mock Get-PythonInfo { return [PSCustomObject]@{
            FullPath = "TestPythonWindowsStore"
        }}

        [array]$installs = Get-PythonInstalls

        It "Get-PythonInstalls query returns 1 item" {
            $installs.Count | Should Be 1
            $installs[0].FullPath | Should Be "TestPythonWindowsStore"
        }

    }
}