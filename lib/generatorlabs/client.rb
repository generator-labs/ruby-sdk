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
  # Main API client for Generator Labs.
  #
  # The Generator Labs API is a RESTful web service API that lets customers manage
  # their RBL monitoring hosts, certificate monitoring, contacts, and retrieve
  # listing information.
  #
  # @example Basic usage
  #   client = GeneratorLabs::Client.new('your_account_sid', 'your_auth_token')
  #
  #   # RBL monitoring
  #   hosts = client.rbl.hosts.get
  #
  #   # Certificate monitoring
  #   monitors = client.cert.monitors.get
  #
  #   # Contact management
  #   contacts = client.contact.contacts.get
  #
  # @example With custom configuration
  #   config = GeneratorLabs::Config.new(
  #     timeout: 45,
  #     max_retries: 5,
  #     retry_backoff: 2.0
  #   )
  #   client = GeneratorLabs::Client.new('your_account_sid', 'your_auth_token', config)
  class Client
    # @return [String] The account SID (2 uppercase + 32 hex characters)
    attr_reader :account_sid

    # @return [String] The authentication token (64 hex characters)
    attr_reader :auth_token

    # @return [Config] The configuration object
    attr_reader :config

    # Initialize a new Generator Labs client.
    #
    # The account SID must be in the format of 2 uppercase letters followed by
    # 32 hexadecimal characters (e.g., "AC" + 32 hex chars).
    #
    # The auth token must be 64 hexadecimal characters.
    #
    # @param account_sid [String] Your Generator Labs account SID
    # @param auth_token [String] Your Generator Labs auth token
    # @param config [Config, nil] Optional configuration object for custom timeouts and retry behavior
    # @raise [Error] if account_sid or auth_token format is invalid
    #
    # @example
    #   client = GeneratorLabs::Client.new('ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx', 'your_auth_token')
    #
    # @example With custom config
    #   config = GeneratorLabs::Config.new(timeout: 60)
    #   client = GeneratorLabs::Client.new('ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx', 'your_auth_token', config)
    def initialize(account_sid, auth_token, config = nil)
      # Validate account SID format
      raise Error, "Invalid account SID format: #{account_sid}" unless account_sid.match?(/^[A-Z]{2}[0-9a-fA-F]{32}$/)

      # Validate auth token format
      raise Error, 'Invalid auth token format' unless auth_token.match?(/^[0-9a-fA-F]{64}$/)

      @account_sid = account_sid
      @auth_token = auth_token
      @config = config || Config.default
      @handler = RequestHandler.new(account_sid, auth_token, @config)
    end

    # Get the RBL monitoring API namespace.
    #
    # The RBL namespace provides access to:
    # - Hosts: Manage monitored hosts (IP addresses and domains)
    # - Profiles: Manage monitoring profiles (which RBLs to check)
    # - Sources: Manage RBL sources
    # - Check: Perform ad-hoc RBL checks
    # - Listings: Retrieve current RBL listings
    #
    # @return [RBL] RBL namespace with endpoints for hosts, profiles, sources, etc.
    #
    # @example
    #   hosts = client.rbl.hosts.get
    #   listings = client.rbl.listings
    def rbl
      @rbl ||= RBL.new(@handler)
    end

    # Get the Contact management API namespace.
    #
    # The Contact namespace provides access to:
    # - Contacts: Manage individual contacts
    # - Groups: Manage contact groups
    #
    # @return [Contact] Contact namespace with endpoints for contacts and groups
    #
    # @example
    #   contacts = client.contact.contacts.get
    #   groups = client.contact.groups.get
    def contact
      @contact ||= Contact.new(@handler)
    end

    # Get the Certificate monitoring API namespace.
    #
    # The Cert namespace provides access to:
    # - Monitors: Manage certificate monitors
    # - Profiles: Manage certificate monitoring profiles
    # - Errors: Retrieve current certificate errors
    #
    # @return [Cert] Cert namespace with endpoints for errors, monitors, and profiles
    #
    # @example
    #   monitors = client.cert.monitors.get
    #   errors = client.cert.errors.get
    def cert
      @cert ||= Cert.new(@handler)
    end
  end
end
