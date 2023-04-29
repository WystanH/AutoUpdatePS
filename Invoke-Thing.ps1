
<#PSScriptInfo

.VERSION 3.0

.GUID f599767a-7b30-4477-b7c8-d059cbdb9b45

.AUTHOR WystanH

.PROJECTURI https://raw.githubusercontent.com/WystanH/AutoUpdatePS/main/Invoke-Thing.ps1

#>

<# 

.DESCRIPTION 
 Auto update script demo

#> 
param(
    [string]$Name,
    
    # two internal params for auto update
    [switch]$Execute,
    [string]$CopyTo = $null
)
begin {
    # the actual work load of our script
    function Invoke-Job {
        Write-Host "Well met, $Name!"
    }

    # validation for parameters
    function Test-ScriptArgs {
        if ([string]::IsNullOrWhiteSpace($Name)) { throw "-Name required" }
    }

    # build the bounce call
    function Get-CommandLine {
        param($Cmd)
        "& $Cmd -Name $Name -Execute"
    }

    # Boilerplate starts here
    function Get-RemoteScript {
        param($SourceUri)
        $versionCheck = "$((New-TemporaryFile).FullName).ps1"
        $priorProgressPreference = $ProgressPreference
        try {
            $ProgressPreference = 'SilentlyContinue' 
            Invoke-WebRequest -URI $SourceUri -OutFile $versionCheck
        } finally {
            $ProgressPreference = $priorProgressPreference
        }
        $versionCheck
    }
}
process {
    Test-ScriptArgs

    $thisFilename = Join-Path $PSScriptRoot $MyInvocation.MyCommand

    if ($Execute) {
        if (![string]::IsNullOrWhiteSpace($CopyTo)) {
            Copy-Item -Path $thisFilename -Destination $CopyTo # -Verbose
        }
        Invoke-Job
    } else {
        $info = Test-ScriptFileInfo $thisFilename
        $remoteFilename = Get-RemoteScript $info.ProjectUri
        $remoteInfo = Test-ScriptFileInfo $remoteFilename
        if ($info.Version -ne $remoteInfo.Version) {
            $execCmd = "$(Get-CommandLine $remoteFilename) -CopyTo '$thisFilename'"
            Invoke-Expression $execCmd

        } else {
            Remove-Item -Path $remoteFilename -Force -ErrorAction SilentlyContinue | Out-Null
            Invoke-Expression (Get-CommandLine $thisFilename)
        }
    }
}
