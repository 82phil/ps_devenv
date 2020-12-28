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
    Describe "Project Settings" {

        Context "Get Default Settings" {

            $result = getProjectSettings

            It "should be contain a version" {
                $result.Keys | Should contain "version"
            }
        }

        Context "Get Project Template Settings if they Exist" {

            Mock Test-Path { return $true }
            Mock Get-Content { return '{"version": "project_template"}'}

            $result = getProjectSettings

            $expected = @{"version" = "project_template"}

            It "should be the project template settings" {
                Compare-Object $expected $result | Should Be $null
                Compare-Object $expected.Values $result.Values | Should Be $null
            }
        }
    }
} 