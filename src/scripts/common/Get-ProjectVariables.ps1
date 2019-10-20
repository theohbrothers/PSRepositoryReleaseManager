[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

try {
    # Global constants
    $script:PROJECT = @{}
    $script:PROJECT['SUPERPROJECT_BASE_DIR'] = if (git rev-parse --show-superproject-working-tree) { Convert-Path -Path (git rev-parse --show-superproject-working-tree) }
    $script:PROJECT['BASE_DIR'] = if ($script:PROJECT['SUPERPROJECT_BASE_DIR']) { $script:PROJECT['SUPERPROJECT_BASE_DIR'] } else { Convert-Path -Path (git rev-parse --show-toplevel) }
    $script:PROJECT['GENERATE_DIR'] = Join-Path $PSScriptRoot 'generate'

}catch {
    throw
}
