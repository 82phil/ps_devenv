$pcode_python = Join-Path -Path $PSScriptRoot ..

# Copy stuff over...
Write-Output "Copying Workspace..."
Copy-Item -Path $pcode_python\* -Destination . -Recurse -Force
# Build Environment
& .pcode\build_env.ps1 $args[0]
. .pcode\autorun.ps1
