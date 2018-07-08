$profile_dir = Split-Path -path $profile
$pcode_python = Join-Path -Path $profile_dir .pcode_python
$old_location = Get-Location

# Copy stuff over...
Write-Output "Copying Workspace..."
Copy-Item -Path $pcode_python\* -Destination . -Recurse -Force
# Build Environment
& .pcode\build_env.ps1
