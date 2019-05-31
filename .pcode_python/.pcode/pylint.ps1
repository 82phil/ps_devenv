$proc = (Get-CimInstance Win32_ComputerSystem).NumberOfLogicalProcessors
if ($env::PYTHONPATH){
    if (Test-Path -path (Join-Path $env::PYTHONPATH -ChildPath ".pylintrc")) {
        &pylint -j"$proc" -f colorized --rcfile $env:PYTHONPATH/.pylintrc @(Get-ChildItem *.py)
    }
} else {
    &pylint -j"$proc" -f colorized @(Get-ChildItem *.py)
}
