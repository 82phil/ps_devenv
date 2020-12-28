# Virtualenv Activate
& {
    $virtualenv_script = [io.path]::Combine(
        $global:_DEVENV_PROJECT_PATH, "venv", "Scripts", "Activate.ps1")
    if ([System.IO.File]::Exists($virtualenv_script)) {
        & $virtualenv_script
        $env:PYTHONPATH=$global:_DEVENV_PROJECT_PATH
        Write-Output "`$env:PYTHONPATH=$global:_DEVENV_PROJECT_PATH"
    }
}
