#!/usr/bin/env ruby
# frozen_string_literal: true

# Example: Paginate through large result sets

require 'generatorlabs'

# Get credentials from environment variables
account_sid = ENV['GENERATOR_LABS_ACCOUNT_SID']
auth_token = ENV['GENERATOR_LABS_AUTH_TOKEN']

if account_sid.nil? || account_sid.empty? || auth_token.nil? || auth_token.empty?
  abort 'Error: Set GENERATOR_LABS_ACCOUNT_SID and GENERATOR_LABS_AUTH_TOKEN environment variables'
end

# Initialize client
client = GeneratorLabs::Client.new(account_sid, auth_token)

puts '=== Fetching all hosts with pagination ==='

all_hosts = []
page = 1
page_size = 50

loop do
  puts "Fetching page #{page}..."

  response = client.rbl.hosts.get(page: page, page_size: page_size)
  hosts = response['hosts'] || []

  all_hosts.concat(hosts)
  puts "  Retrieved #{hosts.length} hosts"

  break unless response['has_more'] && !hosts.empty?

  page += 1
end

puts "\nTotal hosts retrieved: #{all_hosts.length}"

# Alternative: Use the built-in pagination helper
puts "\n=== Using pagination helper ==="

all_hosts_helper = client.rbl.hosts.get_all(page_size: 50)
puts "Total hosts via helper: #{all_hosts_helper.length}"
