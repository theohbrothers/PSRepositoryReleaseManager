# This script acts as an entrypoint for executing all relevant scripts. It is designed for use in both development and CI environments.

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$Namespace
    ,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$Repository
    ,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$ApiKey
    ,
    [Parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [string]$TagName
    ,
    [Parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [string]$TargetCommitish
    ,
    [Parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [string]$Name
    ,
    [Parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [string]$Body
    ,
    [Parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [bool]$Draft
    ,
    [Parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [bool]$Prerelease
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

try {
    # Create the release
    $response = New-GitHubRepositoryRelease @PSBoundParameters
    $response

}catch {
    throw
}
