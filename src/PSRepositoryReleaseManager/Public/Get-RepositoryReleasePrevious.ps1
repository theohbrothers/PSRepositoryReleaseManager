function Get-RepositoryReleasePrevious {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path -Path $_ -PathType Container})]
        [string]$Path
        ,
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$Ref
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

        if ($PSBoundParameters['Ref']) {
            $refSHA = git rev-parse $PSBoundParameters['Ref']
            if ($LASTEXITCODE) {
                throw "An error occurred."
            }
            "Found SHA: $refSHA" | Write-Verbose
        }
        if (@($releaseTagsInfo).Count -eq 1) {
            throw "Only one release tag exists in the repository '$($PSBoundParameters['Path'])'."
        }

        $releasePreviousCommitSHA = if ($PSBoundParameters['Ref']) {
            "Searching for the previous release relative from the ref '$($PSBoundParameters['Ref'])'" | Write-Verbose
            $cnt = 0;
            foreach ($r in $releaseTagsInfo) {
                if ($r -match "^$refSHA\s+") {
                    break
                }
                $cnt++
            }
            if (@($releaseTagsInfo).Count -eq ($cnt+1)) {
                throw "No previous release exists relative from the ref '$($PSBoundParameters['Ref'])'"
            }
            ($releaseTagsInfo[$cnt+1] -split "\s")[0]
        }else {
            ($releaseTagsInfo[1] -split "\s")[0]
        }
        "Previous release commit SHA: $releasePreviousCommitSHA" | Write-Verbose
        "Retrieving previous release tag(s)" | Write-Verbose
        git tag --points-at $releasePreviousCommitSHA | Sort-Object -Descending     # Returns an array of tags if they point to the same commit
    }catch {
        throw
    }finally {
        Pop-Location
    }
}
