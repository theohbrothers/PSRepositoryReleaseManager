Describe "PSRepositoryReleaseManager" -Tag 'Integration' {
    BeforeAll {
        $ErrorActionPreference = 'Continue'
        $ErrorView = 'NormalView'
        $VerbosePreference = 'Continue'
        $env:RELEASE_TAG_REF = git describe --tags --abbrev=0
    }
    BeforeEach {
    }
    AfterEach {
    }
    It "Runs Invoke-Generate.ps1 -ReleaseTagRef" {
        $stdout = ../src/scripts/ci/Invoke-Generate.ps1 -ReleaseTagRef $env:RELEASE_TAG_REF
        "Generate notes content:" | Write-Verbose
        Get-Content -Path "$stdout" | Out-String -Stream | % { $_.Trim() } | ? { $_ } | Write-Host
    }
    It "Runs Invoke-Generate.ps1 -ProjectDirectory -ReleaseTagRef" {
        $private:ProjectDir = "$(git rev-parse --show-toplevel)"

        $stdout = ../src/scripts/ci/Invoke-Generate.ps1 -ProjectDirectory $private:ProjectDir -ReleaseTagRef $env:RELEASE_TAG_REF
        "Generate notes content:" | Write-Verbose
        Get-Content -Path "$stdout" | Out-String -Stream | % { $_.Trim() } | ? { $_ } | Write-Host
    }
    It "Runs Invoke-Generate.ps1 -ReleaseTagRef -ReleaseNotesVariant" {
        $env:RELEASE_NOTES_VARIANT = 'Changes-HashSubject-NoMerges'

        $stdout = ../src/scripts/ci/Invoke-Generate.ps1 -ReleaseTagRef $env:RELEASE_TAG_REF -ReleaseNotesVariant $env:RELEASE_NOTES_VARIANT
        "Generate notes content:" | Write-Verbose
        Get-Content -Path "$stdout" | Out-String -Stream | % { $_.Trim() } | ? { $_ } | Write-Host
    }
    It "Runs Invoke-Generate.ps1 -ReleaseTagRef -ReleaseNotesPath (full)" {
        $env:RELEASE_NOTES_PATH = "$(git rev-parse --show-toplevel)/.release-notes.fullpath.md"

        $stdout = ../src/scripts/ci/Invoke-Generate.ps1 -ReleaseTagRef $env:RELEASE_TAG_REF -ReleaseNotesPath $env:RELEASE_NOTES_PATH
        "Generate notes content:" | Write-Verbose
        Get-Content -Path "$stdout" | Out-String -Stream | % { $_.Trim() } | ? { $_ } | Write-Host
    }
    It "Runs Invoke-Generate.ps1 -ReleaseTagRef -ReleaseNotesPath (relative)" {
        $env:RELEASE_NOTES_PATH = ".release-notes.relativepath.md"

        $stdout = ../src/scripts/ci/Invoke-Generate.ps1 -ReleaseTagRef $env:RELEASE_TAG_REF -ReleaseNotesPath $env:RELEASE_NOTES_PATH
        "Generate notes content:" | Write-Verbose
        Get-Content -Path "$stdout" | Out-String -Stream | % { $_.Trim() } | ? { $_ } | Write-Host
    }
    It "Runs Invoke-Generate.ps1 -ReleaseTagRef -ReleaseNotesVariant -ReleaseNotesPath (all variants)" {
        $ReleaseNotesVariant = Get-ChildItem "../src/PSRepositoryReleaseManager/generate/variants" | % { $_.BaseName }
        "Release notes variants:" | Write-Verbose
        $ReleaseNotesVariant | Write-Host

        foreach ($variant in $ReleaseNotesVariant) {
            $env:RELEASE_NOTES_VARIANT = $variant
            $env:RELEASE_NOTES_PATH = "$(git rev-parse --show-toplevel)/.release-notes.$variant.md"

            $stdout = ../src/scripts/ci/Invoke-Generate.ps1 -ReleaseTagRef $env:RELEASE_TAG_REF -ReleaseNotesVariant $env:RELEASE_NOTES_VARIANT -ReleaseNotesPath $env:RELEASE_NOTES_PATH
            "Generate notes content:" | Write-Verbose
            Get-Content -Path "$stdout" | Out-String -Stream | % { $_.Trim() } | ? { $_ } | Write-Host
        }
    }
}
