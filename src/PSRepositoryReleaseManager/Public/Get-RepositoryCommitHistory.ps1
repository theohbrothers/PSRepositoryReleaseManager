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
    Push-Location $PSBoundParameters['Path']
    $ErrorActionPreference = 'Stop'

    try {
        $PSBoundParameters['FirstRef'],$PSBoundParameters['SecondRef'] | % {
            git rev-parse $_ > $nul
        }
        "First ref: '$FirstRef':" | Write-Verbose
        if ($SecondRef) {
            "Second ref: '$SecondRef':" | Write-Verbose
            $commitSHARange = "$($PSBoundParameters['FirstRef'])...$($PSBoundParameters['SecondRef'])"
        }else {
            "Second ref unspecifed. Full history of First ref will be retrieved."  | Write-Verbose
            $commitSHARange = $PSBoundParameters['FirstRef']
        }
        $_commitHistory = git --no-pager log --pretty=format:"* %h %s" $commitSHARange | Out-String
        "Changelog:" | Write-Verbose
        $_commitHistory | Write-Verbose
        $_commitHistory
    }catch {
        throw
    }finally {
        Pop-Location
    }
}
