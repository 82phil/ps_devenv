# Introduction

Scripts to setup and manage a Python virtual environment

# Setup Python Environment

At the root directory of the Python module (where requirements.txt is located) run the following command in PowerShell.

```powershell
New-Code Python
``` 

This will copy the directories under the DevEnv module directory `.pcode_python/`
over to your current directory and run the build script.

If multiple versions of Python are found, the script will provide a selection
to choose from. A version may also be passed in as an argument.

```powershell
New-Code Python 2.7
```

# Existing Environment

Run the command `Enter-Code` in your workspace directory.

# Workspace Aliases

If a PowerShell session is started in the workspace root directory or has the $env:PWD path pointed to the workspace then aliases specific to the workspace are added.

```powershell
Python workspace alias build added
Python workspace alias clean added
(venv) PS C:\git\CruSSH>
```

## build

Runs the build script. This will setup the virtual environment and install
pip packages listed in requirements.txt

## clean

Removes all pip packages and installs the packages listed in requirements.txt

Another file may be specified as an argument to use as a requirements file.

```powershell
clean dev_requirements.txt
```

## idle

Launches idle from the virtual environment

## lint

Runs pylint across all Python (*.py) files in the current directory.
