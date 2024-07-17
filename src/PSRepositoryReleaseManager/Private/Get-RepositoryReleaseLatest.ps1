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
        [string]$TagType = 'All'
        ,
        [Parameter(Mandatory=$false)]
        [switch]$AllBranches
    )

    try {
        Push-Location $Path
        "TagType: $TagType" | Write-Verbose
        "AllBranches: $AllBranches" | Write-Verbose
        $gitArgs = @(
            '--no-pager'
            'log'
            '--date-order'
            '--simplify-by-decoration'
            '--pretty="format:%H %D"'
            if ($AllBranches) { '--all' }
        )
        if ($TagType -eq 'SemVer') {
            $tagsPattern = '\s+tag:\s+(v\d+\.\d+\.\d+)(,\s+|$)'
        }elseif ($TagType -eq 'All') {
            $tagsPattern = '\s+tag:\s+(.+?)(,\s+|$)'
        }
        "Retrieving info on release tags" | Write-Verbose
        $tagsLatestInfo = (git $gitArgs) -split "`n" | % {
            if ($_ -match $tagsPattern) {
                $_
            }
        }
        if (!$tagsLatestInfo) {
            "No release tags exist in the repository '$($Path)'." | Write-Verbose
            return
        }
        "Latest release tags info:" | Write-Verbose
        $tagsLatestInfo | Write-Verbose
        $tagsLatestCommitSHA = (@($tagsLatestInfo)[0] -split "\s")[0]
        "Latest release commit SHA: $tagsLatestCommitSHA" | Write-Verbose
        $tagsLatest = git tag --points-at $tagsLatestCommitSHA | Sort-Object -Descending # Returns an array of tags if they point to the same commit
        "Latest release tag(s):" | Write-Verbose
        $tagsLatest | Write-Verbose
        $tagsLatest
    }catch {
        Write-Error -Exception $_.Exception -Message $_.Exception.Message -Category $_.CategoryInfo.Category -TargetObject $_.TargetObject
    }finally {
        Pop-Location
    }
}
