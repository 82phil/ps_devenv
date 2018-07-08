# Introduction

Scripts to setup and manage a Python environment

# Setup Python Environment

At the root directory of the Python module (where requirements.txt is located) run the following command in PowerShell.

```powershell
code_python
``` 

This will copy the directories under `%userprofile%\Documents\WindowsPowerShell`
over to your current directory and run the build script.

# Workspace Aliases

If a PowerShell session is started in the workspace root directory or has the $env:PWD path pointed to the workspace then aliases specific to the workspace are added.

```powershell
Python workspace alias build added
Python workspace alias clean added
(venv) PS C:\git\CruSSH>
```

## Build

Runs the build script. This will setup the virtual environment and install
pip packages listed in requirements.txt

## Clean

Removes all pip packages and installs the packages listed in requirements.txt
