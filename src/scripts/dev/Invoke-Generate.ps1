[CmdletBinding()]
param()

################################################

$private:path = '/path/to/mylocalrepository'
$private:myGenerateArgs = @{
    Path = $private:path
    TagName = 'v0.0.0'
    Variant = 'DateCommitHistoryNoMerges'
    ReleaseNotesPath = "$($private:path)/.release-notes.md"
}

################################################

$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'
Set-StrictMode -Version Latest

try {
    Push-Location $PSScriptRoot
    Import-Module "$(git rev-parse --show-toplevel)\src\PSRepositoryReleaseManager\PSRepositoryReleaseManager.psm1" -Force -Verbose

    # Generate release notes
    $private:generateArgs = @{
        Path = if ($private:myGenerateArgs['Path']) { $private:myGenerateArgs['Path'] }
        TagName = if ($private:myGenerateArgs['TagName']) { $private:myGenerateArgs['TagName'] }
        Variant = if ($private:myGenerateArgs['Variant']) { $private:myGenerateArgs['Variant'] } else { 'DateCommitHistoryNoMerges' }
        ReleaseNotesPath = if ($private:myGenerateArgs['ReleaseNotesPath']) {
                               "Using specified release notes path '$($private:myGenerateArgs['ReleaseNotesPath'])'" | Write-Verbose
                               if ([System.IO.Path]::IsPathRooted($private:myGenerateArgs['ReleaseNotesPath'])) { $private:myGenerateArgs['ReleaseNotesPath'] }
                               else { $private:myGenerateArgs['ReleaseNotesPath'] }
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
