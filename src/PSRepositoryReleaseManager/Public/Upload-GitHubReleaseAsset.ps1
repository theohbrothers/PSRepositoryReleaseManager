function Upload-GitHubReleaseAsset {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$UploadUrl
        ,
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path -Path $_ -PathType Leaf})]
        [string[]]$Asset
        ,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$ApiKey
    )

    try {
        $private:releaseAssetArgs = [Ordered]@{}
        if ($UploadUrl) { $private:releaseAssetArgs['UploadUrl'] = $UploadUrl }
        if ($ApiKey) { $private:releaseAssetArgs['ApiKey'] = $ApiKey }
        foreach ($a in $Asset) {
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
