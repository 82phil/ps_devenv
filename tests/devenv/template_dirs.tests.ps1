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
    Describe "Template Dirs" {

        Context "Just Module (Default) Templates" {
            Mock Get-Variable {return "C:\ps_devenv"} -ParameterFilter {$Name -eq "PSScriptRoot"}

            $dirs = templateDirs $false

            It "Should be just the module template directory" {
                $dirs.Count | Should be 1
                $dirs | Should Be "C:\ps_devenv"
            }

        }

        Context "User Template Dir does not exist" {
            Mock Get-Variable {return "C:\ps_devenv"} -ParameterFilter {$Name -eq "PSScriptRoot"}
            Mock getEnvVar {return "C:\Users\a_user\AppData\Roaming"} -ParameterFilter {$env_var -eq "APPDATA"}

            $dirs = templateDirs $true

            It "Should be both the module and users template directory" {
                $dirs.Count | Should be 1
                $dirs | Should Be "C:\ps_devenv"
            }

        }

        Context "Module and User Templates" {
            Mock Get-Variable {return "C:\ps_devenv"} -ParameterFilter {$Name -eq "PSScriptRoot"}
            Mock getEnvVar {return "C:\Users\a_user\AppData\Roaming"} -ParameterFilter {$env_var -eq "APPDATA"}
            Mock Test-Path {return $true}

            $dirs = templateDirs $true

            It "Should be both the module and users template directory" {
                $dirs.Count | Should be 2
                $dirs | Should Be @("C:\ps_devenv", "C:\Users\a_user\AppData\Roaming\PSDevEnv")
            }

        }
    }
}