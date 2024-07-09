[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

try {
    $private:ProjectDir = git rev-parse --show-toplevel

    Push-Location $PSScriptRoot
    Import-Module "$(git rev-parse --show-toplevel)\src\PSRepositoryReleaseManager\PSRepositoryReleaseManager.psm1" -Force

    # Generate release notes
    if ($env:PROJECT_DIRECTORY) {
        "Using specified project directory '$env:PROJECT_DIRECTORY'" | Write-Verbose
        $private:ProjectDir = $env:PROJECT_DIRECTORY
    }else {
        $private:superProjectDir = git rev-parse --show-superproject-working-tree
        if ($private:superProjectDir) {
            $private:ProjectDir = $private:superProjectDir
            "Using superproject directory '$private:ProjectDir'" | Write-Verbose
        }else {
            "Using default project directory '$private:ProjectDir'" | Write-Verbose
        }
    }
    $private:generateArgs = @{
        Path = $private:ProjectDir
        TagName = if ($env:RELEASE_TAG_REF) {
                        "Using specified ref '$env:RELEASE_TAG_REF'" | Write-Verbose
                        $env:RELEASE_TAG_REF
                  }else {
                      "Using default ref 'HEAD'" | Write-Verbose
                      'HEAD'
                  }
        Variant = if ($env:RELEASE_NOTES_VARIANT) {
                        "Using specified release notes variant '$env:RELEASE_NOTES_VARIANT'" | Write-Verbose
                        $env:RELEASE_NOTES_VARIANT
                  }else {
                    "Using default release notes variant 'VersionDate-HashSubject-NoMerges-CategorizedSorted'" | Write-Verbose
                    'VersionDate-HashSubject-NoMerges-CategorizedSorted'
                }
        ReleaseNotesPath = if ($env:RELEASE_NOTES_PATH) {
                               "Using specified release notes path '$env:RELEASE_NOTES_PATH'" | Write-Verbose
                               if ([System.IO.Path]::IsPathRooted($env:RELEASE_NOTES_PATH)) { $env:RELEASE_NOTES_PATH }
                               else { "$private:ProjectDir/$env:RELEASE_NOTES_PATH" }
                           }else {
                               $private:defaultReleaseNotesPath = "$(git rev-parse --show-toplevel)/.release-notes.md"
                               "Using default release notes path '$private:defaultReleaseNotesPath'" | Write-Verbose
                               $private:defaultReleaseNotesPath
                           }
    }
    Generate-ReleaseNotes @private:generateArgs

}catch {
    throw
}finally {
    Pop-Location
}
