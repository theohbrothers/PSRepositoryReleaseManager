[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'
Set-StrictMode -Version Latest

$private:releaseArgs = @{
    Namespace = $env:RELEASE_NAMESPACE
    Repository = $env:RELEASE_REPOSITORY
    ApiKey = $env:GITHUB_API_TOKEN
    TagName = $env:RELEASE_TAG_REF
    TargetCommitish = git rev-parse $env:RELEASE_TAG_REF
    Name = $env:RELEASE_TAG_REF
    Body = Get-Content $(if ($env:RELEASE_NOTES_PATH) { $env:RELEASE_NOTES_PATH } else { "$(git rev-parse --show-toplevel)\.release-notes.md" | Resolve-Path }) -Raw
    Draft = $false
    Prerelease = $false
}

try {
    Push-Location $PSScriptRoot
    Import-Module "$(git rev-parse --show-toplevel)\lib\PSGitHubRestApi\src\PSGitHubRestApi\PSGitHubRestApi.psm1" -Force -Verbose

    # Create GitHub release
    $response = New-GitHubRepositoryRelease @private:releaseArgs
    $response

}catch {
    throw
}finally {
    Pop-Location
}
