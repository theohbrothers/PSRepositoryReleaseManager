function Get-RepositoryReleaseNotes {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path -Path $_ -PathType Container})]
        [string]$Path
        ,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$TagName
        ,
        [Parameter(Mandatory=$true)]
        [ValidateSet("DateCommitHistory")]
        [string]$Variant
        ,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$ReleaseNotesPath
    )

    try {
        # Generate the release body
        $generateArgs = @{
            Path = $PSBoundParameters['Path']
            TagName = $PSBoundParameters['TagName']
        }
        "Generating release notes of variant '$($PSBoundParameters['Variant'])'" | Write-Verbose
        $releaseNotesContent = & "GenerateVariant-$($PSBoundParameters['Variant'])" @generateArgs
        if (!(Test-Path -Path ($ReleaseNotesPath | Split-Path))) {
            New-Item -Path ($ReleaseNotesPath | Split-Path) -ItemType Directory
        }
        $releaseNotesContent | Out-File -FilePath $ReleaseNotesPath -Encoding utf8
        "Release notes generated at the path '$ReleaseNotesPath'" | Write-Verbose

    }catch {
        throw
    }finally {
        Pop-Location
    }
}
