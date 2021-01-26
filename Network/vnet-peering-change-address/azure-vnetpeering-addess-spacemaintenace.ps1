Param(
    [Parameter(Mandatory=$true,
    HelpMessage="Add Virtual Network Name")]
    [String]
    $vnetname,

    [Parameter(Mandatory=$true,
    HelpMessage="Add Resource Group Virtual Netowork")]
    [String]
    $rg,
    
    [Parameter(Mandatory=$true,
    HelpMessage="Inform path and file name with extesion to Add the address space inside vNET. For example: c:\temp\vnet.txt")]
    [String]
    $addvnetPath
)

$peeringtmp = Get-AzVirtualNetworkPeering -VirtualNetworkName $vnetname -ResourceGroupName $rg

#Function 
function Get-VirtualNetworkPeeringInfo() {
    
    $obj = New-Object -TypeName PSCustomObject
    Foreach ($vnetaddress in Get-AzVirtualNetwork -Name $vnetname -ResourceGroupName $rg) {
      ForEach ($peerings in Get-AzVirtualNetworkPeering -VirtualNetworkName $vnetname -ResourceGroupName $rg) {
              $vnetname = $peerings.id -split("/")
              $remotevnetname = $peerings.RemoteVirtualNetwork.id -split("/")
                            
              $obj | Add-Member -MemberType NoteProperty -Name vNETName -Value $($vnetname[8]) -Force
              $obj | Add-Member -MemberType NoteProperty -Name vNETAddressSpace -Value @(($vnetaddress.AddressSpace.AddressPrefixes) -join ',') -Force  
              $obj | Add-Member -MemberType NoteProperty -Name PeeringName -Value $($peerings.Name) -Force
              $obj | Add-Member -MemberType NoteProperty -Name PeeringState -Value $($peerings.PeeringState) -Force
              $obj | Add-Member -MemberType NoteProperty -Name RemoteVirtualNetwork -Value $($remotevnetname[8]) -Force
              $obj | Add-Member -MemberType NoteProperty -Name RemoteVirtualNetworkAddressSpace -Value (@($peerings.RemoteVirtualNetworkAddressSpace.AddressPrefixes)-join ',') -Force  
              $obj | Add-Member -MemberType NoteProperty -Name AllowVirtualNetworkAccess -Value $($peerings.AllowVirtualNetworkAccess) -Force
              $obj | Add-Member -MemberType NoteProperty -Name AllowForwardedTraffic -Value $($peerings.AllowForwardedTraffic) -Force
              $obj | Add-Member -MemberType NoteProperty -Name AllowGatewayTransit -Value $($peerings.AllowGatewayTransit) -Force
              $obj | Add-Member -MemberType NoteProperty -Name UseRemoteGateways -Value $($peerings.UseRemoteGateways) -Force
                if ($null -eq $peerings.UseRemoteGateways) {
                    $obj | Add-Member -MemberType NoteProperty -Name UseRemoteGateways -Value " " -Force
                    }
                 else {
                    $obj | Add-Member -MemberType NoteProperty -Name UseRemoteGateways -Value $($peerings.RemoteGateways) -Force          
                 }
           $obj
      }
                    
  }	
}
Write-Host "*********************************************" -ForegroundColor Yellow 
Write-Host "********** vNET Peering Information *********" -ForegroundColor Yellow 
Write-Host "*********************************************" -ForegroundColor Yellow 
Get-VirtualNetworkPeeringInfo | Format-Table

$confirmationbkp = Read-Host "Do you want to create a backup file ? [y/n]"
Clear-Host
    if ($confirmationbkp -eq 'y') { 
        Write-Progress -Activity "vNET Peering - Backup File " -Status "In Process"  
        Start-Sleep 3  
        Write-Progress -Activity "Sleep" -Completed  
        Start-Sleep 2  
        New-Item -ItemType file -Path "$($vnetname)-peerings.txt" -Force
        Get-VirtualNetworkPeeringInfo | Format-Table | Out-File "$($vnetname)-peerings.txt"
        }
        else {exit}
   
$confirmationdisconnect = Read-Host "Do you want to disconnected all peerings in $vnetname ? [y/n]"
    if ($confirmationdisconnect -eq 'y') { 
       Get-AzVirtualNetworkPeering -VirtualNetworkName $vnetname -ResourceGroupName $rg | Remove-AzVirtualNetworkPeering -force     
    }
        else {exit}

$confirmationaddvnet = Read-Host "Do you want to add an address space into vNET -  $vnetname ? [y/n]"
    if ($confirmationaddvnet -eq 'y') { 
        Test-Path -Path $addvnetPath
        $addvnetPathinfo = Get-Content -Path $addvnetPath
        $vnet = Get-AzVirtualNetwork -Name $vnetname -ResourceGroupName $rg 
            foreach ($add in $addvnetPathinfo ) {
                $vnet.AddressSpace.AddressPrefixes.Add($add)
                } 
                Set-AzVirtualNetwork -VirtualNetwork $vnet
            }
                else {exit}

$confirmationpeering = Read-Host "Do you want to restablish the vNEt peering into vNET -  $vnetname ? [y/n]"
    if ($confirmationpeering -eq 'y') { 
        $vnet = Get-AzVirtualNetwork -Name $vnetname -ResourceGroupName $rg
             foreach ($peer in $peeringtmp) {
                     $remotevnet = $peer.RemoteVirtualNetwork.id -split("/")                  
                     Get-AzVirtualNetworkPeering  -VirtualNetworkName $($remotevnet[8]) -ResourceGroupName $($remotevnet[4]) | Set-AzVirtualNetworkPeering 
                       if ($peer.AllowGatewayTransit -eq "True") {Add-AzVirtualNetworkPeering -Name $peer.Name -VirtualNetwork $vnet -RemoteVirtualNetworkId $peer.RemoteVirtualNetwork.Id -AllowGatewayTransit}
                       else {Add-AzVirtualNetworkPeering -Name $peer.Name -VirtualNetwork $vnet -RemoteVirtualNetworkId $peer.RemoteVirtualNetwork.Id}
                           
                          }
                         
                        }
                            else {exit}
                           
               
           

