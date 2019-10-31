[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'
Set-StrictMode -Version Latest

try {
    Push-Location $PSScriptRoot
    . "$(git rev-parse --show-toplevel)/src/scripts/includes/Create-GitHubRelease.ps1"
    . "$(git rev-parse --show-toplevel)/src/scripts/includes/Upload-GitHubReleaseAsset.ps1"

    $private:superProjectDir = git rev-parse --show-superproject-working-tree
    if (!$private:superProjectDir) { throw "The superproject root directory cannot be determined." }
    $private:createReleaseArgs = @{
        Namespace = $env:RELEASE_NAMESPACE
        Repository = $env:RELEASE_REPOSITORY
        ApiKey = $env:GITHUB_API_TOKEN
        TagName = $env:RELEASE_TAG_REF
        TargetCommitish = git --git-dir "$($private:superProjectDir)/.git" rev-parse $env:RELEASE_TAG_REF
        Name = if ($env:RELEASE_NAME) { $env:RELEASE_NAME } else { $env:RELEASE_TAG_REF }
        Draft = if ($env:RELEASE_DRAFT) { [System.Convert]::ToBoolean($env:RELEASE_DRAFT) } else { $false }
        Prerelease = if ($env:RELEASE_PRERELEASE) { [System.Convert]::ToBoolean($env:RELEASE_PRERELEASE) } else { $false }
    }

    if ($env:RELEASE_NOTES_PATH) {
        "Sourcing from specified release notes path '$env:RELEASE_NOTES_PATH'" | Write-Verbose
        $private:createReleaseArgs['ReleaseNotesPath'] = "$private:superProjectDir/$env:RELEASE_NOTES_PATH"
    }elseif ($env:RELEASE_NOTES_CONTENT) {
        "Using specified release notes content" | Write-Verbose
        $private:createReleaseArgs['ReleaseNotesContent'] = $env:RELEASE_NOTES_CONTENT
    }else {
        $defaultReleaseNotesPath = "$(git rev-parse --show-toplevel)/.release-notes.md"
        if (Test-Path -Path $defaultReleaseNotesPath -PathType Leaf) {
            "Sourcing from the default release notes path '$defaultReleaseNotesPath'" | Write-Verbose
            $private:createReleaseArgs['ReleaseNotesPath'] = $defaultReleaseNotesPath
        }else {
            "Default release notes not found at the path '$defaultReleaseNotesPath'. No release notes will be included with the release." | Write-Verbose
        }
    }
    # Create GitHub release
    $response = Create-GitHubRelease @private:createReleaseArgs
    $responseContent = $response.Content | ConvertFrom-Json

    # Upload release assets
    if ($env:RELEASE_ASSETS) {
        try {
            $private:releaseAssetsArr = $env:RELEASE_ASSETS -Split "`n" | % { $_.Trim() } | ? { $_ }
            "Release assets (Specified):" | Write-Verbose
            $private:releaseAssetsArr | Out-String -Stream | % { $_.Trim() } | ? { $_ } | Write-Verbose
            Push-Location -Path $private:superProjectDir
            $private:assets = $private:releaseAssetsArr | % { Resolve-Path -Path $_ }
            if (!$private:assets) { throw "No assets of the specified release assets file pattern could be found." }
        }catch {
            throw
        }finally {
            Pop-Location
        }
        "Release assets (Full):" | Write-Verbose
        $private:assets | Out-String -Stream | % { $_.Trim() } | ? { $_ } | Write-Verbose
        $private:uploadReleaseAssetsArgs = [Ordered]@{
            UploadUrl = $responseContent.upload_url
            Assets = $private:assets
            ApiKey = $env:GITHUB_API_TOKEN
        }
        Upload-GitHubReleaseAsset @private:uploadReleaseAssetsArgs
    }

}catch {
    throw
}finally {
    Pop-Location
}
