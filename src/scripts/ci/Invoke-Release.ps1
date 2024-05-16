[CmdletBinding(DefaultParameterSetName='Path')]
param(
    [Parameter(Mandatory=$false)]
    [ValidateScript({Test-Path -Path $_ -PathType Container})]
    [string]$ProjectDirectory
    ,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$Namespace
    ,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$Repository
    ,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$ApiKey
    ,
    [Parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [string]$TagName
    ,
    [Parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [string]$Name
    ,
    [Parameter(ParameterSetName='Path', Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [ValidateScript({Test-Path -Path $_ -PathType Leaf})]
    [string]$ReleaseNotesPath
    ,
    [Parameter(ParameterSetName='Content', Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [string]$ReleaseNotesContent
    ,
    [Parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [bool]$Draft
    ,
    [Parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [bool]$Prerelease
    ,
    [Parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [string]$Asset
)

$ErrorActionPreference = 'Stop'
$ErrorView = 'NormalView'
$VerbosePreference = 'Continue'
Set-StrictMode -Version Latest

try {
    Push-Location $PSScriptRoot
    Import-Module "$(git rev-parse --show-toplevel)\lib\PSGitHubRestApi\src\PSGitHubRestApi\PSGitHubRestApi.psm1" -Force -Verbose
    Import-Module "$(git rev-parse --show-toplevel)\src\PSRepositoryReleaseManager\PSRepositoryReleaseManager.psm1" -Force -Verbose

    # Create GitHub release
    if ($private:ProjectDirectory) {
        $private:ProjectDir = $private:ProjectDirectory
    }else {
        $private:superProjectDir = git rev-parse --show-superproject-working-tree
        if ($private:superProjectDir) {
            $private:ProjectDir = $private:superProjectDir
            "Using superproject path '$private:ProjectDir'" | Write-Verbose
        }else {
            $private:ProjectDir = git rev-parse --show-toplevel
            "Superproject does not exist. Using project path '$private:ProjectDir'" | Write-Verbose
        }
    }
    $private:createReleaseArgs = @{
        Namespace = $Namespace
        Repository = $Repository
        ApiKey = $ApiKey
        TagName = $TagName
        TargetCommitish = git --git-dir "$($private:ProjectDir)/.git" rev-parse $TagName
        Name = if ($Name) { $Name } else { $TagName }
    }
    if ($ReleaseNotesPath) {
        "Sourcing from specified release notes path '$ReleaseNotesPath'" | Write-Verbose
        $private:createReleaseArgs['ReleaseNotesPath'] = if ([System.IO.Path]::IsPathRooted($ReleaseNotesPath)) { $ReleaseNotesPath }
                                                         else { "$private:ProjectDir/$ReleaseNotesPath" }
    }elseif ($ReleaseNotesContent) {
        "Using specified release notes content" | Write-Verbose
        $private:createReleaseArgs['ReleaseNotesContent'] = $ReleaseNotesContent
    }else {
        $private:defaultReleaseNotesPath = "$(git rev-parse --show-toplevel)/.release-notes.md"
        if (Test-Path -Path $private:defaultReleaseNotesPath -PathType Leaf) {
            "Sourcing from the default release notes path '$private:defaultReleaseNotesPath'" | Write-Verbose
            $private:createReleaseArgs['ReleaseNotesPath'] = $private:defaultReleaseNotesPath
        }else {
            "Default release notes not found at the path '$private:defaultReleaseNotesPath'. No release notes will be included with the release." | Write-Verbose
        }
    }
    if ($Draft) { $private:createReleaseArgs['Draft'] = $Draft } else { $false }
    if ($Prerelease) { $private:createReleaseArgs['Prerelease'] = $Prerelease } else { $false }
    $response = Create-GitHubRelease @private:createReleaseArgs
    $responseContent = $response.Content | ConvertFrom-Json

    # Upload release assets
    if ($Asset) {
        try {
            $private:releaseAssetsArr = $Asset -Split "`n" | % { $_.Trim() } | ? { $_ }
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
            ApiKey = $ApiKey
        }
        Upload-GitHubReleaseAsset @private:uploadReleaseAssetsArgs
    }

}catch {
    throw
}finally {
    Pop-Location
}
