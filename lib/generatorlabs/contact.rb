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

    # Get contacts (all, by ID, or by array of IDs)
    # @param ids [nil, String, Integer, Array] Optional ID(s) to retrieve
    # @return [Hash] Contact data
    def get(*ids)
      return @handler.get('contact/contacts') if ids.empty?
      return @handler.get("contact/contacts/#{ids.first}") if ids.length == 1

      @handler.get('contact/contacts', { ids: ids.join(',') })
    end

    # Create a new contact
    # @param params [Hash] Contact parameters
    # @return [Hash] Created contact data
    def create(params)
      @handler.post('contact/contacts', params)
    end

    # Update a contact
    # @param id [String, Integer] Contact ID
    # @param params [Hash] Updated parameters
    # @return [Hash] Updated contact data
    def update(id, params)
      @handler.put("contact/contacts/#{id}", params)
    end

    # Delete a contact
    # @param id [String, Integer] Contact ID
    # @return [Hash] Deletion confirmation
    def delete(id)
      @handler.delete("contact/contacts/#{id}")
    end
  end

  # Group management
  class Groups
    def initialize(handler)
      @handler = handler
    end

    # Get groups (all, by ID, or by array of IDs)
    # @param ids [nil, String, Integer, Array] Optional ID(s) to retrieve
    # @return [Hash] Group data
    def get(*ids)
      return @handler.get('contact/groups') if ids.empty?
      return @handler.get("contact/groups/#{ids.first}") if ids.length == 1

      @handler.get('contact/groups', { ids: ids.join(',') })
    end

    # Create a new contact group
    # @param params [Hash] Group parameters
    # @return [Hash] Created group data
    def create(params)
      @handler.post('contact/groups', params)
    end

    # Update a contact group
    # @param id [String, Integer] Group ID
    # @param params [Hash] Updated parameters
    # @return [Hash] Updated group data
    def update(id, params)
      @handler.put("contact/groups/#{id}", params)
    end

    # Delete a contact group
    # @param id [String, Integer] Group ID
    # @return [Hash] Deletion confirmation
    def delete(id)
      @handler.delete("contact/groups/#{id}")
    end
  end
end
