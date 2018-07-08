# Uninstalls all packages then installs only those listed under requirements
if (Test-Path env:PWD) {
    Set-Location $env:PWD
}
& pip freeze | ForEach-Object {pip uninstall -y $_}
& pip install -r .\requirements.txt
Write-Output "Sucessfully cleaned environment!"