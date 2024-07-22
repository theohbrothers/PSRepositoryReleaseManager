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
        [switch]$NoMerges
    )

    try {
        Push-Location $Path
        "Validating FirstRef '$FirstRef'" | Write-Verbose
        git rev-parse $FirstRef > $null
        if ($LASTEXITCODE) {
            throw "An error occurred."
        }
        if ($SecondRef) {
            "Validating SecondRef '$SecondRef'" | Write-Verbose
            git rev-parse $SecondRef > $null
            if ($LASTEXITCODE) {
                throw "An error occurred."
            }
        }
        if ($SecondRef) {
            $commitSHARange = "$($FirstRef)...$($SecondRef)"
        }else {
            "SecondRef unspecified. The full commit history for FirstRef '$FirstRef' will be retrieved." | Write-Verbose
            $commitSHARange = $FirstRef
        }
        $gitArgs = @(
            if ($PrettyFormat) { "--pretty=format:$PrettyFormat" }
            if ($Merges) { '--merges' }
            if ($NoMerges) { '--no-merges' }
        )
        $_commitHistory = git --no-pager log $commitSHARange @gitArgs
        "Changelog:" | Write-Verbose
        $_commitHistory | Write-Verbose
        $_commitHistory
    }catch {
        Write-Error -Exception $_.Exception -Message $_.Exception.Message -Category $_.CategoryInfo.Category -TargetObject $_.TargetObject
    }finally {
        Pop-Location
    }
}
