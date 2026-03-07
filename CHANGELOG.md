# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-03-07

### Added

- Initial release of the `terraform-aws-waf` module.
- WAFv2 Web ACL resource with configurable default action (allow/block).
- Support for AWS Managed Rule Groups with override actions and rule exclusions.
- AWS Bot Control managed rule group with configurable inspection level (COMMON/TARGETED).
- Rate-based rules with configurable rate limits and optional scope-down statements.
- IP set reference rules for allow/block lists.
- Geo match rules for geoblocking by country code.
- Custom rules with support for byte match, geo match, and size constraint statements.
- WAF logging configuration with support for Kinesis Firehose, CloudWatch Logs, and S3.
- Automatic CloudWatch Log Group creation when no log destination is specified.
- Log field redaction support (URI path, query string, single header).
- WAF Web ACL association for ALB, API Gateway, and other supported resources.
- Comprehensive examples: basic, advanced, and complete.
- Full documentation with all AWS managed rule group names.
