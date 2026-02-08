#!/usr/bin/env ruby
# frozen_string_literal: true

# Example: Verifying webhook signatures
#
# This example shows how to verify incoming webhook requests from Generator Labs
# using the SDK's built-in signature verification helper.

require 'generatorlabs'
require 'json'

# Your webhook's signing secret, available in the Edit Webhook panel of the Portal.
# Store this securely (e.g., environment variable), never hard-code it.
signing_secret = ENV.fetch('GENERATOR_LABS_WEBHOOK_SECRET', nil)

if signing_secret.nil? || signing_secret.empty?
  abort 'Error: Set GENERATOR_LABS_WEBHOOK_SECRET environment variable'
end

#
# Example 1: Basic verification
#
# Verify the signature with the default 5-minute tolerance window.
# On success, returns the decoded JSON payload as a Hash.
# Raises a GeneratorLabs::Error if verification fails.
#
def verify_basic(body, header, secret)
  payload = GeneratorLabs::Webhook.verify(body, header, secret)

  puts 'Webhook verified successfully!'
  puts "Event: #{payload['event'] || 'unknown'}"

  payload
rescue GeneratorLabs::Error => e
  puts "Verification failed: #{e.message}"
  nil
end

#
# Example 2: Custom tolerance
#
# Set a custom tolerance window (in seconds) for timestamp validation.
# Use 0 to disable timestamp checking entirely.
#
def verify_custom_tolerance(body, header, secret)
  # 10-minute tolerance
  payload = GeneratorLabs::Webhook.verify(body, header, secret, 600)
  puts "Verified with custom tolerance: #{payload}"
  payload
rescue GeneratorLabs::Error => e
  puts "Verification failed: #{e.message}"
  nil
end

#
# Example 3: Usage with Sinatra
#
# A typical Sinatra webhook endpoint using the SDK verification helper.
#
# require 'sinatra'
#
# post '/webhook' do
#   header = request.env['HTTP_X_WEBHOOK_SIGNATURE'] || ''
#   body = request.body.read
#
#   begin
#     payload = GeneratorLabs::Webhook.verify(body, header, signing_secret)
#   rescue GeneratorLabs::Error
#     halt 403, { 'Content-Type' => 'application/json' }, { error: 'Invalid signature' }.to_json
#   end
#
#   # Process the event
#   case payload['event']
#   when 'rbl.host.listed'
#     # Handle host listed event
#   when 'rbl.host.delisted'
#     # Handle host delisted event
#   when 'billing.balance.alert'
#     # Handle low balance alert
#   end
#
#   content_type :json
#   { status: 'ok' }.to_json
# end
