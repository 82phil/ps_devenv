# Virtualenv Deactivate
& {
    $env:PYTHONPATH=$null
    if (Test-Path function:deactivate) {
        deactivate
    }
}
