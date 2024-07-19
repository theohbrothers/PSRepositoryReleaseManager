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
        ,
        [Parameter(Mandatory=$false)]
        [ValidateSet(
            "SemVer",
            "All"
        )]
        [string]$TagType
    )

    try {
        Push-Location $Path
        "Ref: $Ref" | Write-Verbose
        "TagType: $TagType" | Write-Verbose
        if (!$Ref) {
            "Using default ref 'HEAD'" | Write-Verbose
            $Ref = 'HEAD'
        }
        if (!$TagType) {
            "Using default tag type 'All'" | Write-Verbose
            $TagType = 'All'
        }
        # Validate specified ref is an existing ref
        "Validating ref '$Ref'" | Write-Verbose
        $commitSHA = git rev-parse "$Ref"
        $commitSHA | Write-Verbose
        if ($LASTEXITCODE) {
            throw "An error occurred."
        }
        $isRefTagged = if (git tag --points-at "$Ref") {
                           "Ref '$Ref' is a tagged commit." | Write-Verbose
                           $true
                       }else {
                           "Ref '$Ref' is not a tagged commit." | Write-Verbose
                           $false
                       }
        # Retrieve previous release tags of the specified ref within the same git tree
        if ($TagType -eq 'SemVer') {
            $tagPattern = 'v\d+\.\d+\.\d+'
        }elseif ($TagType -eq 'All') {
            $tagPattern = '.+?'
        }
        $tagsPreviousInfo = (git --no-pager log "$Ref" --date-order --pretty='format:%H %D') -split "`n" | % {
            if ($_ -match "\s+tag:\s+($tagPattern)(,\s+|$)") {
                $_
            }
        }
        if ($tagsPreviousInfo) {
            "Previous release tags info:" | Write-Verbose
            $tagsPreviousInfo | Write-Verbose
        }
        if (!$tagsPreviousInfo -Or ($isRefTagged -And @($tagsPreviousInfo).Count -eq 1)) {
            "No previous release tag(s) for the specified parameters can be found." | Write-Verbose
            return
        }
        $tagPreviousCommitSHA = if ($isRefTagged -And ($tagsPreviousInfo[0] | Select-String -Pattern $commitSHA)) {
                                    (@($tagsPreviousInfo)[1] -split "\s")[0]
                                }else {
                                    (@($tagsPreviousInfo)[0] -split "\s")[0]
                                }
        "Previous release commit SHA: $tagPreviousCommitSHA" | Write-Verbose
        $tagsPrevious = git tag --points-at "$tagPreviousCommitSHA" | Sort-Object -Descending | ? { $_ -match $tagPattern } # Returns an array of tags if they point to the same commit
        "Previous release tag(s):" | Write-Verbose
        $tagsPrevious | Write-Verbose
        $tagsPrevious
    }catch {
        Write-Error -Exception $_.Exception -Message $_.Exception.Message -Category $_.CategoryInfo.Category -TargetObject $_.TargetObject
    }finally {
        Pop-Location
    }
}
