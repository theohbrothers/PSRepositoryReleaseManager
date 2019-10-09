[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [ValidateScript({Test-Path -Path $_ -PathType Container})]
    [string]$Path
    ,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$TagName
)

function Generate-RepositoryReleaseBody {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path -Path $_ -PathType Container})]
        [string]$Path
        ,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$TagName
    )

    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'

    try {
        $previousRelease = Get-RepositoryReleasePrevious -Path $PSBoundParameters['Path'] -Verbose
        "Previous release:" | Write-Verbose
        $previousRelease | Write-Verbose
        $commitHistory = Get-RepositoryCommitHistory -Path $PSBoundParameters['Path'] -FirstRef @($previousRelease)[0] -SecondRef $PSBoundParameters['TagName'] -Verbose
        $releaseBody = @"
## $TagName ($(Get-Date -UFormat '%Y-%m-%d'))

$commitHistory
"@
        $releaseBody
    }catch {
        throw
    }
}

Generate-RepositoryReleaseBody @PSBoundParameters
