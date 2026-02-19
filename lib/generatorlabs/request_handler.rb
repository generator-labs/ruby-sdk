# frozen_string_literal: true

#
# This file is part of the Generator Labs Ruby SDK package.
#
# (c) Generator Labs <support@generatorlabs.com>
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#

require 'faraday'
require 'faraday/retry'
require 'json'

module GeneratorLabs
  # Handles HTTP requests to the Generator Labs API.
  #
  # This class manages HTTP client configuration, authentication, retry logic,
  # and error handling for all API requests. It automatically retries failed
  # requests using exponential backoff on connection errors, 5xx server errors,
  # and 429 rate limit errors.
  class RequestHandler
    # Initialize request handler with authentication and retry logic.
    #
    # This creates a Faraday connection with:
    # - Automatic retries on connection errors, 5xx errors, and 429 rate limits
    # - Exponential backoff based on config.retry_backoff
    # - Configurable timeouts from config.timeout and config.connect_timeout
    # - HTTP Basic Authentication using account_sid and auth_token
    #
    # @param account_sid [String] Account SID for authentication
    # @param auth_token [String] Auth token for authentication
    # @param config [Config] Configuration object with timeouts and retry settings
    def initialize(account_sid, auth_token, config)
      @account_sid = account_sid
      @auth_token = auth_token
      @config = config

      # Create Faraday connection with retry middleware
      @connection = Faraday.new(url: config.base_url) do |faraday_config|
        faraday_config.request :url_encoded
        faraday_config.request :authorization, :basic, account_sid, auth_token
        faraday_config.request :retry,
                               max: config.max_retries,
                               interval: 1.0,
                               backoff_factor: config.retry_backoff,
                               retry_statuses: [429, 500, 502, 503, 504],
                               methods: %i[get post put delete]

        faraday_config.adapter Faraday.default_adapter
        faraday_config.options.timeout = config.timeout
        faraday_config.options.open_timeout = config.connect_timeout
      end
    end

    # Make a GET request to the API.
    #
    # Parameters are sent as query string parameters. The request includes
    # automatic retry logic for failures.
    #
    # @param path [String] API endpoint path (e.g., 'rbl/hosts')
    # @param params [Hash, nil] Query parameters (e.g., {status: 'active'})
    # @return [Hash] Parsed JSON response
    # @raise [Error] if request fails after all retries
    #
    # @example
    #   handler.get('rbl/hosts', { status: 'active' })
    def get(path, params = nil)
      make_request(:get, path, params)
    end

    # Make a POST request to the API.
    #
    # Parameters are sent as application/x-www-form-urlencoded data.
    # The request includes automatic retry logic for failures.
    #
    # @param path [String] API endpoint path (e.g., 'rbl/hosts')
    # @param params [Hash, nil] Request parameters (e.g., {name: 'My Host', host: '1.2.3.4'})
    # @return [Hash] Parsed JSON response
    # @raise [Error] if request fails after all retries
    #
    # @example
    #   handler.post('rbl/hosts', { name: 'My Host', host: '1.2.3.4', type: 'rbl' })
    def post(path, params = nil)
      make_request(:post, path, params)
    end

    # Make a PUT request to the API.
    #
    # Parameters are sent as application/x-www-form-urlencoded data.
    # The request includes automatic retry logic for failures.
    #
    # @param path [String] API endpoint path (e.g., 'rbl/hosts/HTxxxxxxxx')
    # @param params [Hash, nil] Request parameters (e.g., {name: 'Updated Name'})
    # @return [Hash] Parsed JSON response
    # @raise [Error] if request fails after all retries
    #
    # @example
    #   handler.put('rbl/hosts/HT1a2b3c4d5e6f7890abcdef1234567890', { name: 'Updated Name' })
    def put(path, params = nil)
      make_request(:put, path, params)
    end

    # Make a DELETE request to the API.
    #
    # No parameters are sent with DELETE requests. The request includes
    # automatic retry logic for failures.
    #
    # @param path [String] API endpoint path (e.g., 'rbl/hosts/HTxxxxxxxx')
    # @return [Hash] Parsed JSON response
    # @raise [Error] if request fails after all retries
    #
    # @example
    #   handler.delete('rbl/hosts/HT1a2b3c4d5e6f7890abcdef1234567890')
    def delete(path)
      make_request(:delete, path, nil)
    end

    private

    # Make HTTP request to API with automatic retries.
    #
    # This method handles:
    # - Building the request URL with .json extension
    # - Adding query parameters for GET requests
    # - Adding form data for POST/PUT/DELETE requests
    # - Setting authentication headers
    # - Executing the request with retry logic
    # - Parsing JSON responses
    # - Checking for API errors in the response
    #
    # Errors are raised if:
    # - All retry attempts fail
    # - The response body cannot be parsed
    # - The API returns success=false in the response
    # - The HTTP status code is >= 400
    #
    # @param method [Symbol] HTTP method (:get, :post, :put, :delete)
    # @param path [String] API endpoint path
    # @param params [Hash, nil] Request parameters
    # @return [Hash] Parsed JSON response
    # @raise [Error] if request fails or response is invalid
    def make_request(method, path, params)
      url = "#{path}.json"

      # Convert array values to comma-separated strings for form encoding
      if params
        params = params.transform_values { |v| v.is_a?(Array) ? v.join(',') : v }
      end

      response = @connection.send(method) do |req|
        req.url url
        req.headers['User-Agent'] = "GeneratorLabs-Ruby/#{VERSION}"
        req.headers['Accept'] = 'application/json'
        if method == :get && params
          req.params = params
        elsif %i[post put delete].include?(method) && params
          req.body = params
        end
      end

      # Parse JSON response
      data = JSON.parse(response.body)

      # Check for API error in v4.0 format
      if data.is_a?(Hash) && data['success'] == false
        error_msg = data.dig('error', 'message') || data['message'] || 'Unknown error'
        raise Error, "API error: #{error_msg}"
      end

      # Check HTTP status code
      if response.status >= 400
        error_msg = data.dig('error', 'message') || data['message'] || "HTTP #{response.status} error"
        raise Error, "API error: #{error_msg}"
      end

      data
    rescue JSON::ParserError => e
      raise Error, "Failed to parse JSON response: #{e.message}"
    rescue Faraday::Error => e
      raise Error, "API request failed: #{e.message}"
    end
  end
end
