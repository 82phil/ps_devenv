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
    Describe "Convert PSobjects from JSON conversions to hashtables" {

        Context "Simple JSON settings" {

            $json = '{"version": 1}'

            $result = convertToHashtable(ConvertFrom-Json($json))

            $expected = @{"version" = 1}

            It "should be a hashtable with settings" {
                Compare-Object $expected $result | Should Be $null
                Compare-Object $expected.Values $result.Values | Should Be $null
            }
        }

        Context "Null placeholders" {
            $json = '{"version": 1, "test": null}'

            $result = convertToHashtable(ConvertFrom-Json($json))

            $expected = @{"version" = 1}

            It "should be a hashtable with settings" {
                Compare-Object $expected $result | Should Be $null
                Compare-Object $expected.Values $result.Values | Should Be $null
            }
        }

        Context "Nested Settings" {

            $json = '{"version": 1, "nest": {"inner": 2}}'

            $result = convertToHashtable(ConvertFrom-Json($json))

            $expected = @{"version" = 1; "nest" = @{"inner" = 2}}

            It "should be a hashtable with settings" {
                Compare-Object $expected $result | Should Be $null
                Compare-Object $expected.Values $result.Values | Should Be $null
            }
        }
    }
}