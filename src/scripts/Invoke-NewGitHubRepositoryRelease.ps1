######################################################################################################################################
# This script is designed for use in development environments for executing the same release steps that will run in CI environments. #
# You can use the provided switches to test generation and creation of releases in your development environment.                     #
######################################################################################################################################

$private:Path = '/path/to/mylocalrepository'
$private:tagName = 'v0.0.0'

$private:releaseArgs = @{
    Namespace = 'myusername'
    Repository = 'myrepository'
    ApiKey = 'myapikey'
    TagName = $private:tagName
    TargetCommitish = git --git-dir "$private:Path\.git" rev-parse $private:tagName
    Name = $private:tagName
    Body = Get-Content "/path/to/myreleasenotes.md" -Raw
    Draft = $false
    Prerelease = $false
}
$VerbosePreference = 'Continue'

################################################

function Invoke-NewGitHubRepositoryRelease {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Namespace
        ,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Repository
        ,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$ApiKey
        ,
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$TagName
        ,
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$TargetCommitish
        ,
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$Name
        ,
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$Body
        ,
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [bool]$Draft
        ,
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [bool]$Prerelease
    )

    try {
        # Create GitHub release
        $response = New-GitHubRepositoryRelease @PSBoundParameters
        $response

    }catch {
        throw
    }
}

try {
    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'

    # Import modules
    Push-Location $PSScriptRoot
    Import-Module "$(git rev-parse --show-toplevel)\lib\PSGitHubRestApi\src\PSGitHubRestApi\PSGitHubRestApi.psm1" -Force -Verbose

    Invoke-NewGitHubRepositoryRelease @releaseArgs

}catch {
    throw
}finally {
    Pop-Location
}
