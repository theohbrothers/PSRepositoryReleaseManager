function Get-RepositoryCommitHistory {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path -Path $_ -PathType Container})]
        [string]$Path
        ,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$FirstRef
        ,
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$SecondRef
    )

    try {
        "Verifying refs" | Write-Verbose
        Push-Location $PSBoundParameters['Path']
        $PSBoundParameters['FirstRef'],$PSBoundParameters['SecondRef'] | % {
            git rev-parse $_ > $null
            if ($LASTEXITCODE) {
                throw "An error occurred."
            }
        }
        "First ref: '$($PSBoundParameters['FirstRef'])':" | Write-Verbose
        if ($PSBoundParameters['SecondRef']) {
            "Second ref: '$SecondRef':" | Write-Verbose
            $commitSHARange = "$($PSBoundParameters['FirstRef'])...$($PSBoundParameters['SecondRef'])"
        }else {
            "Second ref unspecifed. Full history of First ref will be retrieved."  | Write-Verbose
            $commitSHARange = $PSBoundParameters['FirstRef']
        }
        $_commitHistory = git --no-pager log --pretty=format:"%h %s" $commitSHARange | Out-String
        "Changelog:" | Write-Verbose
        $_commitHistory | Write-Verbose
        $_commitHistory
    }catch {
        Write-Error -Exception $_.Exception -Message $_.Exception.Message -Category $_.CategoryInfo.Category -TargetObject $_.TargetObject
    }finally {
        Pop-Location
    }
}
