## Terraform module which creates VPC resources on AWS

## Main Module

* VPC: Customizable, versioned, and immutable VPC meant to house public-facing and stateless applications or persistent data. The VPC includes Subnets (public, private), Internet gateway (IGW), Route Tables and routing rules, Network Access Control List (NACL), Security Groups, NAT Gateways.



### Supporting Modules
---
There are several supporting modules that add extra functionality on top of the Main Module:

* **VPC-Peering** : By default, VPCs are completely isolated from each other, but sometimes, you want to allow them to communicate, such as allowing the apps in a  VPC housing public-facing applications to communicate with the database VPC. This module creates peering connections and route table entries that allow private communication between VPCs
* **VPN client**: This module enables remote secure access to resources on the VPCs
* **VPC-Flow-Logs**: Create VPC flow logs to log network traffic in VPCs, subnets, and Elastic Network Interfaces.

Click on each module above to see its documentation. *Head over to the example folder, for example, implementations*.

## NAT Gateway Scenarios
This module supports two scenarios for creating NAT gateways.
### Single NAT Gateway
If `enable_single_nat = true`, then all private subnets will route their Internet traffic through this single NAT gateway. The NAT gateway will be placed in the first public subnet in your public_subnets block.
   `enable_single_nat = true`
  `one_nat_gateway_per_az = false`

## One NAT Gateway per Public Subnet per Availability Zone (if enabled)
If `one_nat_gateway_per_az = true` and `enable_single_nat = false`, then the module will place one NAT gateway in each Public Subnet per Availability Zone you specify in public_subnets_cidr_with_azs.
   `one_nat_gateway_per_az = true`
   `enable_single_nat = false`


#### What's a VPC?

AWS VPC is your logically isolated virtual network on Amazon’s public cloud, where you can deploy your own resources. It spans a single region (Max. 5 VPCs per region - soft limit), made up of several Availability Zones. You can further divide your network into multiple smaller networks called subnets (Max. 200 subnets per VPC - soft limit), where you can create AWS resources, such as EC2 instances.

To allow communication between resources in your VPC and the internet, you need an internet gateway attached to the VPC, route table containing routes directing local traffic to the IGW has to be associated with the subnets that need access to the internet

To secure this network, NACLs determine which traffic is allowed in and out of your subnets, Security groups control which traffic is allowed to reach the resources you deployed in your network

Because VPC is Private, only [Private IPv4 Network Ranges RFC1918](https://datatracker.ietf.org/doc/html/rfc1918) of Internet Engineering Task Force (IETF) are allowed as VPC CIDRs.
```
10.0.0.0 - 10.255.255.255 (10.0.0.0/8)
172.16.0.0 - 172.31.255.255 (172.16.0.0/12)
192.168.0.0 - 192.168.255.255 (192.168.0.0/16)

```



When in doubt use [IP address Guide](www.ipaddressguide.com/cidr) to calculate the number of IP addresses in your CIDR
Max CIDR per VPC 5, for each CIDR
```
  Min. size is /28 (16 IP addresses)
  Max. size is /16 (65536 IP addresses)
```
Two private VPCs can communicate with each other using VPC Peering
