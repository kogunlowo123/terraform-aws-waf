provider "aws" {
  region = "us-east-1"
}

###############################################################################
# Supporting Resources
###############################################################################
resource "aws_wafv2_ip_set" "allowed_ips" {
  name               = "allowed-ips"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = ["203.0.113.0/24"]
}

resource "aws_wafv2_ip_set" "blocked_ips" {
  name               = "blocked-ips"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = ["192.0.2.0/24", "198.51.100.0/24"]
}

resource "aws_kinesis_firehose_delivery_stream" "waf_logs" {
  name        = "aws-waf-logs-complete-example"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose.arn
    bucket_arn = aws_s3_bucket.waf_logs.arn
  }
}

resource "aws_s3_bucket" "waf_logs" {
  bucket = "waf-logs-complete-example-bucket"
}

resource "aws_iam_role" "firehose" {
  name = "waf-firehose-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "firehose.amazonaws.com"
        }
      }
    ]
  })
}

###############################################################################
# WAF Module - Complete Example
###############################################################################
module "waf" {
  source = "../../"

  name           = "complete-web-acl"
  description    = "Complete WAF Web ACL demonstrating all features"
  scope          = "REGIONAL"
  default_action = "allow"

  # Managed Rule Groups
  managed_rule_groups = [
    {
      name            = "AWSManagedRulesCommonRuleSet"
      priority        = 10
      override_action = "none"
      excluded_rules  = ["SizeRestrictions_BODY", "CrossSiteScripting_BODY"]
    },
    {
      name            = "AWSManagedRulesKnownBadInputsRuleSet"
      priority        = 20
      override_action = "none"
      excluded_rules  = []
    },
    {
      name            = "AWSManagedRulesSQLiRuleSet"
      priority        = 30
      override_action = "none"
      excluded_rules  = []
    },
    {
      name            = "AWSManagedRulesLinuxRuleSet"
      priority        = 40
      override_action = "none"
      excluded_rules  = []
    },
    {
      name            = "AWSManagedRulesAmazonIpReputationList"
      priority        = 60
      override_action = "none"
      excluded_rules  = []
    },
    {
      name            = "AWSManagedRulesAnonymousIpList"
      priority        = 70
      override_action = "none"
      excluded_rules  = []
    }
  ]

  # Bot Control
  enable_bot_control           = true
  bot_control_priority         = 50
  bot_control_inspection_level = "COMMON"

  # Rate Limiting
  rate_limit_rules = [
    {
      name     = "rate-limit-global"
      priority = 100
      rate     = 2000
      action   = "block"
    },
    {
      name     = "rate-limit-api"
      priority = 110
      rate     = 500
      action   = "block"
      scope_down_statement = {
        geo_match_statement = {
          country_codes = ["US", "CA"]
        }
      }
    }
  ]

  # IP Set Rules
  ip_set_rules = [
    {
      name       = "allow-trusted-ips"
      ip_set_arn = aws_wafv2_ip_set.allowed_ips.arn
      action     = "allow"
      priority   = 1
    },
    {
      name       = "block-malicious-ips"
      ip_set_arn = aws_wafv2_ip_set.blocked_ips.arn
      action     = "block"
      priority   = 2
    }
  ]

  # Geoblocking
  geo_match_rules = [
    {
      name          = "block-sanctioned-countries"
      country_codes = ["RU", "CN", "KP", "IR", "SY"]
      action        = "block"
      priority      = 200
    }
  ]

  # Custom Rules
  custom_rules = [
    {
      name     = "block-bad-uri"
      priority = 250
      action   = "block"
      statement = {
        byte_match_statement = {
          positional_constraint = "STARTS_WITH"
          search_string         = "/admin"
          field_to_match = {
            uri_path = {}
          }
          text_transformations = [
            {
              priority = 0
              type     = "LOWERCASE"
            }
          ]
        }
      }
    }
  ]

  # Logging
  enable_logging       = true
  log_destination_arns = [aws_kinesis_firehose_delivery_stream.waf_logs.arn]
  redacted_fields = [
    {
      type = "single_header"
      name = "authorization"
    },
    {
      type = "single_header"
      name = "cookie"
    },
    {
      type = "query_string"
    }
  ]

  tags = {
    Environment = "production"
    Project     = "complete-example"
    Team        = "security"
  }
}

###############################################################################
# Outputs
###############################################################################
output "web_acl_arn" {
  value = module.waf.web_acl_arn
}

output "web_acl_id" {
  value = module.waf.web_acl_id
}

output "logging_config_id" {
  value = module.waf.logging_configuration_id
}
