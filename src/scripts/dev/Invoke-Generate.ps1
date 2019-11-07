[CmdletBinding()]
param()

################################################

$private:Path = '/path/to/mylocalrepository'
$private:generateArgs = @{
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
    Generate-ReleaseNotes @private:generateArgs

}catch {
    throw
}finally {
    Pop-Location
}
