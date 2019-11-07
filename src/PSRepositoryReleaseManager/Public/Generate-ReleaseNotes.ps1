function Generate-ReleaseNotes {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({Test-Path -Path $_ -PathType Container})]
        [string]$Path
        ,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$TagName
        ,
        [Parameter(Mandatory=$true)]
        [ValidateSet("DateCommitHistory", "DateCommitHistoryNoMerges")]
        [string]$Variant
        ,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$ReleaseNotesPath
    )

    try {
        $private:generateArgs = @{
            Path = $PSBoundParameters['Path']
            TagName = $PSBoundParameters['TagName']
        }
        "Generating release notes of variant '$($PSBoundParameters['Variant'])'" | Write-Verbose
        $releaseNotesContent = & "GenerateVariant-$($PSBoundParameters['Variant'])" @private:generateArgs -ErrorAction Stop
        if (!(Test-Path -Path ($ReleaseNotesPath | Split-Path))) {
            New-Item -Path ($ReleaseNotesPath | Split-Path) -ItemType Directory
        }
        $releaseNotesContent | Out-File -FilePath $ReleaseNotesPath -Encoding utf8
        "Release notes generated at the path '$ReleaseNotesPath'" | Write-Verbose
    }catch {
        Write-Error -Exception $_.Exception -Message $_.Exception.Message -Category $_.CategoryInfo.Category -TargetObject $_.TargetObject
    }
}
