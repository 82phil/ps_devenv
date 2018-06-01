# Introduction

This is a Powershell Profile used to setup VS Code and a Python Virtual Environment for Python Projects.

# Powershell Profile Setup

Open powershell and execute the following command

```powershell
test-path $profile
```

If the profile exists, the response is True; otherwise, it is False.

## New Profile

To create a Windows PowerShell profile file, type:

```powershell
new-item -path $profile -itemtype file -force
```

Then copy the .ps1 profile script and the .vscode directory over to
the profile directory.

## Existing Profile

Copy the .vscode directory over the profile directory. Edit the existing profile and add the contents of the profile script.