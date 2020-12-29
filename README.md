[![Build status](https://ci.appveyor.com/api/projects/status/h61aascy7dkp4u1l?svg=true)](https://ci.appveyor.com/project/82phil/ps-devenv)

# Introduction

This tool provides PowerShell functions that automate the workflow of setting
up and using a development environment.

- Create templates to perform operations like setting environment variables, IDE
workspace settings, etc.
- Create aliases specific to the project, handling routine operations
- Easily switch between development environments

The examples provided are geared to my work but will provide enough for you
to implement your own.

# Use Case

## Set up an environment

Instead of building a Python virtual environment and running pip commands to
install packages, this tool handles it in one command:

1. Clone down a repository
2. Launch Powershell and type `New-Code Python`. Give it a minute or two ☕

![code_python demonstration](./doc/code_python.gif)

The script automates the workflow of creating a Python virtual environment,
installing the requirements file via pip, setting up environmental variables,
and providing additional tools set up as aliases.

[Python Dev Env Template README](./DevEnv/.pcode_python/.pcode/README.md)

## Use an existing environment

Now that you have set up an environment, you can easily come back to it later on.

1. Navigate to the project directory
2. Type `Enter-Code` and your environment is setup and ready to use
3. Type `Exit-Code` to tear down the environment, or simply leave the project
directory.

## Tracking Project Directories

Currently this is a work in progress. Exiting the project directory is
tracked, but not the entrance into the project. Use `Enter-Code` for now.

The `.settings.json` file in `.pcode` that allows you to change the prompt of
the project. UTF8 encoding is supported, use Windows Terminal for characters
such as emojis to work.

By default the prompt is updated before executing the entrant code so, for
example, the Python virtualenv will also update the prompt and will appear
like so:

![default prompt](./doc/default_prompt.png)

However there is a trick if you want to only see the devenv prompt, simply add
a carriage return to the beginning of the prompt.

```json
{
    "version": 1.0,
    "prompt": {
        "Object": "\r🐍 ",
        "BackgroundColor": null,
        "ForegroundColor": null
    }
}
```

![emoji and overwrite prompt](./doc/emoji_overwrite_prompt.png)


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

Simply add `Enter-Code` to your PowerShell Profile by either editing it with
a text editor (ex: `notepad.exe $profile`) or running the following in
PowerShell to append it to the end of the profile.

```powershell
if (-not (test-path $profile)) {
    new-item -path $profile -itemtype file -force
}
Add-Content $profile "`nEnter-Code"
```

# Create your templates

Use the `Set-Code` command to create your environment templates. If there
is an existing template under DevEnv under that name, it will be copied to
your template.

```
Set-Code python
explorer.exe (Get-Code python).FullName
```

# Environment File Structure

DevEnv calls scripts in the `.pcode` directory. Files prefixed with double
dots are executed when a function is called (ex: `Enter-Code`). Any `*.ps1`
files are set up as aliases, with the same name as the file, on project
entrance. Other file types and sub-directories are not used by DevEnv.

```
├───.pcode    - DevEnv executes scripts under this directory
│   │   ..enter.ps1   - Entrant Script (Enter-Code)
│   │   ..exit.ps1    - Exit Script (Exit-Code)
│   │   ..init.ps1    - Initialization Script (New-Code)
│   │   clean.ps1     - Aliases
│   │   idle.ps1      *
│   │   lint.ps1      *
│   │   README.md
│   └───helpers
│           build_env.ps1
│           info.py
│
└───.vscode
        settings.json

```

You can add additional files, which are copied over when creating a new
developer environment (`New-Code`), such as `.gitignore`. In the Python
template above, a `.vscode` directory provides additional for [Visual Studio
Code](https://code.visualstudio.com/) in the development environment.
