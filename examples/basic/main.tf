provider "aws" {
  region = "us-east-1"
}

module "waf" {
  source = "../../"

  name        = "basic-web-acl"
  description = "Basic WAF Web ACL with common managed rules"
  scope       = "REGIONAL"

  managed_rule_groups = [
    {
      name            = "AWSManagedRulesCommonRuleSet"
      priority        = 10
      override_action = "none"
      excluded_rules  = []
    },
    {
      name            = "AWSManagedRulesKnownBadInputsRuleSet"
      priority        = 20
      override_action = "none"
      excluded_rules  = []
    }
  ]

  tags = {
    Environment = "dev"
    Project     = "example"
  }
}

output "web_acl_arn" {
  value = module.waf.web_acl_arn
}
