# Uninstalls all packages then installs only those listed under requirements
Set-Location ..
& pip freeze | ForEach-Object {pip uninstall -y $_}
& pip install -r .\requirements.txt
Write-Output "Sucessfully cleaned environment!"