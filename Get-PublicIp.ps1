[CmdletBinding()]
param (
    [bool]$IncludeInfo = $false
)

#Load functions
. .\functions.ps1


if (!$IncludeInfo) {
    Get-PublicIPAddress
}
else {
    Get-PublicIPAddressInfo
}