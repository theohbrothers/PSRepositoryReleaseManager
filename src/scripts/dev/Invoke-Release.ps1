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
    ReleaseNotesPath = "$private:Path/.release-notes.md"
    # ReleaseNotesContent = Get-Content "$private:Path/.release-notes.md" -Raw
    Draft = $false
    Prerelease = $false
}

################################################

$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'
Set-StrictMode -Version Latest

try {
    Push-Location $PSScriptRoot
    . "$(git rev-parse --show-toplevel)\src\scripts\includes\Create-GitHubRelease.ps1"

    # Create GitHub release
    $response = Create-GitHubRelease @private:releaseArgs
    $response

}catch {
    throw
}finally {
    Pop-Location
}
