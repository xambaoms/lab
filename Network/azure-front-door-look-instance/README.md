# Azure Labs (Networking) - Azure Front Door - APIM, Azure Web Apps and IIS IaaS VM Lockdown requests to only Front Door instance

## Introduction
In this lab, you will build an Azure Front Door infrastructure and secure that their backend is only getting traffic from your Front Door instance. You will also set up different alternatives as a backend (Web App, APIM, and IaaS VM) to limit that traffic.

 **References:**</br>

## Prerequisites

- Install the Az CLI [Install the Azure CLI](https://docs.microsoft.com/pt-br/cli/azure/install-azure-cli) or use the [Azure Cloud Shell](https://docs.microsoft.com/en-us/azure/cloud-shell/overview) to run it.
- Ensure you are properly logged in to your tenant and with a subscription selected for Azure. You can check that by using:

```azure cli
az account list --output table
az account set --subscription "My Subscription"
```

## Lab
# Azure Web App before Azure Front Door

The following diagram illustrates the traffic flow for inbound connections from an outside client:

![Network Architecture](./images/lab-architeture.png)


## Clean All Resources after the lab

After you have successfully completed the lab, you will want to delete the Resource Groups. Run the following command on Azure Cloud Shell:

``` Azure CLI
## Azure Resources
az group delete --name $rg --location $location
```
For AWS resources check out the articles:

 **References:**</br>
 [How do I delete or terminate my Amazon EC2 resources?](https://aws.amazon.com/premiumsupport/knowledge-center/delete-terminate-ec2/)</br>
 [Deleting a Site-to-Site VPN connection](https://docs.aws.amazon.com/vpn/latest/s2svpn/delete-vpn.html)</br>
 [delete-vpc](https://docs.aws.amazon.com/cli/latest/reference/ec2/delete-vpc.html)

## Contributing
Pull requests are welcome. For major changes. Please make sure to update tests as appropriate.
