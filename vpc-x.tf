############ VPC X ############

## VPC
module "module_vpc_x" {
  source  = "app.terraform.io/marvsmpb/vpc-module-marvs/aws"
  version = "1.0.3"

  vpc_cidr_block = "10.100.0.0/16"
  vpc_tags = {
    Name        = "${local.projectname}-${local.environment}-vpc-x"
    Environment = local.environment
    Project     = local.projectname
  }
}

## TGW SUBNET
module "module_vpc_x_tgw_subnet" {
  source  = "app.terraform.io/marvsmpb/subnet-marvs/aws"
  version = "0.0.14"

  subnet_vpc  = module.module_vpc_x.output_vpc_id
  subnet_az   = "ap-southeast-1a"
  subnet_cidr = "10.100.20.0/24"
  subnet_tags = {
    Name        = "${local.projectname}-${local.environment}-vpc-x-tgw-subnet"
    Environment = local.environment
    Project     = local.projectname
  }
}

## FIREWALL SUBNET
module "module_vpc_x_firewall_subnet" {
  source  = "app.terraform.io/marvsmpb/subnet-marvs/aws"
  version = "0.0.14"

  subnet_vpc  = module.module_vpc_x.output_vpc_id
  subnet_az   = "ap-southeast-1a"
  subnet_cidr = "10.100.10.0/24"
  subnet_tags = {
    Name        = "${local.projectname}-${local.environment}-vpc-x-firewall-subnet"
    Environment = local.environment
    Project     = local.projectname
  }
}


## TGW SUBNET ROUTE TABLE
module "module_vpc_x_tgw_subnet_rtb" {
  source  = "app.terraform.io/marvsmpb/rtb-marvs/aws"
  version = "0.0.6"

  rtb_vpc = module.module_vpc_x.output_vpc_id

  ## FIREWALL ENDPOINT                                                    
  route_endpoint                        = element(flatten([for status in tolist(module.module_vpc_x_firewall.output_network_firewall_sync_states) : [for sync in status : sync.attachment[0].endpoint_id if length([for attach in sync.attachment : attach.subnet_id if attach.subnet_id == module.module_vpc_x_firewall_subnet.outputs_subnet_id]) > 0]]), 0)
  route_endpoint_bool                   = true
  route_endpoint_destination_cidr_block = "0.0.0.0/0"

  rtb_tags = {
    Name        = "${local.projectname}-${local.environment}-vpc-x-tgw-rtb"
    Environment = local.environment
    Project     = local.projectname
  }
}

# TGW ROUTE TO FIREWALL ENDPOINT
#resource "aws_route" "route_vpc_x_tgw_subnet_to_firewll_endpoint" {
#  route_table_id         = module.module_vpc_x_tgw_subnet_rtb.outputs_rtb_id
#  destination_cidr_block = "0.0.0.0/0"
#  vpc_endpoint_id     = module.module_vpc_x_firewall.
#}


## FIREWALL SUBNET ROUTE TABLE
module "module_vpc_x_firewall_subnet_rtb" {
  source  = "app.terraform.io/marvsmpb/rtb-marvs/aws"
  version = "0.0.6"

  rtb_vpc = module.module_vpc_x.output_vpc_id

  rtb_tags = {
    Name        = "${local.projectname}-${local.environment}-vpc-x-firewall-rtb"
    Environment = local.environment
    Project     = local.projectname
  }
}

# FIREWALL ROUTE TO TRANSIT GATEWWAY
resource "aws_route" "route_vpc_x_firewall_subnet_to_transit_gateway" {
  depends_on             = [aws_ec2_transit_gateway.tgw]
  route_table_id         = module.module_vpc_x_firewall_subnet_rtb.outputs_rtb_id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}
