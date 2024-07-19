function Get-RepositoryReleaseLatest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path -Path $_ -PathType Container})]
        [string]$Path
        ,
        [Parameter(Mandatory=$false)]
        [ValidateSet(
            "SemVer",
            "All"
        )]
        [string]$TagType
        ,
        [Parameter(Mandatory=$false)]
        [switch]$AllBranches
    )

    try {
        Push-Location $Path
        "TagType: $TagType" | Write-Verbose
        "AllBranches: $AllBranches" | Write-Verbose
        if (!$TagType) {
            "Using default tag type 'All'" | Write-Verbose
            $TagType = 'All'
        }
        $gitArgs = @(
            if ($AllBranches) { '--all' }
        )
        if ($TagType -eq 'SemVer') {
            $tagPattern = 'v\d+\.\d+\.\d+'
        }elseif ($TagType -eq 'All') {
            $tagPattern = '.+?'
        }
        $tagsLatestInfo = (git --no-pager log --date-order --simplify-by-decoration --pretty='format:%H %D' @gitArgs) -split "`n" | % {
            if ($_ -match "\s+tag:\s+($tagPattern)(,\s+|$)") {
                $_
            }
        }
        if (!$tagsLatestInfo) {
            "No latest release tag(s) for the specified parameters can be found." | Write-Verbose
            return
        }
        "Latest release tags info:" | Write-Verbose
        $tagsLatestInfo | Write-Verbose
        $tagsLatestCommitSHA = (@($tagsLatestInfo)[0] -split "\s")[0]
        "Latest release commit SHA: $tagsLatestCommitSHA" | Write-Verbose
        $tagsLatest = git tag --points-at $tagsLatestCommitSHA | Sort-Object -Descending | ? { $_ -match $tagPattern } # Returns an array of tags if they point to the same commit
        "Latest release tag(s):" | Write-Verbose
        $tagsLatest | Write-Verbose
        $tagsLatest
    }catch {
        Write-Error -Exception $_.Exception -Message $_.Exception.Message -Category $_.CategoryInfo.Category -TargetObject $_.TargetObject
    }finally {
        Pop-Location
    }
}
