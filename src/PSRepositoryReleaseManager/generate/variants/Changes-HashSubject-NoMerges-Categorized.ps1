function Changes-HashSubject-NoMerges-Categorized {
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
        $funcArgs = @{
            Path = $Path
            FirstRef = $TagName
            PrettyFormat = '%h %s'
            NoMerges = $true
        }
        if ($previousRelease) { $funcArgs['SecondRef'] = @($previousRelease)[0] }
        $commitHistory = Get-RepositoryCommitHistory @funcArgs
        $commitHistoryCollection = $commitHistory -split "`n" | % { $_.Trim() } | ? { $_ }
        $commitHistoryCategory = @(
            @{
                Title = 'Breaking'
                Name = @(
                    'Breaking'
                    'breaking-change'
                )
            }
            @{
                Title = 'Features'
                Name = @(
                    'Feature'
                    'feat'
                )
            }
            @{
                Title = 'Enhancements'
                Name = @(
                    'Enhancement'
                )
            }
            @{
                Title = 'Performance'
                Name = @(
                    'Performance'
                    'perf'
                )
            }
            @{
                Title = 'Change'
                Name = @(
                    'Change'
                )
            }
            @{
                Title = 'Refactors'
                Name = @(
                    'Refactor'
                )
            }
            @{
                Title = 'Build'
                Name = @(
                    'Build'
                )
            }
            @{
                Title = 'CI'
                Name = @(
                    'CI'
                )
            }
            @{
                Title = 'Tests'
                Name = @(
                    'Test'
                )
            }
            @{
                Title = 'Fixes'
                Name = @(
                    'Fix'
                )
            }
            @{
                Title = 'Style'
                Name = @(
                    'Style'
                )
            }
            @{
                Title = 'Documentation'
                Name = @(
                    'Docs'
                )
            }
            @{
                Title = 'Chore'
                Name = @(
                    'Chore'
                )
            }
        )
        $commitHistoryCategoryNone = @{
            Title = 'Others'
        }
        $commitHistoryCategorizedCollection = New-Object System.Collections.ArrayList
        $commitHistoryUncategorizedCollection = New-Object System.Collections.ArrayList
        $commitHistoryCollection | % {
            if ($_ -match "^[0-9a-f]+ (\s*[a-zA-Z0-9_\-]+\s*)(\(\s*[a-zA-Z0-9_\-\/]+\s*\)\s*)*:(.+)") {
                $commitHistoryCategorizedCollection.Add($_) > $null
            }else {
                $commitHistoryUncategorizedCollection.Add($_) > $null
            }
        }
        $releaseBody = & {
@"
## Changes
"@
            foreach ($c in $commitHistoryCategory) {
                $iscommitHistoryCategoryTitleOutputted = $false
                $commitHistoryCollection | % {
                    foreach ($n in $c['Name']) {
                        if ($_ -match "^[0-9a-f]+ (\s*$n\s*)(\(\s*[a-zA-Z0-9_\-\/]+\s*\)\s*)*:(.+)") {
                            if (!$iscommitHistoryCategoryTitleOutputted) {
@"

### $($c['Title'])

"@
                                $iscommitHistoryCategoryTitleOutputted = $true
                            }
@"
* $_
"@
                            break
                        }
                    }
                }
            }
            if ($commitHistoryUncategorizedCollection) {
@"

### $($commitHistoryCategoryNone['Title'])

"@
                $commitHistoryUncategorizedCollection | % {
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
