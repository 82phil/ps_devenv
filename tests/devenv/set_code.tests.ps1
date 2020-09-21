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
    Describe "Create Project Templates: Set-Code" {

        Context "No Default Template" {

            Mock Get-ChildItem { return @() }
            Mock getEnvVar {return "C:\Users\a_user\AppData\Roaming"} -ParameterFilter {$env_var -eq "APPDATA"}
            Mock New-Item { return [PSCustomObject]@{
                FullName = $Path
            }}
            Mock Copy-Item { }

            $user_path = Set-Code -code_type test

            It "should create a new user template directory" {
                $user_path.FullName | Should Be "C:\Users\a_user\AppData\Roaming\PSDevEnv\.pcode_test"
                Assert-MockCalled Copy-Item -Exactly 0
            }
        }

        Context "Default template exists" {

            Mock Get-Variable {return "C:\ps_devenv"} -ParameterFilter {$Name -eq "PSScriptRoot"}
            Mock getEnvVar {return "C:\Users\a_user\AppData\Roaming"} -ParameterFilter {$env_var -eq "APPDATA"}
            Mock Get-ChildItem {return [PSCustomObject]@{
                Name = ".pcode_test"
                FullName = "C:\ps_devenv\.pcode_test"
            }} -ParameterFilter { $Path -eq "C:\ps_devenv" }
            Mock New-Item { return [PSCustomObject]@{
                FullName = $Path
            }}
            Mock Copy-Item {}

            $user_path = Set-Code -code_type test

            It "should copy the default template to the user template directory" {
                $user_path.FullName | Should Be "C:\Users\a_user\AppData\Roaming\PSDevEnv\.pcode_test"
                Assert-MockCalled Copy-Item -Exactly 1
            }
        }
    }
}
