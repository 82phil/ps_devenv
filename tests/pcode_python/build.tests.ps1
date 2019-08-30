if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

if (-not $ENV:BHModulePath) {
    $module_path = [IO.Path]::Combine($PSScriptRoot, "..", "..", "DevEnv")
} else {
    $module_path = $ENV:BHModulePath
}

$pcode_module =  [IO.Path]::Combine(".pcode_python", ".pcode", "build_env.ps1")
$module_under_test = Join-Path $module_path $pcode_module

Import-Module $module_under_test

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
