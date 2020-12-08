# Azure Networking - Address Space Maintance with vNET Peering

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

> **More Information:** https://docs.microsoft.com/en-us/azure/virtual-network/quick-create-portal

## Contributing

Pull requests are welcome. For major changes. Please make sure to update tests as appropriate.
