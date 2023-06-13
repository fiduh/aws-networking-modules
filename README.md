# AWS networking modules
Create a Virtual Private Cloud (VPC). Includes multiple Subnet tiers, NACLs, NAT gateways, Internet Gateways (IGW), and VPC peering.

This repo contains modules for creating production grade network topology and it's components on AWS

#### Main Modules
The three main modules are:

* vpc-microservices: Launch a vpc meant to house public facing and stateless applications. the VPC includes 2 tiers of subnets (public, hybrid app), internet gateway, routing rules, network access control list, security groups, NAT gateways, egress only gateways.
* vpc-datastore: Launch a vpc meant to house persistent data. the VPC includes a single tier of private subnet, across multiple avaliability zones, routing rules, network ACLs, security groups.
* vpc-mgmt.
