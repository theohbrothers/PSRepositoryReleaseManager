[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'
Set-StrictMode -Version Latest

try {
    Push-Location $PSScriptRoot
    . "$(git rev-parse --show-toplevel)/src/scripts/includes/Create-GitHubRelease.ps1"

    $private:superProjectDir = git rev-parse --show-superproject-working-tree
    if (!$private:superProjectDir) { throw "The superproject root directory cannot be determined." }
    $private:releaseArgs = @{
        Namespace = $env:RELEASE_NAMESPACE
        Repository = $env:RELEASE_REPOSITORY
        ApiKey = $env:GITHUB_API_TOKEN
        TagName = $env:RELEASE_TAG_REF
        TargetCommitish = if ($private:superProjectDir) { git --git-dir "$($private:superProjectDir)/.git" rev-parse $env:RELEASE_TAG_REF }
        Name = if ($env:RELEASE_NAME) { $env:RELEASE_NAME } else { $env:RELEASE_TAG_REF }
        Draft = if ($env:RELEASE_DRAFT) { [System.Convert]::ToBoolean($env:RELEASE_DRAFT) } else { $false }
        Prerelease = if ($env:RELEASE_PRERELEASE) { [System.Convert]::ToBoolean($env:RELEASE_PRERELEASE) } else { $false }
    }

    if ($env:RELEASE_NOTES_PATH) { $private:releaseArgs['ReleaseNotesPath'] = "$private:superProjectDir/$env:RELEASE_NOTES_PATH" }
    elseif ($env:RELEASE_NOTES_CONTENT) { $private:releaseArgs['ReleaseNotesContent'] = $env:RELEASE_NOTES_CONTENT }
    elseif (!$env:RELEASE_NOTES_PATH -And !$env:RELEASE_NOTES_PATH) {
        $defaultReleaseNotesPath = "$(git rev-parse --show-toplevel)/.release-notes.md"
        "Sourcing from the default release notes path '$defaultReleaseNotesPath'" | Write-Verbose
        $private:releaseArgs['ReleaseNotesPath'] = $defaultReleaseNotesPath
    }

    # Create GitHub release
    $response = Create-GitHubRelease @private:releaseArgs
    $response

}catch {
    throw
}finally {
    Pop-Location
}
