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
        if ($Namespace) { $private:releaseArgs['Namespace'] = $Namespace }
        if ($Repository) { $private:releaseArgs['Repository'] = $Repository }
        if ($ApiKey) { $private:releaseArgs['ApiKey'] = $ApiKey }
        if ($TagName) { $private:releaseArgs['TagName'] = $TagName }
        if ($TargetCommitish) { $private:releaseArgs['TargetCommitish'] = $TargetCommitish }
        if ($Name) { $private:releaseArgs['Name'] = $Name }
        if ($ReleaseNotesPath) { $private:releaseArgs['Body'] = Get-Content -Path $ReleaseNotesPath -Raw }
        elseif ($ReleaseNotesContent) { $private:releaseArgs['Body'] = $ReleaseNotesContent }
        if ($null -ne $Draft) { $private:releaseArgs['Draft'] = $Draft }
        if ($null -ne $Prerelease) { $private:releaseArgs['Prerelease'] = $Prerelease }
        $response = New-GitHubRepositoryRelease @private:releaseArgs -ErrorAction Stop
        $response
    }catch {
        Write-Error -Exception $_.Exception -Message $_.Exception.Message -Category $_.CategoryInfo.Category -TargetObject $_.TargetObject
    }
}
