# Azure Networking Lab - Address Space Maintance with vNET Peering

## Introduction

This script dumps all vNET peering information with their relationship, also will export all information to a backup file, and you will set up the new address space on vNET with vNET peering connected from the vNET address space file.

## Requirements

- Install the powershell [Az modules](https://docs.microsoft.com/pt-br/powershell/azure/install-az-ps?view=azps-5.1.0) or use the [Azure Cloud Shell](https://docs.microsoft.com/en-us/azure/cloud-shell/overview) to run it.
- Ensure you are properly logged in to your tenant and with a subscription selected. You can check that by using:

```PowerShell
Add-AzAccount #Logon on your Azure Tenant
Get-AzContext # Check you have selected the correct Azure Subscription
Set-AzContext -Subscription <Subscription Name> # Set appropriate Subscription
```

## Known Issues

- After you establish a vNET peering is it not possible to change the address spaces inside Virtual Network without removing the vNET peering.

## Script
- Save the powershell script file (*azure-vnetpeering-addess-spacemaintenace.ps1*) in specific path and add the required parameters:
    - **$vnetname** = "Add Virtual Network Name"
    - **$rg** = "Add Resource Group Virtual Network"
    - **$exportPat** = "Add path to export the vNET Peering backup file"
    - **$addvnetPath** = "Inform path and file name with extesion to Add the address space inside vNET. For    example: c:\temp\vnet.txt"

Run the command:

***azure-vnetpeering-addess-spacemaintenace.ps1 -vnetname vNETName -rg ResourceGroup -exportPat FilePath -addvnetPath FullFilePath***

## Lab
In this lab, you will setup two virtual networks in a hub-and-spoke design and configure a azure private peering between both vNETs. You will execute the powershell script to print the peering information, take a backup of all vNET information and add new address space into the hub vNET using a file with .txt extension. See the topology of this Lab environment:

![Network Architecture](./images/hub-spoke.png)

## Contributing

Pull requests are welcome. For major changes. Please make sure to update tests as appropriate.
