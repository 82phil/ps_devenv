$profile_dir = Split-Path -path $profile
$python_code_maker = Join-Path -path $profile_dir .vscode\make_env.ps1
New-Alias code_python $python_code_maker
Clear-Host
Write-Output "Profile applied..."
