#Requires -Version 5.0
<#

.SYNOPSIS
Displays the computer's public IP.

.DESCRIPTION
Displays the computer's public IP.

.EXAMPLE
 Get-PublicIPAddress -Site whatismypublicip.com

.LINK
https://github.com/mikemadeja/PublicIPAddress/blob/master/README.md

#>
Function Test-Site  {
  [CmdletBinding()]
  Param (
    [string]$URI
    )
  Write-Verbose "Using site $URI for getting public IP"
  $URI = $URI -replace "http://", ""
  Write-Verbose "Testing the connection to $URI"
if ((Test-Connection $URI -Quiet) -ne $true) {
  Write-Error "Failed connecting to $URI" -ErrorAction "Stop"
  }
}
Function Test-IPAddress {
  Param (
    [string]$IPAddress
  )
  $IPAddress -match "\b(?:\d{1,3}\.){3}\d{1,3}\b"
}
Function Get-IPInfoFromSite {
  [CmdletBinding()]
  param(
    [string]$Site
 )
  $regExIPAddress = "\d+.\d+.\d+.\d+"
  Switch ($Site) 
    { 
      'whatismypublicip.com' {
        $URI = "http://whatismypublicip.com"
        Test-Site ($URI)
        $HTML = Invoke-WebRequest -Uri $URI
        $varIPwhatismyIPAddress = $HTML.ParsedHtml.body.getElementsByTagName('div')
        $varIPwhatismyIPAddressIP = ($varIPwhatismyIPAddress | Where-Object { $_.ID -eq "up_finished" }).textContent
        $varIPwhatismyIPAddressIP = $varIPwhatismyIPAddressIP | Select-Object -First 1
        If ($varIPwhatismyIPAddressIP -match $regExIPAddress) {
        Write-Output $varIPwhatismyIPAddressIP
        }
        Else {
        $URL_Format_Error = [string]"IP Address output error"
        Write-Error $URL_Format_Error
          }
        }
        'ipchicken.com' {
        $URI = "http://ipchicken.com"
        Test-Site -URI $URI
        $HTML = Invoke-WebRequest -Uri $URI

        If ($HTML.ParsedHtml.body.innerText -match '\d+.\d+.\d+.\d+') { 
          Write-Output $matches[0]
        }
        Else { 
          $URL_Format_Error = [string]"IP Address output error"
          Write-Error $URL_Format_Error  
          }
        }
        default {
          Write-Error 'Please select a validite IP site checker'
        }
      }
  }
  Function Get-PublicIPAddress {
      <#
      .SYNOPSIS
      IP.Public.API module.
      .DESCRIPTION
      Displays the computer's public IP.
      .LINK
      https://github.com/mikemadeja/PublicIPAddress/blob/master/README.md
      #>
      [CmdletBinding()]
      Param (
        [ValidateSet('whatismypublicip.com','ipchicken.com')]
        [string]$Site = 'whatismypublicip.com'
        )
        Get-IPInfoFromSite -Site $Site
      }
Function Get-PublicIPAddressInfo {
    <#
    .SYNOPSIS
    Public.IP module.
    .DESCRIPTION
    Displays the computer's public IP info via API.
    .LINK
    https://github.com/mikemadeja/PublicIPAddress/blob/master/README.md
    #>
    [CmdletBinding()]
    Param (
      [string[]]$IPAddress
      )
      If (!$IPAddress) {
        $IPAddress = Get-PublicIPAddress
      }
      $URL = "http://ip-api.com/json/"
      $ObjectFinal = @()

      Foreach ($IPAddressItem in $IPAddress) {
        Write-Verbose -Message "IP Address Input: $IPAddressItem"
        If (Test-IPAddress -IPAddress $IPAddressItem) {

          $URLWithIP = $URL + $IPAddressItem
          Write-Verbose -Message "URL: $URLWithIP"
          $ipAPI = Invoke-RestMethod -Uri $URLWithIP -Method GET

          If ($ipAPI.Status -eq "fail") {
            Write-Error -Message "Error with $IPAddressItem"
          }

            $ipAPIProperties = @{
              'City' = $ipAPI.City;
              'Country' = $ipAPI.Country;
              'CountryCode' = $ipAPI.CountryCode;
              'ISP' = $ipAPI.ISP;
              'Latitude' = $ipAPI.Lat;
              'Longitude' = $ipAPI.Lon;
              'Organization' = $ipAPI.Org;
              'Query' = $ipAPI.Query;
              'Region' = $ipAPI.Region;
              'RegionName' = $ipAPI.RegionName;
              'Status' = $ipAPI.Status;
              'TimeZone' = $ipAPI.TimeZone;
              'Zip' = $ipAPI.Zip;
            }
            $Object = New-Object -TypeName PSObject -Property $ipAPIProperties

        }
        $ObjectFinal += $Object
      }
      Write-Output $ObjectFinal
    }

Export-ModuleMember -Function Get-PublicIPAddress
Export-ModuleMember -Function Get-PublicIPAddressInfo
