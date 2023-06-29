Terraform module which creates VPC resources on AWS

This repo contains modules for creating production-grade VPC and other related components on AWS

## Main Module

* VPC: Customizable, versioned, and immutable VPC meant to house public-facing and stateless applications or persistent data. The VPC includes Subnets (public, private), Internet gateway (IGW), Route Tables and routing rules, Network Access Control List (NACL), Security Groups, NAT Gateways.



## Supporting Modules
There are several supporting modules that add extra functionality on top of the Main Module:

* VPC-Peering: By default, VPCs are completely isolated from each other, but sometimes, you want to allow them to communicate, such as allowing the apps in a  VPC housing public-facing applications to communicate with the database VPC. This module creates peering connections and route table entries that allow private communication between VPCs
* VPN client: This module enables remote secure access to resources on the VPCs
* VPC-Flow-Logs: Create VPC flow logs to log network traffic in VPCs, subnets, and Elastic Network Interfaces.

Click on each module above to see its documentation. Head over to the example folder for example implementations.

#### What is a module?

Best-practices implementation of a piece of infrastructure, such as a VPC, EKS Cluster, or an Auto Scaling Group defined as reusable, customizable, immutable, and versioned code. Modules are versioned using Semantic Versioning to allow users access to the latest infrastructure best practices in a systematic way.

#### Using a Terraform Module
To use a module in your Terraform templates, create module resources and set its source field to the GIT URL of this repo. You should also set the ref parameter so you're fixed to a specific version of this repo, as the master branch may have backward incompatible changes. For example, to use <code>v1.0.8</code> of the VPC module, you would add the following:

```

module "vpc" {
  source = "git::git@github.com:/osemiduh/aws-networking-modules/modules/vpc-microservices?ref=v1.0.8"
  name = "vpc-app"
  vpc_cidr_block = "10.0.0.0/21"

  public_subnets_cidr_with_azs = {
  "us-east-1a" = "10.0.0.0/24"
  "us-east-1b" = "10.0.1.0/24"
  }

  private_subnets_cidr_with_azs = {
  "us-east-1a" = "10.0.2.0/24"
  "us-east-1b" = "10.0.3.0/24"
  }
  
  enable_single_nat = true

  tags = {
    ManagedBy : "Terraform" 
  } 

```

Note: the double slash (//) is intentional and required. it's part of Terraform's Git syntax. See the module's documentation and variable.tf file for all the parameters you can set. Run ` terraform get -update` to pull the latest version of this module from this repo before running the standard ` terraform plan ` and ` terraform apply ` commands.

#### What's a VPC?

AWS VPC

VPC is your logically isolated virtual network on Amazon’s public cloud, where you can deploy your own resources. It spans an entire region, made up of several Availability Zones. You can further divide your network into multiple smaller networks called subnets, where you can create AWS resources, such as EC2 instances.

To allow communication between resources in your VPC and the internet, you need an internet gateway attached to the VPC, route tables directing local traffic to the IGW has to be associated with the subnets that needs access to the internet

To secure this network, NACLs determine which traffic is allowed in and out of your subnets, Security groups control which traffic are allowed to reach the resources you deployed in your network

### Developing a module

#### Versioning
We are following the principles of [Semantic Versioning](https://semver.org/). During initial development, the major version is 0 (e.g., `0.x.y`), which indicates the code does not yet have a stable API. Once we hit `1.0.0` we follow these rules:
1. Increment the patch version for backwards-compatible bug fix (e.g., `v1.0.8 -> v1.0.9`).
2. Increment the minor version for new features that are backwards-compatible (e.g.,`v1.0.8 -> 1.1.0`).
3. Increment the major version for any backwards-incompatible changes (e.g.`1.0.8 -> 2.0.0`).

The version is defined using Git tags. Use GitHub UI to create a release, which will create a tag under the hood, or you can use the Git CLI:

```
git tag -a "v0.0.1" -m "First release"
git push --follow-tags

```


#### License
Please see [License](https://github.com/osemiduh/aws-networking-modules/blob/main/LICENSE) for details on how the code in this repo is licensed.
