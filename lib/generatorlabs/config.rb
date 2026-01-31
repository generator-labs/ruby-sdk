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
  # Configuration options for the Generator Labs API client.
  #
  # All fields are optional. If not provided, default values are used.
  # Create a custom config to override timeouts, retry behavior, or API endpoint.
  #
  # @example Basic usage with defaults
  #   config = GeneratorLabs::Config.new
  #
  # @example Custom timeouts and retries
  #   config = GeneratorLabs::Config.new(
  #     timeout: 45,
  #     max_retries: 5,
  #     retry_backoff: 2.0
  #   )
  #   client = GeneratorLabs::Client.new(account_sid, auth_token, config)
  class Config
    # @return [Integer] Request timeout in seconds (default: 30)
    attr_accessor :timeout

    # @return [Integer] Connection timeout in seconds (default: 5)
    attr_accessor :connect_timeout

    # @return [Integer] Maximum number of retry attempts (default: 3).
    #   The SDK automatically retries on connection errors, 5xx server errors,
    #   and 429 rate limit errors.
    attr_accessor :max_retries

    # @return [Float] Exponential backoff multiplier for retries (default: 1.0).
    #   Each retry waits retry_backoff^attemptNum seconds.
    #   Set to 2.0 for exponential backoff (1s, 2s, 4s, 8s, etc.)
    attr_accessor :retry_backoff

    # @return [String] Custom API base URL (default: "https://api.generatorlabs.com/4.0/").
    #   Override this for testing or if using a proxy.
    attr_accessor :base_url

    # Initialize a new configuration.
    #
    # @param options [Hash] Configuration options
    # @option options [Integer] :timeout Request timeout in seconds
    # @option options [Integer] :connect_timeout Connection timeout in seconds
    # @option options [Integer] :max_retries Maximum retry attempts
    # @option options [Float] :retry_backoff Exponential backoff multiplier
    # @option options [String] :base_url Custom API base URL
    #
    # @example
    #   config = GeneratorLabs::Config.new(timeout: 60, max_retries: 5)
    def initialize(options = {})
      @timeout = options.fetch(:timeout, 30)
      @connect_timeout = options.fetch(:connect_timeout, 5)
      @max_retries = options.fetch(:max_retries, 3)
      @retry_backoff = options.fetch(:retry_backoff, 1.0)
      @base_url = options.fetch(:base_url, 'https://api.generatorlabs.com/4.0/')
    end

    # Create a default configuration with standard values.
    #
    # Returns a Config with:
    # - timeout: 30 seconds
    # - connect_timeout: 5 seconds
    # - max_retries: 3
    # - retry_backoff: 1.0
    # - base_url: "https://api.generatorlabs.com/4.0/"
    #
    # @return [Config] Default configuration instance
    #
    # @example
    #   config = GeneratorLabs::Config.default
    def self.default
      new
    end
  end
end
