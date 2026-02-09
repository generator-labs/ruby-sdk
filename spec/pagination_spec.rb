# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Pagination' do
  let(:handler) { instance_double('GeneratorLabs::RequestHandler') }

  def paginated_response(items, key:, page:, total_pages:, total:, page_size: 100) # rubocop:disable Metrics/ParameterLists
    {
      'status_code' => 200,
      'status_message' => 'OK',
      key => items,
      'total' => total,
      'page' => page,
      'total_pages' => total_pages,
      'page_size' => page_size
    }
  end

  def make_hosts(count, offset = 0)
    (1..count).map { |i| { 'name' => "host_#{i + offset}" } }
  end

  describe GeneratorLabs::RBLHosts do
    let(:hosts_resource) { described_class.new(handler) }

    it 'returns all items from a single page' do
      allow(handler).to receive(:get)
        .with('rbl/hosts', hash_including(page: 1))
        .and_return(paginated_response(make_hosts(3), key: 'hosts', page: 1, total_pages: 1, total: 3))

      result = hosts_resource.get_all

      expect(result.length).to eq(3)
      expect(result[0]['name']).to eq('host_1')
      expect(result[2]['name']).to eq('host_3')
    end

    it 'aggregates items across multiple pages' do
      allow(handler).to receive(:get)
        .with('rbl/hosts', hash_including(page: 1))
        .and_return(paginated_response(
                      make_hosts(2, 0), key: 'hosts', page: 1, total_pages: 3, total: 5, page_size: 2
                    ))

      allow(handler).to receive(:get)
        .with('rbl/hosts', hash_including(page: 2))
        .and_return(paginated_response(
                      make_hosts(2, 2), key: 'hosts', page: 2, total_pages: 3, total: 5, page_size: 2
                    ))

      allow(handler).to receive(:get)
        .with('rbl/hosts', hash_including(page: 3))
        .and_return(paginated_response(
                      make_hosts(1, 4), key: 'hosts', page: 3, total_pages: 3, total: 5, page_size: 2
                    ))

      result = hosts_resource.get_all(page_size: 2)

      expect(result.length).to eq(5)
      expect(result[0]['name']).to eq('host_1')
      expect(result[4]['name']).to eq('host_5')
    end

    it 'returns empty array for empty response' do
      allow(handler).to receive(:get)
        .with('rbl/hosts', hash_including(page: 1))
        .and_return(paginated_response([], key: 'hosts', page: 1, total_pages: 1, total: 0))

      result = hosts_resource.get_all

      expect(result).to be_empty
    end

    it 'passes custom page_size' do
      allow(handler).to receive(:get)
        .with('rbl/hosts', hash_including(page: 1, page_size: 50))
        .and_return(paginated_response(
                      [{ 'name' => 'host_1' }], key: 'hosts', page: 1, total_pages: 1, total: 1, page_size: 50
                    ))

      result = hosts_resource.get_all(page_size: 50)

      expect(result.length).to eq(1)
      expect(handler).to have_received(:get)
        .with('rbl/hosts', hash_including(page_size: 50))
    end
  end

  describe GeneratorLabs::Contacts do
    let(:contacts_resource) { described_class.new(handler) }

    it 'paginates contacts correctly' do
      allow(handler).to receive(:get)
        .with('contact/contacts', hash_including(page: 1))
        .and_return(paginated_response(
                      [{ 'name' => 'contact_1' }, { 'name' => 'contact_2' }],
                      key: 'contacts', page: 1, total_pages: 2, total: 3, page_size: 2
                    ))

      allow(handler).to receive(:get)
        .with('contact/contacts', hash_including(page: 2))
        .and_return(paginated_response(
                      [{ 'name' => 'contact_3' }],
                      key: 'contacts', page: 2, total_pages: 2, total: 3, page_size: 2
                    ))

      result = contacts_resource.get_all(page_size: 2)

      expect(result.length).to eq(3)
      expect(result[0]['name']).to eq('contact_1')
      expect(result[2]['name']).to eq('contact_3')
    end
  end
end
