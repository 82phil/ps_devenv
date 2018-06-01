# Make VS Code Python Environment
$profile_dir = Split-Path -path $profile
$vscode_dir = Join-Path -path $profile_dir .vscode

# Copy stuff over...
Write-Output "Copying VS Code Workspace..."
Copy-Item -Path $vscode_dir -Destination . -Recurse -Force -Exclude "make_env.ps1"

# Build Environment
& .\.vscode\build_env.ps1
