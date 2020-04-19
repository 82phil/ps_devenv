# Virtualenv Activate
& {
    $project_dir = if (Test-Path env:PWD) {$env:PWD} else {Get-Location}
    $virtualenv_script = [io.path]::Combine(
        $project_dir, "venv", "Scripts", "Activate.ps1")
    if ([System.IO.File]::Exists($virtualenv_script)) {
        & $virtualenv_script
        $env:PYTHONPATH=$project_dir
        Write-Output "`$env:PYTHONPATH=$project_dir"
    }
}
