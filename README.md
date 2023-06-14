# AWS networking modules
Create a Virtual Private Cloud (VPC). Includes multiple Subnet tiers, NACLs, NAT gateways, Internet Gateways (IGW), and VPC peering.

This repo contains modules for creating production grade network topology and it's components on AWS

#### Main Modules
The three main modules are:

* vpc-microservices: Launch a vpc meant to house public facing and stateless applications. the VPC includes 2 tiers of subnets (public, hybrid app), internet gateway, routing rules, network access control list, security groups, NAT gateways, egress only gateways.

* vpc-datastores: Launch a vpc meant to house persistent data. the VPC includes a single tier of private subnet, across multiple avaliability zones, routing rules, network ACLs, security groups.


## Supporting Modules
There are several supporting modules that add extra functionality on top of vpc-microservices and vpc-datastores:

* vpc-peering: By default VPCs are completely isolated from each other, but sometimes, you want to allow them communicate, such as allowing the apps in the microservices vpc communicate with the database vpc. This module creates peering connections and route table entries that allows private communication between vpcs
* vpn client: This modules enables remote secure access to resouces on the vpcs
* vpc-flow-logs: Create VPC flow logs to log network traffic in VPCs, subnets, and Elastic Network Interfaces.

Click on each module above to see its documentation. Head over to the example folder for example implemtations.

##### What is a module?
Best-practices implementation of a piece of infrastructure, such as a VPC, EKS Cluster or an Auto Scaling Group defined as reusable code. Modules are versioned using Semantic Versioning to allow users access the latest infrastructure best practices in a systematic way.

Using a Terraform Module

What's a VPC?

Developing a module

Versioning

License
Please see License.txt for details on how the code in this repo is licensed.
