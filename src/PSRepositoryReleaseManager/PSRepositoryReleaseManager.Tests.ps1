Describe "PSRepositoryReleaseManager" -Tag 'Integration' {
    BeforeAll {
        $ErrorView = 'NormalView'
    }
    BeforeEach {
        $env:PROJECT_DIRECTORY = $null
        $env:RELEASE_TAG_REF = $null
        $env:RELEASE_NOTES_VARIANT = $null
        $env:RELEASE_NOTES_PATH = $null
    }
    AfterEach {
    }
    It "Runs Invoke-Generate.ps1" {
        $stdout = ../Invoke-Generate.ps1
        "Generate notes content:" | Write-Verbose
        Get-Content -Path "$stdout" | Write-Host
    }
    It "Runs Invoke-Generate.ps1 with `$env:PROJECT_DIRECTORY" {
        $env:PROJECT_DIRECTORY = "$(git rev-parse --show-toplevel)"

        $stdout = ../Invoke-Generate.ps1
        "Generate notes content:" | Write-Verbose
        Get-Content -Path "$stdout" | Write-Host
    }
    It "Runs Invoke-Generate.ps1 with `$env:RELEASE_TAG_REF='HEAD'" {
        $env:RELEASE_TAG_REF = 'HEAD'

        $stdout = ../Invoke-Generate.ps1
        "Generate notes content:" | Write-Verbose
        Get-Content -Path "$stdout" | Write-Host
    }
    It "Runs Invoke-Generate.ps1 with `$env:RELEASE_TAG_REF='branch'" {
        $env:RELEASE_TAG_REF = 'master'
        git checkout -b 'master' 'HEAD'

        $stdout = ../Invoke-Generate.ps1
        "Generate notes content:" | Write-Verbose
        Get-Content -Path "$stdout" | Write-Host
    }
    It "Runs Invoke-Generate.ps1 with `$env:RELEASE_TAG_REF='vx.x.x'" {
        $env:RELEASE_TAG_REF = git describe --tags --abbrev=0

        $stdout = ../Invoke-Generate.ps1
        "Generate notes content:" | Write-Verbose
        Get-Content -Path "$stdout" | Write-Host
    }
    It "Runs Invoke-Generate.ps1 with `$env:RELEASE_TAG_REF='remote/branch'" {
        $env:RELEASE_TAG_REF = 'origin/master'

        $stdout = ../Invoke-Generate.ps1
        "Generate notes content:" | Write-Verbose
        Get-Content -Path "$stdout" | Write-Host
    }
    It "Runs Invoke-Generate.ps1 with `$env:RELEASE_TAG_REF='commit-hash'" {
        $env:RELEASE_TAG_REF = git rev-parse HEAD

        $stdout = ../Invoke-Generate.ps1
        "Generate notes content:" | Write-Verbose
        Get-Content -Path "$stdout" | Write-Host
    }
    It "Runs Invoke-Generate.ps1 with `$env:RELEASE_NOTES_VARIANT='Changes-HashSubject-NoMerges'" {
        $env:RELEASE_NOTES_VARIANT = 'Changes-HashSubject-NoMerges'

        $stdout = ../Invoke-Generate.ps1
        "Generate notes content:" | Write-Verbose
        Get-Content -Path "$stdout" | Write-Host
    }
    It "Runs Invoke-Generate.ps1 with `$env:RELEASE_NOTES_PATH='.release-notes.md'" {
        $env:RELEASE_NOTES_PATH = ".release-notes.relativepath.md"

        $stdout = ../Invoke-Generate.ps1
        "Generate notes content:" | Write-Verbose
        Get-Content -Path "$stdout" | Write-Host
    }
    It "Runs Invoke-Generate.ps1 with `$env:RELEASE_NOTES_PATH='/path/to/.release-notes.md'" {
        $env:RELEASE_NOTES_PATH = "$(git rev-parse --show-toplevel)/.release-notes.fullpath.md"

        $stdout = ../Invoke-Generate.ps1
        "Generate notes content:" | Write-Verbose
        Get-Content -Path "$stdout" | Write-Host
    }
    It "Runs Invoke-Generate.ps1 with `$env:RELEASE_NOTES_VARIANT `$env:RELEASE_NOTES_PATH (all variants)" {
        $ReleaseNotesVariant = Get-ChildItem "../src/PSRepositoryReleaseManager/generate/variants" | % { $_.BaseName }
        "Release notes variants:" | Write-Verbose
        $ReleaseNotesVariant | Write-Host

        foreach ($variant in $ReleaseNotesVariant) {
            $env:RELEASE_NOTES_VARIANT = $variant
            $env:RELEASE_NOTES_PATH = "$(git rev-parse --show-toplevel)/.release-notes.$variant.md"

            $stdout = ../Invoke-Generate.ps1
            "Generate notes content:" | Write-Verbose
            Get-Content -Path "$stdout" | Write-Host
        }
    }
}
