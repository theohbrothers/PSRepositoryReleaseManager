function Create-GitHubRelease {
    [CmdletBinding(DefaultParameterSetName='Path')]
    param(
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
        [string]$TargetCommitish
        ,
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$Name
        ,
        [Parameter(ParameterSetName='Path', Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
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
        [string[]]$Assets
    )

    $ErrorActionPreference = 'Stop'
    $VerbosePreference = 'Continue'
    Set-StrictMode -Version Latest

    try {
        Push-Location $PSScriptRoot
        Import-Module "$(git rev-parse --show-toplevel)\lib\PSGitHubRestApi\src\PSGitHubRestApi\PSGitHubRestApi.psm1" -Force -Verbose

        $private:releaseArgs = [Ordered]@{}
        if ($PSBoundParameters['Namespace']) { $private:releaseArgs['Namespace'] = $PSBoundParameters['Namespace'] }
        if ($PSBoundParameters['Repository']) { $private:releaseArgs['Repository'] = $PSBoundParameters['Repository'] }
        if ($PSBoundParameters['ApiKey']) { $private:releaseArgs['ApiKey'] = $PSBoundParameters['ApiKey'] }
        if ($PSBoundParameters['TagName']) { $private:releaseArgs['TagName'] = $PSBoundParameters['TagName'] }
        if ($PSBoundParameters['TargetCommitish']) { $private:releaseArgs['TargetCommitish'] = $PSBoundParameters['TargetCommitish'] }
        if ($PSBoundParameters['Name']) { $private:releaseArgs['Name'] = $PSBoundParameters['Name'] }
        if ($PSBoundParameters['ReleaseNotesPath']) { $private:releaseArgs['Body'] = Get-Content -Path $PSBoundParameters['ReleaseNotesPath'] -Raw }
                                       elseif ($PSBoundParameters['ReleaseNotesContent']) { $private:releaseArgs['Body'] = $PSBoundParameters['ReleaseNotesContent'] }
        if ($null -ne $PSBoundParameters['Draft']) { $private:releaseArgs['Draft'] = $PSBoundParameters['Draft'] }
        if ($null -ne $PSBoundParameters['Prerelease']) { $private:releaseArgs['Prerelease'] = $PSBoundParameters['Prerelease'] }

        # Verify specified assets exist
        if ($PSBoundParameters['Assets']) {
            $PSBoundParameters['Assets'] | % {
                if (!(Test-Path -Path $_)) { throw "Asset '$_' does not exist." }
                if (!(Test-Path -Path $_ -PathType Leaf)) { throw "Asset '$_' is not a file." }
            }
        }

        # Create GitHub release
        $response = New-GitHubRepositoryRelease @private:releaseArgs
        $responseContent = $response.Content | ConvertFrom-Json
        "Response:" | Write-Verbose
        $responseContent | Out-String -Stream | % { $_.Trim() } | ? { $_ } | Write-Verbose

        # Create release assets
        if ($PSBoundParameters['Assets']) {
            $private:releaseAssetArgs = [Ordered]@{}
            $private:releaseAssetArgs['UploadUrl'] = $responseContent.upload_url
            if ($PSBoundParameters['ApiKey']) { $private:releaseAssetArgs['ApiKey'] = $PSBoundParameters['ApiKey'] }
            foreach ($a in $PSBoundParameters['Assets']) {
                $private:releaseAssetArgs['Asset'] = Get-Item -Path $a | Select-Object -ExpandProperty FullName
                "Uploading release asset '$a':" | Write-Verbose
                $response = New-GitHubRepositoryReleaseAsset @private:releaseAssetArgs
                $responseContent = $response.Content | ConvertFrom-Json
                "Response:" | Write-Verbose
                $responseContent | Out-String -Stream | % { $_.Trim() } | ? { $_ } | Write-Verbose
            }
        }

    }catch {
        throw
    }finally {
        Pop-Location
    }
}
