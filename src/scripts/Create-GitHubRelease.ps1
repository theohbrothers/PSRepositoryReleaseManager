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
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$TagName
    ,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$ReleaseBody
)

Set-StrictMode -Version Latest

function Create-GitHubRelease {
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
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$TagName
        ,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$ReleaseBody
    )

    $ErrorActionPreference = 'Stop'

    try {
        $releaseArgs = @{
            Namespace = $PSBoundParameters['Namespace']
            Repository = $PSBoundParameters['Repository']
            ApiKey = $PSBoundParameters['ApiKey']
            TagName = $PSBoundParameters['TagName']
            TargetCommitish = git rev-parse $PSBoundParameters['TagName']
            Name = $PSBoundParameters['TagName']
            Body = $PSBoundParameters['ReleaseBody']
            Draft = $false
            Prerelease = $false
        }
        $releaseArgsMasked = $releaseArgs.Clone()
        $releaseArgsMasked['ApiKey'] = "token *******"
        ($releaseArgsMasked | Out-String).Trim() | Write-Verbose
        New-GitHubRepositoryRelease @releaseArgs
    }catch {
        throw
    }
}

Create-GitHubRelease @PSBoundParameters
