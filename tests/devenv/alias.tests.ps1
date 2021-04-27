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
    Describe "Project Alias Files" {

        Context "No files in project" {

            Mock Test-Path { return $true }
            Mock Get-ChildItem { return @() }

            $alias_list = aliasFileList 

            It "There should be no aliases returned" {
                $alias_list.Count | Should Be 0
            }

        }

        Context ".pcode directory does not exist" {

            Mock getProjectPath { return "/" }

            # TODO: This throws an exception on CI, but running locally with Pester shows the error
            # output but Pester does not indicate an exception
            try {
                $alias_list = aliasFileList
            } catch {}

            It "There should be no aliases returned" {
                $alias_list.Count | Should Be 0
            }
        }


        Context "dot files (.test.ps1) in project" {

            Mock Test-Path { return $true }
            Mock Get-ChildItem { return @(
                [PSCustomObject]@{
                    "Name" = "..init.ps1"
                },
                [PSCustomObject]@{
                    "Name" = ".test.ps1"
                })}

            $alias_list = aliasFileList 

            It "There should be no aliases returned" {
                $alias_list.Count | Should Be 0
            }
        }

        Context "Other files in project" {

            Mock Test-Path { return $true }
            Mock Get-ChildItem { return @(
                [PSCustomObject]@{
                    "Name" = ".gitignore"
                },
                [PSCustomObject]@{
                    "Name" = "README.md"
                })}

            $alias_list = aliasFileList 

            It "There should be no aliases returned" {
                $alias_list.Count | Should Be 0
            }
        }

        Context "alias files in project" {

            Mock Test-Path { return $true }
            Mock Get-ChildItem { return @(
                [PSCustomObject]@{
                    "Name" = "test.ps1"
                },
                [PSCustomObject]@{
                    "Name" = "another.ps1"
                })}

            $alias_list = aliasFileList 

            It "There should be aliases returned" {
                $alias_list.Count | Should Be 2
            }

            It "should contain the following aliases:" {
                $alias_list[0].Name | Should Be "test.ps1"
                $alias_list[1].Name | Should Be "another.ps1"
            }
        }
    }

    Describe "Project Alias Adding and Removal" {

        Context "Create alias for workspace" {

            Mock New-Alias -parameterFilter {$name -eq "test" -and $value -eq "test.ps1"}

            $alias_list = @(
                [PSCustomObject]@{
                    "FullName" = "test.ps1"
                    "BaseName" = "test"
                }
            )

            createWorkspaceAlias($alias_list)

            It "generates an alias" {
                Assert-MockCalled New-Alias 1 {$name -eq "test" -and $value -eq "test.ps1"}
            }
        }

        Context "Remove alias for workspace" {

            Mock Remove-Item -parameterFilter {$path -eq "alias:\test"}

            $alias_list = @(
                [PSCustomObject]@{
                    "FullName" = "test.ps1"
                    "BaseName" = "test"
                }
            )

            removeWorkspaceAlias($alias_list)

            It "removes an alias" {
                Assert-MockCalled Remove-Item 1 {$path -eq "alias:\test"}
            }
        }
    }
}