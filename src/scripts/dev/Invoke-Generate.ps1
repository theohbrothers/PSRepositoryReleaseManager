[CmdletBinding()]
param()

################################################

$private:Path = '/path/to/mylocalrepository'
$private:myGenerateArgs = @{
    Path = $private:Path
    TagName = 'v0.0.0'
    Variant = 'DateCommitHistoryNoMerges'
    ReleaseNotesPath = "$($private:Path)/.release-notes.md"
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
                               if ([System.IO.Path]::IsPathRooted($private:myGenerateArgs['ReleaseNotesPath'])) { $private:myGenerateArgs['ReleaseNotesPath'] }
                               else { $private:myGenerateArgs['ReleaseNotesPath'] }
                           }else { "$(git rev-parse --show-toplevel)/.release-notes.md" }
    }
    Generate-ReleaseNotes @private:generateArgs

}catch {
    throw
}finally {
    Pop-Location
}
