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
  # Handles HTTP requests to the Generator Labs API
  class RequestHandler
    # Initialize request handler
    #
    # @param account_sid [String] Account SID for authentication
    # @param auth_token [String] Auth token for authentication
    # @param base_url [String] Base API URL
    def initialize(account_sid, auth_token, base_url)
      @account_sid = account_sid
      @auth_token = auth_token
      @base_url = base_url

      # Create Faraday connection with retry middleware
      @connection = Faraday.new(url: base_url) do |config|
        config.request :url_encoded
        config.request :retry,
                       max: 3,
                       interval: 1.0,
                       backoff_factor: 2,
                       retry_statuses: [429, 500, 502, 503, 504],
                       methods: %i[get post put delete]

        config.adapter Faraday.default_adapter
        config.options.timeout = 30
        config.options.open_timeout = 5
      end
    end

    # Make a GET request
    #
    # @param path [String] API endpoint path
    # @param params [Hash, nil] Query parameters
    # @return [Hash] Parsed JSON response
    # @raise [Error] if request fails
    def get(path, params = nil)
      make_request(:get, path, params)
    end

    # Make a POST request
    #
    # @param path [String] API endpoint path
    # @param params [Hash, nil] Request parameters
    # @return [Hash] Parsed JSON response
    # @raise [Error] if request fails
    def post(path, params = nil)
      make_request(:post, path, params)
    end

    # Make a PUT request
    #
    # @param path [String] API endpoint path
    # @param params [Hash, nil] Request parameters
    # @return [Hash] Parsed JSON response
    # @raise [Error] if request fails
    def put(path, params = nil)
      make_request(:put, path, params)
    end

    # Make a DELETE request
    #
    # @param path [String] API endpoint path
    # @return [Hash] Parsed JSON response
    # @raise [Error] if request fails
    def delete(path)
      make_request(:delete, path, nil)
    end

    private

    # Make HTTP request to API
    #
    # @param method [Symbol] HTTP method (:get, :post, :put, :delete)
    # @param path [String] API endpoint path
    # @param params [Hash, nil] Request parameters
    # @return [Hash] Parsed JSON response
    # @raise [Error] if request fails
    def make_request(method, path, params)
      url = "#{path}.json"

      response = @connection.send(method) do |req|
        req.url url
        req.headers['User-Agent'] = "GeneratorLabs-Ruby/#{VERSION}"
        req.headers['Accept'] = 'application/json'
        req.basic_auth(@account_sid, @auth_token)

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
