resource "aws_ec2_transit_gateway" "tgw" {
  description = "Transit Gateway"

  tags = {
    Name        = "${local.projectname}-${local.environment}-tgw"
    Environment = local.environment
    Project     = local.projectname
  }
}

## VPC-A ATTACHMENT
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attachment_vpc_a" {
  subnet_ids         = [module.module_vpc_a_tgw_subnet.outputs_subnet_id]
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = module.module_vpc_a.output_vpc_id

  tags = {
    Name        = "${local.projectname}-${local.environment}-vpc-a-vpc-attachment"
    Environment = local.environment
    Project     = local.projectname
  }
}
## VPC-B ATTACHMENT
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attachment_vpc_b" {
  subnet_ids         = [module.module_vpc_b_tgw_subnet.outputs_subnet_id]
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = module.module_vpc_b.output_vpc_id

  tags = {
    Name        = "${local.projectname}-${local.environment}-vpc-b-vpc-attachment"
    Environment = local.environment
    Project     = local.projectname
  }
}
## VPC-C ATTACHMENT
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attachment_vpc_c" {
  subnet_ids         = [module.module_vpc_c_tgw_subnet.outputs_subnet_id]
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = module.module_vpc_c.output_vpc_id

  tags = {
    Name        = "${local.projectname}-${local.environment}-vpc-c-vpc-attachment"
    Environment = local.environment
    Project     = local.projectname
  }
}
## VPC-X ATTACHMENT
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attachment_vpc_x" {
  subnet_ids         = [module.module_vpc_x_tgw_subnet.outputs_subnet_id]
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = module.module_vpc_x.output_vpc_id

  tags = {
    Name        = "${local.projectname}-${local.environment}-vpc-x-vpc-attachment"
    Environment = local.environment
    Project     = local.projectname
  }
}




## INSPECTION ROUTE TABLE
resource "aws_ec2_transit_gateway_route_table" "tgw_insp_tgw_rtb" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
}
## INSPECTION ROUTE TO VPC-X
resource "aws_ec2_transit_gateway_route" "tgw_route_to_inspection" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attachment_vpc_x.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_insp_tgw_rtb.id
}
## VPC-A INSPECTION TGW ROUTE TABLE ASSOCIATION
resource "aws_ec2_transit_gateway_route_table_association" "tgw_vpc_a_tgw_rtb_assoc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attachment_vpc_a.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_insp_tgw_rtb.id
}
## VPC-B INSPECTION TGW ROUTE TABLE ASSOCIATION
resource "aws_ec2_transit_gateway_route_table_association" "tgw_vpc_b_tgw_rtb_assoc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attachment_vpc_b.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_insp_tgw_rtb.id
}
## VPC-C INSPECTION TGW ROUTE TABLE ASSOCIATION
resource "aws_ec2_transit_gateway_route_table_association" "tgw_vpc_c_tgw_rtb_assoc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attachment_vpc_c.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_insp_tgw_rtb.id
}


## FIREWALL ROUTE TABLE
resource "aws_ec2_transit_gateway_route_table" "tgw_fw_tgw_rtb" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
}
## FIREWALL ROUTE TO VPC-A
resource "aws_ec2_transit_gateway_route" "tgw_route_to_vpc_a" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attachment_vpc_a.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_fw_tgw_rtb.id
}
## FIREWALL ROUTE TO VPC-B
resource "aws_ec2_transit_gateway_route" "tgw_route_to_vpc_b" {
  destination_cidr_block         = "10.60.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attachment_vpc_b.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_fw_tgw_rtb.id
}
## FIREWALL ROUTE TO VPC-C
resource "aws_ec2_transit_gateway_route" "tgw_route_to_vpc_c" {
  destination_cidr_block         = "10.70.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attachment_vpc_c.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_fw_tgw_rtb.id
}