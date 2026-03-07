variable "name" {
  description = "The name of the WAFv2 Web ACL."
  type        = string
}

variable "scope" {
  description = "Scope of the WAF Web ACL. Valid values are REGIONAL or CLOUDFRONT."
  type        = string
  default     = "REGIONAL"

  validation {
    condition     = contains(["REGIONAL", "CLOUDFRONT"], var.scope)
    error_message = "Scope must be either REGIONAL or CLOUDFRONT."
  }
}

variable "description" {
  description = "A friendly description of the Web ACL."
  type        = string
  default     = ""
}

variable "default_action" {
  description = "The default action for the Web ACL. Valid values are 'allow' or 'block'."
  type        = string
  default     = "allow"

  validation {
    condition     = contains(["allow", "block"], var.default_action)
    error_message = "Default action must be either 'allow' or 'block'."
  }
}

variable "managed_rule_groups" {
  description = "List of AWS managed rule groups to associate with the Web ACL."
  type = list(object({
    name            = string
    priority        = number
    override_action = optional(string, "none")
    excluded_rules  = optional(list(string), [])
  }))
  default = []
}

variable "rate_limit_rules" {
  description = "List of rate-based rules for the Web ACL."
  type = list(object({
    name                 = optional(string, "")
    priority             = optional(number)
    rate                 = number
    action               = optional(string, "block")
    scope_down_statement = optional(any, null)
  }))
  default = []
}

variable "ip_set_rules" {
  description = "List of IP set rules for the Web ACL."
  type = list(object({
    name       = optional(string, "")
    ip_set_arn = string
    action     = optional(string, "block")
    priority   = number
  }))
  default = []
}

variable "geo_match_rules" {
  description = "List of geo match (geoblocking) rules for the Web ACL."
  type = list(object({
    name          = optional(string, "")
    country_codes = list(string)
    action        = optional(string, "block")
    priority      = optional(number)
  }))
  default = []
}

variable "custom_rules" {
  description = "List of custom rules for the Web ACL."
  type = list(object({
    name      = string
    priority  = number
    action    = string
    statement = any
  }))
  default = []
}

variable "enable_logging" {
  description = "Whether to enable WAF logging."
  type        = bool
  default     = true
}

variable "log_destination_arns" {
  description = "List of ARNs of the logging destinations (Kinesis Firehose, CloudWatch Log Group, or S3 Bucket)."
  type        = list(string)
  default     = []
}

variable "redacted_fields" {
  description = "List of fields to redact from the logs. Each item should have a 'type' key (e.g., 'uri_path', 'query_string', 'single_header') and optionally a 'name' key for single_header."
  type = list(object({
    type = string
    name = optional(string, "")
  }))
  default = []
}

variable "resource_arns" {
  description = "List of ARNs of the resources to associate with the Web ACL (ALB, API Gateway, etc.)."
  type        = list(string)
  default     = []
}

variable "enable_bot_control" {
  description = "Whether to enable AWS Bot Control managed rule group."
  type        = bool
  default     = false
}

variable "bot_control_priority" {
  description = "Priority for the Bot Control rule group."
  type        = number
  default     = 50
}

variable "bot_control_inspection_level" {
  description = "The inspection level for Bot Control. Valid values are COMMON or TARGETED."
  type        = string
  default     = "COMMON"

  validation {
    condition     = contains(["COMMON", "TARGETED"], var.bot_control_inspection_level)
    error_message = "Bot Control inspection level must be either COMMON or TARGETED."
  }
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}
