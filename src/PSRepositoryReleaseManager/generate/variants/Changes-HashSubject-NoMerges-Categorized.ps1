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
        $releaseBody = & {
@"
## Changes
"@
            foreach ($c in $commitHistoryCategory) {
                $iscommitHistoryCategoryTitleOutputted = $false
                $commitHistoryCollection | % {
                    if ($_ -match "^[0-9a-f]+ (\s*$($c['Name'])\s*)(\(\s*[a-zA-Z0-9_-]+\s*\)\s*)*:(.+)") {
                        if (!$iscommitHistoryCategoryTitleOutputted) {
@"

### $($c['Title'])

"@
                            $iscommitHistoryCategoryTitleOutputted = $true
                        }
@"
* $_
"@
                    }
                }
            }
            if ($commitHistoryUncategorizedCollection) {
@"

### Others

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
