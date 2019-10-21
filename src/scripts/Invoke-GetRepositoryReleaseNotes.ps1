#######################################################################################################################################
# This script is designed for use in development environments for executing the same generate steps that will run in CI environments. #
# You can use the provided switches to test generation and creation of releases in your development environment.                      #
#######################################################################################################################################

$private:generateArgs = @{
    Path = '/path/to/mylocalrepository'
    TagName = 'v0.0.0'
    Variant = 'DateCommitHistory'
    ReleaseNotesPath = "$(git rev-parse --show-toplevel)/.release-notes.md"
}
$VerbosePreference = 'Continue'

################################################

function Invoke-GenerateRepositoryReleaseNotes {
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
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Variant
        ,
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$ReleaseNotesPath
    )

    try {
        # Generate release notes
        Get-RepositoryReleaseNotes @PSBoundParameters

    }catch {
        throw
    }
}

try {
    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'

    # Import modules
    Push-Location $PSScriptRoot
    Import-Module "$(git rev-parse --show-toplevel)\src\PSRepositoryReleaseManager\PSRepositoryReleaseManager.psm1" -Force -Verbose
    Import-Module "$(git rev-parse --show-toplevel)\lib\PSGitHubRestApi\src\PSGitHubRestApi\PSGitHubRestApi.psm1" -Force -Verbose

    Invoke-GenerateRepositoryReleaseNotes @generateArgs

}catch {
    throw
}finally {
    Pop-Location
}
