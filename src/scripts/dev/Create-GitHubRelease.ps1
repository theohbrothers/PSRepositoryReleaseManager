[CmdletBinding()]
param()

################################################

$private:Path = '/path/to/mylocalrepository'
$private:tagName = 'v0.0.0'
$private:releaseArgs = @{
    Namespace = 'myusername'
    Repository = 'myrepository'
    ApiKey = 'myapikey'
    TagName = $private:tagName
    TargetCommitish = git --git-dir "$private:Path/.git" rev-parse $private:tagName
    Name = $private:tagName
    Body = Get-Content "$private:Path/.release-notes.md" -Raw
    Draft = $false
    Prerelease = $false
}

################################################

$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'
Set-StrictMode -Version Latest

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
