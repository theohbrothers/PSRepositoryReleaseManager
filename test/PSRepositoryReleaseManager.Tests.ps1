[CmdletBinding()]
param()

$ErrorActionPreference = 'Continue'
$VerbosePreference = 'Continue'

$failedCount = 0

$functionTestScriptBlock = {
    try {
        "Command: $script:cmd" | Write-Verbose
        "Args:" | Write-Verbose
        $script:cmdArgs | Out-String -Stream | % { $_.Trim() } | ? { $_ } | Write-Verbose
        for ($i=0; $i -le $script:iterations-1; $i++) {
            "Iteration: $($i+1)" | Write-Verbose
            if ($script:cmdArgs) {
                $stdout = & $script:cmd @script:cmdArgs
            }else {
                $stdout = & $script:cmd
            }
            "Generate notes content:" | Write-Verbose
            Get-Content -Path "$stdout" | Out-String -Stream | % { $_.Trim() } | ? { $_ } | Write-Host
        }
    }catch {
        $_ | Write-Error
        $script:failedCount++
    }
}

# Globals
$env:RELEASE_TAG_REF = git describe --tags --abbrev=0

# Script: ci/Invoke-Generate.ps1
$ReleaseNotesVariant = Get-ChildItem "../src/PSRepositoryReleaseManager/generate/variants" | % { $_.BaseName }
"Release notes variants:" | Write-Verbose
$ReleaseNotesVariant | Write-Host

foreach ($variant in $ReleaseNotesVariant) {
    $env:RELEASE_NOTES_VARIANT = $variant
    $env:RELEASE_NOTES_PATH = "$(git rev-parse --show-toplevel)/test/.release-notes.$variant.md"

    $cmd = "../src/scripts/ci/Invoke-Generate.ps1"
    $cmdArgs=@{
        ReleaseTagRef = $env:RELEASE_TAG_REF
        ReleaseNotesVariant = $env:RELEASE_NOTES_VARIANT
        ReleaseNotesPath = $env:RELEASE_NOTES_PATH
    }
    $iterations = 1
    & $functionTestScriptBlock
}

###########
# Results #
###########
if ($failedCount -gt 0) {
    "$failedCount tests failed." | Write-Warning
}
$failedCount
