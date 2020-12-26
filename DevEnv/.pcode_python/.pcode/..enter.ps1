# Virtualenv Activate
& {
    $project_dir = if ($null -ne $_DEVENV_PROJECT_PATH -and (Test-Path $_DEVENV_PROJECT_PATH)) {$_DEVENV_PROJECT_PATH} else {Get-Location}
    $virtualenv_script = [io.path]::Combine(
        $project_dir, "venv", "Scripts", "Activate.ps1")
    if ([System.IO.File]::Exists($virtualenv_script)) {
        & $virtualenv_script
        $env:PYTHONPATH=$project_dir
        Write-Output "`$env:PYTHONPATH=$project_dir"
    }
}
