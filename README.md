# Azure Virtual Network Manager Demo

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fchrisdoofer%2FAVNMDemo%2Fmain%2Fazuredeploy.json)

This template deploys a specified number of VNETs (1 - 254), each with a small Windows VM with a custom script extension to deploy IIS. 

The address space in each VNET is unique: 10.0.<1-254>.0.

The goal behind this is to provide a base infrastructure to demonstrate the key capabilities of Azure Virtual Network Manager.

Usage:
- Create a resource group in your region of choice.
- Deploy the template to the resource group.
- Deploy ANM to the resource group.
- Configure and test AVNM per instructions provided in this repo.

