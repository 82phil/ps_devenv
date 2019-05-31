[CmdletBinding()]
Param(
    # Specify a specific requirements file to use
    [Parameter(Mandatory=$False,Position=1)]
    [string]$requirementsFile
)

# Uninstalls all packages then installs only those listed under requirements
if (Test-Path env:PWD) {
    Set-Location $env:PWD
}

& python -m pip freeze | ForEach-Object {pip uninstall -y $_}
if ($requirementsFile) {
    if (Test-Path $requirementsFile) {
        & python -m pip install -r $requirementsFile
    } else {
        Write-Error "Failed to find requirements file"
    }
} else {
    & python -m pip install -r .\requirements.txt
}
Write-Output "Sucessfully cleaned environment"
Enter-Code
