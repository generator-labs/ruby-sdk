# Generator Labs Ruby SDK

[![Gem Version](https://badge.fury.io/rb/generatorlabs.svg)](https://badge.fury.io/rb/generatorlabs)
[![Tests](https://github.com/generator-labs/ruby-sdk/workflows/Tests/badge.svg)](https://github.com/generator-labs/ruby-sdk/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Official Ruby SDK for the [Generator Labs API](https://generatorlabs.com). This library provides a simple and intuitive interface for interacting with the Generator Labs v4.0 API, including RBL monitoring, contact management, and more.

## Features

- Full support for Generator Labs API v4.0
- Automatic retry logic with exponential backoff
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

# Initialize the client
client = GeneratorLabs::Client.new(
  'YOUR_ACCOUNT_SID',
  'YOUR_AUTH_TOKEN'
)

# Get all monitored hosts
hosts = client.rbl.hosts.get
puts hosts

# Check an IP address
result = client.rbl.check('8.8.8.8')
puts result

# Get all contacts
contacts = client.contact.contacts.get
puts contacts
```

## API Reference

### Client Initialization

```ruby
client = GeneratorLabs::Client.new(account_sid, auth_token)
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
- Maximum 3 retry attempts
- Retries on connection errors, 5xx server errors, and 429 rate limits
- Exponential backoff delays: 1s, 2s, 4s
- Connection timeout: 5 seconds
- Request timeout: 30 seconds

## Requirements

- Ruby 3.0 or higher
- Valid Generator Labs API credentials (account SID and auth token)

## Testing

```bash
bundle exec rspec
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- Documentation: https://docs.generatorlabs.com/api/v4/
- Issues: https://github.com/generator-labs/ruby-sdk/issues
- Email: support@generatorlabs.com

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
