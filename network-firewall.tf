# FIREWALL
module "module_vpc_x_firewall" {
  source  = "app.terraform.io/marvsmpb/network-firewall-marvs/aws"
  version = "0.0.14"

  network_firewall_name      = "${local.projectname}-firewall"
  network_firewall_subnet_id = [module.module_vpc_x_firewall_subnet.outputs_subnet_id]
  network_firewall_vpc_id    = module.module_vpc_x.output_vpc_id
  network_firewall_tags = {
    Environment = local.environment
  }

  firewall_policy_name = "${local.projectname}-firewall-policy"
  firewall_policy_rule_group_arn = [
    {
      arn      = "arn:aws:network-firewall:ap-southeast-1:015594108990:stateful-rulegroup/SURICATA-RULES"
      priority = 1
    }
  ]
  network_firewall_policy_tags = {
    Environment = local.environment
  }

  firewall_policy_stateful_default_actions         = ["aws:drop_established", "aws:alert_established"]
  firewall_policy_stateful_rule_order              = "STRICT_ORDER"
  firewall_policy_stateful_stream_exception_policy = "REJECT"

  network_firewall_delete_protection        = false
  network_firewall_subnet_change_protection = false

}