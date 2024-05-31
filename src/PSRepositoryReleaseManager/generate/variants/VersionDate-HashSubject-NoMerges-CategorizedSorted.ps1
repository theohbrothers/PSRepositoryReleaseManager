function VersionDate-HashSubject-NoMerges-CategorizedSorted {
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
            PrettyFormat = '%h %s'
            NoMerges = $true
        }
        if ($previousRelease) { $funcArgs['SecondRef'] = @($previousRelease)[0] }
        $commitHistory = Get-RepositoryCommitHistory @funcArgs
        $commitHistoryCollection = $commitHistory -split "`n" | % { $_.Trim() } | ? { $_ }
        $commitHistoryCategory = @(
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
                Title = 'Maintenance'
            }
        )
        $commitHistoryCategorizedCollection = New-Object System.Collections.ArrayList
        $commitHistoryUncategorizedCollection = New-Object System.Collections.ArrayList
        $commitHistoryCollection | % {
            if ($_ -match "^[0-9a-f]+ (\s*\w+\s*)(\(\s*[a-zA-Z0-9_-]+\s*\)\s*)*:(.+)") {
                $commitHistoryCategorizedCollection.Add($_) > $null
            }else {
                $commitHistoryUncategorizedCollection.Add($_) > $null
            }
        }
        $commitHistoryCategorizedCustomCollection = $commitHistoryCategorizedCollection | % {
            $matchInfo = $_ | Select-String -Pattern "(^[0-9a-f]+) (.+)"
            if ($matchInfo) {
                [PSCustomObject]@{
                    Ref = $matchInfo.Matches.Groups[1].Value
                    Subject = $matchInfo.Matches.Groups[2].Value
                }
            }
        }
        $commitHistoryUncategorizedCustomCollection = $commitHistoryUncategorizedCollection | % {
            $matchInfo = $_ | Select-String -Pattern "(^[0-9a-f]+) (.+)"
            if ($matchInfo) {
                [PSCustomObject]@{
                    Ref = $matchInfo.Matches.Groups[1].Value
                    Subject = $matchInfo.Matches.Groups[2].Value
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
                    if ("$($_.Ref) $($_.Subject)" -match "^[0-9a-f]+ (\s*$($c['Name'])\s*)(\(\s*[a-zA-Z0-9_-]+\s*\)\s*)*:(.+)") {
                        if (!$iscommitHistoryCategoryTitleOutputted) {
@"

### $($c['Title'])

"@
                            $iscommitHistoryCategoryTitleOutputted = $true
                        }
@"
* $($_.Ref) $($_.Subject)
"@
                    }
                }
            }
            if ($commitHistoryUncategorizedCustomCollection) {
@"

### Others

"@
                $commitHistoryUncategorizedCustomCollection | Sort-Object -Property Subject | % {
@"
* $($_.Ref) $($_.Subject)
"@
                }
            }
        }
        $releaseBody
    }catch {
        Write-Error -Exception $_.Exception -Message $_.Exception.Message -Category $_.CategoryInfo.Category -TargetObject $_.TargetObject
    }
}
