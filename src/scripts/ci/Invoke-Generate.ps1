[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'
Set-StrictMode -Version Latest

try {
    Push-Location $PSScriptRoot
    . "$(git rev-parse --show-toplevel)/src/scripts/includes/Generate-ReleaseNotes.ps1"

    $private:superProjectDir = git rev-parse --show-superproject-working-tree
    if (!$private:superProjectDir) { throw "The superproject root directory cannot be determined." }
    $private:generateArgs = @{
        Path = $private:superProjectDir
        TagName = $env:RELEASE_TAG_REF
        Variant = 'DateCommitHistory'
        ReleaseNotesPath = if ($env:RELEASE_NOTES_PATH) { "$private:superProjectDir/$env:RELEASE_NOTES_PATH" } else { "$(git rev-parse --show-toplevel)/.release-notes.md" }
    }

    # Generate release notes
    Generate-ReleaseNotes @private:generateArgs

}catch {
    throw
}finally {
    Pop-Location
}
