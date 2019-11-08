[CmdletBinding()]
param()

################################################

$private:path = '/path/to/mylocalrepository'
$private:tagName = 'v0.0.0'
$private:myReleaseArgs = @{
    Namespace = 'myusername'
    Repository = 'myrepository'
    ApiKey = 'myapikey'
    TagName = $private:tagName
    TargetCommitish = git --git-dir "$private:path/.git" rev-parse $private:tagName
    Name = $private:tagName
    ReleaseNotesPath = "$private:path/.release-notes.md"
    # ReleaseNotesContent = Get-Content "$private:path/.release-notes.md" -Raw
    Draft = $false
    Prerelease = $false
    Assets = @(
        # "$private:path/path/to/asset1.tar.gz"
        # "$private:path/path/to/asset2.gz"
        # "$private:path/path/to/asset3.zip"
        # "$private:path/path/to/assets/*.gz"
        # "$private:path/path/to/assets/*.zip"
    )
}

################################################

$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'
Set-StrictMode -Version Latest

try {
    Push-Location $PSScriptRoot
    Import-Module "$(git rev-parse --show-toplevel)\lib\PSGitHubRestApi\src\PSGitHubRestApi\PSGitHubRestApi.psm1" -Force -Verbose
    Import-Module "$(git rev-parse --show-toplevel)\src\PSRepositoryReleaseManager\PSRepositoryReleaseManager.psm1" -Force -Verbose

    # Create GitHub release
    $private:createReleaseArgs = @{
        Namespace = $private:myReleaseArgs['Namespace']
        Repository = $private:myReleaseArgs['Repository']
        ApiKey = $private:myReleaseArgs['ApiKey']
        TagName = $private:myReleaseArgs['TagName']
        TargetCommitish = $private:myReleaseArgs['TargetCommitish']
        Name = $private:myReleaseArgs['Name']
        Draft = $private:myReleaseArgs['Draft']
        Prerelease = $private:myReleaseArgs['Prerelease']
    }
    if ($private:myReleaseArgs['ReleaseNotesPath']) {
        "Sourcing from specified release notes path '$($private:myReleaseArgs['ReleaseNotesPath'])'" | Write-Verbose
        $private:createReleaseArgs['ReleaseNotesPath'] = if ([System.IO.Path]::IsPathRooted($private:myReleaseArgs['ReleaseNotesPath'])) { $private:myReleaseArgs['ReleaseNotesPath'] }
                                                         else { $private:myReleaseArgs['ReleaseNotesPath'] }
    }elseif ($private:myReleaseArgs['ReleaseNotesPath']) {
        "Using specified release notes content" | Write-Verbose
        $private:createReleaseArgs['ReleaseNotesContent'] = $private:myReleaseArgs['ReleaseNotesPath']
    }else {
        $private:defaultReleaseNotesPath = "$(git rev-parse --show-toplevel)/.release-notes.md"
        if (Test-Path -Path $private:defaultReleaseNotesPath -PathType Leaf) {
            "Sourcing from the default release notes path '$private:defaultReleaseNotesPath'" | Write-Verbose
            $private:createReleaseArgs['ReleaseNotesPath'] = $private:defaultReleaseNotesPath
        }else {
            "Default release notes not found at the path '$private:defaultReleaseNotesPath'. No release notes will be included with the release." | Write-Verbose
        }
    }
    $response = Create-GitHubRelease @private:createReleaseArgs
    $responseContent = $response.Content | ConvertFrom-Json

    # Upload release assets
    if ($private:myReleaseArgs['Assets']) {
        try {
            "Release assets (Specified):" | Write-Verbose
            $private:myReleaseArgs['Assets'] | Out-String -Stream | % { $_.Trim() } | ? { $_ } | Write-Verbose
            Push-Location $private:path
            $private:assets = $private:myReleaseArgs['Assets'] | % { Resolve-Path -Path $_ }
            if (!$private:assets) { throw "No assets of the specified release assets file pattern could be found." }
        }catch {
            throw
        }finally {
            Pop-Location
        }
        "Release assets (Full):" | Write-Verbose
        $private:assets | Out-String -Stream | % { $_.Trim() } | ? { $_ } | Write-Verbose
        $private:uploadReleaseAssetsArgs = @{
            UploadUrl = $responseContent.upload_url
            Asset = $private:assets
            ApiKey = $private:myReleaseArgs['ApiKey']
        }
        Upload-GitHubReleaseAsset @private:uploadReleaseAssetsArgs
    }

}catch {
    throw
}finally {
    Pop-Location
}
