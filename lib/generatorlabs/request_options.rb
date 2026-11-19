# frozen_string_literal: true

#
# This file is part of the Generator Labs Ruby SDK package.
#
# (c) Generator Labs <support@generatorlabs.com>
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#

# Generator Labs API client: the request options, and the limit on a Retry-After wait.
module GeneratorLabs
  # The longest Retry-After (in seconds) that is waited out before a retry. A longer wait
  # is not slept: the response is raised as the error instead.
  MAX_RETRY_AFTER = 60

  # Options any request accepts, passed as the last argument of a resource method.
  #
  # - idempotency_key: the Idempotency-Key of a request that creates something or starts a
  #   check; a repeat with the same key returns the first answer (generated when left out)
  # - request_id: the X-Request-Id to send (the API generates one otherwise)
  # - if_none_match: the ETag of an earlier response; the answer is not_modified when
  #   nothing changed
  # - fields: the keys to keep in each object of the response data (GET requests), as a
  #   comma-separated String or an Array
  #
  # @example
  #   options = GeneratorLabs::RequestOptions.new(fields: %w[id host])
  #   client.rbl.hosts.get('HT1a2b3c4d5e6f7890abcdef1234567890', options)
  RequestOptions = Struct.new(:idempotency_key, :request_id, :if_none_match, :fields, keyword_init: true)

  # Sort the arguments of a resource's get into the arguments of RequestHandler#get: an ID
  # or a Hash of query parameters, followed by RequestOptions.
  #
  # @param path [String] API endpoint path of the resource
  # @param args [Array] Arguments the resource's get received
  # @return [Array] The path, the parameters and the request options
  def self.get_args(path, args)
    options = args.grep(RequestOptions).first
    args = args.grep_v(RequestOptions)
    raise ArgumentError, 'only one ID can be requested at a time' if args.length > 1

    id = args.first
    params = id if id.is_a?(Hash)
    path = "#{path}/#{id}" if id && params.nil?
    request = [path, params, options]
    request.pop while request.length > 1 && request.last.nil?
    request
  end
end
