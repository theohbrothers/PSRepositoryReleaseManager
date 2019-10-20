###################################################################################################################################################
# This script is designed for use in development environments for executing the same generate and release steps that will run in CI environments. #
# You can use the provided switches to test generation and creation of releases in your development environment.                                  #
###################################################################################################################################################

$script:generateArgs = @{
    Path = '/path/to/mylocalrepository'
    TagName = 'v0.0.0'
    Variant = 'DateCommitHistory'
}
$script:releaseArgs = @{
    # Namespace = 'myusername'
    # Repository = 'myrepo'
    # ApiKey = ''
    # TagName = { $script:Tagname }
    # # TargetCommitish = { 'master' }
    # # Name = { $script:Tagname }
    # Body = { $script:releaseBody }
    # Draft = $true
    # Prerelease = $true
}
$VerbosePreference = 'Continue'

################################################

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Invoke-PSRepositoryReleaseManager {

    try {
        Push-Location $PSScriptRoot

        # Import modules
        Import-Module "$(git rev-parse --show-toplevel)\src\PSRepositoryReleaseManager\PSRepositoryReleaseManager.psm1" -Force -Verbose
        Import-Module "$(git rev-parse --show-toplevel)\lib\PSGitHubRestApi\src\PSGitHubRestApi\PSGitHubRestApi.psm1" -Force -Verbose

        # Run the generate entrypoint script
        $releaseBody = & "$(git rev-parse --show-toplevel)\src\scripts\Invoke-Generate.ps1" @script:generateArgs

        # Run the test release script
        if ($releaseArgs.Count -ne 0) {
            $response = & "$(git rev-parse --show-toplevel)\src\scripts\Invoke-Release.ps1" @script:releaseArgs
            $response
        }else {
            "Release args are empty. Not executing release." | Write-Warning
        }

    }catch {
        throw
    }finally {
        Pop-Location
    }
}

Invoke-PSRepositoryReleaseManager
