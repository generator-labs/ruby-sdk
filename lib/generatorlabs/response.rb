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

    # @return [String, nil] The X-Request-Id of the response; quote it when contacting support
    attr_reader :request_id

    # @return [String, nil] The ETag of a GET response, to send back as if_none_match
    attr_reader :etag

    # @return [Boolean] true when the API answered with the result of an earlier request
    #   that carried the same Idempotency-Key
    attr_reader :replayed

    # @return [Boolean] true for a 304 Not Modified answer to if_none_match (no data)
    attr_reader :not_modified

    # @param data [Hash] Parsed JSON response body
    # @param rate_limit_info [RateLimitInfo, nil] Rate limit information
    # @param request_id [String, nil] X-Request-Id of the response
    # @param etag [String, nil] ETag of the response
    # @param replayed [Boolean] Whether the answer is a replay of an earlier request
    # @param not_modified [Boolean] Whether the answer is 304 Not Modified
    def initialize(data, rate_limit_info = nil, request_id: nil, etag: nil, replayed: false, not_modified: false) # rubocop:disable Metrics/ParameterLists
      @data = data
      @rate_limit_info = rate_limit_info
      @request_id = request_id
      @etag = etag
      @replayed = replayed
      @not_modified = not_modified
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
