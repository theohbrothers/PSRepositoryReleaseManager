function Upload-GitHubReleaseAsset {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$UploadUrl
        ,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({Test-Path -Path $_ -PathType Leaf})]
        [string[]]$Asset
        ,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$ApiKey
    )

    try {
        $private:releaseAssetArgs = [Ordered]@{}
        if ($PSBoundParameters['UploadUrl']) { $private:releaseAssetArgs['UploadUrl'] = $PSBoundParameters['UploadUrl'] }
        if ($PSBoundParameters['ApiKey']) { $private:releaseAssetArgs['ApiKey'] = $PSBoundParameters['ApiKey'] }
        foreach ($a in $PSBoundParameters['Asset']) {
            try {
                $private:releaseAssetArgs['Asset'] = Get-Item -Path $a | Select-Object -ExpandProperty FullName
                "Uploading release asset '$a':" | Write-Verbose
                $response = New-GitHubRepositoryReleaseAsset @private:releaseAssetArgs -ErrorAction Stop
            }catch {
                Write-Error -Exception $_.Exception -Message $_.Exception.Message -Category $_.CategoryInfo.Category -TargetObject $_.TargetObject
                continue
            }
            $response
        }
    }catch {
        Write-Error -Exception $_.Exception -Message $_.Exception.Message -Category $_.CategoryInfo.Category -TargetObject $_.TargetObject
    }
}
