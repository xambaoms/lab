## Azure Networking Lab - Azure Virtual WAN - Site to Site VPN with Windows RRAS 

This lab guide how to build a basic Virtual WAN infrastructure including simulated on prem sites (no hardware needed). This is for testing purposes only and should not be considered production configurations. The lab builds two "on prem" VNETs allowing you to simulate your infrastructure. The two on prem sites connect to the VWAN hub via an IPSEC/IKEv2 tunnel that is also connected to two VNETs. At the end of the lab, the two on prem sites will be able to talk to the VNETs as well as each other through the tunnel. The base infrastructure configurations for the on prem environments will not be described in detail. The main goal is to quickly build a test VWAN environment so that you can overlay 3rd party integration tools if needed. You only need to access the portal to download the configuration file of VWAN to determine the public IPs of the VPN gateways. All other configs are done in Azure CLI and/or Windows RRASS so you can change them as needed to match your environment.

**Requirements:**

- A valid Azure subscription account. If you don’t have one, you can create your free azure account (https://azure.microsoft.com/en-us/free/) today.
- Latest Azure CLI, follow these instructions to install: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
- 
   
> [!NOTE]
> - Azure CLI and Cloud Shell for VWAN are in preview and require the "virtual-wan" extension. You can view the extensions by running "az extension list-available --output table". Install the extension "az extension add --name virtual-wan".


<span style="color:blue;font-size:2em">**Azure Virtual WAN Lab Architecture** </span>

![Virtual WAN](./images/virtualwan1.png#center)


**Create the VWAN hub that allows on prem to on prem to hairpin through the tunnel. The address space used should not overlap. VWAN deploys 2 "appliances" as well as a number of underlying components. We're starting here as the last command can take 30+ minutes to deploy. By specifying "--no-wait", you can move on to other steps while this section of VWAN continues to deploy in the background. **