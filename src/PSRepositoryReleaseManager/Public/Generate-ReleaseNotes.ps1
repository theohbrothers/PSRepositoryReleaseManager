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
        [ValidateSet(
            "Changes-HashSubject-Merges",
            "Changes-HashSubject-NoMerges-Categorized",
            "Changes-HashSubject-NoMerges",
            "Changes-HashSubject",
            "VersionDate-HashSubject-Merges",
            "VersionDate-HashSubject-NoMerges-Categorized",
            "VersionDate-HashSubject-NoMerges",
            "VersionDate-HashSubject",
            "VersionDate-Subject-Merges",
            "VersionDate-Subject-NoMerges-Categorized",
            "VersionDate-Subject-NoMerges",
            "VersionDate-Subject"
        )]
        [string]$Variant
        ,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$ReleaseNotesPath
    )

    try {
        $private:generateArgs = @{
            Path = $Path
            TagName = $TagName
        }
        "Generating release notes of variant '$($Variant)'" | Write-Verbose
        $releaseNotesContent = & $Variant @private:generateArgs -ErrorAction Stop
        if (!(Test-Path -Path ($ReleaseNotesPath | Split-Path))) {
            New-Item -Path ($ReleaseNotesPath | Split-Path) -ItemType Directory
        }
        $releaseNotesContent | Out-File -FilePath $ReleaseNotesPath -Encoding utf8
        "Release notes generated at the path '$ReleaseNotesPath'" | Write-Verbose
        $ReleaseNotesPath
    }catch {
        Write-Error -Exception $_.Exception -Message $_.Exception.Message -Category $_.CategoryInfo.Category -TargetObject $_.TargetObject
    }
}
