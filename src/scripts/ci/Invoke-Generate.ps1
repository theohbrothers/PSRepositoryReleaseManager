[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [ValidateScript({Test-Path -Path $_ -PathType Container})]
    [string]$ProjectDirectory
    ,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$ReleaseTagRef
    ,
    [Parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [string]$ReleaseNotesVariant
    ,
    [Parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [string]$ReleaseNotesPath

    <# Examples

    # Maximum defaults
    ./Invoke-Generate.ps1 -ReleaseTagRef v1.0.12

    # Default -ReleaseNotesVariant and -ReleaseNotesPath
    ./Invoke-Generate.ps1 -ProjectDirectory '/path/to/repository' -ReleaseTagRef v1.0.12

    # Default -ReleaseNotesPath
    ./Invoke-Generate.ps1 -ProjectDirectory '/path/to/repository' -ReleaseTagRef v1.0.12 -ReleaseNotesVariant 'Changes-HashSubject-NoMerges'

    # Custom -ReleaseNotesPath relative to -ProjectDirectory
    ./Invoke-Generate.ps1 -ProjectDirectory '/path/to/repository' -ReleaseTagRef v1.0.12 -ReleaseNotesVariant 'Changes-HashSubject-NoMerges' -ReleaseNotesPath 'my-custom-release-notes.md'

    # No defaults
    ./Invoke-Generate.ps1 -ProjectDirectory '/path/to/repository' -ReleaseTagRef v1.0.12 -ReleaseNotesVariant 'Changes-HashSubject-NoMerges' -ReleaseNotesPath '/path/to/repository/.release-notes.md'
    #>

)

$ErrorActionPreference = 'Stop'
$ErrorView = 'NormalView'
$VerbosePreference = 'Continue'
Set-StrictMode -Version Latest

try {
    Push-Location $PSScriptRoot
    Import-Module "$(git rev-parse --show-toplevel)\src\PSRepositoryReleaseManager\PSRepositoryReleaseManager.psm1" -Force -Verbose

    # Generate release notes
    if ($private:ProjectDirectory) {
        $private:ProjectDir = $private:ProjectDirectory
    }else {
        $private:superProjectDir = git rev-parse --show-superproject-working-tree
        if ($private:superProjectDir) {
            "Using superproject path '$private:ProjectDir'" | Write-Verbose
            $private:ProjectDir = $private:superProjectDir
        }else {
            $private:ProjectDir = git rev-parse --show-toplevel
            "Superproject does not exist. Using project path '$private:ProjectDir'" | Write-Verbose
        }
    }
    $private:generateArgs = @{
        Path = $private:ProjectDir
        TagName = $private:ReleaseTagRef
        Variant = if ($private:ReleaseNotesVariant) { $private:ReleaseNotesVariant } else { 'VersionDate-HashSubject-NoMerges' }
        ReleaseNotesPath = if ($private:ReleaseNotesPath) {
                               "Using specified release notes path '$private:ReleaseNotesPath'" | Write-Verbose
                               if ([System.IO.Path]::IsPathRooted($private:ReleaseNotesPath)) { $private:ReleaseNotesPath }
                               else { "$private:ProjectDir/$private:ReleaseNotesPath" }
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
