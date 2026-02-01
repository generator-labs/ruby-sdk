#!/usr/bin/env ruby
# frozen_string_literal: true

#
# Example: Certificate monitoring - list errors, manage monitors and profiles
#

require 'generatorlabs'

account_sid = ENV.fetch('GENERATOR_LABS_ACCOUNT_SID', nil)
auth_token = ENV.fetch('GENERATOR_LABS_AUTH_TOKEN', nil)

if account_sid.nil? || auth_token.nil?
  puts 'Error: Set GENERATOR_LABS_ACCOUNT_SID and GENERATOR_LABS_AUTH_TOKEN environment variables'
  exit 1
end

begin
  client = GeneratorLabs::Client.new(account_sid, auth_token)

  # ===================================================================
  # Certificate Errors
  # ===================================================================
  puts '=== Listing Certificate Errors ==='
  errors = client.cert.errors.get
  puts "Total errors: #{errors['errors']&.length || 0}\n\n"

  errors['errors']&.each do |error|
    puts "Error ID: #{error['id']}"
    puts "  Monitor: #{error['monitor_name']}"
    puts "  Type: #{error['error_type']}"
    puts "  Message: #{error['message']}\n\n"
  end

  # ===================================================================
  # Certificate Profiles
  # ===================================================================
  puts '=== Managing Certificate Profiles ==='

  # List all profiles
  profiles = client.cert.profiles.get
  puts "Total profiles: #{profiles['profiles']&.length || 0}"

  # Create a new profile
  puts "\n=== Creating a new certificate profile ==="
  new_profile = client.cert.profiles.create(
    name: 'Example Certificate Profile',
    expiration_warning_days: 30,
    expiration_critical_days: 7,
    check_self_signed: true,
    check_hostname_mismatch: true
  )
  puts "Created profile ID: #{new_profile['profile']['id']}"
  profile_id = new_profile['profile']['id']

  # Get specific profile
  puts "\n=== Getting specific profile ==="
  profile = client.cert.profiles.get(profile_id)
  puts "Profile name: #{profile['profile']['name']}"
  puts "Expiration warning days: #{profile['profile']['expiration_warning_days']}"

  # Update profile
  puts "\n=== Updating profile ==="
  client.cert.profiles.update(profile_id, expiration_warning_days: 45)
  puts 'Updated profile warning days to 45'

  # ===================================================================
  # Certificate Monitors
  # ===================================================================
  puts "\n=== Managing Certificate Monitors ==="

  # List all monitors
  monitors = client.cert.monitors.get
  puts "Total monitors: #{monitors['monitors']&.length || 0}"

  # Create a new HTTPS monitor
  puts "\n=== Creating HTTPS certificate monitor ==="
  https_monitor = client.cert.monitors.create(
    name: 'Example HTTPS Monitor',
    hostname: 'example.com',
    port: 443,
    protocol: 'https',
    cert_profile: profile_id,
    contact_group: 'CG4f3e2d1c0b9a8776655443322110fed' # Use your contact group ID
  )
  puts "Created HTTPS monitor ID: #{https_monitor['monitor']['id']}"
  https_monitor_id = https_monitor['monitor']['id']

  # Create a mail server monitor (SMTPS)
  puts "\n=== Creating SMTPS certificate monitor ==="
  smtps_monitor = client.cert.monitors.create(
    name: 'Example Mail Server Monitor',
    hostname: 'mail.example.com',
    port: 465,
    protocol: 'smtps',
    cert_profile: profile_id,
    contact_group: 'CG4f3e2d1c0b9a8776655443322110fed'
  )
  puts "Created SMTPS monitor ID: #{smtps_monitor['monitor']['id']}"
  smtps_monitor_id = smtps_monitor['monitor']['id']

  # Get specific monitor
  puts "\n=== Getting specific monitor ==="
  monitor = client.cert.monitors.get(https_monitor_id)
  puts "Monitor name: #{monitor['monitor']['name']}"
  puts "Hostname: #{monitor['monitor']['hostname']}"
  puts "Protocol: #{monitor['monitor']['protocol']}"
  puts "Status: #{monitor['monitor']['status']}"

  # Update monitor
  puts "\n=== Updating monitor ==="
  client.cert.monitors.update(https_monitor_id, name: 'Updated HTTPS Monitor Name')
  puts 'Updated monitor name'

  # Pause monitoring
  puts "\n=== Pausing monitor ==="
  client.cert.monitors.pause(https_monitor_id)
  puts "Paused monitor ID: #{https_monitor_id}"

  # Resume monitoring
  puts "\n=== Resuming monitor ==="
  client.cert.monitors.resume(https_monitor_id)
  puts "Resumed monitor ID: #{https_monitor_id}"

  # ===================================================================
  # Cleanup
  # ===================================================================
  puts "\n=== Cleaning up - Deleting created resources ==="

  # Delete monitors
  client.cert.monitors.delete(https_monitor_id)
  puts "Deleted HTTPS monitor ID: #{https_monitor_id}"

  client.cert.monitors.delete(smtps_monitor_id)
  puts "Deleted SMTPS monitor ID: #{smtps_monitor_id}"

  # Delete profile
  client.cert.profiles.delete(profile_id)
  puts "Deleted profile ID: #{profile_id}"

  puts "\n=== Certificate Monitoring Example Complete ==="
rescue GeneratorLabs::Error => e
  puts "API Error: #{e.message}"
  exit 1
end
