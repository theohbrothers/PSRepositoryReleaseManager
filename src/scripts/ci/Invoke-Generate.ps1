[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$ErrorView = 'NormalView'
$VerbosePreference = 'Continue'
Set-StrictMode -Version Latest

try {
    Push-Location $PSScriptRoot
    Import-Module "$(git rev-parse --show-toplevel)\src\PSRepositoryReleaseManager\PSRepositoryReleaseManager.psm1" -Force -Verbose

    # Generate release notes
    $private:superProjectDir = git rev-parse --show-superproject-working-tree
    if ($private:superProjectDir) {
        "Using superproject path '$private:ProjectDir'" | Write-Verbose
        $private:ProjectDir = $private:superProjectDir
    }else {
        $private:ProjectDir = git rev-parse --show-toplevel
        "Superproject does not exist. Using project path '$private:ProjectDir'" | Write-Verbose
    }
    $private:generateArgs = @{
        Path = $private:ProjectDir
        TagName = $env:RELEASE_TAG_REF
        Variant = if ($env:RELEASE_NOTES_VARIANT) { $env:RELEASE_NOTES_VARIANT } else { 'VersionDate-HashSubject-NoMerges' }
        ReleaseNotesPath = if ($env:RELEASE_NOTES_PATH) {
                               "Using specified release notes path '$env:RELEASE_NOTES_PATH'" | Write-Verbose
                               if ([System.IO.Path]::IsPathRooted($env:RELEASE_NOTES_PATH)) { $env:RELEASE_NOTES_PATH }
                               else { "$private:ProjectDir/$env:RELEASE_NOTES_PATH" }
                           }else {
                               $private:defaultReleaseNotesPath = "$(git rev-parse --show-toplevel)/.release-notes.md"
                               "Using the default release notes path '$private:defaultReleaseNotesPath'" | Write-Verbose
                               $private:defaultReleaseNotesPath
                           }
    }
    Generate-ReleaseNotes @private:generateArgs

}catch {
    throw
}finally {
    Pop-Location
}
