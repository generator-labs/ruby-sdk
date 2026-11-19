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

    # Access certificate finding operations
    # @return [CertFindings]
    def findings
      @findings ||= CertFindings.new(@handler)
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
    # @param options [RequestOptions, nil] Request options
    # @return [Hash] Error data
    def get(params = {}, options = nil)
      @handler.get('cert/errors', params, options)
    end

    # Get the number of current certificate warnings and errors
    # @param options [RequestOptions, nil] Request options
    # @return [Integer] Number of warnings and errors
    def count(options = nil)
      Integer(@handler.get_plain('cert/errors/count', options))
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
        errors = response['data'] || []

        all_items.concat(errors)

        break unless page < (response['total_pages'] || 1) && !errors.empty?

        page += 1
      end

      all_items
    end
  end

  # Certificate findings: list, dismiss and restore
  class CertFindings
    def initialize(handler)
      @handler = handler
    end

    # Get the current findings on the active certificate monitors
    # @param params [Hash] Optional parameters (page, page_size, dismissed)
    # @param options [RequestOptions, nil] Request options
    # @return [Hash] One entry per monitor, each with its findings
    def get(params = {}, options = nil)
      @handler.get('cert/findings', params, options)
    end

    # Get the findings of every monitor with automatic pagination
    # @param params [Hash] Optional parameters (e.g., page_size, dismissed)
    # @return [Array] All monitors with findings across all pages
    def get_all(params = {})
      all_items = []
      page = 1
      params = params.dup

      loop do
        params[:page] = page
        response = get(params)
        monitors = response['data'] || []

        all_items.concat(monitors)

        break unless page < (response['total_pages'] || 1) && !monitors.empty?

        page += 1
      end

      all_items
    end

    # Dismiss findings
    # @param params [Hash] Findings to dismiss (finding_id, monitors); without monitors,
    #   from every active monitor that has the finding
    # @param options [RequestOptions, nil] Request options
    # @return [Hash] Monitors changed
    def dismiss(params, options = nil)
      @handler.post('cert/findings/dismiss', params, options)
    end

    # Restore dismissed findings
    # @param params [Hash] Findings to restore (finding_id, monitors); without monitors,
    #   on every monitor the finding is dismissed from
    # @param options [RequestOptions, nil] Request options
    # @return [Hash] Monitors changed
    def restore(params, options = nil)
      @handler.post('cert/findings/restore', params, options)
    end
  end

  # Certificate monitor management
  class CertMonitors
    def initialize(handler)
      @handler = handler
    end

    # Get monitors (all, or one by ID)
    # @param args [String, Hash, RequestOptions] Optional ID or parameters, then request options
    # @return [Hash] Monitor data
    def get(*args)
      @handler.get(*GeneratorLabs.get_args('cert/monitors', args))
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
        monitors = response['data'] || []

        all_items.concat(monitors)

        break unless page < (response['total_pages'] || 1) && !monitors.empty?

        page += 1
      end

      all_items
    end

    # Create a new certificate monitor
    # @param params [Hash] Monitor parameters
    # @param options [RequestOptions, nil] Request options
    # @return [Hash] Created monitor data
    def create(params, options = nil)
      @handler.post('cert/monitors', params, options, idempotent: true)
    end

    # Update a certificate monitor
    # @param id [String, Integer] Monitor ID
    # @param params [Hash] Updated parameters
    # @param options [RequestOptions, nil] Request options
    # @return [Hash] Updated monitor data
    def update(id, params, options = nil)
      @handler.put("cert/monitors/#{id}", params, options)
    end

    # Delete a certificate monitor
    # @param id [String, Integer] Monitor ID
    # @param options [RequestOptions, nil] Request options
    # @return [Hash] Deletion confirmation
    def delete(id, options = nil)
      @handler.delete("cert/monitors/#{id}", options, idempotent: true)
    end

    # Pause monitoring for a certificate
    # @param id [String, Integer] Monitor ID
    # @param options [RequestOptions, nil] Request options
    # @return [Hash] Response
    def pause(id, options = nil)
      @handler.post("cert/monitors/#{id}/pause", nil, options)
    end

    # Resume monitoring for a certificate
    # @param id [String, Integer] Monitor ID
    # @param options [RequestOptions, nil] Request options
    # @return [Hash] Response
    def resume(id, options = nil)
      @handler.post("cert/monitors/#{id}/resume", nil, options)
    end

    # Queue a check of a monitor now
    # @param id [String] Monitor ID
    # @param options [RequestOptions, nil] Request options
    # @return [Hash] Queued check
    def check(id, options = nil)
      @handler.post("cert/monitors/#{id}/check", nil, options, idempotent: true)
    end
  end

  # Certificate profile management
  class CertProfiles
    def initialize(handler)
      @handler = handler
    end

    # Get profiles (all, or one by ID)
    # @param args [String, Hash, RequestOptions] Optional ID or parameters, then request options
    # @return [Hash] Profile data
    def get(*args)
      @handler.get(*GeneratorLabs.get_args('cert/profiles', args))
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

    # Create a new certificate monitoring profile
    # @param params [Hash] Profile parameters
    # @param options [RequestOptions, nil] Request options
    # @return [Hash] Created profile data
    def create(params, options = nil)
      @handler.post('cert/profiles', params, options, idempotent: true)
    end

    # Update a certificate monitoring profile
    # @param id [String, Integer] Profile ID
    # @param params [Hash] Updated parameters
    # @param options [RequestOptions, nil] Request options
    # @return [Hash] Updated profile data
    def update(id, params, options = nil)
      @handler.put("cert/profiles/#{id}", params, options)
    end

    # Delete a certificate monitoring profile
    # @param id [String, Integer] Profile ID
    # @param options [RequestOptions, nil] Request options
    # @return [Hash] Deletion confirmation
    def delete(id, options = nil)
      @handler.delete("cert/profiles/#{id}", options)
    end
  end
end
