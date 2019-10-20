# This script acts as an entrypoint for executing all relevant scripts. It is designed for use in both development and CI environments.

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
    [ValidateNotNullOrEmpty()]
    [string]$Variant
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

try {
    # Get project variables
    . "$PSScriptRoot\common\Get-ProjectVariables.ps1"

    # Generate the release body
    $releaseBody = & "$PSScriptRoot\generate\variants\$($PSBoundParameters['Variant']).ps1" -Path $PSBoundParameters['Path'] -TagName $PSBoundParameters['TagName']
    $releaseBody

}catch {
    throw
}
