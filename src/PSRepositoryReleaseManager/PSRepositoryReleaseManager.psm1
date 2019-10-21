Set-StrictMode -Version Latest

##################
# Module globals #
##################

# Module constants
$script:MODULE = @{}
$script:MODULE['BASE_DIR'] = $PSScriptRoot
$script:MODULE['PUBLIC_DIR'] = Join-Path $script:MODULE['BASE_DIR'] 'Public'          # Module public functions
$script:MODULE['PRIVATE_DIR'] = Join-Path $script:MODULE['BASE_DIR'] 'Private'        # Module private functions
$script:MODULE['GENERATE_DIR'] = Join-Path $script:MODULE['BASE_DIR'] 'generate'
$script:MODULE['VARIANT_DIR'] = Join-Path $script:MODULE['GENERATE_DIR'] 'variants'

# Load vendor, Public, Private, classes, helpers
Get-ChildItem -Path "$($script:MODULE['PUBLIC_DIR'])\*.ps1" | % { . $_.FullName }
Get-ChildItem -Path "$($script:MODULE['PRIVATE_DIR'])\*.ps1" | % { . $_.FullName }
Get-ChildItem -Path "$($script:MODULE['VARIANT_DIR'])\*.ps1" | % { . $_.FullName }

# Export Public functions
Export-ModuleMember -Function (Get-ChildItem "$($script:MODULE['PUBLIC_DIR'])\*.ps1" | Select-Object -ExpandProperty BaseName)
