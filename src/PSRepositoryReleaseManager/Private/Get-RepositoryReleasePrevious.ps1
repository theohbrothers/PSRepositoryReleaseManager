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
        $isRefTag = $false
        if ($Ref) {
            # Validate specified ref is an existing ref
            "Validating ref '$Ref'" | Write-Verbose
            git rev-parse "$Ref" | Write-Verbose
            if ($LASTEXITCODE) {
                throw "An error occurred."
            }
            "Verifying if ref '$Ref' is a tag" | Write-Verbose
            git show-ref --verify "refs/tags/$Ref" 2> $null | Write-Verbose
            if (!$LASTEXITCODE) {
                $isRefTag = $true
            }
        }
        # Retrieve previous release tags of the specified ref within the same git tree
        "Retrieving info on previous release tags" | Write-Verbose
        $tagsPreviousInfo = (git --no-pager log "$Ref" --date-order --simplify-by-decoration --pretty="format:%H %D") -split "`n" | % {
            if ($_ -match '\s+tag:\s+(v\d+\.\d+\.\d+)(,\s+|$)') {
                $_
            }
        }
        "Previous release tags info:" | Write-Verbose
        $tagsPreviousInfo | Write-Verbose
        if ($isRefTag -And @($tagsPreviousInfo).Count -eq 1) {
            "No previous tags for ref '$Ref' exists in the repository '$($Path)'." | Write-Verbose
            return
        }
        $tagPreviousCommitSHA = if ($isRefTag) { # If specified ref is a tag, the previous tag is on the following line
                                    (@($tagsPreviousInfo)[1] -split "\s")[0]
                                }else {
                                    (@($tagsPreviousInfo)[0] -split "\s")[0]
                                }
        "Previous release commit SHA: $tagPreviousCommitSHA" | Write-Verbose
        $tagsPrevious = git tag --points-at "$tagPreviousCommitSHA" | Sort-Object -Descending # Returns an array of tags if they point to the same commit
        "Previous release tag(s):" | Write-Verbose
        $tagsPrevious | Write-Verbose
        $tagsPrevious
    }catch {
        Write-Error -Exception $_.Exception -Message $_.Exception.Message -Category $_.CategoryInfo.Category -TargetObject $_.TargetObject
    }finally {
        Pop-Location
    }
}
