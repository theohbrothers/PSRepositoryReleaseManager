function Generate-ReleaseNotes {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path -Path $_ -PathType Container})]
        [string]$Path
        ,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$TagName
        ,
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$Variant
        ,
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$ReleaseNotesPath
    )

    $ErrorActionPreference = 'Stop'
    $VerbosePreference = 'Continue'
    Set-StrictMode -Version Latest

    try {
        Push-Location $PSScriptRoot
        Import-Module "$(git rev-parse --show-toplevel)\src\PSRepositoryReleaseManager\PSRepositoryReleaseManager.psm1" -Force -Verbose
        Import-Module "$(git rev-parse --show-toplevel)\lib\PSGitHubRestApi\src\PSGitHubRestApi\PSGitHubRestApi.psm1" -Force -Verbose

        # Generate release notes
        Get-RepositoryReleaseNotes @PSBoundParameters

    }catch {
        throw
    }finally {
        Pop-Location
    }
}
