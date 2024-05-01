[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

try {
    Push-Location $PSScriptRoot

    # Install Pester if needed
    "Checking Pester version" | Write-Host
    $pesterMinimumVersion = [version]'4.0.0'
    $pesterMaximumVersion = [version]'4.10.1'
    $pester = Get-Module 'Pester' -ListAvailable -ErrorAction SilentlyContinue
    if (!$pester -or !($pester | ? { $_.Version -ge $pesterMinimumVersion -and $_.Version -le $pesterMaximumVersion })) {
        "Installing Pester" | Write-Host
        Install-Module -Name 'Pester' -Repository 'PSGallery' -MinimumVersion $pesterMinimumVersion -MaximumVersion $pesterMaximumVersion -Scope CurrentUser -Force
    }
    Get-Module Pester -ListAvailable | Out-String | Write-Verbose
    Import-Module -Name 'Pester' -MinimumVersion $pesterMinimumVersion -MaximumVersion $pesterMaximumVersion -Force   # Force import to ensure environment uses the correct version of Pester

}catch {
    throw
}finally{
    Pop-Location
}