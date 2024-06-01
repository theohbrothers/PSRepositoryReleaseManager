[CmdletBinding()]
param()

<# Examples

# Maximum defaults
./Invoke-Generate.ps1

# Default project directory, release notes variant, and release notes path
$env:RELEASE_TAG_REF = 'v1.0.12'
./Invoke-Generate.ps1

# Default release notes variant and release notes path
$env:PROJECT_DIRECTORY = '/path/to/my-project'
$env:RELEASE_TAG_REF = 'v1.0.12'
./Invoke-Generate.ps1

# Default release notes path
$env:PROJECT_DIRECTORY = '/path/to/my-project'
$env:RELEASE_TAG_REF = 'v1.0.12'
$env:RELEASE_NOTES_VARIANT = 'Changes-HashSubject-NoMerges'
./Invoke-Generate.ps1

# Custom -ReleaseNotesPath relative to -ProjectDirectory
$env:PROJECT_DIRECTORY = '/path/to/my-project'
$env:RELEASE_TAG_REF = 'v1.0.12'
$env:RELEASE_NOTES_VARIANT = 'Changes-HashSubject-NoMerges'
$env:RELEASE_NOTES_PATH = '.release-notes.md'
./Invoke-Generate.ps1

# No defaults
$env:PROJECT_DIRECTORY = '/path/to/my-project'
$env:RELEASE_TAG_REF = 'v1.0.12'
$env:RELEASE_NOTES_VARIANT = 'Changes-HashSubject-NoMerges'
$env:RELEASE_NOTES_PATH = '/path/to/.release-notes.md'
./Invoke-Generate.ps1

#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ErrorView = 'NormalView'

try {
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
            throw "`$env:PROJECT_DIRECTORY is undefined or superproject directory cannot be determined." | Write-Verbose
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
