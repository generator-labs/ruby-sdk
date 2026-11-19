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
  # RBL monitoring API namespace
  class RBL
    def initialize(handler)
      @handler = handler
    end

    # Access host management operations
    # @return [RBLHosts]
    def hosts
      @hosts ||= RBLHosts.new(@handler)
    end

    # Access profile management operations
    # @return [RBLProfiles]
    def profiles
      @profiles ||= RBLProfiles.new(@handler)
    end

    # Access source management operations
    # @return [RBLSources]
    def sources
      @sources ||= RBLSources.new(@handler)
    end

    # Access manual RBL check operations
    # @return [RBLCheck]
    def check
      @check ||= RBLCheck.new(@handler)
    end

    # Get current RBL listings for monitored hosts
    # @param params [Hash, nil] Optional parameters (page, page_size)
    # @param options [RequestOptions, nil] Request options
    # @return [Hash] Listing information
    def listings(params = nil, options = nil)
      @handler.get('rbl/listings', params, options)
    end
  end

  # Manual RBL check operations
  class RBLCheck
    def initialize(handler)
      @handler = handler
    end

    # Start a manual RBL check
    # @param params [Hash] Check parameters (host, callback, details)
    # @param options [RequestOptions, nil] Request options
    # @return [Hash] Check result with check ID
    def start(params, options = nil)
      @handler.post('rbl/check/start', params, options, idempotent: true)
    end

    # Get the status of a manual RBL check
    # @param id [String] Check ID
    # @param params [Hash] Optional parameters (details)
    # @param options [RequestOptions, nil] Request options
    # @return [Hash] Check status
    def status(id, params = {}, options = nil)
      @handler.get("rbl/check/status/#{id}", params, options)
    end
  end

  # RBL host management
  class RBLHosts
    def initialize(handler)
      @handler = handler
    end

    # Get hosts (all, or one by ID)
    # @param args [String, Hash, RequestOptions] Optional ID or parameters, then request options
    # @return [Hash] Host data
    def get(*args)
      @handler.get(*GeneratorLabs.get_args('rbl/hosts', args))
    end

    # Get all hosts with automatic pagination
    # @param params [Hash] Optional parameters (e.g., page_size)
    # @return [Array] All hosts across all pages
    def get_all(params = {})
      all_items = []
      page = 1
      params = params.dup

      loop do
        params[:page] = page
        response = get(params)
        hosts = response['data'] || []

        all_items.concat(hosts)

        break unless page < (response['total_pages'] || 1) && !hosts.empty?

        page += 1
      end

      all_items
    end

    # Create a new monitored host
    # @param params [Hash] Host parameters
    # @param options [RequestOptions, nil] Request options
    # @return [Hash] Created host data
    def create(params, options = nil)
      @handler.post('rbl/hosts', params, options, idempotent: true)
    end

    # Update a monitored host
    # @param id [String, Integer] Host ID
    # @param params [Hash] Updated parameters
    # @param options [RequestOptions, nil] Request options
    # @return [Hash] Updated host data
    def update(id, params, options = nil)
      @handler.put("rbl/hosts/#{id}", params, options)
    end

    # Delete a monitored host
    # @param id [String, Integer] Host ID
    # @param options [RequestOptions, nil] Request options
    # @return [Hash] Deletion confirmation
    def delete(id, options = nil)
      @handler.delete("rbl/hosts/#{id}", options)
    end

    # Pause monitoring for a host
    # @param id [String, Integer] Host ID
    # @param options [RequestOptions, nil] Request options
    # @return [Hash] Response
    def pause(id, options = nil)
      @handler.post("rbl/hosts/#{id}/pause", nil, options)
    end

    # Resume monitoring for a host
    # @param id [String, Integer] Host ID
    # @param options [RequestOptions, nil] Request options
    # @return [Hash] Response
    def resume(id, options = nil)
      @handler.post("rbl/hosts/#{id}/resume", nil, options)
    end
  end

  # RBL profile management
  class RBLProfiles
    def initialize(handler)
      @handler = handler
    end

    # Get profiles (all, or one by ID)
    # @param args [String, Hash, RequestOptions] Optional ID or parameters, then request options
    # @return [Hash] Profile data
    def get(*args)
      @handler.get(*GeneratorLabs.get_args('rbl/profiles', args))
    end

    # Get all profiles with automatic pagination
    # @param params [Hash] Optional parameters (e.g., page_size)
    # @return [Array] All profiles across all pages
    def get_all(params = {})
      all_items = []
      page = 1
      params = params.dup

      loop do
        params[:page] = page
        response = get(params)
        profiles = response['data'] || []

        all_items.concat(profiles)

        break unless page < (response['total_pages'] || 1) && !profiles.empty?

        page += 1
      end

      all_items
    end

    # Create a new monitoring profile
    # @param params [Hash] Profile parameters
    # @param options [RequestOptions, nil] Request options
    # @return [Hash] Created profile data
    def create(params, options = nil)
      @handler.post('rbl/profiles', params, options, idempotent: true)
    end

    # Update a monitoring profile
    # @param id [String, Integer] Profile ID
    # @param params [Hash] Updated parameters
    # @param options [RequestOptions, nil] Request options
    # @return [Hash] Updated profile data
    def update(id, params, options = nil)
      @handler.put("rbl/profiles/#{id}", params, options)
    end

    # Delete a monitoring profile
    # @param id [String, Integer] Profile ID
    # @param options [RequestOptions, nil] Request options
    # @return [Hash] Deletion confirmation
    def delete(id, options = nil)
      @handler.delete("rbl/profiles/#{id}", options)
    end
  end

  # RBL source management
  class RBLSources
    def initialize(handler)
      @handler = handler
    end

    # Get sources (all, or one by ID)
    # @param args [String, Hash, RequestOptions] Optional ID or parameters, then request options
    # @return [Hash] Source data
    def get(*args)
      @handler.get(*GeneratorLabs.get_args('rbl/sources', args))
    end

    # Get all sources with automatic pagination
    # @param params [Hash] Optional parameters (e.g., page_size)
    # @return [Array] All sources across all pages
    def get_all(params = {})
      all_items = []
      page = 1
      params = params.dup

      loop do
        params[:page] = page
        response = get(params)
        sources = response['data'] || []

        all_items.concat(sources)

        break unless page < (response['total_pages'] || 1) && !sources.empty?

        page += 1
      end

      all_items
    end

    # Create a new RBL source
    # @param params [Hash] Source parameters
    # @param options [RequestOptions, nil] Request options
    # @return [Hash] Created source data
    def create(params, options = nil)
      @handler.post('rbl/sources', params, options, idempotent: true)
    end

    # Update an RBL source
    # @param id [String, Integer] Source ID
    # @param params [Hash] Updated parameters
    # @param options [RequestOptions, nil] Request options
    # @return [Hash] Updated source data
    def update(id, params, options = nil)
      @handler.put("rbl/sources/#{id}", params, options)
    end

    # Delete an RBL source
    # @param id [String, Integer] Source ID
    # @param options [RequestOptions, nil] Request options
    # @return [Hash] Deletion confirmation
    def delete(id, options = nil)
      @handler.delete("rbl/sources/#{id}", options)
    end

    # Pause an RBL source
    # @param id [String, Integer] Source ID
    # @param options [RequestOptions, nil] Request options
    # @return [Hash] Response
    def pause(id, options = nil)
      @handler.post("rbl/sources/#{id}/pause", nil, options)
    end

    # Resume an RBL source
    # @param id [String, Integer] Source ID
    # @param options [RequestOptions, nil] Request options
    # @return [Hash] Response
    def resume(id, options = nil)
      @handler.post("rbl/sources/#{id}/resume", nil, options)
    end
  end
end
