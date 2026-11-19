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
  # Contact management API namespace
  class Contact
    def initialize(handler)
      @handler = handler
    end

    # Access contact management operations
    # @return [Contacts]
    def contacts
      @contacts ||= Contacts.new(@handler)
    end

    # Access group management operations
    # @return [Groups]
    def groups
      @groups ||= Groups.new(@handler)
    end
  end

  # Contact management
  class Contacts
    def initialize(handler)
      @handler = handler
    end

    # Get contacts (all, or one by ID)
    # @param args [String, Hash, RequestOptions] Optional ID or parameters, then request options
    # @return [Hash] Contact data
    def get(*args)
      @handler.get(*GeneratorLabs.get_args('contact/contacts', args))
    end

    # Get all contacts with automatic pagination
    # @param params [Hash] Optional parameters (e.g., page_size)
    # @return [Array] All contacts across all pages
    def get_all(params = {})
      all_items = []
      page = 1
      params = params.dup

      loop do
        params[:page] = page
        response = get(params)
        contacts = response['data'] || []

        all_items.concat(contacts)

        break unless page < (response['total_pages'] || 1) && !contacts.empty?

        page += 1
      end

      all_items
    end

    # Create a new contact
    # @param params [Hash] Contact parameters
    # @param options [RequestOptions, nil] Request options
    # @return [Hash] Created contact data
    def create(params, options = nil)
      @handler.post('contact/contacts', params, options, idempotent: true)
    end

    # Update a contact
    # @param id [String, Integer] Contact ID
    # @param params [Hash] Updated parameters
    # @param options [RequestOptions, nil] Request options
    # @return [Hash] Updated contact data
    def update(id, params, options = nil)
      @handler.put("contact/contacts/#{id}", params, options)
    end

    # Delete a contact
    # @param id [String, Integer] Contact ID
    # @param options [RequestOptions, nil] Request options
    # @return [Hash] Deletion confirmation
    def delete(id, options = nil)
      @handler.delete("contact/contacts/#{id}", options)
    end

    # Pause a contact
    # @param id [String, Integer] Contact ID
    # @param options [RequestOptions, nil] Request options
    # @return [Hash] Response
    def pause(id, options = nil)
      @handler.post("contact/contacts/#{id}/pause", nil, options)
    end

    # Resume a contact
    # @param id [String, Integer] Contact ID
    # @param options [RequestOptions, nil] Request options
    # @return [Hash] Response
    def resume(id, options = nil)
      @handler.post("contact/contacts/#{id}/resume", nil, options)
    end

    # Confirm a contact with an auth code
    # @param id [String, Integer] Contact ID
    # @param params [Hash] Confirmation parameters (authcode)
    # @param options [RequestOptions, nil] Request options
    # @return [Hash] Response
    def confirm(id, params, options = nil)
      @handler.post("contact/contacts/#{id}/confirm", params, options, idempotent: true)
    end

    # Resend confirmation to a contact
    # @param id [String, Integer] Contact ID
    # @param options [RequestOptions, nil] Request options
    # @return [Hash] Response
    def resend(id, options = nil)
      @handler.post("contact/contacts/#{id}/resend", nil, options, idempotent: true)
    end
  end

  # Group management
  class Groups
    def initialize(handler)
      @handler = handler
    end

    # Get groups (all, or one by ID)
    # @param args [String, Hash, RequestOptions] Optional ID or parameters, then request options
    # @return [Hash] Group data
    def get(*args)
      @handler.get(*GeneratorLabs.get_args('contact/groups', args))
    end

    # Get all groups with automatic pagination
    # @param params [Hash] Optional parameters (e.g., page_size)
    # @return [Array] All groups across all pages
    def get_all(params = {})
      all_items = []
      page = 1
      params = params.dup

      loop do
        params[:page] = page
        response = get(params)
        groups = response['data'] || []

        all_items.concat(groups)

        break unless page < (response['total_pages'] || 1) && !groups.empty?

        page += 1
      end

      all_items
    end

    # Create a new contact group
    # @param params [Hash] Group parameters
    # @param options [RequestOptions, nil] Request options
    # @return [Hash] Created group data
    def create(params, options = nil)
      @handler.post('contact/groups', params, options, idempotent: true)
    end

    # Update a contact group
    # @param id [String, Integer] Group ID
    # @param params [Hash] Updated parameters
    # @param options [RequestOptions, nil] Request options
    # @return [Hash] Updated group data
    def update(id, params, options = nil)
      @handler.put("contact/groups/#{id}", params, options)
    end

    # Delete a contact group
    # @param id [String, Integer] Group ID
    # @param options [RequestOptions, nil] Request options
    # @return [Hash] Deletion confirmation
    def delete(id, options = nil)
      @handler.delete("contact/groups/#{id}", options)
    end
  end
end
