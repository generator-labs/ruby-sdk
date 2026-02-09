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
  # Certificate monitoring API namespace
  class Cert
    def initialize(handler)
      @handler = handler
    end

    # Access certificate error operations
    # @return [CertErrors]
    def errors
      @errors ||= CertErrors.new(@handler)
    end

    # Access certificate monitor management operations
    # @return [CertMonitors]
    def monitors
      @monitors ||= CertMonitors.new(@handler)
    end

    # Access certificate profile management operations
    # @return [CertProfiles]
    def profiles
      @profiles ||= CertProfiles.new(@handler)
    end
  end

  # Certificate error retrieval
  class CertErrors
    def initialize(handler)
      @handler = handler
    end

    # Get certificate errors
    # @param params [nil, Hash] Optional parameters
    # @return [Hash] Error data
    def get(params = {})
      @handler.get('cert/errors', params)
    end

    # Get all errors with automatic pagination
    # @param params [Hash] Optional parameters (e.g., page_size)
    # @return [Array] All errors across all pages
    def get_all(params = {})
      all_items = []
      page = 1
      params = params.dup

      loop do
        params[:page] = page
        response = get(params)
        errors = response['errors'] || []

        all_items.concat(errors)

        break unless page < (response['total_pages'] || 1) && !errors.empty?

        page += 1
      end

      all_items
    end
  end

  # Certificate monitor management
  class CertMonitors
    def initialize(handler)
      @handler = handler
    end

    # Get monitors (all, by ID, or by array of IDs)
    # @param ids [nil, String, Integer, Hash, Array] Optional ID(s) or parameters
    # @return [Hash] Monitor data
    def get(*ids)
      return @handler.get('cert/monitors') if ids.empty?

      # Check if first argument is a hash (parameters)
      return @handler.get('cert/monitors', ids.first) if ids.first.is_a?(Hash)

      return @handler.get("cert/monitors/#{ids.first}") if ids.length == 1

      @handler.get('cert/monitors', { ids: ids.join(',') })
    end

    # Get all monitors with automatic pagination
    # @param params [Hash] Optional parameters (e.g., page_size)
    # @return [Array] All monitors across all pages
    def get_all(params = {})
      all_items = []
      page = 1
      params = params.dup

      loop do
        params[:page] = page
        response = get(params)
        monitors = response['monitors'] || []

        all_items.concat(monitors)

        break unless page < (response['total_pages'] || 1) && !monitors.empty?

        page += 1
      end

      all_items
    end

    # Create a new certificate monitor
    # @param params [Hash] Monitor parameters
    # @return [Hash] Created monitor data
    def create(params)
      @handler.post('cert/monitors', params)
    end

    # Update a certificate monitor
    # @param id [String, Integer] Monitor ID
    # @param params [Hash] Updated parameters
    # @return [Hash] Updated monitor data
    def update(id, params)
      @handler.put("cert/monitors/#{id}", params)
    end

    # Delete a certificate monitor
    # @param id [String, Integer] Monitor ID
    # @return [Hash] Deletion confirmation
    def delete(id)
      @handler.delete("cert/monitors/#{id}")
    end

    # Pause monitoring for a certificate
    # @param id [String, Integer] Monitor ID
    # @return [Hash] Response
    def pause(id)
      @handler.post("cert/monitors/#{id}/pause")
    end

    # Resume monitoring for a certificate
    # @param id [String, Integer] Monitor ID
    # @return [Hash] Response
    def resume(id)
      @handler.post("cert/monitors/#{id}/resume")
    end
  end

  # Certificate profile management
  class CertProfiles
    def initialize(handler)
      @handler = handler
    end

    # Get profiles (all, by ID, or by array of IDs)
    # @param ids [nil, String, Integer, Hash, Array] Optional ID(s) or parameters
    # @return [Hash] Profile data
    def get(*ids)
      return @handler.get('cert/profiles') if ids.empty?

      # Check if first argument is a hash (parameters)
      return @handler.get('cert/profiles', ids.first) if ids.first.is_a?(Hash)

      return @handler.get("cert/profiles/#{ids.first}") if ids.length == 1

      @handler.get('cert/profiles', { ids: ids.join(',') })
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
        profiles = response['profiles'] || []

        all_items.concat(profiles)

        break unless page < (response['total_pages'] || 1) && !profiles.empty?

        page += 1
      end

      all_items
    end

    # Create a new certificate monitoring profile
    # @param params [Hash] Profile parameters
    # @return [Hash] Created profile data
    def create(params)
      @handler.post('cert/profiles', params)
    end

    # Update a certificate monitoring profile
    # @param id [String, Integer] Profile ID
    # @param params [Hash] Updated parameters
    # @return [Hash] Updated profile data
    def update(id, params)
      @handler.put("cert/profiles/#{id}", params)
    end

    # Delete a certificate monitoring profile
    # @param id [String, Integer] Profile ID
    # @return [Hash] Deletion confirmation
    def delete(id)
      @handler.delete("cert/profiles/#{id}")
    end
  end
end
