# Azure Virtual Network Manager Overview

Azure Virtual Network Manager is a highly scalable and highly available network management solution that lets you manage virtual network connectivity and network security rules. Currently, AVNM supports connectivity and security admin configuration features. AVNM allows you to group, configure, deploy, and manage virtual networks at scale across your subscriptions and Azure regions. Network managers can be scoped at any level (or multiple! See below.) of your management group or subscription hierarchy as long as you have the network contributor role, and all child virtual networks “downstream” can be managed from a single pane of glass.

Below, if you select the scope for your AVNM to be only management group A, then the VNets under subscriptions D, E, and F (which are ultimately encapsulated within management group A) are all visible to that network manager.

![Hierarchy](/images/AVNM HierarchyandScoping.png)
	
	
	 
	
	
	
				
		
			
				
						
				Simple and Central Azure Virtual Network Management Using the New Azure Virtual Network Manager
							
						
					
			
		
	
			
	
	
	
	
	

 

Additionally, you can create multiple AVNMs – as long as two AVNMs do not have the exact same scope and feature combination, they can coexist and the configurations of these AVNMs will be overlayed. The reason why AVNM has this design is because this ensures that VNets would know which AVNM’s configuration would prevail when there is a conflict.

For example, referencing the diagram above, you can have one AVNM scoped to management group A for corporate-wide enforcement; and another AVNM scoped to management group C for business- or environment-specific security or connectivity purposes. These two AVNMs can be used by two different teams. When there is a conflict between the security admin configurations from different AVNMs, the configuration from the AVNM with a higher-level scope will prevail. 

# So, What Can AVNM Do?

At a high level, AVNM can create connectivity configurations and/or security admin configurations to control either network connectivity and/or network security.

Connectivity configuration: this will create connections between Azure VNets in either hub and spoke or full mesh topologies. In the hub and spoke topology, you can also enable an option to allow spoke VNets to connect directly to each other without going through the hub VNet. In the example shown below, you can allow the “Prod” spoke VNets to connect to each other, while the “Test” VNets do not.

![Connectivity](/images/AVNMConnectivity.png)
	
	
	 
	
	
	
				
		
			
				
						
				Simple and Central Azure Virtual Network Management Using the New Azure Virtual Network Manager
							
						
					
			
		
	
			
	
	
	
	
	
Security admin configuration:  this will create security admin rules for controlling either inbound or outbound traffic. Security admin rules are evaluated prior to NSG rules as shown below, so you can use this security admin configuration to create and enforce organizational level rules.
 
![Security](/images/AVNMSecurity.png)
 
	
	
	 
	
	
	
				
		
			
				
						
				Simple and Central Azure Virtual Network Management Using the New Azure Virtual Network Manager
							
						
					
			
		
	
			
	
	
	
	
	


This demo environment seeks to provide a pre-configured environment to demonstrate the following key use cases:

1. Connectivity 

    a) Configuring Full Mesh Network
    
    b) Configuring Hub & Spoke
    
    c) Configuring Hub & Spoke with Direct Spoke Connectivity

2. Security

    a) Configuring Security Admin Rules

You can read more on the common use cases for leveraging Azure Virtual Network Manager here:

https://docs.microsoft.com/en-us/azure/virtual-network-manager/concept-use-cases
