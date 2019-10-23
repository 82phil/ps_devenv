[![Build status](https://ci.appveyor.com/api/projects/status/h61aascy7dkp4u1l?svg=true)](https://ci.appveyor.com/project/82phil/ps-devenv)

# Introduction

This tool provides PowerShell functions that automate the setup of a development
environment. The examples provided are tuned to my workflow but hopefully
provide enough to allow you to implement your own. 

# Use Case

## Setup an environment

Instead of manually building (or rebuilding) a Python virtual environment
and running pip commands to install packages this is meant to do it all in one
command, like so:

1. Clone down a repository
2. Launch Powershell and type `New-Code Python`. Give it a minute or two ☕

![code_python demonstration](./doc/code_python.gif)

The script automates the workflow of creating the Python virtualenv and
installing packages via pip. A moment or two later everything should be ready.

[More Information](./DevEnv/.pcode_python/.pcode/README.md)

## Use an existing environment

Now that you have setup an environment, you can easily come back to it later on.

1. Navigate to the project directory
2. Type `Enter-Code`

# Installation 

## Module installation

This module is available from the PowerShell Gallery, perform the following:

```
Install-Module DevEnv -Scope CurrentUser
```

## Add `Enter-Code` to your PowerShell Profile

Automatically enter your development environment when starting a shell in your
project directory.

![Enter-Code Added to profile](./doc/enter_code_added_to_profile.gif)

Simply add `Enter-Code` to your PowerShell Profile.

### PowerShell Profile Setup

If you don't know if you already have a profile in Powershell, open powershell
and execute the following command

```powershell
test-path $profile
```

If the profile exists, the response is True; otherwise, it is False. If it does
exists, skip to the editing profile section.

#### Create a New Profile

To create a Windows PowerShell profile file, type:

```powershell
new-item -path $profile -itemtype file -force
```

#### Editing Profile

Add the following to the end of the Profile
```
Enter-Code
```

Now your session will be automatically setup when you launch a PowerShell
session in your project directory.

# Structure

Under each environment is a `.pcode` folder. Under this are two scripts, `.init.ps1` and
`autorun.ps1`. The init script is called when the environment is first built. The autorun
script is called if the environment already exists.

```
└───.pcode_python
    ├───.pcode
    │       .init.ps1
    │       autorun.ps1
    │       build_env.ps1
    │       clean_env.ps1
    │       README.md
    │
    └───.vscode
            settings.json
```

Initially all contents are copied over from the directory where the module is.
Take advantage of this to also bring over files like settings for your IDE, or a
`.gitignore` file.
