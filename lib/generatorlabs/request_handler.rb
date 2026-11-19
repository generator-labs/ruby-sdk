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
require 'securerandom'

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
        # Retry with exponential backoff; faraday-retry respects Retry-After
        # headers automatically on rate limit (429) responses. A Retry-After longer
        # than max_interval is not waited out: the response is raised as the error.
        # RateLimit-Reset is on every response and is not a time to wait before a
        # retry, so the reset header is pointed at Retry-After as well.
        faraday_config.request :retry,
                               max: config.max_retries,
                               interval: 1.0,
                               backoff_factor: config.retry_backoff,
                               max_interval: MAX_RETRY_AFTER,
                               rate_limit_reset_header: 'Retry-After',
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
    # @param options [RequestOptions, nil] Request options
    # @return [Response] Response wrapper with parsed data and rate limit info
    # @raise [Error] if request fails after all retries
    #
    # @example
    #   handler.get('rbl/hosts', { status: 'active' })
    def get(path, params = nil, options = nil)
      make_request(:get, path, params, options)
    end

    # Make a GET request to an endpoint that answers in plain text.
    #
    # @param path [String] API endpoint path (e.g., 'account/balance')
    # @param options [RequestOptions, nil] Request options
    # @return [String] The response body
    # @raise [Error] if request fails or the HTTP status code is >= 400
    def get_plain(path, options = nil)
      response = send_request(:get, path, nil, options, false)
      return response.body.to_s.strip if response.status < 400

      raise Error.new("API error: HTTP #{response.status} error",
                      status_code: response.status, request_id: response.headers['x-request-id'])
    end

    # Make a POST request to the API.
    #
    # Parameters are sent as application/x-www-form-urlencoded data.
    # The request includes automatic retry logic for failures.
    #
    # @param path [String] API endpoint path (e.g., 'rbl/hosts')
    # @param params [Hash, nil] Request parameters (e.g., {name: 'My Host', host: '1.2.3.4'})
    # @param options [RequestOptions, nil] Request options
    # @param idempotent [Boolean] Whether the endpoint accepts an Idempotency-Key
    # @return [Response] Response wrapper with parsed data and rate limit info
    # @raise [Error] if request fails after all retries
    #
    # @example
    #   handler.post('rbl/hosts', { name: 'My Host', host: '1.2.3.4', type: 'rbl' })
    def post(path, params = nil, options = nil, idempotent: false)
      make_request(:post, path, params, options, idempotent)
    end

    # Make a PUT request to the API.
    #
    # Parameters are sent as application/x-www-form-urlencoded data.
    # The request includes automatic retry logic for failures.
    #
    # @param path [String] API endpoint path (e.g., 'rbl/hosts/HTxxxxxxxx')
    # @param params [Hash, nil] Request parameters (e.g., {name: 'Updated Name'})
    # @param options [RequestOptions, nil] Request options
    # @return [Response] Response wrapper with parsed data and rate limit info
    # @raise [Error] if request fails after all retries
    #
    # @example
    #   handler.put('rbl/hosts/HT1a2b3c4d5e6f7890abcdef1234567890', { name: 'Updated Name' })
    def put(path, params = nil, options = nil)
      make_request(:put, path, params, options)
    end

    # Make a DELETE request to the API.
    #
    # No parameters are sent with DELETE requests. The request includes
    # automatic retry logic for failures.
    #
    # @param path [String] API endpoint path (e.g., 'rbl/hosts/HTxxxxxxxx')
    # @param options [RequestOptions, nil] Request options
    # @param idempotent [Boolean] Whether the endpoint accepts an Idempotency-Key
    # @return [Response] Response wrapper with parsed data and rate limit info
    # @raise [Error] if request fails after all retries
    #
    # @example
    #   handler.delete('rbl/hosts/HT1a2b3c4d5e6f7890abcdef1234567890')
    def delete(path, options = nil, idempotent: false)
      make_request(:delete, path, nil, options, idempotent)
    end

    private

    # Send HTTP request to API with automatic retries.
    #
    # This method handles:
    # - Building the request URL with .json extension
    # - Adding query parameters for GET requests
    # - Adding form data for POST/PUT/DELETE requests
    # - Setting authentication and request option headers
    # - Executing the request with retry logic
    #
    # @param method [Symbol] HTTP method (:get, :post, :put, :delete)
    # @param path [String] API endpoint path
    # @param params [Hash, nil] Request parameters
    # @param options [RequestOptions, nil] Request options
    # @param idempotent [Boolean] Whether the endpoint accepts an Idempotency-Key; one is
    #   generated when the caller gave none
    # @return [Faraday::Response] The HTTP response
    # @raise [Error] if all retry attempts fail
    def send_request(method, path, params, options, idempotent)
      options ||= RequestOptions.new

      # Field selection applies to GET requests
      params = (params || {}).merge(fields: options.fields) if method == :get && options.fields
      params = convert_params(params)

      # The headers are set once per call, so every retry of the call sends the same
      # Idempotency-Key and the API answers a repeat with the first result
      headers = {
        'User-Agent' => "GeneratorLabs-Ruby/#{VERSION}",
        'Accept' => 'application/json',
        'Idempotency-Key' => options.idempotency_key || (SecureRandom.uuid if idempotent),
        'X-Request-Id' => options.request_id,
        'If-None-Match' => options.if_none_match
      }.compact

      @connection.send(method) do |req|
        req.url "#{path}.json"
        req.headers.update(headers)
        apply_params(req, method, params)
      end
    rescue Faraday::Error => e
      raise Error, "API request failed: #{e.message}"
    end

    # Make HTTP request to API and parse the JSON response.
    #
    # Errors are raised if:
    # - All retry attempts fail
    # - The response body cannot be parsed
    # - The HTTP status code or the API status_code is >= 400
    #
    # @param method [Symbol] HTTP method (:get, :post, :put, :delete)
    # @param path [String] API endpoint path
    # @param params [Hash, nil] Request parameters
    # @param options [RequestOptions, nil] Request options
    # @param idempotent [Boolean] Whether the endpoint accepts an Idempotency-Key
    # @return [Response] Response wrapper with parsed data and rate limit info
    # @raise [Error] if request fails or response is invalid
    def make_request(method, path, params, options = nil, idempotent = false) # rubocop:disable Style/OptionalBooleanParameter
      response = send_request(method, path, params, options, idempotent)
      metadata = { request_id: response.headers['x-request-id'], etag: response.headers['etag'] }

      #
      # parse rate limit headers
      #
      rate_limit_info = nil
      if response.headers['ratelimit-limit']
        rate_limit_info = RateLimitInfo.new(
          limit: response.headers['ratelimit-limit'],
          remaining: response.headers['ratelimit-remaining'].to_i,
          reset: response.headers['ratelimit-reset'].to_i
        )
      end

      # 304 Not Modified has no body: the copy the caller's ETag came from is still current
      return Response.new({}, rate_limit_info, **metadata, not_modified: true) if response.status == 304

      Response.new(parse_response(response), rate_limit_info, **metadata,
                   replayed: response.headers['idempotent-replayed'] == 'true')
    end

    # Convert array values to comma-separated strings for form encoding.
    def convert_params(params)
      return unless params

      params.transform_values { |v| v.is_a?(Array) ? v.join(',') : v }
    end

    # Apply parameters to request based on HTTP method.
    def apply_params(req, method, params)
      return unless params

      if method == :get
        req.params = params
      else
        req.body = params
      end
    end

    # Parse JSON response and check for errors.
    def parse_response(response)
      data = JSON.parse(response.body)

      code = (data.is_a?(Hash) && data['status_code']) || response.status
      if code.to_i >= 400 || response.status >= 400
        error_msg = (data.is_a?(Hash) && data['status_message']) || "HTTP #{response.status} error"
        raise Error.new("API error: #{error_msg}", status_code: code.to_i,
                                                   request_id: response.headers['x-request-id'])
      end

      data
    rescue JSON::ParserError => e
      raise Error.new("Failed to parse JSON response: #{e.message}",
                      request_id: response.headers['x-request-id'])
    end
  end
end
