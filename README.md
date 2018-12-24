# Introduction

Provides PowerShell aliases to automated the setup of a development environment.
The examples provided are tuned to my workflow but hopefully
provide enough to allow you to implement your own. 

# Use Case

Instead of manually building (or rebuilding) a Python virtual environment
and running pip commands to install packages this is meant to do it all in one
command, like so:

1. Clone down repository
2. Launch Powershell and type `code_python`, grab a cup of coffee

![code_python demonstration](./doc/code_python.gif)

The script automates the workflow of creating the Python virtualenv and
installing packages via pip. A moment or two later everything should be ready.

[More Information](./.pcode_python/.pcode/README.md)

# Installation 

If you don't know if you already have a profile in Powershell, open powershell
and execute the following command

```powershell
test-path $profile
```

If the profile exists, the response is True; otherwise, it is False. If it does
exists, skip to the existing profile section.

## New Profile

To create a Windows PowerShell profile file, type:

```powershell
new-item -path $profile -itemtype file -force
```

Then update the .ps1 profile script with the profile script in this repository, also
copy the directories in this repository over to where the profile script is.

## Existing Profile

Copy the directories from this repository over the profile directory. Edit the
existing profile and add the contents of the profile script.

# Structure

Under each environment is a `.pcode` folder. Under this are two scripts, `.init.ps1` and
`autorun.ps1`. The init script is called when the environment is first built. The autorun
script is called if the PowerShell session is started under a directory where the environment
was previously built.

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

Initially all contents are copied over from the PowerShell folder. Take advantage of this to
also bring over common settings for your IDE, or a `.gitignore` file.

