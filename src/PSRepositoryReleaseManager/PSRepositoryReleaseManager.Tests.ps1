Describe "PSRepositoryReleaseManager" -Tag 'Integration' {
    BeforeAll {
        $ErrorView = 'NormalView'
        $env:RELEASE_TAG_REF = 'HEAD'
        $env:PROJECT_DIRECTORY = "$(git rev-parse --show-toplevel)"
    }
    BeforeEach {
    }
    AfterEach {
        $env:RELEASE_NOTES_VARIANT = $null
        $env:RELEASE_NOTES_PATH = $null
    }
    It "Runs Invoke-Generate.ps1 with `$env:PROJECT_DIRECTORY `$env:RELEASE_TAG_REF" {
        $stdout = ../src/scripts/ci/Invoke-Generate.ps1
        "Generate notes content:" | Write-Verbose
        Get-Content -Path "$stdout" | Out-String -Stream | % { $_.Trim() } | ? { $_ } | Write-Host
    }
    It "Runs Invoke-Generate.ps1 with `$env:PROJECT_DIRECTORY `$env:RELEASE_TAG_REF `$env:RELEASE_NOTES_VARIANT" {
        $env:RELEASE_NOTES_VARIANT = 'Changes-HashSubject-NoMerges'

        $stdout = ../src/scripts/ci/Invoke-Generate.ps1
        "Generate notes content:" | Write-Verbose
        Get-Content -Path "$stdout" | Out-String -Stream | % { $_.Trim() } | ? { $_ } | Write-Host
    }
    It "Runs Invoke-Generate.ps1 with `$env:PROJECT_DIRECTORY `$env:RELEASE_TAG_REF `$env:RELEASE_NOTES_PATH (full)" {
        $env:RELEASE_NOTES_PATH = "$(git rev-parse --show-toplevel)/.release-notes.fullpath.md"

        $stdout = ../src/scripts/ci/Invoke-Generate.ps1
        "Generate notes content:" | Write-Verbose
        Get-Content -Path "$stdout" | Out-String -Stream | % { $_.Trim() } | ? { $_ } | Write-Host
    }
    It "Runs Invoke-Generate.ps1 with `$env:PROJECT_DIRECTORY `$env:RELEASE_TAG_REF `$env:RELEASE_NOTES_PATH (relative)" {
        $env:RELEASE_NOTES_PATH = ".release-notes.relativepath.md"

        $stdout = ../src/scripts/ci/Invoke-Generate.ps1
        "Generate notes content:" | Write-Verbose
        Get-Content -Path "$stdout" | Out-String -Stream | % { $_.Trim() } | ? { $_ } | Write-Host
    }
    It "Runs Invoke-Generate.ps1 with `$env:PROJECT_DIRECTORY `$env:RELEASE_TAG_REF `$env:RELEASE_NOTES_VARIANT `$env:RELEASE_NOTES_PATH (all variants)" {
        $ReleaseNotesVariant = Get-ChildItem "../src/PSRepositoryReleaseManager/generate/variants" | % { $_.BaseName }
        "Release notes variants:" | Write-Verbose
        $ReleaseNotesVariant | Write-Host

        foreach ($variant in $ReleaseNotesVariant) {
            $env:RELEASE_NOTES_VARIANT = $variant
            $env:RELEASE_NOTES_PATH = "$(git rev-parse --show-toplevel)/.release-notes.$variant.md"

            $stdout = ../src/scripts/ci/Invoke-Generate.ps1
            "Generate notes content:" | Write-Verbose
            Get-Content -Path "$stdout" | Out-String -Stream | % { $_.Trim() } | ? { $_ } | Write-Host
        }
    }
}
