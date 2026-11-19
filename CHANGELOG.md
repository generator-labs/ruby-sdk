# Changelog

All notable changes to the Generator Labs Ruby SDK will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.1.0]

### Added
- `client.account`: `get`, `balance`, `usage`, `pause_checks` and `resume_checks`.
- `client.cert.findings`: `get`, `get_all`, `dismiss` and `restore`.
- `client.cert.monitors.check(id)` queues a check now, and `client.cert.errors.count` returns the
  number of current certificate errors.
- Request options as the last argument of every method, in a `GeneratorLabs::RequestOptions`:
  `idempotency_key`, `request_id`, `if_none_match` and `fields`.
- An `Idempotency-Key` is sent automatically on requests that create something or start a check
  (creates, contact resend and confirm, certificate monitor delete, RBL check start, certificate
  check now). It is generated once per call and reused on every retry, so a retried request is not
  applied twice. A key you pass yourself is used instead.
- `Response` exposes `request_id`, `etag`, `replayed` and `not_modified`, and `Error` carries the
  `request_id`. A 304 answer to `if_none_match` is a normal response with `not_modified` set.
- `client.rbl.listings` accepts query parameters, for paging.

### Changed
- A `Retry-After` longer than 60 seconds (`GeneratorLabs::MAX_RETRY_AFTER`) is not waited out: the
  429 is raised as the error.
- `get` takes a single ID. The form with several IDs is removed and raises `ArgumentError`: it
  sent an `ids` parameter the API does not have.

### Fixed
- `get_all` returned an empty list for every resource: it read the wrong key of the response.
- A retry no longer waits for the `RateLimit-Reset` time, which is on every response and can be
  the hourly reset. Only `Retry-After` sets the wait.

## [2.0.1]

### Changed
- Error detection now reads the API `status_code` and `status_message` fields and treats any
  `status_code` (or HTTP status) of 400 or greater as an error, raising `Error` with the API's
  `status_message`. `Error` now exposes a `status_code` reader so callers can branch on the
  specific code. Previously the handler looked for a `success`/`error.message` shape the v4.0 API
  does not send.

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
