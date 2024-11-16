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
  #projectname = "network-firewall-project"
  projectname = "Kyndryl-FW"
  environment = "test"
}


############ VPC A ############

### VPC
#module "module_vpc_a" {
#  source  = "app.terraform.io/marvsmpb/vpc-module-marvs/aws"
#  version = "1.0.3"
#
#  vpc_cidr_block = "10.50.0.0/16"
#  vpc_tags = {
#    Name        = "${local.projectname}-${local.environment}-vpc-a"
#    Environment = local.environment
#    Project     = local.projectname
#  }
#}
#
## SSM VPC ENDPOINTS
##module "module_vpc_a_ssm_endpoints" {
##  source  = "app.terraform.io/marvsmpb/vpc-endpoint-ssm/aws"
##  version = "0.0.2"
##
##  vpc_id                 = module.module_vpc_a.output_vpc_id
##  ssm_endpoint_subnet_id = [module.module_workload_subnet_a.outputs_subnet_id]
##  ssm_messages_subnet_id = [module.module_workload_subnet_a.outputs_subnet_id]
##  ec2_messages_subnet_id = [module.module_workload_subnet_a.outputs_subnet_id]
##
##  endpoint_tags = {
##    Name        = "${local.projectname}-${local.environment}-vpc-a-ssm"
##    Environment = local.environment
##    Project     = local.projectname
##  }
##}
#
### PUBLIC SUBNET
#module "module_public_subnet_a" {
#  source  = "app.terraform.io/marvsmpb/subnet-marvs/aws"
#  version = "0.0.14"
#
#  subnet_vpc         = module.module_vpc_a.output_vpc_id
#  subnet_az          = "ap-southeast-1a"
#  subnet_cidr        = "10.50.10.0/24"
#  subnet_public_bool = true
#  subnet_nat_bool    = true
#  subnet_tags = {
#    Name        = "${local.projectname}-${local.environment}-public-subnet-a"
#    Environment = local.environment
#    Project     = local.projectname
#  }
#  igw_tags = {
#    Name        = "${local.projectname}-${local.environment}-igw-a"
#    Environment = local.environment
#    Project     = local.projectname
#  }
#  nat_tags = {
#    Name        = "${local.projectname}-${local.environment}-natgw-a"
#    Environment = local.environment
#    Project     = local.projectname
#  }
#  eip_tags = {
#    Name        = "${local.projectname}-${local.environment}-eip-a"
#    Environment = local.environment
#    Project     = local.projectname
#  }
#}
#
### FIREWALL SUBNET
#module "module_firewall_subnet_a" {
#  source  = "app.terraform.io/marvsmpb/subnet-marvs/aws"
#  version = "0.0.14"
#
#  subnet_vpc  = module.module_vpc_a.output_vpc_id
#  subnet_az   = "ap-southeast-1a"
#  subnet_cidr = "10.50.20.0/24"
#  subnet_tags = {
#    Name        = "${local.projectname}-${local.environment}-firewall-subnet-a"
#    Environment = local.environment
#    Project     = local.projectname
#  }
#}
#
### WORKLOAD SUBNET
#module "module_workload_subnet_a" {
#  source  = "app.terraform.io/marvsmpb/subnet-marvs/aws"
#  version = "0.0.14"
#
#  subnet_vpc  = module.module_vpc_a.output_vpc_id
#  subnet_az   = "ap-southeast-1a"
#  subnet_cidr = "10.50.30.0/24"
#  subnet_tags = {
#    Name        = "${local.projectname}-${local.environment}-workload-subnet-a"
#    Environment = local.environment
#    Project     = local.projectname
#  }
#}
#
### PEERING CONNECTION (ACCEPTER)
#module "module_peering_accepter" {
#  source  = "app.terraform.io/marvsmpb/vpc-peering-accepter-marvs/aws"
#  version = "0.0.6"
#
#  peering_connection_id = module.module_peer_owner.output_peering_id
#  peer_tags = {
#    Name        = "${local.projectname}-${local.environment}-peering-a"
#    Environment = local.environment
#    Project     = local.projectname
#  }
#}
#
### WORKLOAD SUBNET ROUTE TABLE
#module "module_vpc_a_workload_subnet_rtb" {
#  source  = "app.terraform.io/marvsmpb/rtb-marvs/aws"
#  version = "0.0.6"
#
#  rtb_vpc = module.module_vpc_a.output_vpc_id
#  #route_peering_bool                       = true
#  #route_peering                            = module.module_peering_accepter.output_peering_id
#  #route_vpc_peering_destination_cidr_block = "10.60.0.0/16"
#
#  ## FIREWALL ENDPOINT                                                    
#  route_endpoint                        = element(flatten([for status in tolist(module.module_vpc_a_firewall.output_network_firewall_sync_states) : [for sync in status : sync.attachment[0].endpoint_id if length([for attach in sync.attachment : attach.subnet_id if attach.subnet_id == module.module_firewall_subnet_a.outputs_subnet_id]) > 0]]), 0)
#  route_endpoint_bool                   = true
#  route_endpoint_destination_cidr_block = "0.0.0.0/0"
#
#  rtb_tags = {
#    Name        = "${local.projectname}-${local.environment}-workload-rtb-a"
#    Environment = local.environment
#    Project     = local.projectname
#  }
#}
#
### WORKLOAD SUBNET ROUTE TABLE ASSOCIATION
#resource "aws_route_table_association" "rtb_assoc_vpc_a_workload_rtb" {
#  subnet_id      = module.module_workload_subnet_a.outputs_subnet_id
#  route_table_id = module.module_vpc_a_workload_subnet_rtb.outputs_rtb_id
#}
#
### FIREWALL SUBNET ROUTE TABLE
#module "module_vpc_a_firewall_subnet_rtb" {
#  source  = "app.terraform.io/marvsmpb/rtb-marvs/aws"
#  version = "0.0.6"
#
#  rtb_vpc = module.module_vpc_a.output_vpc_id
#
#  route_nat_gateway_bool                   = true
#  route_nat_gateway                        = module.module_public_subnet_a.outputs_nat_gateway_id
#  route_nat_gateway_destination_cidr_block = "0.0.0.0/0"
#
#  route_peering_bool                       = true
#  route_peering                            = module.module_peering_accepter.output_peering_id
#  route_vpc_peering_destination_cidr_block = "10.60.0.0/16"
#
#  rtb_tags = {
#    Name        = "${local.projectname}-${local.environment}-firewall-rtb-a"
#    Environment = local.environment
#    Project     = local.projectname
#  }
#}
#
### FIREWALL SUBNET ROUTE TABLE ASSOCIATION
#resource "aws_route_table_association" "rtb_assoc_vpc_a_firewall_rtb" {
#  subnet_id      = module.module_firewall_subnet_a.outputs_subnet_id
#  route_table_id = module.module_vpc_a_firewall_subnet_rtb.outputs_rtb_id
#}
#
### PUBLIC SUBNET ROUTE TABLE
#module "module_vpc_a_public_subnet_rtb" {
#  source  = "app.terraform.io/marvsmpb/rtb-marvs/aws"
#  version = "0.0.6"
#
#  rtb_vpc = module.module_vpc_a.output_vpc_id
#
#  route_internet_gateway_bool                   = true
#  route_internet_gateway                        = module.module_public_subnet_a.outputs_internet_gateway_id
#  route_internet_gateway_destination_cidr_block = "0.0.0.0/0"
#
#
#  rtb_tags = {
#    Name        = "${local.projectname}-${local.environment}-public-rtb-a"
#    Environment = local.environment
#    Project     = local.projectname
#  }
#}
#
### PUBLIC SUBNET ROUTE TABLE ASSOCIATION
#resource "aws_route_table_association" "rtb_assoc_vpc_a_public_rtb" {
#  subnet_id      = module.module_public_subnet_a.outputs_subnet_id
#  route_table_id = module.module_vpc_a_public_subnet_rtb.outputs_rtb_id
#}

## FIREWALL
#module "module_vpc_a_firewall" {
#  source  = "app.terraform.io/marvsmpb/network-firewall-marvs/aws"
#  version = "0.0.14"
#
#  network_firewall_name      = "${local.projectname}-firewall"
#  network_firewall_subnet_id = [module.module_firewall_subnet_a.outputs_subnet_id]
#  network_firewall_vpc_id    = module.module_vpc_a.output_vpc_id
#  network_firewall_tags = {
#    Environment = local.environment
#  }
#
#  firewall_policy_name = "${local.projectname}-firewall-policy"
#  firewall_policy_rule_group_arn = [
#    {
#      arn      = "arn:aws:network-firewall:ap-southeast-1:015594108990:stateful-rulegroup/SURICATA-RULES"
#      priority = 1
#    }
#  ]
#  network_firewall_policy_tags = {
#    Environment = local.environment
#  }
#
#  firewall_policy_stateful_default_actions         = ["aws:drop_established", "aws:alert_established"]
#  firewall_policy_stateful_rule_order              = "STRICT_ORDER"
#  firewall_policy_stateful_stream_exception_policy = "REJECT"
#
#  network_firewall_delete_protection        = false
#  network_firewall_subnet_change_protection = false
#
#}





