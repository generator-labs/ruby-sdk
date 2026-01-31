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
  # Configuration options for the Generator Labs API client
  class Config
    # @return [Integer] Request timeout in seconds (default: 30)
    attr_accessor :timeout

    # @return [Integer] Connection timeout in seconds (default: 5)
    attr_accessor :connect_timeout

    # @return [Integer] Maximum number of retry attempts (default: 3)
    attr_accessor :max_retries

    # @return [Float] Backoff multiplier for retries (default: 1.0)
    attr_accessor :retry_backoff

    # @return [String] Custom API base URL
    attr_accessor :base_url

    # Initialize a new configuration
    #
    # @param options [Hash] Configuration options
    # @option options [Integer] :timeout Request timeout in seconds
    # @option options [Integer] :connect_timeout Connection timeout in seconds
    # @option options [Integer] :max_retries Maximum retry attempts
    # @option options [Float] :retry_backoff Backoff multiplier
    # @option options [String] :base_url Custom API base URL
    def initialize(options = {})
      @timeout = options.fetch(:timeout, 30)
      @connect_timeout = options.fetch(:connect_timeout, 5)
      @max_retries = options.fetch(:max_retries, 3)
      @retry_backoff = options.fetch(:retry_backoff, 1.0)
      @base_url = options.fetch(:base_url, 'https://api.generatorlabs.com/4.0/')
    end

    # Create a default configuration
    #
    # @return [Config] Default configuration
    def self.default
      new
    end
  end
end
