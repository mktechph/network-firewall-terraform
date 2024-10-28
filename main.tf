terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.73.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

locals {
  projectname = "network-firewall-project"
  environment = "test"
}


### VPC A ###

## VPC
module "module-vpc-a" {
  source  = "app.terraform.io/marvsmpb/vpc-module-marvs/aws"
  version = "1.0.3"

  vpc_cidr_block = "10.50.0.0/16"
  vpc_tags = {
    Name        = "${local.projectname}-${local.environment}-vpc-a"
    Environment = local.environment
  }
}

## PUBLIC SUBNET
module "module-public-subnet-a" {
  source  = "app.terraform.io/marvsmpb/subnet-marvs/aws"
  version = "0.0.8"

  subnet_vpc         = module.module-vpc-a.output_vpc_id
  subnet_az          = "ap-southeast-1a"
  subnet_cidr        = "10.50.10.0/24"
  subnet_public_bool = true
  subnet_nat_bool    = true
  subnet_tags = {
    Name        = "${local.projectname}-${local.environment}-public-subnet-a"
    Environment = local.environment
  }
  igw_tags = {
    Name        = "${local.projectname}-${local.environment}-igw-a"
    Environment = local.environment
  }
  nat_tags = {
    Name        = "${local.projectname}-${local.environment}-natgw-a"
    Environment = local.environment
  }
}

## FIREWALL SUBNET
module "module-firewall-subnet-a" {
  source  = "app.terraform.io/marvsmpb/subnet-marvs/aws"
  version = "0.0.8"

  subnet_vpc  = module.module-vpc-a.output_vpc_id
  subnet_az   = "ap-southeast-1a"
  subnet_cidr = "10.50.20.0/24"
  subnet_tags = {
    Name        = "${local.projectname}-${local.environment}-firewall-subnet-a"
    Environment = local.environment
  }
}

## WORKLOAD SUBNET
module "module-workload-subnet-a" {
  source  = "app.terraform.io/marvsmpb/subnet-marvs/aws"
  version = "0.0.8"

  subnet_vpc  = module.module-vpc-a.output_vpc_id
  subnet_az   = "ap-southeast-1a"
  subnet_cidr = "10.50.30.0/24"
  subnet_tags = {
    Name        = "${local.projectname}-${local.environment}-workload-subnet-a"
    Environment = local.environment
  }
}

## PEERING CONNECTION (ACCEPTER)
module "peering_accepter" {
  source  = "app.terraform.io/marvsmpb/vpc-peering-accepter-marvs/aws"
  version = "0.0.2"

  peer_vpc_id = module.module-vpc-b.output_vpc_id
  peer_tags = {
    Name        = "${local.projectname}-${local.environment}-peering-a"
    Environment = local.environment
  }
}


### VPC B ###

## VPC
module "module-vpc-b" {
  source  = "app.terraform.io/marvsmpb/vpc-module-marvs/aws"
  version = "1.0.3"

  vpc_cidr_block = "10.60.0.0/16"
  vpc_tags = {
    Name        = "${local.projectname}-${local.environment}-vpc-b"
    Environment = local.environment
  }
}

## WORKLOAD SUBNET
module "module-workload-subnet-b" {
  source  = "app.terraform.io/marvsmpb/subnet-marvs/aws"
  version = "0.0.8"

  subnet_vpc  = module.module-vpc-b.output_vpc_id
  subnet_az   = "ap-southeast-1a"
  subnet_cidr = "10.60.10.0/24"
  subnet_tags = {
    Name        = "${local.projectname}-${local.environment}-workload-subnet-b"
    Environment = local.environment
  }
}

## PEERING CONNECTION (OWNER)
module "peer-owner" {
  source  = "app.terraform.io/marvsmpb/vpc-peering-owner-marvs/aws"
  version = "0.0.1"

  vpc_id      = module.module-vpc-b.output_vpc_id
  peer_vpc_id = module.module-vpc-a.output_vpc_id
  owner_tags = {
    Name        = "${local.projectname}-${local.environment}-peering-b"
    Environment = local.environment
  }
}