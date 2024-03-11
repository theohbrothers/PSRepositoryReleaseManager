function VersionDate-HashSubject-NoMerges {
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
        $previousRelease = Get-RepositoryReleasePrevious -Path $Path -Ref $TagName -ErrorAction SilentlyContinue
        if ($previousRelease) {
            "Previous release:" | Write-Verbose
            $previousRelease | Write-Verbose
        }
        $funcArgs = @{
            Path = $Path
            FirstRef = if ($previousRelease) { @($previousRelease)[0] } else { $TagName }
            PrettyFormat = '%h %s'
            NoMerges = $true
        }
        if ($previousRelease) { $funcArgs['SecondRef'] = $TagName }
        $commitHistory = Get-RepositoryCommitHistory @funcArgs
        $releaseBody = & {
@"
## $TagName ($(Get-Date -UFormat '%Y-%m-%d'))

"@
$commitHistory -split "`n" | % { $_.Trim() } | ? { $_ } | % {
@"
* $_
"@
}
        }
        $releaseBody
    }catch {
        Write-Error -Exception $_.Exception -Message $_.Exception.Message -Category $_.CategoryInfo.Category -TargetObject $_.TargetObject
    }
}
