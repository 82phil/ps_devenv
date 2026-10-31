# Virtualenv Activate
& {
    . ([io.path]::Combine($PSScriptRoot, "helpers", "build_env.ps1"))
    $venv_path = Get-ProjectVenv $global:_DEVENV_PROJECT_PATH
    if ($venv_path) {
        $virtualenv_script = [io.path]::Combine($venv_path, "Scripts", "Activate.ps1")
        if ([System.IO.File]::Exists($virtualenv_script)) {
            & $virtualenv_script
            $env:PYTHONPATH=$global:_DEVENV_PROJECT_PATH
            Write-Output "`$env:PYTHONPATH=$global:_DEVENV_PROJECT_PATH"
        }
    }
}
