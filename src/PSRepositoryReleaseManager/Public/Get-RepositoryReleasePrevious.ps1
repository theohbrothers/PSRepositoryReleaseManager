function Get-RepositoryReleasePrevious {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path -Path $_ -PathType Container})]
        [string]$Path
    )
    Push-Location $PSBoundParameters['Path']
    $ErrorActionPreference = 'Stop'

    try {
        "Searching for the previous release in the repository '$($PSBoundParameters['Path'])'" | Write-Verbose
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
        if ($releaseTagsInfo.Count -eq 1) {
            "Only one release tag is found. There are no previous releases." | Write-Verbose
        }else {
            $releasePreviousCommitSHA = ($releaseTagsInfo[1] -split "\s")[0]
            "Previous release commit SHA: $releasePreviousCommitSHA" | Write-Verbose
            git tag --points-at $releasePreviousCommitSHA | Sort-Object -Descending     # Returns an array of tags if they point to the same commit
        }
    }catch {
        throw
    }finally {
        Pop-Location
    }
}
