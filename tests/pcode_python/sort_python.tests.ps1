if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

if (-not $ENV:BHModulePath) {
    $module_path = [IO.Path]::Combine($PSScriptRoot, "..", "..", "DevEnv")
} else {
    $module_path = $ENV:BHModulePath
}

$pcode_module =  [IO.Path]::Combine(".pcode_python", ".pcode", "helpers", "build_env.ps1")
$module_under_test = Join-Path $module_path $pcode_module

Import-Module $module_under_test -Force

Describe "Get-PythonInstalls Sorting Tests" {

    Context "When multiple Python installations are found" {

        # Mock the helper functions to return predictable test data
        Mock Get-PythonFromRegistry { 
            return @(
                "C:\Python27\python.exe",
                "C:\Python39\python.exe", 
                "C:\Python38\python.exe",
                "C:\Python310\python.exe"
            )
        }
        
        Mock Get-PythonFromAppx { 
            return @("C:\WindowsApps\Python39\python.exe") 
        }
        
        Mock PythonInfo {
            return @(
                [PSCustomObject]@{ versionInfo = @(2, 7, 18); is64Bit = "True"; FullPath = "C:\Python27\python.exe" },
                [PSCustomObject]@{ versionInfo = @(3, 9, 7); is64Bit = "False"; FullPath = "C:\Python39\python.exe" }
                [PSCustomObject]@{ versionInfo = @(3, 8, 10); is64Bit = "True"; FullPath = "C:\Python38\python.exe" },
                [PSCustomObject]@{ versionInfo = @(3, 10, 1); is64Bit = "True"; FullPath = "C:\Python38\python.exe" },
                [PSCustomObject]@{ versionInfo = @(3, 9, 7); is64Bit = "True"; FullPath = "C:\WindowsApps\Python39\python.exe" }
            )
        }

        It "Should return installations in descending version order" {
            $result = Get-PythonInstalls

            $result[0].versionInfo | Should be (@(3, 10, 1))
            $result[1].versionInfo | Should be (@(3, 9, 7))
            $result[2].versionInfo | Should be (@(3, 9, 7))
            $result[3].versionInfo | Should be (@(3, 8, 10))
            $result[4].versionInfo | Should be (@(2, 7, 18))
        }

        It "Should prioritize 64-bit over 32-bit for same version" {
            $result = Get-PythonInstalls

            # Find all Python 3.9.7 installations
            $python39Installs = $result | Where-Object { 
                $_.versionInfo[0] -eq 3 -and $_.versionInfo[1] -eq 9 -and $_.versionInfo[2] -eq 7 
            }

            $python39Installs.Count | Should be 2

            # 64-bit should come before 32-bit
            $python39Installs[0].is64Bit | Should be "True"
            $python39Installs[1].is64Bit | Should be "False"
        }

        It "Should filter by desired version when specified" {
            $result = Get-PythonInstalls -desiredVersion "3.9"
            
            $result.Count | Should be 2
            $result | ForEach-Object {
                $_.versionInfo[0] | Should be 3
                $_.versionInfo[1] | Should be 9
            }
        }

        It "Should throw error when no installations match desired version" {
            { Get-PythonInstalls -desiredVersion "3.11" } | Should -Throw "Could not find a Python Installation matching version 3.11"
        }

        It "Should throw error when no installations found at all" {
            Mock Get-PythonFromRegistry { return @() }
            Mock Get-PythonFromAppx { return @() }
            Mock PythonInfo { return @() }

            { Get-PythonInstalls } | Should -Throw "Could not find a Python Installation!"
        }
    }
}
