############ VPC C ############

## VPC
module "module_vpc_c" {
  source  = "app.terraform.io/marvsmpb/vpc-module-marvs/aws"
  version = "1.0.3"

  vpc_cidr_block = "10.70.0.0/16"
  vpc_tags = {
    Name        = "${local.projectname}-${local.environment}-vpc-c"
    Environment = local.environment
  }
}

## TGW SUBNET
module "module_vpc_c_tgw_subnet" {
  source  = "app.terraform.io/marvsmpb/subnet-marvs/aws"
  version = "0.0.14"

  subnet_vpc  = module.module_vpc_c.output_vpc_id
  subnet_az   = "ap-southeast-1a"
  subnet_cidr = "10.70.20.0/24"
  subnet_tags = {
    Name        = "${local.projectname}-${local.environment}-vpc-c-tgw-subnet"
    Environment = local.environment
  }
}

## WORKLOAD SUBNET
module "module_vpc_c_workload_subnet" {
  source  = "app.terraform.io/marvsmpb/subnet-marvs/aws"
  version = "0.0.14"

  subnet_vpc  = module.module_vpc_c.output_vpc_id
  subnet_az   = "ap-southeast-1a"
  subnet_cidr = "10.70.10.0/24"
  subnet_tags = {
    Name        = "${local.projectname}-${local.environment}-vpc-c-workload-subnet"
    Environment = local.environment
  }
}



## VPC-C ROUTE TABLE
module "module_vpc_c_rtb" {
  source  = "app.terraform.io/marvsmpb/rtb-marvs/aws"
  version = "0.0.6"

  rtb_vpc = module.module_vpc_c.output_vpc_id

  rtb_tags = {
    Name        = "${local.projectname}-${local.environment}-vpc-c-rtb"
    Environment = local.environment
  }
}
# TGW ROUTE
resource "aws_route" "vpc_c_route_public_subnet_to_tgw" {
  route_table_id         = aws_ec2_transit_gateway.tgw.id
  destination_cidr_block = "0.0.0.0/0"
}


# TGW SUBNET ROUTE TABLE ASSOCIATION
resource "aws_route_table_association" "rtb_assoc_vpc_c_tgw_subnet" {
  subnet_id      = module.module_vpc_c_tgw_subnet.outputs_subnet_id
  route_table_id = module.module_vpc_c_rtb.outputs_rtb_id
}

# WORKLOAD SUBNET ROUTE TABLE ASSOCIATION
resource "aws_route_table_association" "rtb_assoc_vpc_c_workload_subnet" {
  subnet_id      = module.module_vpc_c_workload_subnet.outputs_subnet_id
  route_table_id = module.module_vpc_c_rtb.outputs_rtb_id
}



# SSM ENDPOINTS
#module "module_vpc_b_ssm_endpoints" {
#  source  = "app.terraform.io/marvsmpb/vpc-endpoint-ssm/aws"
#  version = "0.0.2"
#
#  vpc_id                 = module.module_vpc_b.output_vpc_id
#  ssm_endpoint_subnet_id = [module.module_workload_subnet_b.outputs_subnet_id]
#  ssm_messages_subnet_id = [module.module_workload_subnet_b.outputs_subnet_id]
#  ec2_messages_subnet_id = [module.module_workload_subnet_b.outputs_subnet_id]
#
#  endpoint_tags = {
#    Name        = "${local.projectname}-${local.environment}-vpc-b-ssm"
#    Environment = local.environment
#    Project     = local.projectname
#  }
#}

## EC2 WORKLOAD
#module "module_vpc_b_ec2" {
#  source  = "app.terraform.io/marvsmpb/ec2-marvs/aws"
#  version = "0.0.12"
#
#  ami_name                = ["Windows_Server-2022-English-Full-Base-2024.10.09"] # Windows Server 2022 Base 
#  ami_owner_account_id    = ["801119661308"]
#  ami_virtualization_type = ["hvm"]
#
#  instance_name     = "vpc-b-workload"
#  instance_type     = "t3.medium"
#  instance_key_name = "key-pair_WIN_PC"
#  instance_subnet   = module.module_workload_subnet_b.outputs_subnet_id
#  instance_tags = {
#    Name        = "${local.projectname}-${local.environment}-ec2-b"
#    Environment = local.environment
#  }
#
#  instance_vol_root_encrypted = true
#  instance_vol_root_size      = "30"
#  instance_vol_root_type      = "gp3"
#  instance_vol_tags = {
#    Name        = "${local.projectname}-${local.environment}-root-ebs-b"
#    Environment = local.environment
#  }
#
#  ebs_attachment_name = "xvdf"
#  ebs_encrypted       = true
#  ebs_size            = "10"
#  ebs_type            = "gp3"
#  ebs_tags = {
#    Name        = "${local.projectname}-${local.environment}-ec2-ebs-b"
#    Environment = local.environment
#  }
#}


