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

    $ErrorActionPreference = 'Stop'

    try {
        $previousRelease = Get-RepositoryReleasePrevious -Path $PSBoundParameters['Path'] -Ref $TagName
        if ($previousRelease) {
            "Previous release:" | Write-Verbose
            $previousRelease | Write-Verbose
        }
        $funcArgs = @{
            Path = $PSBoundParameters['Path']
            FirstRef = if ($previousRelease) { @($previousRelease)[0] } else { $PSBoundParameters['TagName'] }
        }
        if ($previousRelease) { $funcArgs['SecondRef'] = $PSBoundParameters['TagName'] }
        $commitHistory = Get-RepositoryCommitHistory @funcArgs
        $commitHistoryWithAsterisks = $commitHistory -split "`n" | ? { $_ } | % { "* $_" } | Out-String
        $releaseBody = @"
## $TagName ($(Get-Date -UFormat '%Y-%m-%d'))

$commitHistoryWithAsterisks
"@
        $releaseBody
    }catch {
        throw
    }
}

Generate-RepositoryReleaseBody @PSBoundParameters
