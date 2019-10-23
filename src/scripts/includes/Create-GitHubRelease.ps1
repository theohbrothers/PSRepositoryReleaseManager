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

        # Create GitHub release
        New-GitHubRepositoryRelease @private:releaseArgs

    }catch {
        throw
    }finally {
        Pop-Location
    }

}
