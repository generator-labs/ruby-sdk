#!/usr/bin/env ruby
# frozen_string_literal: true

# Example: Manage monitored hosts (create, list, update, delete)

require 'generatorlabs'

# Get credentials from environment variables
account_sid = ENV['GENERATOR_LABS_ACCOUNT_SID']
auth_token = ENV['GENERATOR_LABS_AUTH_TOKEN']

if account_sid.nil? || account_sid.empty? || auth_token.nil? || auth_token.empty?
  abort 'Error: Set GENERATOR_LABS_ACCOUNT_SID and GENERATOR_LABS_AUTH_TOKEN environment variables'
end

# Initialize client
client = GeneratorLabs::Client.new(account_sid, auth_token)

# List all hosts
puts '=== Listing all monitored hosts ==='
hosts = client.rbl.hosts.get
puts "Total hosts: #{hosts['hosts'].length}\n\n"
hosts['hosts'].each do |host|
  puts "ID: #{host['id']}, IP: #{host['ip']}, Description: #{host['description']}"
end

# Create a new host
puts "\n=== Creating a new host ==="
new_host = client.rbl.hosts.create(
  ip: '203.0.113.10',
  description: 'Example host from Ruby SDK',
  profile_id: 1 # Use your profile ID
)
host_id = new_host.dig('host', 'id')
puts "Created host ID: #{host_id}"

# Get specific host
puts "\n=== Getting specific host ==="
host = client.rbl.hosts.get(host_id)
puts 'Host details:'
puts host.inspect

# Update host
puts "\n=== Updating host ==="
client.rbl.hosts.update(host_id, description: 'Updated description from Ruby SDK')
puts 'Updated host description'

# Delete host
puts "\n=== Deleting host ==="
client.rbl.hosts.delete(host_id)
puts "Deleted host ID: #{host_id}"
