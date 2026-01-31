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

    # Check if an IP is listed on any RBLs
    # @param ip [String] IP address to check
    # @return [Hash] Check results
    def check(ip)
      @handler.get('rbl/check', { ip: ip })
    end

    # Get current RBL listings for monitored hosts
    # @return [Hash] Listing information
    def listings
      @handler.get('rbl/listings')
    end
  end

  # RBL host management
  class RBLHosts
    def initialize(handler)
      @handler = handler
    end

    # Get hosts (all, by ID, or by array of IDs)
    # @param ids [nil, String, Integer, Array] Optional ID(s) to retrieve
    # @return [Hash] Host data
    def get(*ids)
      return @handler.get('rbl/hosts') if ids.empty?
      return @handler.get("rbl/hosts/#{ids.first}") if ids.length == 1

      @handler.get('rbl/hosts', { ids: ids.join(',') })
    end

    # Create a new monitored host
    # @param params [Hash] Host parameters
    # @return [Hash] Created host data
    def create(params)
      @handler.post('rbl/hosts', params)
    end

    # Update a monitored host
    # @param id [String, Integer] Host ID
    # @param params [Hash] Updated parameters
    # @return [Hash] Updated host data
    def update(id, params)
      @handler.put("rbl/hosts/#{id}", params)
    end

    # Delete a monitored host
    # @param id [String, Integer] Host ID
    # @return [Hash] Deletion confirmation
    def delete(id)
      @handler.delete("rbl/hosts/#{id}")
    end
  end

  # RBL profile management
  class RBLProfiles
    def initialize(handler)
      @handler = handler
    end

    # Get profiles (all, by ID, or by array of IDs)
    # @param ids [nil, String, Integer, Array] Optional ID(s) to retrieve
    # @return [Hash] Profile data
    def get(*ids)
      return @handler.get('rbl/profiles') if ids.empty?
      return @handler.get("rbl/profiles/#{ids.first}") if ids.length == 1

      @handler.get('rbl/profiles', { ids: ids.join(',') })
    end

    # Create a new monitoring profile
    # @param params [Hash] Profile parameters
    # @return [Hash] Created profile data
    def create(params)
      @handler.post('rbl/profiles', params)
    end

    # Update a monitoring profile
    # @param id [String, Integer] Profile ID
    # @param params [Hash] Updated parameters
    # @return [Hash] Updated profile data
    def update(id, params)
      @handler.put("rbl/profiles/#{id}", params)
    end

    # Delete a monitoring profile
    # @param id [String, Integer] Profile ID
    # @return [Hash] Deletion confirmation
    def delete(id)
      @handler.delete("rbl/profiles/#{id}")
    end
  end

  # RBL source management
  class RBLSources
    def initialize(handler)
      @handler = handler
    end

    # Get sources (all, by ID, or by array of IDs)
    # @param ids [nil, String, Integer, Array] Optional ID(s) to retrieve
    # @return [Hash] Source data
    def get(*ids)
      return @handler.get('rbl/sources') if ids.empty?
      return @handler.get("rbl/sources/#{ids.first}") if ids.length == 1

      @handler.get('rbl/sources', { ids: ids.join(',') })
    end

    # Create a new RBL source
    # @param params [Hash] Source parameters
    # @return [Hash] Created source data
    def create(params)
      @handler.post('rbl/sources', params)
    end

    # Update an RBL source
    # @param id [String, Integer] Source ID
    # @param params [Hash] Updated parameters
    # @return [Hash] Updated source data
    def update(id, params)
      @handler.put("rbl/sources/#{id}", params)
    end

    # Delete an RBL source
    # @param id [String, Integer] Source ID
    # @return [Hash] Deletion confirmation
    def delete(id)
      @handler.delete("rbl/sources/#{id}")
    end
  end
end
