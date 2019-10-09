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
        if ($previousRelease) {
            "Previous release:" | Write-Verbose
            $previousRelease | Write-Verbose
        }
        $funcArgs = @{
            Path = $PSBoundParameters['Path']
            FirstRef = if ($previousRelease) { @($previousRelease)[0] } else { $PSBoundParameters['TagName'] }
        }
        if ($previousRelease) { $funcArgs['SecondRef'] = $PSBoundParameters['TagName'] }
        $commitHistory = Get-RepositoryCommitHistory @funcArgs -Verbose
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
