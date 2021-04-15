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

    Describe "DevEnv prompt hook" {

        Context "Preserve prompt" {

            $orig_prompt = $function:global:prompt
            function global:prompt { return "Test Prompt" }

            preservePrompt

            It "should copy prompt to _DEVENV_ORIG_PROMPT" {
                $function:global:_DEVENV_ORIG_PROMPT | Should be $function:global:prompt
            }

            $function:global:prompt = $orig_prompt 
        }

    }

    Describe "stuff" {

    }

}