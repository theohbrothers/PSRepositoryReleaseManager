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
    )

    try {
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
        $response = New-GitHubRepositoryRelease @private:releaseArgs -ErrorAction Stop
        $response
    }catch {
        Write-Error -Exception $_.Exception -Message $_.Exception.Message -Category $_.CategoryInfo.Category -TargetObject $_.TargetObject
    }
}
