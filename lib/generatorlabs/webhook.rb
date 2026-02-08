# frozen_string_literal: true

#
# This file is part of the Generator Labs Ruby SDK package.
#
# (c) Generator Labs <support@generatorlabs.com>
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#

require 'openssl'
require 'json'

module GeneratorLabs
  # Webhook signature verification utility.
  #
  # Verifies that incoming webhook requests were sent by Generator Labs
  # using HMAC-SHA256 signatures.
  #
  # @example
  #   payload = GeneratorLabs::Webhook.verify(body, header, signing_secret)
  class Webhook
    # Default tolerance in seconds for timestamp validation (5 minutes).
    DEFAULT_TOLERANCE = 300

    # Verify a webhook signature and return the decoded payload.
    #
    # @param body [String] The raw request body string
    # @param header [String] The X-Webhook-Signature header value
    # @param secret [String] Your webhook's signing secret
    # @param tolerance [Integer] Maximum age in seconds (0 to disable, default: 300)
    # @return [Hash] The decoded JSON payload
    # @raise [Error] if verification fails
    def self.verify(body, header, secret, tolerance = DEFAULT_TOLERANCE)
      raise Error, 'Missing X-Webhook-Signature header.' if header.nil? || header.empty?

      # Parse the header: t=timestamp,v1=signature
      parts = {}
      header.split(',').each do |part|
        key, value = part.split('=', 2)
        parts[key] = value
      end

      raise Error, 'Invalid X-Webhook-Signature header format.' unless parts.key?('t') && parts.key?('v1')

      # Check timestamp tolerance
      if tolerance > 0 && (Time.now.to_i - parts['t'].to_i).abs > tolerance
        raise Error, 'Webhook timestamp is outside the tolerance window.'
      end

      # Compute and compare the signature
      expected = OpenSSL::HMAC.hexdigest('sha256', secret, "#{parts['t']}.#{body}")

      unless secure_compare(expected, parts['v1'])
        raise Error, 'Webhook signature verification failed.'
      end

      # Decode and return the payload
      JSON.parse(body)
    end

    # Constant-time string comparison.
    def self.secure_compare(a, b)
      return false unless a.bytesize == b.bytesize

      OpenSSL.fixed_length_secure_compare(a, b)
    end

    private_class_method :secure_compare
  end
end
