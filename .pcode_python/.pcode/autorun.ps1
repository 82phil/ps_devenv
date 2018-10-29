function code_alias{
    Param([string] $alias_name, [string] $script)
    $project_dir = if (Test-Path env:PWD) {$env:PWD} else {Get-Location}
    $script_path = [io.path]::Combine($project_dir, ".pcode", $script)
    if ([System.IO.File]::Exists($script_path)) {
        New-Alias $alias_name $script_path -Scope global
    }
    Write-Output "Python workspace alias $alias_name added"
}

# Workspace Aliases

code_alias -alias_name "build" -script "build_env.ps1"
code_alias -alias_name "clean" -script "clean_env.ps1"

# Virtualenv Activate
& {
    $project_dir = if (Test-Path env:PWD) {$env:PWD} else {Get-Location}
    $virtualenv_script = [io.path]::Combine(
        $project_dir, "venv", "Scripts", "Activate.ps1")
    if ([System.IO.File]::Exists($virtualenv_script)) {
        & $virtualenv_script
    }
}

# SIG # Begin signature block
# MIIGlwYJKoZIhvcNAQcCoIIGiDCCBoQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUC12cPp97mPAGJhR2vJ5cYFAD
# oSGgggPOMIIDyjCCArKgAwIBAgIQTP3uDUHglaREeCKNEB56ujANBgkqhkiG9w0B
# AQUFADB9MSwwKgYDVQQLDCNodHRwczovL2dpdGh1Yi5jb20vODJwaGlsL3BzX2Rl
# dmVudjEgMB4GCSqGSIb3DQEJARYRODIucGhpbEBnbWFpbC5jb20xFzAVBgNVBAoM
# DlBoaWxpcCBIb2ZmbWFuMRIwEAYDVQQDDAlwc19kZXZlbnYwHhcNMTgxMDI5MDQy
# OTM5WhcNMjExMDI5MDQzOTM5WjB9MSwwKgYDVQQLDCNodHRwczovL2dpdGh1Yi5j
# b20vODJwaGlsL3BzX2RldmVudjEgMB4GCSqGSIb3DQEJARYRODIucGhpbEBnbWFp
# bC5jb20xFzAVBgNVBAoMDlBoaWxpcCBIb2ZmbWFuMRIwEAYDVQQDDAlwc19kZXZl
# bnYwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDBe3XlB9fSC7zg8tPI
# vwsZumH2GgGVvz68Z1KSMLTXsny9bSgBo/K3B2r3j4V76u7SxLxkX4qMn1C5siQ5
# 5CLytUxOx+DKaQuynDonlmR9XV+EkEnwSYoxQK3wCHqlTvX2fuYyzCl8YppT5Ao6
# BfI8aRCHqGIjla2fu/pUR+MLroz10ikG0HPYxDyT29MOwh5UgIhtVG1lLVdtwhzk
# OqaiKCZBz9qsAZ4cCHJcS0BJ0NxsEsmvvWsgiBY9DljEn2RDByshqJz+TZJ6pakX
# iVTkJI2HtkkApL/DQSAfcF2JHgipspGP3129eTdyBBy9rnHG3qDxNWCJozoM7ky8
# DwzxAgMBAAGjRjBEMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggrBgEFBQcD
# AzAdBgNVHQ4EFgQUHtGBHiQ2iwZKRlOw+jyEmKsLiwEwDQYJKoZIhvcNAQEFBQAD
# ggEBAKj+aoAfiysWmdnbuEIeF7aEG7L7/enfB8kzxIfgTKVWlXOneD+lY/jRbwfa
# o/q30pWY7x+t6k13kacqNbgOIS09ni8i6ZTdgkzjErwfxRKU/iReGAUvDeg2ixFx
# p1GIn/Kh3x8JagPoWAqwIwW2hdEHZgupP42UBC8zFG+FYIhAx/s/4YBLHJFnkgHC
# gc9quDMlKsmLZXMaL01z/5PdwskHPjk+p8Q6GMrWQcO2xbHdlxMvCIZ/UaA5CCVE
# lQ6fIOG94HQQtKJTK1YfQksbYM/J7Ix3cFlYx13JLXAz6kH2/R6phh0YRuEwpSaF
# rqeFP4EjhKEOw/cJjhT4zO8jXpUxggIzMIICLwIBATCBkTB9MSwwKgYDVQQLDCNo
# dHRwczovL2dpdGh1Yi5jb20vODJwaGlsL3BzX2RldmVudjEgMB4GCSqGSIb3DQEJ
# ARYRODIucGhpbEBnbWFpbC5jb20xFzAVBgNVBAoMDlBoaWxpcCBIb2ZmbWFuMRIw
# EAYDVQQDDAlwc19kZXZlbnYCEEz97g1B4JWkRHgijRAeerowCQYFKw4DAhoFAKB4
# MBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQB
# gjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkE
# MRYEFDUZT9KzAy8ymX0KoU2c8Yz1pIrxMA0GCSqGSIb3DQEBAQUABIIBAE8ul6sD
# atDTa4bXE2W/IukvdaCLiCGt2XJNBieJzr20uRJZA0ASIiqr5EabaxK4IQQZbZ0a
# Lkv/78MrnUFOE4t5wsFK1RWRUkuisJ1tJDzYyAp9zbnBGUp9D20czSj8m3CYuPXq
# zb6NE3zSOHKlOI+1mdx8P24HHCdlUFiHNNMF9VdJ3sw7gCZhcD8COm2NIMNdMtTI
# HYHg76gs7E7q4TjhflM5F/UDnjwuozvExNqd7sYAjyQVr4Co1RPIGMri7gSxPdAP
# wU259u9EXmZlVacxivNSDt9uLHFD+Gsrc1T9lpaygTZYH6l7+TdOTEj2kOb6eAl8
# i7twNh10E0XQKtY=
# SIG # End signature block
