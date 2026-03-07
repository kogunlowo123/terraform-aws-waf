output "web_acl_id" {
  description = "The ID of the WAFv2 Web ACL."
  value       = aws_wafv2_web_acl.this.id
}

output "web_acl_arn" {
  description = "The ARN of the WAFv2 Web ACL."
  value       = aws_wafv2_web_acl.this.arn
}

output "web_acl_name" {
  description = "The name of the WAFv2 Web ACL."
  value       = aws_wafv2_web_acl.this.name
}

output "web_acl_capacity" {
  description = "The capacity units used by the Web ACL."
  value       = aws_wafv2_web_acl.this.capacity
}

output "web_acl_visibility_config" {
  description = "The visibility configuration of the Web ACL."
  value       = aws_wafv2_web_acl.this.visibility_config
}

output "logging_configuration_id" {
  description = "The ID of the WAF logging configuration."
  value       = try(aws_wafv2_web_acl_logging_configuration.this[0].id, null)
}

output "cloudwatch_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group created for WAF logging."
  value       = try(aws_cloudwatch_log_group.waf[0].arn, null)
}

output "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch Log Group created for WAF logging."
  value       = try(aws_cloudwatch_log_group.waf[0].name, null)
}

output "web_acl_association_ids" {
  description = "Map of resource ARNs to their WAF association IDs."
  value       = { for k, v in aws_wafv2_web_acl_association.this : k => v.id }
}
