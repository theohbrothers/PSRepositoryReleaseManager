[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'
Set-StrictMode -Version Latest

$private:generateArgs = @{
    Path = "$(Get-Location)"
    TagName = $env:RELEASE_TAG_REF
    Variant = 'DateCommitHistory'
    ReleaseNotesPath = if ($env:RELEASE_NOTES_PATH) { $env:RELEASE_NOTES_PATH } else { "$(git rev-parse --show-toplevel)/.release-notes.md" }
}

try {
    Push-Location $PSScriptRoot
    Import-Module "$(git rev-parse --show-toplevel)\src\PSRepositoryReleaseManager\PSRepositoryReleaseManager.psm1" -Force -Verbose
    Import-Module "$(git rev-parse --show-toplevel)\lib\PSGitHubRestApi\src\PSGitHubRestApi\PSGitHubRestApi.psm1" -Force -Verbose

    # Generate release notes
    Get-RepositoryReleaseNotes @private:generateArgs

}catch {
    throw
}finally {
    Pop-Location
}
