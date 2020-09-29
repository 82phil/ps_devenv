function Resolve-Module
{
    [Cmdletbinding()]
    param
    (
        [Parameter(Mandatory)]
        [string[]]$Name
    )

    Process
    {
        foreach ($ModuleName in $Name)
        {
            # If the version was stated use it as the required version, otherwise use the latest available
            $split_name = $ModuleName -split " ",2
            if ($split_name.count -eq 2) {
                $ModuleName = $split_name[0]
                $ReqVersion = $split_name[1]
            } else {
                $ReqVersion = Find-Module -Name $ModuleName -Repository PSGallery | Measure-Object -Property Version -Maximum | Select-Object -ExpandProperty Maximum
            }

            $Module = Get-Module -Name $ModuleName -ListAvailable
            Write-Verbose -Message "Resolving Module $($ModuleName)"


            if ($Module) 
            {                
                $Version = $Module | Measure-Object -Property Version -Maximum | Select-Object -ExpandProperty Maximum

                if ($Version -ne $ReqVersion)
                {
                    if ((Get-PSRepository -Name PSGallery).InstallationPolicy -ne 'Trusted') { Set-PSRepository -Name PSGallery -InstallationPolicy Trusted }

                    Write-Verbose -Message "$($ModuleName) Installed Version [$($Version.tostring())] does not match required. Installing Required Version [$($ReqVersion.tostring())]"

                    Install-Module -Name $ModuleName -Force -RequiredVersion $ReqVersion
                    Import-Module -Name $ModuleName -Force -RequiredVersion $ReqVersion
                }
                else
                {
                    Write-Verbose -Message "Module Installed, Importing $($ModuleName)"
                    Import-Module -Name $ModuleName -Force -RequiredVersion $Version
                }
            }
            else
            {
                Write-Verbose -Message "$($ModuleName) Missing, installing Module"
                Install-Module -Name $ModuleName -Force -RequiredVersion $ReqVersion
                Import-Module -Name $ModuleName -Force -RequiredVersion $ReqVersion
            }
        }
    }
}

# Grab Nuget bits, install modules, set build variables, start build
Get-PackageProvider -Name NuGet -ForceBootstrap | Out-Null

Resolve-Module Psake, PSDeploy, "Pester 4.8.1", BuildHelpers

Set-BuildEnvironment

Invoke-psake .\psake.ps1
exit ( [int](-not $psake.build_success) )
