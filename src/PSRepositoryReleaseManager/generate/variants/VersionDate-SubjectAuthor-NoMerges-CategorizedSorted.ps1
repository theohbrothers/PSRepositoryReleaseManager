function VersionDate-SubjectAuthor-NoMerges-CategorizedSorted {
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
            PrettyFormat = '%s - `%aN`'
            NoMerges = $true
        }
        if ($previousRelease) { $funcArgs['SecondRef'] = @($previousRelease)[0] }
        $commitHistory = Get-RepositoryCommitHistory @funcArgs
        $commitHistoryCollection = $commitHistory -split "`n" | % { $_.Trim() } | ? { $_ }
        $commitHistoryCategory = @(
            @{
                Name = 'Breaking'
                Title = 'Breaking'
            }
            @{
                Name = 'Feature'
                Title = 'Features'
            }
            @{
                Name = 'Enhancement'
                Title = 'Enhancements'
            }
            @{
                Name = 'Change'
                Title = 'Change'
            }
            @{
                Name = 'Refactor'
                Title = 'Refactors'
            }
            @{
                Name = 'CI'
                Title = 'CI'
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
                Name = 'Style'
                Title = 'Style'
            }
            @{
                Name = 'Docs'
                Title = 'Documentation'
            }
            @{
                Name = 'Chore'
                Title = 'Chore'
            }
        )
        $commitHistoryCategoryNone = @{
            Title = 'Others'
        }
        $commitHistoryCategorizedCollection = New-Object System.Collections.ArrayList
        $commitHistoryUncategorizedCollection = New-Object System.Collections.ArrayList
        $commitHistoryCollection | % {
            if ($_ -match "^(\s*\w+\s*)(\(\s*[a-zA-Z0-9_\-\/]+\s*\)\s*)*:(.+)") {
                $commitHistoryCategorizedCollection.Add($_) > $null
            }else {
                $commitHistoryUncategorizedCollection.Add($_) > $null
            }
        }
        $commitHistoryCategorizedCustomCollection = $commitHistoryCategorizedCollection | % {
            $matchInfo = $_ | Select-String -Pattern "^(.+) (- `.+`)$"
            if ($matchInfo) {
                [PSCustomObject]@{
                    Subject = $matchInfo.Matches.Groups[1].Value
                    Author = $matchInfo.Matches.Groups[2].Value
                }
            }
        }
        $commitHistoryUncategorizedCustomCollection = $commitHistoryUncategorizedCollection | % {
            $matchInfo = $_ | Select-String -Pattern "^(.+) (- `.+`)$"
            if ($matchInfo) {
                [PSCustomObject]@{
                    Subject = $matchInfo.Matches.Groups[1].Value
                    Author = $matchInfo.Matches.Groups[2].Value
                }
            }
        }
        $releaseBody = & {
@"
## $TagName ($(Get-Date -UFormat '%Y-%m-%d'))
"@
            foreach ($c in $commitHistoryCategory) {
                $iscommitHistoryCategoryTitleOutputted = $false
                $commitHistoryCategorizedCustomCollection | Sort-Object -Property Subject | % {
                    if ("$($_.Subject) $($_.Author)" -match "^(\s*$($c['Name'])\s*)(\(\s*[a-zA-Z0-9_\-\/]+\s*\)\s*)*:(.+)") {
                        if (!$iscommitHistoryCategoryTitleOutputted) {
@"

### $($c['Title'])

"@
                            $iscommitHistoryCategoryTitleOutputted = $true
                        }
@"
* $($_.Subject) $($_.Author)
"@
                    }
                }
            }
            if ($commitHistoryUncategorizedCustomCollection) {
@"

### $($commitHistoryCategoryNone['Title'])

"@
                $commitHistoryUncategorizedCustomCollection | Sort-Object -Property Subject | % {
@"
* $($_.Subject) $($_.Author)
"@
                }
            }
        }
        $releaseBody
    }catch {
        Write-Error -Exception $_.Exception -Message $_.Exception.Message -Category $_.CategoryInfo.Category -TargetObject $_.TargetObject
    }
}
