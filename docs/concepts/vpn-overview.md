# Cluster VPN overview

This chapter summarizes Virtual Private Network (VPN) architecture for multi-cloud private network.

### Cloud provided VPN

!!! note
    Cloud provided VPN is currently not available on Digital Ocean.
    
Cloud provided VPN - a VPN option provided by a cloud service provider.



**Traffic in CAST AI platform:**

In order to access Virtual Private Cloud (VPC) network of each node CAST AI platform
provisions managed Highly Available (HA) VPN gateways.

- VPN Gateway is created on each cloud and adds additional cluster costs.
- Traffic between nodes in different VPC is always encrypted.
- Traffic between nodes in the same VPC is plaintext.

Example with nodes on AWS, AZURE and GCP clouds:

![](vpn-overview/cloudvpn.svg)



### WireGuard VPN

WireGuard VPN - CAST AI integrated alternative to Cloud provided VPN. This option is optimized for cost saving. 

You can choose between two topologies:

| Topology | Description |
|---|---|
| Full Mesh | Traffic is encrypted between each node even if it is located in the same VPC. |
| Cross Location Mesh | Traffic is encrypted only between nodes in different VPC. |



**Traffic in CAST AI platform:**

Each node runs WireGuard kernel module. VPN peers configuration, keys exchange, network interfaces
and routing tables are fully managed by CAST AI platform.

- Each nodes has public IP for node to node communication.
- Firewall rules allows to send/receive UDP packets on 51820 port for each node.
- Each node assigned private IP from clouds VPC subnet range and WireGuard interface IP
from 10.4.0.0/16 subnet.
- Traffic between nodes in different VPC is always encrypted.
- Traffic between nodes in the same VPC is encrypted or plaintext depending on topology selection.

Example with nodes on AWS, AZURE, GCP and DIGITAL OCEAN clouds:

![](vpn-overview/wireguard.svg)


