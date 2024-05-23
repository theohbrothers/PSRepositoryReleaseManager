[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ErrorView = 'NormalView'
$VerbosePreference = 'Continue'

try {
    Push-Location $PSScriptRoot
    Import-Module "$(git rev-parse --show-toplevel)\lib\PSGitHubRestApi\src\PSGitHubRestApi\PSGitHubRestApi.psm1" -Force
    Import-Module "$(git rev-parse --show-toplevel)\src\PSRepositoryReleaseManager\PSRepositoryReleaseManager.psm1" -Force

    # Create GitHub release
    if ($env:PROJECT_DIRECTORY) {
        $private:ProjectDir = $env:PROJECT_DIRECTORY
    }else {
        $private:superProjectDir = git rev-parse --show-superproject-working-tree
        if ($private:superProjectDir) {
            $private:ProjectDir = $private:superProjectDir
            "Using superproject path '$private:ProjectDir'" | Write-Verbose
        }else {
            throw "`$env:PROJECT_DIRECTORY is undefined or superproject directory cannot be determined." | Write-Verbose
        }
    }
    $private:createReleaseArgs = @{
        Namespace = $env:RELEASE_NAMESPACE
        Repository = $env:RELEASE_REPOSITORY
        ApiKey = $env:GITHUB_API_TOKEN
        TagName = $env:RELEASE_TAG_REF
        TargetCommitish = git --git-dir "$($private:ProjectDir)/.git" rev-parse $env:RELEASE_TAG_REF
        Name = if ($env:RELEASE_NAME) { $env:RELEASE_NAME } else { $env:RELEASE_TAG_REF }
    }
    if ($env:RELEASE_NOTES_PATH) {
        "Sourcing from specified release notes path '$env:RELEASE_NOTES_PATH'" | Write-Verbose
        $private:createReleaseArgs['ReleaseNotesPath'] = if ([System.IO.Path]::IsPathRooted($env:RELEASE_NOTES_PATH)) { $env:RELEASE_NOTES_PATH }
                                                         else { "$private:ProjectDir/$env:RELEASE_NOTES_PATH" }
    }elseif ($env:RELEASE_NOTES_CONTENT) {
        "Using specified release notes content" | Write-Verbose
        $private:createReleaseArgs['ReleaseNotesContent'] = $env:RELEASE_NOTES_CONTENT
    }else {
        $private:defaultReleaseNotesPath = "$(git rev-parse --show-toplevel)/.release-notes.md"
        if (Test-Path -Path $private:defaultReleaseNotesPath -PathType Leaf) {
            "Sourcing from the default release notes path '$private:defaultReleaseNotesPath'" | Write-Verbose
            $private:createReleaseArgs['ReleaseNotesPath'] = $private:defaultReleaseNotesPath
        }else {
            "Default release notes not found at the path '$private:defaultReleaseNotesPath'. No release notes will be included with the release." | Write-Verbose
        }
    }
    $private:createReleaseArgs['Draft'] = if ($env:RELEASE_DRAFT) { [System.Convert]::ToBoolean($env:RELEASE_DRAFT) } else { $false }
    $private:createReleaseArgs['Prerelease'] = if ($env:RELEASE_PRERELEASE) { [System.Convert]::ToBoolean($env:RELEASE_PRERELEASE) } else { $false }
    $response = Create-GitHubRelease @private:createReleaseArgs
    $responseContent = $response.Content | ConvertFrom-Json

    # Upload release assets
    if ($env:RELEASE_ASSETS) {
        try {
            $private:releaseAssetsArr = $env:RELEASE_ASSETS -Split "`n" | % { $_.Trim() } | ? { $_ }
            "Release assets (Specified):" | Write-Verbose
            $private:releaseAssetsArr | Out-String -Stream | % { $_.Trim() } | ? { $_ } | Write-Verbose
            Push-Location $private:ProjectDir
            $private:assets = $private:releaseAssetsArr | % { Resolve-Path -Path $_ }
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
            ApiKey = $env:GITHUB_API_TOKEN
        }
        Upload-GitHubReleaseAsset @private:uploadReleaseAssetsArgs
    }

}catch {
    throw
}finally {
    Pop-Location
}
