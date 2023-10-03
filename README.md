## This repo contains modules for creating production-grade AWS resources, such as EKS Clusters, VPC, RDS, S3, DynamoDB, etc


#### What is a module?

Best-practices implementation of a piece of infrastructure, such as a VPC, EKS Cluster, or an Auto Scaling Group defined as reusable, customizable, immutable, and versioned code. Modules are versioned using Semantic Versioning to allow users access to the latest infrastructure best practices in a systematic way.

#### Using a Terraform Module
To use a module in your Terraform templates, create module resources and set its source field to the GIT URL of this repo. You should also set the ref parameter so you're fixed to a specific version of this repo, as the master branch may have backward incompatible changes. For example, to use <code>v1.0.8</code> of the VPC module, you would add the following:

```hcl

data "aws_availability_zones" "available_azs" {
  state = "available"
}

locals {
  azs = slice(data.aws_availability_zones.available_azs.names, 0, 2)
  vpc_cidr = "10.0.0.0/21"
}

module "vpc" {
  source = "github.com/fiduh/aws-networking-modules//modules/vpc?ref=v0.1.0"
  name = "vpc-app"
  azs = local.azs
  vpc_cidr_block = local.vpc_cidr

  public_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 3, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 3, k + 3)]
  
  enable_single_nat = true
  one_nat_gateway_per_subnet = false

  tags = {
    ManagedBy : "Terraform" 
  }
}

```

Note: *the double slash (//) is intentional and required*. it's part of Terraform's Git syntax. See the module's documentation and variable.tf file for all the parameters you can set. Run ` terraform get -update` to pull the latest version of this module from this repo before running the standard ` terraform plan ` and ` terraform apply ` commands.


### Developing a module

#### Versioning
We are following the principles of [Semantic Versioning](https://semver.org/). During initial development, the major version is 0 (e.g., `0.x.y`), which indicates the code does not yet have a stable API. Once we hit `1.0.0` we follow these rules:
1. Increment the patch version for backwards-compatible bug fixes (e.g., `v1.0.8 -> v1.0.9`).
2. Increment the minor version for new features that are backwards-compatible (e.g.,`v1.0.8 -> 1.1.0`).
3. Increment the major version for any backwards-incompatible changes (e.g.`1.0.8 -> 2.0.0`).

The version is defined using Git tags. Use GitHub UI to create a release, which will create a tag under the hood, or you can use the Git CLI:

```bash
git tag -a "v0.0.1" -m "First release"
git push --follow-tags

```


#### License
Please see [License](https://github.com/osemiduh/aws-networking-modules/blob/main/LICENSE) for details on how the code in this repo is licensed.
