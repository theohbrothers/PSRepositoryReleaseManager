function Get-RepositoryPreviousRelease {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path -Path $_ -PathType Container})]
        [string]$Path
    )
    $_path = Get-Item -Path $PSBoundParameters['Path']
    Push-Location $_path
    $ErrorActionPreference = 'Stop'

    try {
        "Searching for the previous release in the repository '$_path'" | Write-Verbose
        $releaseTagsInfo = (git --no-pager log --tags --simplify-by-decoration --pretty="format:%H %D") -split "`n" | % {
            if ($_ -match '\s+tag:\s+(v\d+\.\d+\.\d+)(,|$)') {
                $_
            }
        }
        if (!$releaseTagsInfo) {
            throw "No release tags could be found in the repository '$_path'."
        }
        "Release tags info:" | Write-Verbose
        $releaseTagsInfo | Write-Verbose
        if ($releaseTagsInfo.Count -eq 1) {
            "Only one release tag is found. There are no previous releases." | Write-Verbose
        }else {
            $releasePreviousCommitSHA = ($releaseTagsInfo[1] -split "\s")[0]
            "Previous release commit SHA: $releasePreviousCommitSHA" | Write-Verbose
            git tag --points-at $releasePreviousCommitSHA | Sort-Object -Descending
        }
    }catch {
        throw
    }finally {
        Pop-Location
    }
}
