[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$VerbosePreference = 'Continue'
$global:PesterDebugPreference_ShowFullErrors = $true

try {
    Push-Location $PSScriptRoot

    # Install test dependencies
    "Installing test dependencies" | Write-Verbose
    & "$PSScriptRoot\Install-TestDependencies.ps1" > $null

    # Run unit tests
    "Running unit tests" | Write-Verbose
    $testFailed = $false
    $unitResult = Invoke-Pester -Script "$PSScriptRoot\..\src\PSRepositoryReleaseManager" -Tag 'Unit' -PassThru
    if ($unitResult.FailedCount -gt 0) {
        "$($unitResult.FailedCount) tests failed." | Write-Warning
        $testFailed = $true
    }

    # Run integration tests
    "Running integration tests" | Write-Verbose
    $integratedResult = Invoke-Pester -Script "$PSScriptRoot\..\src\PSRepositoryReleaseManager" -Tag 'Integration' -PassThru
    if ($integratedResult.FailedCount -gt 0) {
        "$($integratedResult.FailedCount) tests failed." | Write-Warning
        $testFailed = $true
    }

    "Listing test artifacts" | Write-Verbose
    git ls-files --others --exclude-standard

    "End of tests" | Write-Verbose
    if ($testFailed) {
        throw "One or more tests failed."
    }
}catch {
    throw
}finally {
    Pop-Location
}
