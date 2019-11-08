[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'
Set-StrictMode -Version Latest

try {
    Push-Location $PSScriptRoot
    Import-Module "$(git rev-parse --show-toplevel)\src\PSRepositoryReleaseManager\PSRepositoryReleaseManager.psm1" -Force -Verbose

    # Generate release notes
    $private:superProjectDir = git rev-parse --show-superproject-working-tree
    if (!$private:superProjectDir) { throw "The superproject root directory cannot be determined." }
    $private:generateArgs = @{
        Path = $private:superProjectDir
        TagName = $env:RELEASE_TAG_REF
        Variant = if ($env:RELEASE_NOTES_VARIANT) { $env:RELEASE_NOTES_VARIANT } else { 'DateCommitHistoryNoMerges' }
        ReleaseNotesPath = if ($env:RELEASE_NOTES_PATH) {
                               if ([System.IO.Path]::IsPathRooted($env:RELEASE_NOTES_PATH)) { $env:RELEASE_NOTES_PATH }
                               else { "$private:superProjectDir/$env:RELEASE_NOTES_PATH" }
                           }else { "$(git rev-parse --show-toplevel)/.release-notes.md" }
    }
    Generate-ReleaseNotes @private:generateArgs

}catch {
    throw
}finally {
    Pop-Location
}
