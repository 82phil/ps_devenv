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
    Describe "Project Path Detection" {

        Context "_DEVENV_PROJECT_PATH not defined" {

            Mock Get-Location { @{"Path" = "Current Dir Location"} }

            $path = getProjectPath

            It "The current directory is used" {
                $path | Should Be "Current Dir Location"
            }

        }

        Context "_DEVENV_PROJECT_PATH defined but bad path" {

            $_DEVENV_PROJECT_PATH = "Bad Path"
            Mock Get-Location { @{"Path" = "Current Dir Location"} }
            Mock Test-Path { $false }

            $path = getProjectPath

            It "The current directory is used" {
                $path | Should Be "Current Dir Location"
            }
        }

        Context "_DEVENV_PROJECT_PATH defined and good path" {

            $_DEVENV_PROJECT_PATH = "Devenv Project Path Var"
            Mock Get-Location { @{"Path" = "Current Dir Location"} }
            Mock Test-Path { $true }

            $path = getProjectPath

            It "The _DEVENV_PROJECT_PATH value is used" {
                $path | Should Be "Devenv Project Path Var"
            }
        }

    }
}