function Get-RepositoryReleaseLatest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path -Path $_ -PathType Container})]
        [string]$Path
    )

    try {
        Push-Location $PSBoundParameters['Path']
        "Retrieving info on release tags" | Write-Verbose
        $releaseTagsInfo = (git --no-pager log --date-order --tags --simplify-by-decoration --pretty="format:%H %D") -split "`n" | % {
            if ($_ -match '\s+tag:\s+(v\d+\.\d+\.\d+)(,|$)') {
                $_
            }
        }
        if (!$releaseTagsInfo) {
            throw "No release tags exist in the repository '$($PSBoundParameters['Path'])'."
        }
        "Release tags info:" | Write-Verbose
        $releaseTagsInfo | Write-Verbose
        "Retrieving latest release tag(s)" | Write-Verbose
        $releaseLatestCommitSHA = ($releaseTagsInfo[0] -split "\s")[0]
        git tag --points-at $releaseLatestCommitSHA | Sort-Object -Descending       # Returns an array of tags if they point to the same commit
    }catch {
        Write-Error -Exception $_.Exception -Message $_.Exception.Message -Category $_.CategoryInfo.Category -TargetObject $_.TargetObject
    }finally {
        Pop-Location
    }
}
