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
  # Main API client for Generator Labs
  class Client
    attr_reader :account_sid, :auth_token

    # Initialize a new Generator Labs client
    #
    # @param account_sid [String] Your Generator Labs account SID
    # @param auth_token [String] Your Generator Labs auth token
    # @raise [Error] if credentials are invalid
    def initialize(account_sid, auth_token)
      # Validate account SID format
      raise Error, "Invalid account SID format: #{account_sid}" unless account_sid.match?(/^[A-Z]{2}[0-9a-fA-F]{32}$/)

      # Validate auth token format
      raise Error, 'Invalid auth token format' unless auth_token.match?(/^[0-9a-fA-F]{64}$/)

      @account_sid = account_sid
      @auth_token = auth_token
      @handler = RequestHandler.new(account_sid, auth_token, 'https://api.generatorlabs.com/4.0/')
    end

    # Get the RBL monitoring API namespace
    #
    # @return [RBL] RBL namespace with endpoints for hosts, profiles, sources, etc.
    def rbl
      @rbl ||= RBL.new(@handler)
    end

    # Get the Contact management API namespace
    #
    # @return [Contact] Contact namespace with endpoints for contacts and groups
    def contact
      @contact ||= Contact.new(@handler)
    end
  end
end
