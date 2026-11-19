# Generator Labs Ruby SDK

[![Gem Version](https://badge.fury.io/rb/generatorlabs.svg)](https://badge.fury.io/rb/generatorlabs)
[![Tests](https://github.com/generator-labs/ruby-sdk/workflows/Tests/badge.svg)](https://github.com/generator-labs/ruby-sdk/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Official Ruby SDK for the [Generator Labs API](https://generatorlabs.com). This library provides a simple and intuitive interface for interacting with the Generator Labs v4.0 API, including RBL monitoring, contact management, and more.

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Webhook Verification](#webhook-verification)
- [API Reference](#api-reference)
  - [Client Initialization](#client-initialization)
  - [Configuration Options](#configuration-options)
  - [Pagination](#pagination)
  - [Request Options](#request-options)
  - [Account](#account)
  - [RBL Monitoring](#rbl-monitoring) - [Hosts](#hosts) | [Profiles](#profiles) | [Sources](#sources) | [Check & Listings](#check--listings)
  - [Certificate Monitoring](#certificate-monitoring) - [Errors](#errors) | [Monitors](#monitors) | [Findings](#findings) | [Profiles](#profiles-1)
  - [Contact Management](#contact-management) - [Contacts](#contacts) | [Groups](#groups)
- [Error Handling](#error-handling)
- [Retry Logic](#retry-logic)
- [Rate Limiting](#rate-limiting)
- [Examples](#examples)
- [Requirements](#requirements)
- [Testing](#testing)
- [Security](#security)
- [Release History](#release-history)
- [License](#license)
- [Support](#support)
- [Contributing](#contributing)

## Features

- Full support for Generator Labs API v4.0
- Configurable timeouts, retries, and backoff strategies
- Automatic retry logic with exponential backoff
- Automatic pagination for large result sets
- Connection pooling and timeout management
- Clean, Ruby-idiomatic API
- Comprehensive error handling
- Ruby 3.0+ support

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'generatorlabs'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install generatorlabs
```

## Quick Start

```ruby
require 'generatorlabs'

# Initialize the client with default configuration
client = GeneratorLabs::Client.new(
  'YOUR_ACCOUNT_SID',
  'YOUR_AUTH_TOKEN'
)

# Or with custom configuration
config = GeneratorLabs::Config.new(
  timeout: 45,
  connect_timeout: 10,
  max_retries: 5,
  retry_backoff: 2.0,
  base_url: 'https://api.generatorlabs.com/4.0/'
)
client = GeneratorLabs::Client.new(
  'YOUR_ACCOUNT_SID',
  'YOUR_AUTH_TOKEN',
  config
)

# Get all monitored hosts
hosts = client.rbl.hosts.get
puts hosts

# Start a manual RBL check
result = client.rbl.check.start(host: '8.8.8.8')
puts result

# Get all contacts with automatic pagination
all_contacts = client.contact.contacts.get_all
puts "Total contacts: #{all_contacts.length}"
```

## Webhook Verification

The SDK includes a helper for verifying incoming webhook signatures. Each webhook is assigned a signing secret (available in the Portal), which is used to compute an HMAC-SHA256 signature sent with every request in the `X-Webhook-Signature` header.

```ruby
require 'generatorlabs'

header = request.env['HTTP_X_WEBHOOK_SIGNATURE'] || ''
body = request.body.read
secret = ENV['GENERATOR_LABS_WEBHOOK_SECRET']

begin
  payload = GeneratorLabs::Webhook.verify(body, header, secret)

  # payload is the decoded event data
  puts payload['event']

rescue GeneratorLabs::Error => e
  # Signature verification failed
  halt 403, { error: 'Invalid signature' }.to_json
end
```

The default timestamp tolerance is 5 minutes. You can customize it (in seconds), or pass `0` to disable:

```ruby
payload = GeneratorLabs::Webhook.verify(body, header, secret, 600)  # 10-minute tolerance
payload = GeneratorLabs::Webhook.verify(body, header, secret, 0)    # disable timestamp check
```

See `examples/webhook_verification.rb` for a complete example.

## API Reference

### Client Initialization

```ruby
# With default configuration
client = GeneratorLabs::Client.new(account_sid, auth_token)

# With custom configuration
config = GeneratorLabs::Config.new(
  timeout: 45,           # Request timeout in seconds (default: 30)
  connect_timeout: 10,   # Connection timeout in seconds (default: 5)
  max_retries: 5,        # Max retry attempts (default: 3)
  retry_backoff: 2.0,    # Backoff multiplier (default: 1.0)
  base_url: 'https://api.generatorlabs.com/4.0/'
)
client = GeneratorLabs::Client.new(account_sid, auth_token, config)
```

### Configuration Options

- **timeout**: Maximum duration for the entire request in seconds (default: 30)
- **connect_timeout**: Maximum duration for connection establishment in seconds (default: 5)
- **max_retries**: Maximum number of retry attempts for failed requests (default: 3)
- **retry_backoff**: Multiplier for exponential backoff between retries (default: 1.0)
- **base_url**: Custom API base URL (default: https://api.generatorlabs.com/4.0/)

### Pagination

All list operations support automatic pagination using the `get_all` method:

```ruby
# Get all hosts across multiple pages
all_hosts = client.rbl.hosts.get_all(page_size: 50)

# Get all profiles with automatic pagination
all_profiles = client.rbl.profiles.get_all

# Get all contacts with automatic pagination
all_contacts = client.contact.contacts.get_all

# Get all groups with automatic pagination
all_groups = client.contact.groups.get_all
```

### Request Options

Every resource method takes a `GeneratorLabs::RequestOptions` as its last argument: `idempotency_key`, `request_id`, `if_none_match` and `fields`.

**Idempotency keys.** Requests that create something (`create`), a contact `resend` or `confirm`, the certificate monitor `delete`, and the two check requests (`rbl.check.start`, `cert.monitors.check`) are sent with an `Idempotency-Key` header. The SDK generates one key per call and sends the same key on every automatic retry of that call, so a retry after a timeout never creates, sends, bills or deletes anything twice. Pass your own key to make a repeat of the call from your code safe as well:

```ruby
options = GeneratorLabs::RequestOptions.new(idempotency_key: 'b0e1f6a2-4d7c-4b43-9d3c-3f1c5a9f2e11')
host = client.rbl.hosts.create({ name: 'My Mail Server', host: '192.168.1.100' }, options)

# true when the API answered with the result of an earlier request with the same key
puts host.replayed
```

The same key with a different request is refused with a 422.

**Request IDs.** Every response carries an `X-Request-Id`, available as `request_id` on the response and on `GeneratorLabs::Error`. Quote it when you contact support about a request. You can also send your own (1 to 64 letters, digits, `-`, `_`, `.` or `:`):

```ruby
begin
  hosts = client.rbl.hosts.get(GeneratorLabs::RequestOptions.new(request_id: 'my-request-1'))
  puts hosts.request_id
rescue GeneratorLabs::Error => e
  puts "#{e.status_code} #{e.request_id}"
end
```

**Conditional requests.** Every `GET` response carries an `ETag`. Send it back as `if_none_match`: when nothing has changed the API answers `304 Not Modified`, and the response has `not_modified` set and no data.

```ruby
hosts = client.rbl.hosts.get

later = client.rbl.hosts.get(GeneratorLabs::RequestOptions.new(if_none_match: hosts.etag))
hosts = later unless later.not_modified
```

**Field selection.** Any `GET` takes `fields` (an Array, or a comma-separated String) to keep only those keys in each object of `data`. A nested key is written with a dot. A field no object has is refused with a 422.

```ruby
options = GeneratorLabs::RequestOptions.new(fields: %w[id host listed])

host = client.rbl.hosts.get('HT1a2b3c4d5e6f7890abcdef1234567890', options)
hosts = client.rbl.hosts.get({ page_size: 50 }, options)
```

### Account

```ruby
# The account: balance, whether scheduled checks are running, and plan usage
account = client.account.get

# The account balance, as a Float
balance = client.account.balance

# Usage by month, for the last 3 months
usage = client.account.usage(months: 3)

# Pause and resume the account's scheduled checks
client.account.pause_checks
client.account.resume_checks
```

### RBL Monitoring

#### Hosts

```ruby
# Get all hosts
hosts = client.rbl.hosts.get

# Get a specific host
host = client.rbl.hosts.get('HT1a2b3c4d5e6f7890abcdef1234567890')

# Create a host
host = client.rbl.hosts.create(
  host: '8.8.8.8',
  name: 'Google DNS',
  profile: 'RP9f8e7d6c5b4a3210fedcba0987654321',
  contact_group: [
    'CG4f3e2d1c0b9a8776655443322110fedc',
    'CG5a6b7c8d9e0f1234567890abcdef1234'
  ],
  tags: ['production', 'web']
)

# Update a host
host = client.rbl.hosts.update('HT1a2b3c4d5e6f7890abcdef1234567890',
  name: 'Updated description',
  tags: ['production', 'web']
)

# Delete a host
result = client.rbl.hosts.delete('HT1a2b3c4d5e6f7890abcdef1234567890')
```

#### Profiles

```ruby
# Get all profiles
profiles = client.rbl.profiles.get

# Get a specific profile
profile = client.rbl.profiles.get('RP9f8e7d6c5b4a3210fedcba0987654321')

# Create a profile
profile = client.rbl.profiles.create(
  name: 'My Custom Profile',
  entries: [
    'RB1234567890abcdef1234567890abcdef',
    'RB0987654321fedcba0987654321fedcba'
  ]
)

# Update a profile
profile = client.rbl.profiles.update('RP9f8e7d6c5b4a3210fedcba0987654321',
  name: 'Updated Profile Name',
  entries: [
    'RB1234567890abcdef1234567890abcdef',
    'RB0987654321fedcba0987654321fedcba'
  ]
)

# Delete a profile
result = client.rbl.profiles.delete('RP9f8e7d6c5b4a3210fedcba0987654321')
```

#### Sources

```ruby
# Get all RBL sources
sources = client.rbl.sources.get

# Get a specific source
source = client.rbl.sources.get('RB18c470cc518a09678bb280960dbdd524')

# Create a custom source
source = client.rbl.sources.create(
  host: 'custom.rbl.example.com',
  type: 'rbl',
  custom_codes: ['127.0.0.2', '127.0.0.3']
)

# Update a source
source = client.rbl.sources.update('RB18c470cc518a09678bb280960dbdd524',
  host: 'updated.rbl.example.com',
  custom_codes: ['127.0.0.2', '127.0.0.3']
)

# Delete a source
result = client.rbl.sources.delete('RB18c470cc518a09678bb280960dbdd524')
```

#### Check & Listings

```ruby
# Start a manual RBL check
result = client.rbl.check.start(host: '8.8.8.8')

# Get check status
status = client.rbl.check.status('check_id')

# Get current listings
listings = client.rbl.listings

# Get the second page of listings
listings = client.rbl.listings(page: 2)
```

### Certificate Monitoring

Certificate monitoring allows you to monitor SSL/TLS certificates for expiration, validity, and configuration issues across HTTPS, SMTPS, IMAPS, and other TLS-enabled services.

#### Errors

```ruby
# Get all certificate errors
errors = client.cert.errors.get
```

```ruby
# The number of current certificate warnings and errors
count = client.cert.errors.count
```

#### Monitors

```ruby
# Get all certificate monitors
monitors = client.cert.monitors.get

# Get a specific monitor
monitor = client.cert.monitors.get('CM62944aeeee2b46d7a28221164f38976a')

# Create a certificate monitor
monitor = client.cert.monitors.create(
  name: 'Production Web Server',
  hostname: 'example.com',
  protocol: 'https',
  profile: 'CP79b597e61a984a35b5eb7dcdbc3de53c',
  contact_group: [
    'CG4f3e2d1c0b9a8776655443322110fedc',
    'CG5a6b7c8d9e0f1234567890abcdef1234'
  ],
  tags: ['production', 'web', 'ssl']
)

# Update a monitor
monitor = client.cert.monitors.update('CM62944aeeee2b46d7a28221164f38976a',
  name: 'Updated Server Name',
  tags: ['production', 'web', 'ssl']
)

# Delete a monitor
result = client.cert.monitors.delete('CM62944aeeee2b46d7a28221164f38976a')

# Pause monitoring
result = client.cert.monitors.pause('CM62944aeeee2b46d7a28221164f38976a')

# Resume monitoring
result = client.cert.monitors.resume('CM62944aeeee2b46d7a28221164f38976a')

# Queue a check now, instead of waiting for the next scheduled check
result = client.cert.monitors.check('CM62944aeeee2b46d7a28221164f38976a')
```

#### Findings

Findings are everything the last check of each active monitor found: errors, warnings and notices, whatever the profile's alert settings. Some findings can be dismissed, and restored later.

```ruby
# List the current findings, one entry per monitor
findings = client.cert.findings.get

# Include the findings dismissed from each monitor
findings = client.cert.findings.get(dismissed: 1)

# Dismiss findings on named monitors (leave monitors out for every monitor that has them)
result = client.cert.findings.dismiss(
  finding_id: %w[CERT_CAA01 CERT_CAA02],
  monitors: ['CM62944aeeee2b46d7a28221164f38976a']
)

# Restore dismissed findings
result = client.cert.findings.restore(finding_id: 'CERT_CAA01')
```

#### Profiles

```ruby
# Get all certificate profiles
profiles = client.cert.profiles.get

# Get a specific profile
profile = client.cert.profiles.get('CP79b597e61a984a35b5eb7dcdbc3de53c')

# Create a profile
profile = client.cert.profiles.create(
  name: 'Standard Certificate Profile',
  expiration_thresholds: [30, 14, 7],
  alert_on_expiration: true,
  alert_on_name_mismatch: true,
  alert_on_misconfigurations: true,
  alert_on_changes: true
)

# Update a profile
profile = client.cert.profiles.update('CP79b597e61a984a35b5eb7dcdbc3de53c',
  expiration_thresholds: [45, 14, 7],
  alert_on_misconfigurations: true,
  alert_on_changes: true
)

# Delete a profile
result = client.cert.profiles.delete('CP79b597e61a984a35b5eb7dcdbc3de53c')
```

### Contact Management

#### Contacts

```ruby
# Get all contacts
contacts = client.contact.contacts.get

# Get a specific contact
contact = client.contact.contacts.get('COabcdef1234567890abcdef1234567890')

# Create a contact
contact = client.contact.contacts.create(
  contact: 'user@example.com',
  type: 'email',
  schedule: 'every_check',
  contact_group: [
    'CG4f3e2d1c0b9a8776655443322110fedc',
    'CG5a6b7c8d9e0f1234567890abcdef1234'
  ]
)

# Update a contact
contact = client.contact.contacts.update('COabcdef1234567890abcdef1234567890',
  contact: 'updated@example.com',
  contact_group: [
    'CG4f3e2d1c0b9a8776655443322110fedc',
    'CG5a6b7c8d9e0f1234567890abcdef1234'
  ]
)

# Delete a contact
result = client.contact.contacts.delete('COabcdef1234567890abcdef1234567890')
```

#### Groups

```ruby
# Get all groups
groups = client.contact.groups.get

# Get a specific group
group = client.contact.groups.get('CG4f3e2d1c0b9a8776655443322110fedc')

# Create a group
group = client.contact.groups.create(
  name: 'Primary Contacts'
)

# Update a group
group = client.contact.groups.update('CG4f3e2d1c0b9a8776655443322110fedc',
  name: 'Updated Group Name'
)

# Delete a group
result = client.contact.groups.delete('CG4f3e2d1c0b9a8776655443322110fedc')
```

## Error Handling

All methods raise `GeneratorLabs::Error` on failure:

```ruby
begin
  result = client.rbl.check('8.8.8.8')
rescue GeneratorLabs::Error => e
  puts "API error: #{e.message}"
end
```

## Retry Logic

The SDK automatically retries failed requests with exponential backoff:
- Configurable maximum retry attempts (default: 3)
- Retries on connection errors, 5xx server errors, and 429 rate limits
- Respects `Retry-After` header on 429 responses before falling back to exponential backoff
- A `Retry-After` longer than 60 seconds is not waited out: the 429 is raised as the error instead
- Configurable exponential backoff multiplier (default: 1.0 for 1s, 2s, 4s delays)
- Configurable connection timeout (default: 5 seconds)
- Configurable request timeout (default: 30 seconds)

Customize retry behavior via the `Config` class:

```ruby
config = GeneratorLabs::Config.new(
  max_retries: 5,        # More retry attempts
  retry_backoff: 2.0,    # Faster exponential growth
  timeout: 60            # Longer timeout
)
client = GeneratorLabs::Client.new(account_sid, auth_token, config)
```

## Rate Limiting

The API enforces two layers of rate limiting:

- **Hourly limit**: 1,000 requests per hour per application
- **Per-second limit**: varies by endpoint — 100 RPS for read operations, 50 RPS for write operations, and 20 RPS for manual check start

When a rate limit is exceeded, the API returns HTTP 429 with a `Retry-After` header indicating how many seconds to wait. The SDK automatically respects this header during retries.

All API responses include IETF draft rate limit headers, accessible via the `rate_limit_info` attribute on every response:

| Header | Description | Example |
|--------|-------------|---------|
| `RateLimit-Limit` | Active rate limit policies | `1000;w=3600, 100;w=1` |
| `RateLimit-Remaining` | Requests remaining in the most restrictive window | `95` |
| `RateLimit-Reset` | Seconds until the most restrictive window resets | `1` |

```ruby
response = client.rbl.hosts.get

# Access response data (bracket notation works as before)
hosts = response['data']

# Access rate limit info
if response.rate_limit_info
  puts "Remaining: #{response.rate_limit_info.remaining}"
  puts "Reset: #{response.rate_limit_info.reset}s"
end
```

## Examples

The `examples/` directory contains complete, runnable examples demonstrating:

- **check_ip.rb**: Check if an IP is listed on any RBLs
- **manage_hosts.rb**: Create, list, update, and delete monitored hosts
- **pagination.rb**: Handle large result sets with automatic pagination
- **error_handling.rb**: Proper error handling and custom configuration

Run examples:

```bash
export GENERATOR_LABS_ACCOUNT_SID="your_account_sid"
export GENERATOR_LABS_AUTH_TOKEN="your_auth_token"
ruby examples/check_ip.rb
```

## Requirements

- Ruby 3.0 or higher
- Valid Generator Labs API credentials (account SID and auth token)

## Testing

```bash
bundle exec rspec
```

## Security

For security best practices and vulnerability reporting, see [SECURITY.md](SECURITY.md).

## Release History

### v2.1.0 (2026-11-19)
* Added `client.account` (account, balance, usage, pause and resume scheduled checks)
* Added `client.cert.findings` (list, dismiss, restore), `client.cert.monitors.check` and `client.cert.errors.count`
* Added request options (`GeneratorLabs::RequestOptions`): `idempotency_key`, `request_id`, `if_none_match` and `fields`
* Automatic `Idempotency-Key` on requests that create something or start a check, reused on every retry
* `Response` exposes `request_id`, `etag`, `replayed` and `not_modified`; `Error` carries the `request_id`
* A `Retry-After` longer than 60 seconds is raised as the error, not waited out
* Fixed `get_all` returning an empty list, and retries waiting for the `RateLimit-Reset` time
* `get` takes a single ID; the form with several IDs is removed

### v2.0.1 (2026-06-19)
* Error detection now reads the API `status_code` and `status_message`; any `status_code` (or HTTP status) of 400 or greater raises `Error` with the API message
* `Error` now exposes a `status_code` reader

### v2.0.0 (2026-01-31)
* Complete rewrite for Generator Labs API v4.0
* RESTful endpoint design with proper HTTP verbs
* Updated to use Generator Labs branding (formerly RBLTracker)
* Automatic `Retry-After` header support on 429 rate limit responses
* `Response` wrapper (Hash-like) exposes per-request rate limit info (`rate_limit_info`)
* Added `RateLimitInfo` class with `limit`, `remaining`, and `reset` attributes
* Automatic retry with exponential backoff on 429 and 5xx errors
* Webhook signature verification with HMAC-SHA256 and constant-time comparison
* Automatic pagination via `get_all` for large result sets

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- Documentation: https://docs.generatorlabs.com/api/v4/
- Issues: https://github.com/generator-labs/ruby-sdk/issues
- Email: support@generatorlabs.com

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
