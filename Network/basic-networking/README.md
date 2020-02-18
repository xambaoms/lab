# Azure Networking hands-on lab step-by-step

## Overview

 In this hands-on lab, you will setup a virtual networks in a hub-and-spoke design. You will also learn how to secure virtual networks by implementing Azure Firewall, network security groups and application security groups, as well as configure route tables on the subnets in your virtual network. Additionally, you will set up access to the virtual network via a jump box and provision a site-to-site VPN connection from another virtual network, providing emulation of hybrid connectivity from an on-premises environment.

At the end of this hands-on lab, you will be better able to configure Azure networking components and you will be learning:

- How to bypass system routing to accomplish custom routing scenarios.

- How to setup and configure a virtual network and subnets on Azure

- How to capitalize on load balancers to distribute load and ensure service availability.

- How to implement Azure Firewall to control hybrid and cross-virtual network traffic flow based on policies.

- How to implement a combination of Network Security Groups (NSGs)  to control traffic flow within virtual networks.

- How to monitor network traffic for proper route configuration and troubleshooting.

## Network Architecture

![Network Architecture](./images/basic_network.png)

## Requirements

- Valid the Azure subscription account. If you don’t have one, you can create your free azure account (https://azure.microsoft.com/en-us/free/).

## Exercise 1: Create a virtual network and provision subnets

Duration: 20 minutes

### Task 1: Create a Virtual Network and Configure Subnets

**Reference:**</br>
Virtual Network documentation</br>
<https://azure.microsoft.com/en-us/documentation/services/virtual-network/>  


> **More Information:** https://docs.microsoft.com/en-us/azure/virtual-network/quick-create-portal

#### Create a virtual network using the Azure Cloud Shell. (*Bash*)

> **More Information:** https://docs.microsoft.com/en-us/azure/virtual-network/quick-create-portal

1. To start Azure Cloud Shell:

- Select the Cloud Shell button on the menu bar at the upper right in the Azure portal. ->

    ![](./images/hdi-cloud-shell-menu.png)

2. Wait the windows apear and enter into the prompt with the following information:

```Azure CLI
** Virtual Network - HUB **
az group create --name networking-handson-rg --location eastus2
az network vnet create --resource-group networking-handson-rg --name hubvnet --location eastus2 --address-prefixes 10.0.0.0/16 --subnet-name GatewaySubnet --subnet-prefix 10.0.1.0/27
az network vnet subnet create --address-prefix 10.0.2.0/24 --name managementsubnet --resource-group networking-handson-rg --vnet-name hubvnet
az network vnet subnet create --address-prefix 10.0.8.0/26 --name AzureFirewallSubnet --resource-group networking-handson-rg --vnet-name hubvnet
az network vnet subnet create --address-prefix 10.0.10.0/27 --name AzureBastionSubnet --resource-group networking-handson-rg --vnet-name hubvnet
```

```Azure CLI
** Virtual Network - SPOKE **
az network vnet create --resource-group networking-handson-rg --name spokevnet --location eastus2 --address-prefixes 10.1.0.0/16 --subnet-name websubnet --subnet-prefix 10.1.1.0/24
```

```Azure CLI
** Virtual Network - On-premises **
az network vnet create --resource-group networking-handson-rg --name onpremvnet --location eastus2 --address-prefixes 192.168.0.0/16 --subnet-name onpremSubnet --subnet-prefix 192.168.1.0/24
```

3. Validate if **Virtual Networks** is create, run following command:

```Azure CLI
az network vnet list -g networking-handson-rg --output table
```
Now you built the Azure network enviroments: On-premises, Hub and Spoke on Azure.

## Exercise 2: Create a Virtual Machine

Duration: 30 minutes

### Task 1: Create the Virtual Machines

**Reference:**</br>
Virtual Machines Documentation</br>
<https://docs.microsoft.com/en-us/azure/virtual-machines/>  

#### Create a virtual machine using the Azure Cloud Shell. (*Bash*)

> **More Information:** https://docs.microsoft.com/en-us/azure/virtual-machines/windows/quick-create-cli

> **Note:** In this step you wil create 4 machines: 2 VMs for hubvnet, 1 VM for spokevnet and 1 VM for onpremisesvnet.

1. To start Azure Cloud Shell:

- Select the Cloud Shell button on the menu bar at the upper right in the Azure portal. ->

    ![](./images/hdi-cloud-shell-menu.png)


2. Wait the windows apear and enter into the prompt with the following information:

```Azure CLI
** Virtual Machine - Hub **
az network nic create --resource-group networking-handson-rg -n azmngserver1-nic --location eastus2 --subnet managementsubnet --vnet-name hubvnet --private-ip-address 10.0.2.4
az vm create -n azmngserver1 -g networking-handson-rg --image win2016datacenter  --storage-sku Standard_LRS --admin-username azureuser --admin-password Msft@123456@ --nics azmngserver1-nic --no-wait
az vm extension set --publisher Microsoft.Compute --version 1.8 --name CustomScriptExtension --vm-name azmngserver1 -g networking-handson-rg --settings '{"fileUris":["https://aznetworkinghandson.blob.core.windows.net/public/enable-icmp.ps1"],"commandToExecute":"powershell.exe -ExecutionPolicy Unrestricted -file enable-icmp.ps1"}' --no-wait

```

```Azure CLI
** Virtual Machine - Spoke **
az vm availability-set create -n azwsserver-avset -g networking-handson-rg --platform-fault-domain-count 2 --platform-update-domain-count 2
az network nic create --resource-group networking-handson-rg -n azwsserver1-nic --location eastus2 --subnet websubnet --vnet-name spokevnet --private-ip-address 10.1.1.4
az vm create -n azwsserver1 -g networking-handson-rg --image win2016datacenter --storage-sku Standard_LRS --admin-username azureuser --admin-password Msft@123456@ --nics azwsserver1-nic --availability-set azwsserver-avset --no-wait
az vm extension set --publisher Microsoft.Compute --version 1.8 --name CustomScriptExtension --vm-name azwsserver1 -g networking-handson-rg --settings '{"fileUris":["https://aznetworkinghandson.blob.core.windows.net/public/deploy-iis.ps1"],"commandToExecute":"powershell.exe -ExecutionPolicy Unrestricted -file deploy-iis.ps1"}' --no-wait

az network nic create --resource-group networking-handson-rg -n azwsserver2-nic --location eastus2 --subnet websubnet --vnet-name spokevnet --private-ip-address 10.1.1.5
az vm create -n azwsserver2 -g networking-handson-rg --image win2016datacenter --storage-sku Standard_LRS --admin-username azureuser --admin-password Msft@123456@ --nics azwsserver2-nic --availability-set azwsserver-avset --no-wait
az vm extension set --publisher Microsoft.Compute --version 1.8 --name CustomScriptExtension --vm-name azwsserver2 -g networking-handson-rg --settings '{"fileUris":["https://aznetworkinghandson.blob.core.windows.net/public/deploy-iis.ps1"],"commandToExecute":"powershell.exe -ExecutionPolicy Unrestricted -file deploy-iis.ps1"}' --no-wait
```

```Azure CLI
** Virtual Machine - On-premises **
az network nic create --resource-group networking-handson-rg -n onpremserver1-nic --location eastus2 --subnet onpremSubnet --vnet-name onpremvnet --private-ip-address 192.168.1.4
az vm create -n onpremserver1 -g networking-handson-rg --image win2016datacenter --storage-sku Standard_LRS --admin-username azureuser --admin-password Msft@123456@ --nics onpremserver1-nic --no-wait
az vm extension set --publisher Microsoft.Compute --version 1.8 --name CustomScriptExtension --vm-name onpremserver1 -g networking-handson-rg --settings '{"fileUris":["https://aznetworkinghandson.blob.core.windows.net/public/enable-icmp.ps1"],"commandToExecute":"powershell.exe -ExecutionPolicy Unrestricted -file enable-icmp.ps1"}' --no-wait
```

3. Validate if **Virtual Machines** is create, run following command:

``` Azure CLI
az vm list -g networking-handson-rg --output table
```

## Exercise 3: Create a Network Monitoring Solution

Duration: 15 minutes

### Task 1: Create a Log Analytics Workspace

**Reference:**</br>
Azure Monitor documentation</br>
<https://docs.microsoft.com/en-us/azure/azure-monitor/></br>
What is Azure Network Watcher?</br>
<https://docs.microsoft.com/en-us/azure/network-watcher/network-watcher-monitoring-overview>


#### Create a Log Analytics and Network Watcher using the Azure Cloud Shell.(*Bash*)

> **More Information:** https://docs.microsoft.com/en-us/azure/virtual-machines/windows/quick-create-cli

1. To start Azure Cloud Shell:

- Select the Cloud Shell button on the menu bar at the upper right in the Azure portal. ->

    ![](./images/hdi-cloud-shell-menu.png)


2. Wait the windows apear and enter into the prompt with the following information:

``` Azure CLI
az monitor log-analytics workspace create -g networking-handson-rg  -n azurenetworkmonitor 
```
In workspace name **Enter Unique Name all lowercase**

3. Validate if **Log Analytics** is create, run following command:

``` Azure CLI
az monitor log-analytics workspace list -g networking-handson-rg  --output table
```

### Task 2: Configure Network Watcher

1. To start Azure Cloud Shell and enter with the following information:

``` Azure CLI
az network watcher configure -g networking-handson-rg  -l eastus2 --enabled true
```
3. Validate if **Network Watcher** is create, run following command:

``` Azure CLI
az network watcher list --output table
```
## Exercise 4: Configure Network Security Groups

In this exercise, you will restrict traffic between tiers of n-tier application by using network security groups and application security groups.

Duration: 20 minutes

**Reference:**</br>
Azure Network Security Groups</br>
<https://docs.microsoft.com/en-us/azure/virtual-network/security-overview></br>


### Task 1: Create a network security group

#### Create a Network Security Groups using the Azure Cloud Shell.(*Bash*)

> **More Information:** https://docs.microsoft.com/en-us/azure/virtual-machines/windows/quick-create-cli

1. To start Azure Cloud Shell:

- Select the Cloud Shell button on the menu bar at the upper right in the Azure portal. ->

    ![](./images/hdi-cloud-shell-menu.png)


2. Wait the windows apear and enter into the prompt with the following information:

``` Azure CLI
** Virtual Machine - Azure Bastion **
az network nsg create -g networking-handson-rg --name nsg_azurebastion
az network nsg rule create --name bastion-in-allow --nsg-name nsg_azurebastion --priority 100 -g networking-handson-rg --access Allow --protocol Tcp --direction Inbound --destination-port-ranges 443
az network nsg rule create --name bastion-control-in-allow --nsg-name nsg_azurebastion --priority 120 -g networking-handson-rg --access Allow --protocol Tcp --direction Inbound --destination-port-ranges 443 4443 --source-address-prefixes GatewayManager
az network nsg rule create --name bastion-in-deny --nsg-name nsg_azurebastion --priority 900 -g networking-handson-rg --access Deny --protocol Tcp --direction Inbound
az network nsg rule create --name bastion-vnet-out-allow --nsg-name nsg_azurebastion --priority 100 -g networking-handson-rg --access Allow --protocol Tcp --direction Outbound --destination-port-ranges 22 3389 --destination-address-prefixes VirtualNetwork
az network nsg rule create --name bastion-azure-out-allow --nsg-name nsg_azurebastion --priority 120 -g networking-handson-rg --access Allow --protocol Tcp --direction Outbound --destination-port-ranges 443 --destination-address-prefixes AzureCloud
az network vnet subnet update -g networking-handson-rg -n AzureBastionSubnet --vnet-name hubvnet --network-security-group nsg_azurebastion
```

``` Azure CLI
** Virtual Machine - Management Subnet **
az network nsg create -g networking-handson-rg --name nsg_managment
az network nsg rule create --name managment-in-allow_ssh_rdp --nsg-name nsg_managment --priority 100 -g networking-handson-rg --access Allow --protocol Tcp --direction Inbound --destination-port-ranges 22 3389 --source-address-prefixes VirtualNetwork
az network nsg rule create --name managment-in-allow_icmp --nsg-name nsg_managment --priority 120 -g networking-handson-rg --access Allow --protocol Icmp --direction Inbound --source-address-prefixes VirtualNetwork
az network vnet subnet update -g networking-handson-rg -n managementsubnet --vnet-name hubvnet --network-security-group nsg_managment
```

``` Azure CLI
** Virtual Machine - Web Subnet **
az network nsg create -g networking-handson-rg --name nsg_web
az network nsg rule create --name web-in-allow_ssh_rdp --nsg-name nsg_web --priority 100 -g networking-handson-rg --access Allow --protocol Tcp --direction Inbound --destination-port-ranges 22 3389 --destination-address-prefixes VirtualNetwork
az network nsg rule create --name web-in-allow_https_http --nsg-name nsg_web --priority 120 -g networking-handson-rg --access Allow --protocol Tcp --direction Inbound --destination-port-ranges 443 80 --destination-address-prefixes VirtualNetwork
az network nsg rule create --name web-in-allow_icmp --nsg-name nsg_web --priority 130 -g networking-handson-rg --access Allow --protocol Icmp --direction Inbound --source-address-prefixes VirtualNetwork
az network vnet subnet update -g networking-handson-rg -n websubnet --vnet-name spokevnet --network-security-group nsg_web
```

3. Validate if **Network Security Group** is create, run following command:

``` Azure CLI
az network nsg list -g networking-handson-rg --output table
```

## Exercise 5: Configure Azure Bastion Host

In this exercise, you will create and configure an Azure Bastion host. Once you provision the Azure Bastion service in your virtual network, the seamless RDP/SSH experience is available to all of the VMs in the same virtual network. Azure Bastion deployment is per virtual network.

Duration: 15 minutes

**Reference:**</br>
Azure Bastion documentation</br>
<https://docs.microsoft.com/en-us/azure/bastion/></br>


### Task 1: Create Azure Bastion Host

#### Create an Azure Bastion Hosts using the Azure Cloud Shell. (*Powershell*)

> **More Information:** https://docs.microsoft.com/en-us/azure/bastion/bastion-create-host-powershell

1. To start Azure Cloud Shell:

- Select the Cloud Shell button on the menu bar at the upper right in the Azure portal. ->

    ![](./images/hdi-cloud-shell-menu.png)


2. Wait the windows apear and enter into the prompt with the following information:

```Powershell
$vnet = Get-AzVirtualNetwork -Name hubvnet -ResourceGroupName networking-handson-rg 
$publicip = New-AzPublicIpAddress -ResourceGroupName "networking-handson-rg" -name "azurebastionhub-pip" -location "eastus2" -AllocationMethod Static -Sku Standard
$bastion = New-AzBastion -ResourceGroupName "networking-handson-rg" -Name "azurebastionhub" -PublicIpAddress $publicip -VirtualNetwork $vnet
```
After that wait 5 minutes for bastion resoruce to create and deploy.

3. Open the **Azure portal**. Navigate to the virtual machine that you want to connect to, then click Connect. The VM should be a Windows virtual machine when using an RDP connection.

![](./images/bastion-connect.png)

4. After you click Connect, a side bar appears that has three tabs – RDP, SSH, and Bastion. If Bastion was provisioned for the virtual network, the Bastion tab is active by default. If you didn't provision Bastion for the virtual network, you can click the link to configure Bastion

![](./images/bastion-connect-2.png)


5. Connect a Azure Bastion to **azmngserver1** virtual machine and sign in. On **azmngserver1**, open the command prompt and run *ping -t 10.1.1.4* **(azwsserver1)**. The ping should fail.

## Exercise 6: Configure Virtual Network Peering

In this exercise, you will create and configure a Virtual Network peering between hubvnet and spokevnet. These virtual networks can be in the same region or different regions (also known as Global VNet peering). Once virtual networks are peered, resources in both virtual networks are able to communicate with each other, with the same latency and bandwidth as if the resources were in the same virtual network.

Duration: 15 minutes

**Reference:**</br>
Virtual network peering</br>
<https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-peering-overview></br>

### Task 1: Create Virtual Network Peering

#### Create a Virtual Network Peering using the Azure Cloud Shell. (*Bash*)

> **More Information:** https://docs.microsoft.com/en-us/azure/bastion/bastion-create-host-powershell

1. To start Azure Cloud Shell:

- Select the Cloud Shell button on the menu bar at the upper right in the Azure portal. ->

    ![](./images/hdi-cloud-shell-menu.png)


2. Wait the windows apear and enter into the prompt with the following information:

``` Azure CLI
hubvNet1Id=$(az network vnet show --resource-group networking-handson-rg --name hubvnet --query id --out tsv)
spokevNet1Id=$(az network vnet show --resource-group networking-handson-rg --name spokevnet --query id --out tsv)
az network vnet peering create --name hubvnet-to-spokevnet --resource-group networking-handson-rg --vnet-name hubvnet --remote-vnet $spokevNet1Id --allow-vnet-access 
az network vnet peering create --name spokevnet-to-hubvnet --resource-group networking-handson-rg --vnet-name spokevnet --remote-vnet $hubvNet1Id --allow-vnet-access 
```
3. You created a peering from hubvnet to spokehub on both side. Resources in one virtual network cannot communicate with resources in the other virtual network until the **peeringState** for the peerings in both virtual networks is *Connected*. Validate it with following command.

``` Azure CLI
az network vnet peering show --name hubvnet-to-spokevnet --resource-group networking-handson-rg --vnet-name hubvnet --query peeringState
```

## Exercise 7: Create route tables with definition routes

Route Tables are containers for User Defined Routes (UDRs). The route table is created and associated with a subnet. UDRs allow you to direct traffic in ways other than normal system routes would. In this case, UDRs will direct outbound traffic via the Azure firewall.

Duration: 20 minutes

**Reference:**</br>
Virtual network traffic routing</br>
<https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-udr-overview/></br>

### Task 1: Create and configure Route Table

#### Create and Configure a Route Table using the Azure Cloud Shell. (*Bash*)

> **More Information:** https://docs.microsoft.com/en-us/azure/firewall/deploy-cli

1. To start Azure Cloud Shell:

- Select the Cloud Shell button on the menu bar at the upper right in the Azure portal. ->

    ![](./images/hdi-cloud-shell-menu.png)


2. Wait the windows apear and enter into the prompt with the following information:

``` Azure CLI
az network route-table create --name route-hubvnet-managementsubnet --resource-group networking-handson-rg
az network route-table route create --name hubvnet-managementsubnet-to-internet --resource-group networking-handson-rg --route-table-name route-hubvnet-managementsubnet --address-prefix 0.0.0.0/0 --next-hop-type VirtualAppliance --next-hop-ip-address 10.0.8.4
az network vnet subnet update --name managementsubnet --vnet-name hubvnet --resource-group networking-handson-rg --route-table route-hubvnet-managementsubnet

az network route-table create --name route-spokevnet-websubnet --resource-group networking-handson-rg
az network route-table route create --name spokevnet-websubnet-to-internet --resource-group networking-handson-rg --route-table-name route-spokevnet-websubnet --address-prefix 0.0.0.0/0 --next-hop-type VirtualAppliance --next-hop-ip-address 10.0.8.4
az network vnet subnet update --name websubnet --vnet-name spokevnet --resource-group networking-handson-rg --route-table route-spokevnet-websubnet

az network route-table create --name route-onpremvnet-onpresubnet --resource-group networking-handson-rg
az network route-table route create --name onpremvnet-onpresubnet-to-hubvnet --resource-group networking-handson-rg --route-table-name route-onpremvnet-onpresubnet --address-prefix 10.0.1.0/27 --next-hop-type VirtualAppliance --next-hop-ip-address 10.0.8.4
az network vnet subnet update --name GatewaySubnet --vnet-name hubvnet --resource-group networking-handson-rg --route-table route-onpremvnet-onpresubnet

```

## Exercise 8: Configure Azure Firewall

In this exercise, you will create and configure an Azure Firewall and their rules. All the traffic (inside and outside) will be control by Firewall.

Duration: 40 minutes

**Reference:**</br>
Azure Firewall documentation</br>
<https://docs.microsoft.com/en-us/azure/firewall/></br>

### Task 1: Create an Azure Firewall

#### Create a Azure Firewall using the Azure Cloud Shell. (*Bash*)

> **More Information:** https://docs.microsoft.com/en-us/azure/firewall/deploy-cli

1. To start Azure Cloud Shell:

- Select the Cloud Shell button on the menu bar at the upper right in the Azure portal. ->

    ![](./images/hdi-cloud-shell-menu.png)


2. Wait the windows apear and enter into the prompt with the following information:

``` Azure CLI
az extension add -n azure-firewall
az network firewall create --name azfirewall --resource-group networking-handson-rg --location eastus2 
az network public-ip create --name azfirewall-pip --resource-group networking-handson-rg --location eastus2 --allocation-method static --sku standard
az network firewall ip-config create --firewall-name azfirewall --name azfirewall-config --public-ip-address azfirewall-pip --resource-group networking-handson-rg --vnet-name hubvnet
az network firewall update --name azfirewall --resource-group networking-handson-rg
```

### Task 2: Configure rules for Azure Firewall
1. Repeat step 1 from **Task 1** and enter with the following command to create the Azure firewall rules:

``` Azure CLI
az network firewall application-rule create --collection-name app-allow-rule-websites --firewall-name azfirewall --name allow-microsoft --protocols Http=80 Https=443 --resource-group networking-handson-rg --target-fqdns www.microsoft.com  --source-addresses 10.0.2.0/24 --priority 200 --action Allow
az network firewall network-rule create --collection-name net-allow-rule-dns --destination-addresses 168.63.129.16 --destination-ports 53 --firewall-name azfirewall --name allow-azure-dns  --protocols UDP --resource-group networking-handson-rg --priority 200 --source-addresses 10.0.0.0/16 10.1.0.0/16 --action Allow
```
2. Connect a Azure Bastion to **azmngserver1** virtual machine and sign in. On **azmngserver1**, open the internet explorer and first try to navigate in *www.google.com* and second in *www.microsoft.com*.The www.microsoft.com requests should succeed, and the www.google.com requests should fail

### Task 3: Configure monitoring for Azure Firewall

1. Follow step-by-step in the **<https://docs.microsoft.com/en-us/azure/firewall/tutorial-diagnostics#enable-diagnostic-logging-through-the-azure-portal>** to enable the  Diagnostic logs of Azure firewall in Log Analytics workspace.

2. Configure Azure Monitor logs view in **<https://docs.microsoft.com/en-us/azure/firewall/log-analytics-samples#azure-monitor-logs-view>** 

## Exercise 9: Configure Site-to-Site connectivity

Duration: 60 minutes

In this exercise, we will simulate an on-premises connection to the internal web application. To do this, we will first set up another Virtual Network in a separate Azure region followed by the Site-to-Site connection of the 2 Virtual Networks Finally, we will set up a virtual machine in the new Virtual Network to simulate on-premises connectivity to the internal load-balancer

**Reference:**</br>
VPN Gateway documentation</br>
<https://docs.microsoft.com/en-us/azure/vpn-gateway/></br>

### Task 1: Configure gateway subnets and create VPN Gateway for on premise and Azure Hub Virtual Network

#### Create and Configure a VPN Gateway using the Azure Cloud Shell. (*Bash*)

> **More Information:** https://docs.microsoft.com/en-us/azure/vpn-gateway/create-routebased-vpn-gateway-cli

1. To start Azure Cloud Shell:

- Select the Cloud Shell button on the menu bar at the upper right in the Azure portal. ->

    ![](./images/hdi-cloud-shell-menu.png)


2. Wait the windows of bash console apear and run commands with the following information:

``` Azure CLI
* VPN Gateway - On-premises **
az network vnet subnet create --address-prefix 192.168.10.0/27 --name GatewaySubnet --resource-group networking-handson-rg --vnet-name onpremvnet
az network public-ip create -n onpremvnetgw-pip -g networking-handson-rg --allocation-method Dynamic
az network vnet-gateway create -g networking-handson-rg -n onpremvnetgw --public-ip-address onpremvnetgw-pip --vnet onpremvnet --gateway-type Vpn --sku VpnGw1 --vpn-type RouteBased --no-wait

* VPN Gateway - Azure Hub **
az network public-ip create -n hubvnetgw-pip -g networking-handson-rg --allocation-method Dynamic
az network vnet-gateway create -g networking-handson-rg -n hubvnetgw --public-ip-address hubvnetgw-pip --vnet hubvnet --gateway-type Vpn --sku VpnGw1 --vpn-type RouteBased --no-wait
```
A VPN gateway can take 45 minutes or more to create.

### Task 2: Update Virtual Network Peering for Spoke Virtual Network

1. Repeat step 1 from **Task 1** and run following commands to update the Virtual Network Peering:

``` Azure CLI
az network vnet peering update -g networking-handson-rg -n hubvnet-to-spokevnet --vnet-name hubvnet --set allowGatewayTransit=true
az network vnet peering update -g networking-handson-rg -n spokevnet-to-hubvnet --vnet-name spokevnet --set useRemoteGateways=true
``` 
### Task 3: Connect the gateways

1. Repeat step 1 from **Task 1** and run following commands to create a connection between On-premises gateway to Azure Hub Gateway :

``` Azure CLI
hubvgwId=$(az network vnet-gateway show --resource-group networking-handson-rg --name hubvnetgw --query id --out tsv)
onpremgwId=$(az network vnet-gateway show --resource-group networking-handson-rg --name onpremvnetgw --query id --out tsv)
az network vpn-connection create -n HubgwToOnpremgw -g networking-handson-rg --vnet-gateway1 $hubvgwId -l eastus2 --shared-key "Msft@123456@" --vnet-gateway2 $onpremgwId
az network vpn-connection create -n OnpremgwtoHubgw -g networking-handson-rg --vnet-gateway1 $onpremgwId -l eastus2 --shared-key "Msft@123456@" --vnet-gateway2 $hubvgwId
``` 

2. You can verify that your connection succeeded by using the az network vpn-connection show command. In the example, '--name' refers to the name of the connection that you want to test. When the connection is in the process of being established, its connection status shows 'Connecting'. Once the connection is established, the status changes to *Connected*.

``` Azure CLI
az network vpn-connection show --name HubgwToOnpremgw --resource-group networking-handson-rg
az network vpn-connection show --name OnpremgwtoHubgw --resource-group networking-handson-rg
``` 

## Exercise 10: Configure application with Load Balance and Azure Front Door

## After the hands-on lab

Duration: 10 minutes

After you have successfully completed the Azure Networking hands-on lab step-by-step, you will want to delete the Resource Groups. This will free up your subscription from future charges. You should follow all steps provided *after* attending the Hands-on lab.
