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
        ,
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$PrettyFormat
        ,
        [Parameter(Mandatory=$false)]
        [switch]$Merges
        ,
        [Parameter(Mandatory=$false)]
        [string]$NoMerges
    )

    try {
        "Verifying refs" | Write-Verbose
        Push-Location $Path
        $FirstRef,$SecondRef | % {
            git rev-parse $_ > $null
            if ($LASTEXITCODE) {
                throw "An error occurred."
            }
        }
        "First ref: '$($FirstRef)':" | Write-Verbose
        if ($SecondRef) {
            "Second ref: '$SecondRef':" | Write-Verbose
            $commitSHARange = "$($FirstRef)...$($SecondRef)"
        }else {
            "Second ref unspecifed. Full history of First ref will be retrieved."  | Write-Verbose
            $commitSHARange = $FirstRef
        }
        $gitArgs = @(
            '--no-pager'
            'log'
            "--pretty=format:$($PrettyFormat)"
            $commitSHARange
            if ($Merges) { '--merges' }
            elseif ($NoMerges) { '--no-merges' }
        )
        $_commitHistory = git $gitArgs | Out-String
        "Changelog:" | Write-Verbose
        $_commitHistory | Write-Verbose
        $_commitHistory
    }catch {
        Write-Error -Exception $_.Exception -Message $_.Exception.Message -Category $_.CategoryInfo.Category -TargetObject $_.TargetObject
    }finally {
        Pop-Location
    }
}
