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
    Describe "Find Project Templates: Get-Code" {

        Context "No Project Template Directories" {

            Mock Get-ChildItem { return @() }

            It "should throw an error about not finding templates" {
                { Get-Code -use_user_templates $true } | Should Throw "Could not find template directories"
            }

        }

        Context "Multiple Templates Match when no code type is provided" { 

            Mock Get-Variable {return "C:\ps_devenv"} -ParameterFilter {$Name -eq "PSScriptRoot"}
            Mock getEnvVar {return "C:\Users\a_user\AppData\Roaming"} -ParameterFilter {$env_var -eq "APPDATA"}
            Mock Get-ChildItem {return [PSCustomObject]@{
                Name = ".pcode_test"
            }} -ParameterFilter { $Path -eq "C:\ps_devenv" } 
            Mock Get-ChildItem {return [PSCustomObject]@{
                Name = ".pcode_user_test"
            }} -ParameterFilter { $Path -eq "C:\Users\a_user\AppData\Roaming\PSDevEnv" } 


            It "should raise for multiple matches" {
                { Get-Code -use_user_templates $true} | Should Throw "Found multiple matches"
            }
        }

        Context "Prefer User Template over Default" { 

            Mock Get-Variable {return "C:\ps_devenv"} -ParameterFilter {$Name -eq "PSScriptRoot"}
            Mock getEnvVar {return "C:\Users\a_user\AppData\Roaming"} -ParameterFilter {$env_var -eq "APPDATA"}
            Mock Get-ChildItem {return [PSCustomObject]@{
                Name = ".pcode_test"
                FullName = "default"
            }} -ParameterFilter { $Path -eq "C:\ps_devenv" } 
            Mock Get-ChildItem {return [PSCustomObject]@{
                Name = ".pcode_test"
                FullName = "user template"
            }} -ParameterFilter { $Path -eq "C:\Users\a_user\AppData\Roaming\PSDevEnv" } 

            $template_dir = Get-Code -code_type "test" -use_user_templates $true


            It "should provide the user template" {
                $template_dir.Name | Should Be ".pcode_test"
                $template_dir.FullName | Should Be "user template"
            }
        }

    }
}