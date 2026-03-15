module "waf" {
  source = "../"

  name           = "test-waf-acl"
  scope          = "REGIONAL"
  description    = "Test WAF Web ACL"
  default_action = "allow"

  managed_rule_groups = [
    {
      name     = "AWSManagedRulesCommonRuleSet"
      priority = 10
    }
  ]

  rate_limit_rules   = []
  ip_set_rules       = []
  geo_match_rules    = []
  custom_rules       = []
  enable_logging     = false
  log_destination_arns = []
  resource_arns      = []
  enable_bot_control = false

  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
  }
}
