locals {
  # Determine if logging should be configured
  enable_logging = var.enable_logging && length(var.log_destination_arns) > 0

  # Default tags merged with user-provided tags
  default_tags = {
    ManagedBy = "terraform"
    Module    = "terraform-aws-waf"
  }

  tags = merge(local.default_tags, var.tags)

  # Build geo match rules with auto-generated priorities if not specified
  geo_match_rules = [
    for i, rule in var.geo_match_rules : {
      name          = rule.name != "" ? rule.name : "geo-match-${i}"
      country_codes = rule.country_codes
      action        = rule.action
      priority      = rule.priority != null ? rule.priority : (200 + i)
    }
  ]

  # Build rate limit rules with auto-generated names and priorities
  rate_limit_rules = [
    for i, rule in var.rate_limit_rules : {
      name                 = rule.name != "" ? rule.name : "rate-limit-${i}"
      priority             = rule.priority != null ? rule.priority : (300 + i)
      rate                 = rule.rate
      action               = rule.action
      scope_down_statement = rule.scope_down_statement
    }
  ]

  # Build IP set rules with auto-generated names
  ip_set_rules = [
    for i, rule in var.ip_set_rules : {
      name       = rule.name != "" ? rule.name : "ip-set-${i}"
      ip_set_arn = rule.ip_set_arn
      action     = rule.action
      priority   = rule.priority
    }
  ]
}
