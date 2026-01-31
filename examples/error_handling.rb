#!/usr/bin/env ruby
# frozen_string_literal: true

# Example: Proper error handling and configuration

require 'generatorlabs'

account_sid = ENV['GENERATOR_LABS_ACCOUNT_SID']
auth_token = ENV['GENERATOR_LABS_AUTH_TOKEN']

if account_sid.nil? || account_sid.empty? || auth_token.nil? || auth_token.empty?
  abort 'Error: Set GENERATOR_LABS_ACCOUNT_SID and GENERATOR_LABS_AUTH_TOKEN environment variables'
end

# Initialize client with custom configuration
config = GeneratorLabs::Config.new(
  timeout: 45,
  connect_timeout: 10,
  max_retries: 5,
  retry_backoff: 2.0
)
client = GeneratorLabs::Client.new(account_sid, auth_token, config)

puts '=== Example 1: Handling API errors ==='
begin
  client.rbl.hosts.get('999999')
rescue GeneratorLabs::Error => e
  puts "Caught error: #{e.message}"
  puts "This is expected for a non-existent resource\n\n"
end

puts '=== Example 2: Invalid credentials ==='
begin
  GeneratorLabs::Client.new('INVALID', auth_token)
rescue GeneratorLabs::Error => e
  puts "Caught error: #{e.message}"
  puts "Credential validation works!\n\n"
end

puts '=== Example 3: Network resilience ==='
# The SDK automatically retries on:
# - Connection errors
# - 5xx server errors
# - 429 rate limit errors
# With exponential backoff

begin
  client.rbl.check('1.1.1.1')
  puts "Request succeeded (with automatic retries if needed)\n\n"
rescue GeneratorLabs::Error => e
  puts "API Error: #{e.message}"
end

puts '=== Example 4: Graceful degradation ==='
begin
  hosts = client.rbl.hosts.get
  puts "Successfully retrieved #{hosts['hosts'].length} hosts"
rescue GeneratorLabs::Error => e
  # Log error and continue with cached/default data
  puts "API error: #{e.message}"
  puts 'Using cached data due to API error'
  hosts = { 'hosts' => [] }
end

puts "\nAll examples completed!"
