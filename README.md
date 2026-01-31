# Generator Labs Ruby SDK

[![Gem Version](https://badge.fury.io/rb/generatorlabs.svg)](https://badge.fury.io/rb/generatorlabs)
[![Tests](https://github.com/generator-labs/ruby-sdk/workflows/Tests/badge.svg)](https://github.com/generator-labs/ruby-sdk/actions)
[![CodeQL](https://github.com/generator-labs/ruby-sdk/workflows/CodeQL/badge.svg)](https://github.com/generator-labs/ruby-sdk/actions?query=workflow%3ACodeQL)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Official Ruby SDK for the [Generator Labs API](https://generatorlabs.com). This library provides a simple and intuitive interface for interacting with the Generator Labs v4.0 API, including RBL monitoring, contact management, and more.

## Features

- Full support for Generator Labs API v4.0
- Configurable timeouts, retries, and backoff strategies
- Automatic retry logic with exponential backoff
- Automatic pagination for large result sets
- Connection pooling and timeout management
- Clean, Ruby-idiomatic API
- Comprehensive error handling
- Security scanning with CodeQL and Dependabot
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

# Check an IP address
result = client.rbl.check('8.8.8.8')
puts result

# Get all contacts with automatic pagination
all_contacts = client.contact.contacts.get_all
puts "Total contacts: #{all_contacts.length}"
```

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

### RBL Monitoring

#### Hosts

```ruby
# Get all hosts
hosts = client.rbl.hosts.get

# Get a specific host
host = client.rbl.hosts.get(123)

# Get multiple hosts
hosts = client.rbl.hosts.get(123, 456, 789)

# Create a host
host = client.rbl.hosts.create(
  ip: '8.8.8.8',
  description: 'Google DNS'
)

# Update a host
host = client.rbl.hosts.update(123, description: 'Updated description')

# Delete a host
result = client.rbl.hosts.delete(123)
```

#### Profiles

```ruby
# Get all profiles
profiles = client.rbl.profiles.get

# Get a specific profile
profile = client.rbl.profiles.get(1)

# Create/Update/Delete - similar to Hosts
```

#### Sources

```ruby
# Get all RBL sources
sources = client.rbl.sources.get

# Get a specific source
source = client.rbl.sources.get(10)

# Create/Update/Delete - similar to Hosts
```

#### Check & Listings

```ruby
# Check an IP address
result = client.rbl.check('8.8.8.8')

# Get current listings
listings = client.rbl.listings
```

### Certificate Monitoring

Certificate monitoring allows you to monitor SSL/TLS certificates for expiration, validity, and configuration issues across HTTPS, SMTPS, IMAPS, and other TLS-enabled services.

#### Errors

```ruby
# Get all certificate errors
errors = client.cert.errors.get

# Get a specific error
error = client.cert.errors.get('CE5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a')
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
  port: 443,
  protocol: 'https',
  cert_profile: 'CP79b597e61a984a35b5eb7dcdbc3de53c',
  contact_group: 'CG4f3e2d1c0b9a8776655443322110fed'
)

# Update a monitor
monitor = client.cert.monitors.update('CM62944aeeee2b46d7a28221164f38976a', name: 'Updated Server Name')

# Delete a monitor
result = client.cert.monitors.delete('CM62944aeeee2b46d7a28221164f38976a')

# Pause monitoring
result = client.cert.monitors.pause('CM62944aeeee2b46d7a28221164f38976a')

# Resume monitoring
result = client.cert.monitors.resume('CM62944aeeee2b46d7a28221164f38976a')
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
  expiration_warning_days: 30,
  expiration_critical_days: 7
)

# Update a profile
profile = client.cert.profiles.update('CP79b597e61a984a35b5eb7dcdbc3de53c', expiration_warning_days: 45)

# Delete a profile
result = client.cert.profiles.delete('CP79b597e61a984a35b5eb7dcdbc3de53c')
```

### Contact Management

#### Contacts

```ruby
# Get all contacts
contacts = client.contact.contacts.get

# Get a specific contact
contact = client.contact.contacts.get(456)

# Get multiple contacts
contacts = client.contact.contacts.get(456, 789)

# Create a contact
contact = client.contact.contacts.create(
  email: 'user@example.com',
  name: 'John Doe'
)

# Update a contact
contact = client.contact.contacts.update(456, name: 'Jane Doe')

# Delete a contact
result = client.contact.contacts.delete(456)
```

#### Groups

```ruby
# Get all groups
groups = client.contact.groups.get

# Get a specific group
group = client.contact.groups.get(10)

# Create/Update/Delete - similar to Contacts
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

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- Documentation: https://docs.generatorlabs.com/api/v4/
- Issues: https://github.com/generator-labs/ruby-sdk/issues
- Email: support@generatorlabs.com

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
