#!/usr/bin/env ruby
# frozen_string_literal: true

# Example: Check if an IP address is listed on any RBLs

require 'generatorlabs'

# Get credentials from environment variables
account_sid = ENV.fetch('GENERATOR_LABS_ACCOUNT_SID', nil)
auth_token = ENV.fetch('GENERATOR_LABS_AUTH_TOKEN', nil)

if account_sid.nil? || account_sid.empty? || auth_token.nil? || auth_token.empty?
  abort 'Error: Set GENERATOR_LABS_ACCOUNT_SID and GENERATOR_LABS_AUTH_TOKEN environment variables'
end

# Initialize client
client = GeneratorLabs::Client.new(account_sid, auth_token)

# Check a single IP address
ip = '8.8.8.8'
puts "Checking IP: #{ip}"

result = client.rbl.check(ip)

puts 'Results:'
puts result.inspect

# Check if IP is listed
if result['listed']
  puts "\nWARNING: IP #{ip} is listed on one or more RBLs!"
  puts "Listed on: #{result['listings'].length} RBL(s)" if result['listings']
else
  puts "\nIP #{ip} is clean - not listed on any RBLs"
end
