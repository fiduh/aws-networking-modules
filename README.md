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

#### What is a module?
Best-practices implementation of a piece of infrastructure, such as a VPC, EKS Cluster or an Auto Scaling Group defined as reusable code. Modules are versioned using Semantic Versioning to allow users access the latest infrastructure best practices in a systematic way.

#### Using a Terraform Module
To use a module in your Terraform templates, create a module resources and set its source field to the GIT URL of this repo. You should also set the ref parameter so you're fixed to a specific version of this repo, as the master branch may have backwards incompatible changes. For example, to use <code>v1.0.8</code> of the vpc module, you would add the following:

```

module "ecs_cluster" {
  source = "git::git@github.com:/osemiduh/aws-networking-modules/modules/vpc-microservices?ref=v1.0.8"

  // set the parameters for the vpc-microservices module
} 

```

Note: the double slash (//) is intentional and required. it's part of Terraform's Git syntax. See the module's documentation and vars.tf file for all the parameters you can set. Run ` terraform get -update` to pull the latest version of this module from this repo before running the standard terraform plan and terraform apply commands.

#### What's a VPC?

### Developing a module

#### Versioning
We are following the principles of [Semantic Versioning](https://semver.org/). During initial development, the major version is 0 (e.g., == 0.x.y ==), which indicates the code does not yet have a stable API. Once we hit `1.0.0` we follow these rules:
1. Increment the patch version for backwards-compatible bug fix (e.g., `v1.0.8 -> v1.0.9`).
2. Increment the minor version for new features that are backwards-compatible (e.g.,`v1.0.8 -> 1.1.0`).
3. Increment the major version for any backwards-incompatible changes (e.g.`1.0.8 -> 2.0.0`).

The version is defined using Git tags. Use GitHub to create a release, which will have the effect of adding a git tag.


#### License
Please see [License](https://github.com/osemiduh/aws-networking-modules/blob/main/LICENSE) for details on how the code in this repo is licensed.
