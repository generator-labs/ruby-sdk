# Changelog

All notable changes to the Generator Labs Ruby SDK will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0]

### Added
- Configuration options for timeouts, retries, and backoff strategies
- Automatic pagination support with `get_all` methods
- `Response` wrapper class with Hash-like `[]` access and `rate_limit_info` attribute
- `RateLimitInfo` class exposing `limit`, `remaining`, and `reset` from IETF draft rate limit headers
- faraday-retry automatically respects `Retry-After` header on 429 rate limit responses
- Certificate monitoring endpoints (monitors, profiles, errors)
- Webhook signature verification with HMAC-SHA256 and constant-time comparison
- Comprehensive examples (check_ip.rb, manage_hosts.rb, pagination.rb, error_handling.rb)
- CHANGELOG.md and SECURITY.md documentation
- CodeQL security scanning workflow
- Dependabot for automated dependency updates
- RuboCop configuration for code quality

### Changed
- Updated to API v4.0
- Improved error handling and retry logic
- Enhanced README with configuration and pagination examples

### Fixed
- RuboCop style violations
- Gemspec metadata and dependencies

## [1.0.0] - 2025-01-15

### Added
- Initial release of Generator Labs Ruby SDK
- Support for RBL monitoring API
- Support for Contact management API
- Automatic retry logic with exponential backoff
- Comprehensive test suite
