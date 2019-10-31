[CmdletBinding()]
param()

################################################

$private:Path = '/path/to/mylocalrepository'
$private:tagName = 'v0.0.0'
$private:releaseArgs = @{
    Namespace = 'myusername'
    Repository = 'myrepository'
    ApiKey = 'myapikey'
    TagName = $private:tagName
    TargetCommitish = git --git-dir "$private:Path/.git" rev-parse $private:tagName
    Name = $private:tagName
    ReleaseNotesPath = "$private:Path/.release-notes.md"
    # ReleaseNotesContent = Get-Content "$private:Path/.release-notes.md" -Raw
    Draft = $false
    Prerelease = $false
    Assets = @(
        # "/path/to/asset1"
        # "/path/to/asset2"
    )
}

################################################

$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'
Set-StrictMode -Version Latest

try {
    Push-Location $PSScriptRoot
    . "$(git rev-parse --show-toplevel)/src/scripts/includes/Create-GitHubRelease.ps1"

    $private:createReleaseArgs = @{
        Namespace = $private:releaseArgs['Namespace']
        Repository = $private:releaseArgs['Repository']
        ApiKey = $private:releaseArgs['ApiKey']
        TagName = $private:releaseArgs['TagName']
        TargetCommitish = $private:releaseArgs['TargetCommitish']
        Name = $private:releaseArgs['Name']
        Draft = $private:releaseArgs['Draft']
        Prerelease = $private:releaseArgs['Prerelease']
    }
    if ($PSBoundParameters['ReleaseNotesPath']) { $private:createReleaseArgs['ReleaseNotesPath'] = $PSBoundParameters['ReleaseNotesPath'] }
    if ($PSBoundParameters['ReleaseNotesContent']) { $private:createReleaseArgs['ReleaseNotesContent'] = $PSBoundParameters['ReleaseNotesContent'] }

    # Create GitHub release
    $response = Create-GitHubRelease @private:createReleaseArgs
    $responseContent = $response.Content | ConvertFrom-Json

    if ($private:releaseArgs['Assets']) {
        "Release assets:" | Write-Verbose
        $private:releaseArgs['Assets'] | Out-String -Stream | Write-Verbose
        $private:uploadReleaseAssetsArgs = [Ordered]@{
            UploadUrl = $responseContent.upload_url
            Assets = $private:releaseArgs['Assets']
            ApiKey = $env:GITHUB_API_TOKEN
        }
        Upload-GitHubReleaseAsset @private:uploadReleaseAssetsArgs
    }

}catch {
    throw
}finally {
    Pop-Location
}
