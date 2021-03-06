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
        Push-Location $Path
        "Retrieving info on release tags" | Write-Verbose
        $releaseTagsInfo = (git --no-pager log --date-order --tags --simplify-by-decoration --pretty="format:%H %D") -split "`n" | % {
            if ($_ -match '\s+tag:\s+(v\d+\.\d+\.\d+)(,|$)') {
                $_
            }
        }
        if (!$releaseTagsInfo) {
            throw "No release tags exist in the repository '$($Path)'."
        }
        "Release tags info:" | Write-Verbose
        $releaseTagsInfo | Write-Verbose

        if ($Ref) {
            $refSHA = git rev-parse $Ref
            if ($LASTEXITCODE) {
                throw "An error occurred."
            }
            "Found SHA: $refSHA" | Write-Verbose
        }
        if (@($releaseTagsInfo).Count -eq 1) {
            throw "Only one release tag exists in the repository '$($Path)'."
        }

        $releasePreviousCommitSHA = if ($Ref) {
            "Searching for the previous release relative from the ref '$($Ref)'" | Write-Verbose
            $cnt = 0;
            foreach ($r in $releaseTagsInfo) {
                if ($r -match "^$refSHA\s+") {
                    break
                }
                $cnt++
            }
            if ($releaseTagsInfo.Count -eq $cnt) {
                throw "The specified ref '$($Ref)' is not a valid release."
            }
            if (@($releaseTagsInfo).Count -eq ($cnt+1)) {
                throw "No previous release exists relative from the ref '$($Ref)'"
            }
            ($releaseTagsInfo[$cnt+1] -split "\s")[0]
        }else {
            ($releaseTagsInfo[1] -split "\s")[0]
        }
        "Previous release commit SHA: $releasePreviousCommitSHA" | Write-Verbose
        "Retrieving previous release tag(s)" | Write-Verbose
        git tag --points-at $releasePreviousCommitSHA | Sort-Object -Descending     # Returns an array of tags if they point to the same commit
    }catch {
        Write-Error -Exception $_.Exception -Message $_.Exception.Message -Category $_.CategoryInfo.Category -TargetObject $_.TargetObject
    }finally {
        Pop-Location
    }
}
