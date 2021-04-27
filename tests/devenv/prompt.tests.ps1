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

    Describe "DevEnv prompt on no project" {

        $orig_prompt = $function:global:prompt

        $_DEVENV_PROJECT_PATH = $null

        preservePrompt
        updatePwshPrompt

        $result = prompt

        It "should return null" {
            $result | Should be $null
        }
        It "should restore the original prompt" {
            $function:global:prompt | Should be $orig_prompt
        }

        $function:global:prompt = $orig_prompt 
    }

    Describe "DevEnv prompt on project" {

        $orig_prompt = $function:global:prompt
        $orig_prompt_result = prompt

        $_DEVENV_PROJECT_PATH = Get-Location
        $tmp_prompt_wi_capture = "TestDrive:\prompt_output.txt"

        loadProjectSettings
        preservePrompt
        updatePwshPrompt

        # DevEnv outputs prompt to Write-Host as some of the virtualenv prompts also do this
        $result = prompt 6> $tmp_prompt_wi_capture

        It "should match the prompt from the devenv settings" {
            Get-Content $tmp_prompt_wi_capture | Should be $_DEVENV_SETTINGS.prompt.Object
        }
        It "should return the original prompt with the devenv prompt" {
            $result | Should be $orig_prompt_result
        }

        $function:global:prompt = $orig_prompt 

    }

    Describe "DevEnv prompt removes itself when leaving the project" {

        $orig_prompt = $function:global:prompt
        $orig_prompt_result = prompt

        $_DEVENV_PROJECT_PATH = Get-Location
        $tmp_prompt_inproj_wi_capture = "TestDrive:\prompt_in_output.txt"
        $tmp_prompt_outproj_wi_capture = "TestDrive:\prompt_out_output.txt"

        loadProjectSettings
        preservePrompt
        updatePwshPrompt

        # DevEnv outputs prompt to Write-Host as some of the virtualenv prompts also do this
        $in_project_result = prompt 6> $tmp_prompt_inproj_wi_capture

        # TODO: Come up with better way move out of the project
        $_DEVENV_PROJECT_PATH = [IO.Path]::Combine((Get-Location), "move_out")

        $out_project_result = prompt 6> $tmp_prompt_outproj_wi_capture

        It "should match the prompt from the devenv settings" {
            Get-Content $tmp_prompt_inproj_wi_capture | Should be $_DEVENV_SETTINGS.prompt.Object
        }
        It "should return the original prompt with the devenv prompt" {
            $in_project_result | Should be $orig_prompt_result
        }

        It "should match the prompt from the devenv settings" {
            Get-Content $tmp_prompt_outproj_wi_capture | Should be $null
        }
        It "should return the original prompt with the devenv prompt" {
            $out_project_result | Should be $orig_prompt_result
        }

        $function:global:prompt = $orig_prompt 

    }

    Describe "Devenv stacked prompt (2) functions the same as unstacked" {

        $orig_prompt = $function:global:prompt
        $orig_prompt_result = prompt

        $_DEVENV_PROJECT_PATH = Get-Location
        $tmp_prompt_wi_capture = "TestDrive:\prompt_output.txt"

        loadProjectSettings
        preservePrompt
        updatePwshPrompt
        function global:_DEVENV_TEST_PROMPT {

        }
        $function:_DEVENV_TEST_PROMPT = $function:global:prompt
        function global:prompt {
            return & $function:_DEVENV_TEST_PROMPT
        }
        updatePwshPrompt

        # DevEnv outputs prompt to Write-Host as some of the virtualenv prompts also do this
        $result = prompt 6> $tmp_prompt_wi_capture

        It "should match the prompt from the devenv settings" {
            Get-Content $tmp_prompt_wi_capture | Should be $_DEVENV_SETTINGS.prompt.Object
        }
        It "should return the original prompt with the devenv prompt" {
            $result | Should be $orig_prompt_result
        }

        $function:global:prompt = $orig_prompt 

    }
}