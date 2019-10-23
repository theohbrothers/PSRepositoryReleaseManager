[CmdletBinding()]
param()

################################################

$private:Path = '/path/to/mylocalrepository'
$private:generateArgs = @{
    Path = $private:Path
    TagName = 'v0.0.0'
    Variant = 'DateCommitHistory'
    ReleaseNotesPath = "$($private:Path)/.release-notes.md"
}

################################################

$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'
Set-StrictMode -Version Latest

try {
    Push-Location $PSScriptRoot
    . "$(git rev-parse --show-toplevel)/src/scripts/includes/Generate-ReleaseNotes.ps1"

    # Generate release notes
    Generate-ReleaseNotes @private:generateArgs

}catch {
    throw
}finally {
    Pop-Location
}
