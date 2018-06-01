# Builds a virtual enviornment
Write-Output "Building Virtual Environment..."
$python = [io.path]::Combine((Get-Location).Drive.Root, "Python36", "Python.exe")
if ([System.IO.File]::Exists($python)) {
    # Start building the env
    if ((Split-Path (Get-Location) -Leaf) -eq ".vscode") {
    	# Stepping out of .vscode dir
	Set-Location ..
    }
    & $python -m venv venv
    & .\venv\Scripts\activate.ps1

    # Install requirements
    Write-Output "Installing PIP packages listed in requirements"
    & pip install -r .\requirements.txt
    Write-Output "Virtual Env up"
} else {
    Write-Output "Failed to create virtual environment"
}
