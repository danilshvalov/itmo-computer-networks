Import-Module -Name NetTCPIP

$adapter = "Ethernet"

function Change-Config
{
  $type = Read-Host -Prompt "Choose configuration type [DHCP (1), static (2)]"
  if ($type -eq 1)
  {
    Set-DHCP-Config
  }
  elseif ($type -eq 2)
  {
    Set-Static-Config
  }
  else
  {
    Write-Host "Incorrect option"
  }
}

function Reload-Config
{
  Write-Host "Updating config..."
  cmd.exe /c "timeout /t 5 /nobreak > nul"
  cmd.exe /c "netsh interface ip show config $adapter"
}

function Clear-Routes
{
  Remove-NetRoute -InterfaceAlias $adapter `
     -Confirm:$false `
     -ErrorAction 'silentlycontinue'
  Remove-NetIPAddress -InterfaceAlias $adapter `
     -Confirm:$false `
     -ErrorAction 'silentlycontinue'
}

function Set-DHCP-Config
{
  Clear-Routes
  Set-NetIPInterface -InterfaceAlias $adapter -Dhcp Enabled
  Set-DnsClientServerAddress -InterfaceAlias $adapter -ResetServerAddresses
  Restart-NetAdapter -InterfaceAlias $adapter
  Reload-Config
}

function Set-Static-Config
{
  $ipAddress = Read-Host -Prompt "Enter IP address"
  if ($ipAddress)
  {
    Clear-Routes

    $ipMask = Read-Host -Prompt "Enter IP prefix lenght"
    $gateway = Read-Host -Prompt "Enter gateway"

    New-NetIPAddress -IPAddress:$ipAddress `
       -InterfaceAlias:$adapter `
       -PrefixLength:$ipMask `
       -DefaultGateway:$gateway | Out-Null
  }

  $dns = Read-Host -Prompt "Enter DNS"
  if ($dns)
  {
    Set-DnsClientServerAddress -InterfaceAlias $adapter -ServerAddresses $dns
  }

  Reload-Config
}

function Show-Network-Adapter-Model
{
  Write-Host "Model: $((Get-NetAdapter -Name $adapter).InterfaceDescription)"
}

function Show-Physical-Link
{
  Write-Host "Physical link:" `
      $((Get-NetAdapter -Name $adapter).MediaConnectionState)
}

function Show-Network-Adapter-Info
{
  $info = Get-NetAdapter -Name $adapter
  Write-Host "Link speed: $($info.LinkSpeed)"
  Write-Host "Full duplex: $($info.FullDuplex)"
}

Write-Host "Available actions:"
Write-Host "1. Change configuration"
Write-Host "2. Show model of network adapter"
Write-Host "3. Show physical link"
Write-Host "4. Show speed and mode of network adapter"

$type = Read-Host -Prompt "Choose action"
if ($type -eq 1)
{
  Change-Config
}
elseif ($type -eq 2)
{
  Show-Network-Adapter-Model
}
elseif ($type -eq 3)
{
  Show-Physical-Link
}
elseif ($type -eq 4)
{
  Show-Network-Adapter-Info
}
else
{
  Write-Host "Incorrect option"
}
