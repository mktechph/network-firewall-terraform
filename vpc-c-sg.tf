#### WORKLOAD SECURITY GROUP ####
resource "aws_security_group" "vpc_c_sg_workload" {
  name        = "vpc_c_workload_sg"
  description = "VPC C - Security Group for Workloads"
  vpc_id      = module.module_vpc_b.output_vpc_id

  tags = {
    Name        = "${local.projectname}-${local.environment}-vpc-c-sg-workload"
    Environment = local.environment
  }
}

### INBOUND 
resource "aws_vpc_security_group_ingress_rule" "vpc_c_sg_workload_inbound_all" {
  security_group_id = aws_security_group.vpc_c_sg_workload.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

### OUTBOUND 
resource "aws_vpc_security_group_egress_rule" "vpc_c_sg_workload_outbound_all" {
  security_group_id = aws_security_group.vpc_c_sg_workload.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

