###############################################################################
# WAFv2 Web ACL
###############################################################################
resource "aws_wafv2_web_acl" "this" {
  name        = var.name
  description = var.description
  scope       = var.scope

  default_action {
    dynamic "allow" {
      for_each = var.default_action == "allow" ? [1] : []
      content {}
    }
    dynamic "block" {
      for_each = var.default_action == "block" ? [1] : []
      content {}
    }
  }

  # --------------------------------------------------------------------------
  # Managed Rule Groups
  # --------------------------------------------------------------------------
  dynamic "rule" {
    for_each = var.managed_rule_groups
    content {
      name     = rule.value.name
      priority = rule.value.priority

      override_action {
        dynamic "none" {
          for_each = rule.value.override_action == "none" ? [1] : []
          content {}
        }
        dynamic "count" {
          for_each = rule.value.override_action == "count" ? [1] : []
          content {}
        }
      }

      statement {
        managed_rule_group_statement {
          name        = rule.value.name
          vendor_name = "AWS"

          dynamic "excluded_rule" {
            for_each = rule.value.excluded_rules
            content {
              name = excluded_rule.value
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "waf-${var.name}-${rule.value.name}"
        sampled_requests_enabled   = true
      }
    }
  }

  # --------------------------------------------------------------------------
  # Bot Control (AWS Managed)
  # --------------------------------------------------------------------------
  dynamic "rule" {
    for_each = var.enable_bot_control ? [1] : []
    content {
      name     = "AWSManagedRulesBotControlRuleSet"
      priority = var.bot_control_priority

      override_action {
        none {}
      }

      statement {
        managed_rule_group_statement {
          name        = "AWSManagedRulesBotControlRuleSet"
          vendor_name = "AWS"

          managed_rule_group_configs {
            aws_managed_rules_bot_control_rule_set {
              inspection_level = var.bot_control_inspection_level
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "waf-${var.name}-bot-control"
        sampled_requests_enabled   = true
      }
    }
  }

  # --------------------------------------------------------------------------
  # Rate Limit Rules
  # --------------------------------------------------------------------------
  dynamic "rule" {
    for_each = local.rate_limit_rules
    content {
      name     = rule.value.name
      priority = rule.value.priority

      action {
        dynamic "block" {
          for_each = rule.value.action == "block" ? [1] : []
          content {}
        }
        dynamic "count" {
          for_each = rule.value.action == "count" ? [1] : []
          content {}
        }
        dynamic "allow" {
          for_each = rule.value.action == "allow" ? [1] : []
          content {}
        }
      }

      statement {
        rate_based_statement {
          limit              = rule.value.rate
          aggregate_key_type = "IP"

          dynamic "scope_down_statement" {
            for_each = rule.value.scope_down_statement != null ? [rule.value.scope_down_statement] : []
            content {
              dynamic "geo_match_statement" {
                for_each = try(scope_down_statement.value.geo_match_statement, null) != null ? [scope_down_statement.value.geo_match_statement] : []
                content {
                  country_codes = geo_match_statement.value.country_codes
                }
              }
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "waf-${var.name}-${rule.value.name}"
        sampled_requests_enabled   = true
      }
    }
  }

  # --------------------------------------------------------------------------
  # IP Set Rules
  # --------------------------------------------------------------------------
  dynamic "rule" {
    for_each = local.ip_set_rules
    content {
      name     = rule.value.name
      priority = rule.value.priority

      action {
        dynamic "block" {
          for_each = rule.value.action == "block" ? [1] : []
          content {}
        }
        dynamic "count" {
          for_each = rule.value.action == "count" ? [1] : []
          content {}
        }
        dynamic "allow" {
          for_each = rule.value.action == "allow" ? [1] : []
          content {}
        }
      }

      statement {
        ip_set_reference_statement {
          arn = rule.value.ip_set_arn
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "waf-${var.name}-${rule.value.name}"
        sampled_requests_enabled   = true
      }
    }
  }

  # --------------------------------------------------------------------------
  # Geo Match Rules (Geoblocking)
  # --------------------------------------------------------------------------
  dynamic "rule" {
    for_each = local.geo_match_rules
    content {
      name     = rule.value.name
      priority = rule.value.priority

      action {
        dynamic "block" {
          for_each = rule.value.action == "block" ? [1] : []
          content {}
        }
        dynamic "count" {
          for_each = rule.value.action == "count" ? [1] : []
          content {}
        }
        dynamic "allow" {
          for_each = rule.value.action == "allow" ? [1] : []
          content {}
        }
      }

      statement {
        geo_match_statement {
          country_codes = rule.value.country_codes
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "waf-${var.name}-${rule.value.name}"
        sampled_requests_enabled   = true
      }
    }
  }

  # --------------------------------------------------------------------------
  # Custom Rules
  # --------------------------------------------------------------------------
  dynamic "rule" {
    for_each = var.custom_rules
    content {
      name     = rule.value.name
      priority = rule.value.priority

      action {
        dynamic "block" {
          for_each = rule.value.action == "block" ? [1] : []
          content {}
        }
        dynamic "count" {
          for_each = rule.value.action == "count" ? [1] : []
          content {}
        }
        dynamic "allow" {
          for_each = rule.value.action == "allow" ? [1] : []
          content {}
        }
      }

      statement {
        dynamic "byte_match_statement" {
          for_each = try(rule.value.statement.byte_match_statement, null) != null ? [rule.value.statement.byte_match_statement] : []
          content {
            positional_constraint = byte_match_statement.value.positional_constraint
            search_string         = byte_match_statement.value.search_string

            dynamic "field_to_match" {
              for_each = try(byte_match_statement.value.field_to_match, null) != null ? [byte_match_statement.value.field_to_match] : []
              content {
                dynamic "uri_path" {
                  for_each = try(field_to_match.value.uri_path, null) != null ? [1] : []
                  content {}
                }
                dynamic "query_string" {
                  for_each = try(field_to_match.value.query_string, null) != null ? [1] : []
                  content {}
                }
                dynamic "single_header" {
                  for_each = try(field_to_match.value.single_header, null) != null ? [field_to_match.value.single_header] : []
                  content {
                    name = single_header.value.name
                  }
                }
              }
            }

            dynamic "text_transformation" {
              for_each = try(byte_match_statement.value.text_transformations, [{ priority = 0, type = "NONE" }])
              content {
                priority = text_transformation.value.priority
                type     = text_transformation.value.type
              }
            }
          }
        }

        dynamic "geo_match_statement" {
          for_each = try(rule.value.statement.geo_match_statement, null) != null ? [rule.value.statement.geo_match_statement] : []
          content {
            country_codes = geo_match_statement.value.country_codes
          }
        }

        dynamic "size_constraint_statement" {
          for_each = try(rule.value.statement.size_constraint_statement, null) != null ? [rule.value.statement.size_constraint_statement] : []
          content {
            comparison_operator = size_constraint_statement.value.comparison_operator
            size                = size_constraint_statement.value.size

            dynamic "field_to_match" {
              for_each = try(size_constraint_statement.value.field_to_match, null) != null ? [size_constraint_statement.value.field_to_match] : []
              content {
                dynamic "body" {
                  for_each = try(field_to_match.value.body, null) != null ? [1] : []
                  content {}
                }
                dynamic "uri_path" {
                  for_each = try(field_to_match.value.uri_path, null) != null ? [1] : []
                  content {}
                }
              }
            }

            dynamic "text_transformation" {
              for_each = try(size_constraint_statement.value.text_transformations, [{ priority = 0, type = "NONE" }])
              content {
                priority = text_transformation.value.priority
                type     = text_transformation.value.type
              }
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "waf-${var.name}-${rule.value.name}"
        sampled_requests_enabled   = true
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "waf-${var.name}"
    sampled_requests_enabled   = true
  }

  tags = local.tags
}

###############################################################################
# CloudWatch Log Group for WAF Logging
###############################################################################
resource "aws_cloudwatch_log_group" "waf" {
  count = var.enable_logging && length(var.log_destination_arns) == 0 ? 1 : 0

  name              = "aws-waf-logs-${var.name}"
  retention_in_days = 90

  tags = local.tags
}

###############################################################################
# WAFv2 Logging Configuration
###############################################################################
resource "aws_wafv2_web_acl_logging_configuration" "this" {
  count = var.enable_logging ? 1 : 0

  log_destination_configs = length(var.log_destination_arns) > 0 ? var.log_destination_arns : [aws_cloudwatch_log_group.waf[0].arn]
  resource_arn            = aws_wafv2_web_acl.this.arn

  dynamic "redacted_fields" {
    for_each = var.redacted_fields
    content {
      dynamic "uri_path" {
        for_each = redacted_fields.value.type == "uri_path" ? [1] : []
        content {}
      }
      dynamic "query_string" {
        for_each = redacted_fields.value.type == "query_string" ? [1] : []
        content {}
      }
      dynamic "single_header" {
        for_each = redacted_fields.value.type == "single_header" ? [1] : []
        content {
          name = redacted_fields.value.name
        }
      }
    }
  }
}

###############################################################################
# WAFv2 Web ACL Association
###############################################################################
resource "aws_wafv2_web_acl_association" "this" {
  for_each = toset(var.resource_arns)

  resource_arn = each.value
  web_acl_arn  = aws_wafv2_web_acl.this.arn
}
