# Azure Labs (Networking) - Hub-Spoke design - Azure VPN Gateway to AWS VPG with IKEv2 and BGP

## Introduction
This lab will guide you how to build a IPSEC VPN tunnel w/IKEv2 between a AWS VPG and the Azure VPN gateway with BGP. Before you had to use just static route to establish site-to-site between Azure and AWS, now it is possible to use the BGP and APIPA address space.

 All Azure configs are done in Azure CLI and, you can change them as needed to match your environment. 

 > Note: 

 **References:**</br>
 [How to configure BGP on Azure VPN Gateways](https://docs.microsoft.com/en-us/azure/vpn-gateway/bgp-howto)

## Prerequisites

- Install the Az ClI [Install the Azure CLI](https://docs.microsoft.com/pt-br/cli/azure/install-azure-cli) or use the [Azure Cloud Shell](https://docs.microsoft.com/en-us/azure/cloud-shell/overview) to run it.
- Ensure you are properly logged in to your tenant and with a subscription selected. You can check that by using:

```azure cli
az account list --output table
az account set --subscription "My Subscription"
```

## Lab
In this lab, you will setup two virtual networks in a hub-and-spoke design and configure an Azure Private Peering between both vNETs. You will execute the Powershell script to print the peering information, take a backup of all virtual network information and add new address space into the hub vNET using a file with a .txt extension. 

See the base topology:

![Network Architecture](./images/lab-architeture.png)

Create the Lab environment using the Azure CLI inside Azure Cloud Shell.

1. To start Azure Cloud Shell:

    - Select the Cloud Shell button on the menu bar at the upper right in the Azure portal. ->

    ![](./images/hdi-cloud-shell-menu.png)

2. Wait for the windows appear and enter into the prompt with the following information:

```azure cli
** Virtual Network - HUB **
$location = 'eastus2'
$rg = 'lab-aws-vpn-to-azurevpngw-ikev2-bgp-rg'
az group create --name $rg --location $location
az network vnet create --resource-group $rg --name az-hub-vnet --location $location --address-prefixes 10.0.0.0/16 --subnet-name GatewaySubnet --subnet-prefix 10.0.1.0/27
```

```azure cli
** Virtual Network - SPOKE **
az network vnet create --resource-group $rg --name az-spoke-vnet --location $location --address-prefixes 10.1.0.0/16 --subnet-name websubnet --subnet-prefix 10.1.1.0/24
```
``` azure cli
$hubvNet1Id=$(az network vnet show --resource-group $rg --name az-hub-vnet --query id --out tsv)
$spokevNet1Id=$(az network vnet show --resource-group $rg --name az-spoke-vnet --query id --out tsv)
az network vnet peering create --name to-spokevnet --resource-group $rg --vnet-name az-hub-vnet --remote-vnet $spokevNet1Id --allow-vnet-access 
az network vnet peering create --name to-hubvnet --resource-group $rg --vnet-name az-spoke-vnet --remote-vnet $hubvNet1Id --allow-vnet-access 
```

```azure cli
az network public-ip create --name azure-vpngw-pip --resource-group $rg --allocation-method Dynamic
az network vnet-gateway create --name azure-vpngw --public-ip-address azure-vpngw-pip --resource-group $rg --vnet az-hub-vnet --gateway-type Vpn --vpn-type RouteBased --sku VpnGw1 --asn 65001 --bgp-peering-address 169.254.21.2 --no-wait
```

3. Create a file to add the new address space that you would like to insert in your virtual network. Run follow command on Powershell:

```powershell
New-Item "add_new_address_space.txt" -ItemType File -Value "10.0.5.0/24" 
```
4. Run the Powershell script to get vNET peering information and add new address space inside of virtual network (hub-vnet). Run the following command:

```powershell
azure-vnetpeering-addess-spacemaintenace.ps1 -vnetname hub-vnet -rg lab-adressSpace-maintance-vnetpeering-rg  -addvnetPath add_new_address_space.txt
```
**Output below will show a summary of vNET Peering Information and process to add new address space inside of virtual network.**

![](./images/get-vnet-peering-info.PNG)

***Figure 1 - vNET Peering Information***

![](./images/add-process-new-address-space.PNG)

***Figure 2 - The process to add new address space, remove peering and restabish again***

  > Note: Choice **"Yes" [y]** or **"No [n]"** to follow the procedure to add a new address space inside the virtual network.
## Clean All Resources after the lab

After you have successfully completed the lab, you will want to delete the Resource Groups.Run the following command on Azure Cloud Shell:

```powershell
Get-AzureRmResourceGroup -Name "lab-adressSpace-maintance-vnetpeering-rg" | Remove-AzureRmResourceGroup -Verbose -Force
```
## Contributing
Pull requests are welcome. For major changes. Please make sure to update tests as appropriate.
