function Get-RepositoryReleaseLatest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path -Path $_ -PathType Container})]
        [string]$Path
    )
    $ErrorActionPreference = 'Stop'
    
    try {
        Push-Location $PSBoundParameters['Path']
        "Searching for the latest release in the repository '$($PSBoundParameters['Path'])'" | Write-Verbose
        $releaseTagsInfo = (git --no-pager log --date-order --tags --simplify-by-decoration --pretty="format:%H %D") -split "`n" | % {
            if ($_ -match '\s+tag:\s+(v\d+\.\d+\.\d+)(,|$)') {
                $_
            }
        }
        if (!$releaseTagsInfo) {
            throw "No release tags could be found in the repository '$($PSBoundParameters['Path'])'."
        }
        "Release tags info:" | Write-Verbose
        $releaseTagsInfo | Write-Verbose
        $releaseLatestCommitSHA = ($releaseTagsInfo[0] -split "\s")[0]
        git tag --points-at $releaseLatestCommitSHA | Sort-Object -Descending       # Returns an array of tags if they point to the same commit
    }catch {
        throw
    }finally {
        Pop-Location
    }
}
