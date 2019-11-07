[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'
Set-StrictMode -Version Latest

try {
    Push-Location $PSScriptRoot
    Import-Module "$(git rev-parse --show-toplevel)\src\PSRepositoryReleaseManager\PSRepositoryReleaseManager.psm1" -Force -Verbose

    $private:superProjectDir = git rev-parse --show-superproject-working-tree
    if (!$private:superProjectDir) { throw "The superproject root directory cannot be determined." }
    $private:generateArgs = @{
        Path = $private:superProjectDir
        TagName = $env:RELEASE_TAG_REF
        Variant = if ($env:RELEASE_NOTES_VARIANT) { $env:RELEASE_NOTES_VARIANT } else { 'DateCommitHistory' }
        ReleaseNotesPath = if ($env:RELEASE_NOTES_PATH) { "$private:superProjectDir/$env:RELEASE_NOTES_PATH" } else { "$(git rev-parse --show-toplevel)/.release-notes.md" }
    }

    # Generate release notes
    Generate-ReleaseNotes @private:generateArgs

}catch {
    throw
}finally {
    Pop-Location
}
