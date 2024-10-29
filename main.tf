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
module "module_vpc_a" {
  source  = "app.terraform.io/marvsmpb/vpc-module-marvs/aws"
  version = "1.0.3"

  vpc_cidr_block = "10.50.0.0/16"
  vpc_tags = {
    Name        = "${local.projectname}-${local.environment}-vpc-a"
    Environment = local.environment
  }
}

## PUBLIC SUBNET
module "module_public_subnet_a" {
  source  = "app.terraform.io/marvsmpb/subnet-marvs/aws"
  version = "0.0.13"

  subnet_vpc         = module.module_vpc_a.output_vpc_id
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
module "module_firewall_subnet_a" {
  source  = "app.terraform.io/marvsmpb/subnet-marvs/aws"
  version = "0.0.13"

  subnet_vpc  = module.module_vpc_a.output_vpc_id
  subnet_az   = "ap-southeast-1a"
  subnet_cidr = "10.50.20.0/24"
  subnet_tags = {
    Name        = "${local.projectname}-${local.environment}-firewall-subnet-a"
    Environment = local.environment
  }
}

## WORKLOAD SUBNET
module "module_workload_subnet_a" {
  source  = "app.terraform.io/marvsmpb/subnet-marvs/aws"
  version = "0.0.13"

  subnet_vpc  = module.module_vpc_a.output_vpc_id
  subnet_az   = "ap-southeast-1a"
  subnet_cidr = "10.50.30.0/24"
  subnet_tags = {
    Name        = "${local.projectname}-${local.environment}-workload-subnet-a"
    Environment = local.environment
  }
}

## PEERING CONNECTION (ACCEPTER)
module "module_peering_accepter" {
  source  = "app.terraform.io/marvsmpb/vpc-peering-accepter-marvs/aws"
  version = "0.0.6"

  peering_connection_id = module.module_peer_owner.output_peering_id
  peer_tags = {
    Name        = "${local.projectname}-${local.environment}-peering-a"
    Environment = local.environment
  }
}

## WORKLOAD SUBNET ROUTE TABLE
module "module_vpc_a_workload_subnet_rtb" {
  source  = "app.terraform.io/marvsmpb/rtb-marvs/aws"
  version = "0.0.4"

  rtb_vpc                                  = module.module_vpc_a.output_vpc_id
  route_peering_bool                       = true
  route_peering                            = module.module_peering_accepter.output_peering_id
  route_vpc_peering_destination_cidr_block = "10.60.0.0/16"

  #route_endpoint
  #route_endpoint_bool
  #route_endpoint_destination_cidr_block

  rtb_tags = {
    Name        = "${local.projectname}-${local.environment}-private-rtb-b"
    Environment = local.environment
  }
}

## FIREWALL SUBNET ROUTE TABLE
module "module_vpc_a_firewall_subnet_rtb" {
  source  = "app.terraform.io/marvsmpb/rtb-marvs/aws"
  version = "0.0.4"

  rtb_vpc = module.module_vpc_a.output_vpc_id

  route_nat_gateway_bool                   = true
  route_nat_gateway                        = module.module_public_subnet_a.outputs_nat_gateway_id
  route_nat_gateway_destination_cidr_block = "0.0.0.0/0"

  rtb_tags = {
    Name        = "${local.projectname}-${local.environment}-private-rtb-b"
    Environment = local.environment
  }
}

## PUBLIC SUBNET ROUTE TABLE
module "module_vpc_a_public_subnet_rtb" {
  source  = "app.terraform.io/marvsmpb/rtb-marvs/aws"
  version = "0.0.4"

  rtb_vpc = module.module_vpc_a.output_vpc_id

  route_internet_gateway_bool                   = true
  route_internet_gateway                        = module.module_public_subnet_a.outputs_internet_gateway_id
  route_internet_gateway_destination_cidr_block = "0.0.0.0/0"


  rtb_tags = {
    Name        = "${local.projectname}-${local.environment}-private-rtb-b"
    Environment = local.environment
  }
}


### VPC B ###

## VPC
module "module_vpc_b" {
  source  = "app.terraform.io/marvsmpb/vpc-module-marvs/aws"
  version = "1.0.3"

  vpc_cidr_block = "10.60.0.0/16"
  vpc_tags = {
    Name        = "${local.projectname}-${local.environment}-vpc-b"
    Environment = local.environment
  }
}

## WORKLOAD SUBNET
module "module_workload_subnet_b" {
  source  = "app.terraform.io/marvsmpb/subnet-marvs/aws"
  version = "0.0.13"

  subnet_vpc  = module.module_vpc_b.output_vpc_id
  subnet_az   = "ap-southeast-1a"
  subnet_cidr = "10.60.10.0/24"
  subnet_tags = {
    Name        = "${local.projectname}-${local.environment}-workload-subnet-b"
    Environment = local.environment
  }
}

## PEERING CONNECTION (OWNER)
module "module_peer_owner" {
  source  = "app.terraform.io/marvsmpb/vpc-peering-owner-marvs/aws"
  version = "0.0.3"

  vpc_id      = module.module_vpc_b.output_vpc_id
  peer_vpc_id = module.module_vpc_a.output_vpc_id
  owner_tags = {
    Name        = "${local.projectname}-${local.environment}-peering-b"
    Environment = local.environment
  }
}

## WORKLOAD SUBNET ROUTE TABLE
module "module_vpc_b_workload_subnet_rtb" {
  source  = "app.terraform.io/marvsmpb/rtb-marvs/aws"
  version = "0.0.4"

  rtb_vpc                                  = module.module_vpc_b.output_vpc_id
  route_peering_bool                       = true
  route_peering                            = module.module_peer_owner.output_peering_id
  route_vpc_peering_destination_cidr_block = "0.0.0.0/0"

  rtb_tags = {
    Name        = "${local.projectname}-${local.environment}-private-rtb-b"
    Environment = local.environment
  }
}