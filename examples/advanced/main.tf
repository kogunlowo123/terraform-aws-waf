provider "aws" {
  region = "us-east-1"
}

resource "aws_wafv2_ip_set" "blocked_ips" {
  name               = "blocked-ips"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = ["192.0.2.0/24", "198.51.100.0/24"]
}

module "waf" {
  source = "../../"

  name           = "advanced-web-acl"
  description    = "Advanced WAF Web ACL with rate limiting, geoblocking, and IP sets"
  scope          = "REGIONAL"
  default_action = "allow"

  managed_rule_groups = [
    {
      name            = "AWSManagedRulesCommonRuleSet"
      priority        = 10
      override_action = "none"
      excluded_rules  = ["SizeRestrictions_BODY"]
    },
    {
      name            = "AWSManagedRulesSQLiRuleSet"
      priority        = 20
      override_action = "none"
      excluded_rules  = []
    },
    {
      name            = "AWSManagedRulesLinuxRuleSet"
      priority        = 30
      override_action = "none"
      excluded_rules  = []
    }
  ]

  rate_limit_rules = [
    {
      name     = "rate-limit-global"
      priority = 100
      rate     = 2000
      action   = "block"
    }
  ]

  ip_set_rules = [
    {
      name       = "block-known-bad-ips"
      ip_set_arn = aws_wafv2_ip_set.blocked_ips.arn
      action     = "block"
      priority   = 5
    }
  ]

  geo_match_rules = [
    {
      name          = "block-restricted-countries"
      country_codes = ["RU", "CN", "KP"]
      action        = "block"
      priority      = 150
    }
  ]

  enable_logging = true
  redacted_fields = [
    {
      type = "single_header"
      name = "authorization"
    }
  ]

  tags = {
    Environment = "staging"
    Project     = "example"
  }
}

output "web_acl_arn" {
  value = module.waf.web_acl_arn
}
