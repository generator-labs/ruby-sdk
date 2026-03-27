# frozen_string_literal: true

#
# This file is part of the Generator Labs Ruby SDK package.
#
# (c) Generator Labs <support@generatorlabs.com>
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#

module GeneratorLabs
  # API response wrapper providing Hash-like access to response data and rate limit info.
  #
  # Supports bracket notation (response['key']) for backward compatibility
  # with raw Hash returns, while also exposing rate_limit_info.
  class Response
    # @return [RateLimitInfo, nil] Rate limit information from response headers
    attr_reader :rate_limit_info

    # @param data [Hash] Parsed JSON response body
    # @param rate_limit_info [RateLimitInfo, nil] Rate limit information
    def initialize(data, rate_limit_info = nil)
      @data = data
      @rate_limit_info = rate_limit_info
    end

    # Access response data by key (Hash-like access).
    # @param key [String] The key to look up
    # @return [Object] The value
    def [](key)
      @data[key]
    end

    # Dig into nested response data.
    # @param keys [Array] Keys to dig through
    # @return [Object] The nested value
    def dig(*keys)
      @data.dig(*keys)
    end

    # Check if a key exists in the response data.
    # @param key [String] The key to check
    # @return [Boolean]
    def key?(key)
      @data.key?(key)
    end

    # Convert to a plain Hash.
    # @return [Hash]
    def to_h
      @data
    end

    # Check if the response data is a Hash (for type compatibility).
    # @param klass [Class] The class to check
    # @return [Boolean]
    def is_a?(klass)
      klass == Hash ? true : super
    end
  end
end
