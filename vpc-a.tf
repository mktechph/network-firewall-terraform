############ VPC A ############

## VPC
module "module_vpc_a" {
  source  = "app.terraform.io/marvsmpb/vpc-module-marvs/aws"
  version = "1.0.3"

  vpc_cidr_block = "10.50.0.0/16"
  vpc_tags = {
    Name        = "${local.projectname}-${local.environment}-vpc-a"
    Environment = local.environment
    Project     = local.projectname
  }
}

# SSM VPC ENDPOINTS
#module "module_vpc_a_ssm_endpoints" {
#  source  = "app.terraform.io/marvsmpb/vpc-endpoint-ssm/aws"
#  version = "0.0.2"
#
#  vpc_id                 = module.module_vpc_a.output_vpc_id
#  ssm_endpoint_subnet_id = [module.module_workload_subnet_a.outputs_subnet_id]
#  ssm_messages_subnet_id = [module.module_workload_subnet_a.outputs_subnet_id]
#  ec2_messages_subnet_id = [module.module_workload_subnet_a.outputs_subnet_id]
#
#  endpoint_tags = {
#    Name        = "${local.projectname}-${local.environment}-vpc-a-ssm"
#    Environment = local.environment
#    Project     = local.projectname
#  }
#}

## PUBLIC SUBNET
module "module_vpc_a_public_subnet" {
  source  = "app.terraform.io/marvsmpb/subnet-marvs/aws"
  version = "0.0.14"

  subnet_vpc         = module.module_vpc_a.output_vpc_id
  subnet_az          = "ap-southeast-1a"
  subnet_cidr        = "10.50.10.0/24"
  subnet_public_bool = true
  subnet_nat_bool    = true
  subnet_tags = {
    Name        = "${local.projectname}-${local.environment}-vpc-a-public-subnet"
    Environment = local.environment
    Project     = local.projectname
  }
  igw_tags = {
    Name        = "${local.projectname}-${local.environment}-vpc-a-igw"
    Environment = local.environment
    Project     = local.projectname
  }
  nat_tags = {
    Name        = "${local.projectname}-${local.environment}-vpc-a-natgw"
    Environment = local.environment
    Project     = local.projectname
  }
  eip_tags = {
    Name        = "${local.projectname}-${local.environment}-vpc-a-eip"
    Environment = local.environment
    Project     = local.projectname
  }
}

## TGW SUBNET
module "module_vpc_a_tgw_subnet" {
  source  = "app.terraform.io/marvsmpb/subnet-marvs/aws"
  version = "0.0.14"

  subnet_vpc  = module.module_vpc_a.output_vpc_id
  subnet_az   = "ap-southeast-1a"
  subnet_cidr = "10.50.20.0/24"
  subnet_tags = {
    Name        = "${local.projectname}-${local.environment}-vpc-a-tgw-subnet"
    Environment = local.environment
    Project     = local.projectname
  }
}

## PUBLIC SUBNET ROUTE TABLE
module "module_vpc_a_public_subnet_rtb" {
  source  = "app.terraform.io/marvsmpb/rtb-marvs/aws"
  version = "0.0.6"

  rtb_vpc = module.module_vpc_a.output_vpc_id

  route_internet_gateway_bool                   = true
  route_internet_gateway                        = module.module_vpc_a_public_subnet.outputs_internet_gateway_id
  route_internet_gateway_destination_cidr_block = "0.0.0.0/0"



  rtb_tags = {
    Name        = "${local.projectname}-${local.environment}-vpc-a-public-rtb"
    Environment = local.environment
    Project     = local.projectname
  }
}

# PUBLIC ROUTE
resource "aws_route" "vpc_a_route_public_subnet_to_tgw" {
  route_table_id         = module.module_vpc_a_public_subnet_rtb.outputs_rtb_id
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}


## TGW SUBNET ROUTE TABLE
module "module_vpc_a_tgw_subnet_rtb" {
  source  = "app.terraform.io/marvsmpb/rtb-marvs/aws"
  version = "0.0.6"

  rtb_vpc = module.module_vpc_a.output_vpc_id

  route_nat_gateway_bool                   = true
  route_nat_gateway                        = module.module_vpc_a_public_subnet.outputs_nat_gateway_id
  route_nat_gateway_destination_cidr_block = "0.0.0.0/0"


  rtb_tags = {
    Name        = "${local.projectname}-${local.environment}-vpc-a-tgw-rtb"
    Environment = local.environment
    Project     = local.projectname
  }
}

# TGW ROUTE
resource "aws_route" "route_vpc_a_tgw_subnet_to_tgw" {
  route_table_id         = module.module_vpc_a_tgw_subnet_rtb.outputs_rtb_id
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}


## PUBLIC SUBNET ROUTE TABLE ASSOCIATION
resource "aws_route_table_association" "rtb_assoc_vpc_a_public_rtb" {
  subnet_id      = module.module_vpc_a_public_subnet.outputs_subnet_id
  route_table_id = module.module_vpc_a_public_subnet_rtb.outputs_rtb_id
}

## TGW SUBNET ROUTE TABLE ASSOCIATION
resource "aws_route_table_association" "rtb_assoc_vpc_a_tgw_rtb" {
  subnet_id      = module.module_vpc_a_tgw_subnet.outputs_subnet_id
  route_table_id = module.module_vpc_a_tgw_subnet_rtb.outputs_rtb_id
}