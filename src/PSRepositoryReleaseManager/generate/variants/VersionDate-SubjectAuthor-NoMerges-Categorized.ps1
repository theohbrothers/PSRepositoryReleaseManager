function VersionDate-SubjectAuthor-NoMerges-Categorized {
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
            FirstRef = $TagName
            PrettyFormat = '%s - `%aN`'
            NoMerges = $true
        }
        if ($previousRelease) { $funcArgs['SecondRef'] = @($previousRelease)[0] }
        $commitHistory = Get-RepositoryCommitHistory @funcArgs
        $commitHistoryTrimmed = $commitHistory -split "`n" | % { $_.Trim() } | ? { $_ }
        $commitCategory = @(
            @{
                Name = 'Feature'
                Title = 'Features'
            }
            @{
                Name = 'Enhancement'
                Title = 'Enhancements'
            }
            @{
                Name = 'Refactor'
                Title = 'Refactors'
            }
            @{
                Name = 'Test'
                Title = 'Tests'
            }
            @{
                Name = 'Fix'
                Title = 'Fixes'
            }
            @{
                Name = 'Docs'
                Title = 'Documentation'
            }
            @{
                Name = 'Chore'
                Title = 'Chores'
            }
        )
        $commitHistoryUncategorized = $commitHistoryTrimmed | % {
            if (!($_ -match "^(\s*\w+\s*\(\s*[a-zA-Z0-9_-]+\s*\)\s*:)(.+)")) {
                $_
            }
        }
        $releaseBody = & {
@"
## $TagName ($(Get-Date -UFormat '%Y-%m-%d'))
"@
            foreach ($c in $commitCategory) {
                $isTitleOutputted = $false
                $commitHistoryTrimmed | % {
                    if ($_ -match "^(\s*$($c['Name'])\s*\(\s*[a-zA-Z0-9_-]+\s*\)\s*:)(.+)") {
                        if (!$isTitleOutputted) {
@"

### $($c['Title'])

"@
                            $isTitleOutputted = $true
                        }
@"
* $_
"@
                    }
                }
            }
            if ($commitHistoryUncategorized) {
@"

### Others

"@
                $commitHistoryUncategorized | % {
@"
* $_
"@
                }
            }
        }
        $releaseBody
    }catch {
        Write-Error -Exception $_.Exception -Message $_.Exception.Message -Category $_.CategoryInfo.Category -TargetObject $_.TargetObject
    }
}
