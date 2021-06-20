if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

if (-not $ENV:BHModulePath) {
    $module_path = [IO.Path]::Combine($PSScriptRoot, "..", "..", "DevEnv")
} else {
    $module_path = $ENV:BHModulePath
}

$pcode_module = "DevEnv.psm1"
$module_under_test = Join-Path $module_path $pcode_module

Get-Module DevEnv | Remove-Module -Force
Import-Module $module_under_test -Force

InModuleScope DevEnv {
    Describe "User Directory Traverse Detection" {

        Context "Startup in new directory" {

            # Blank out global variable
            Remove-Variable -Scope global -Name _DEVENV_DIR_HIST -ErrorAction:Ignore

            $result = userTraversingDownTree "C:\work"

            It "Should return true and create global varaible to track history" {
                $result | Should Be $true
                $_DEVENV_DIR_HIST | Should Be "C:\work"
            }

        }

        Context "Stay in the same directory" {

            # Blank out global variable
            Remove-Variable -Scope global -Name _DEVENV_DIR_HIST -ErrorAction:Ignore

            userTraversingDownTree "C:\work"
            $result = userTraversingDownTree "C:\work"

            It "Should return false and track history" {
                $result | Should Be $false
                $_DEVENV_DIR_HIST | Should Be "C:\work"
            }
        }

        Context "Coming up the directory tree" {

            # Blank out global variable
            Remove-Variable -Scope global -Name _DEVENV_DIR_HIST -ErrorAction:Ignore

            userTraversingDownTree "C:\work\project\subdir"
            $result = userTraversingDownTree "C:\work\project"

            It "Should return false and track history" {
                $result | Should Be $false
                $_DEVENV_DIR_HIST | Should Be "C:\work\project"
            }
        }

        Context "Going down the directory tree" {

            # Blank out global variable
            Remove-Variable -Scope global -Name _DEVENV_DIR_HIST -ErrorAction:Ignore

            userTraversingDownTree "C:\work"
            $result = userTraversingDownTree "C:\work\project"

            It "Should return true and track history" {
                $result | Should Be $true
                $_DEVENV_DIR_HIST | Should Be "C:\work\project"
            }
        }

        # Cleanup
        Remove-Variable -Scope global -Name _DEVENV_DIR_HIST -ErrorAction:Ignore
    }
}