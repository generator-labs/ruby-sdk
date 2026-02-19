# frozen_string_literal: true

require 'spec_helper'
require 'webmock/rspec'

RSpec.describe GeneratorLabs::RequestHandler do
  let(:account_sid) { 'AC0123456789abcdef0123456789abcdef' }
  let(:auth_token) { '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef' }
  let(:config) { GeneratorLabs::Config.new }
  let(:handler) { described_class.new(account_sid, auth_token, config) }

  describe 'array parameter conversion' do
    it 'converts array values to comma-separated strings in POST' do
      stub = stub_request(:post, 'https://api.generatorlabs.com/4.0/rbl/hosts.json')
             .to_return(
               status: 200,
               headers: { 'Content-Type' => 'application/json' },
               body: { status_code: 200, status_message: 'OK', data: [] }.to_json
             )

      params = {
        name: 'Test Host',
        host: '1.2.3.4',
        contact_group: %w[
          CG11111111111111111111111111111111
          CG22222222222222222222222222222222
        ]
      }
      handler.post('rbl/hosts', params)

      expect(stub).to have_been_requested
      expect(WebMock).to have_requested(:post, 'https://api.generatorlabs.com/4.0/rbl/hosts.json')
        .with(body: hash_including(
          'contact_group' => 'CG11111111111111111111111111111111,CG22222222222222222222222222222222'
        ))
    end

    it 'converts array values to comma-separated strings in PUT' do
      stub_request(:put, 'https://api.generatorlabs.com/4.0/rbl/hosts/HT11111111111111111111111111111111.json')
        .to_return(
          status: 200,
          headers: { 'Content-Type' => 'application/json' },
          body: { status_code: 200, status_message: 'OK' }.to_json
        )

      params = {
        contact_group: %w[
          CG11111111111111111111111111111111
          CG22222222222222222222222222222222
        ]
      }
      handler.put('rbl/hosts/HT11111111111111111111111111111111', params)

      expect(WebMock).to have_requested(:put, 'https://api.generatorlabs.com/4.0/rbl/hosts/HT11111111111111111111111111111111.json')
        .with(body: hash_including(
          'contact_group' => 'CG11111111111111111111111111111111,CG22222222222222222222222222222222'
        ))
    end

    it 'passes string values unchanged' do
      stub_request(:post, 'https://api.generatorlabs.com/4.0/rbl/hosts.json')
        .to_return(
          status: 200,
          headers: { 'Content-Type' => 'application/json' },
          body: { status_code: 200, status_message: 'OK', data: [] }.to_json
        )

      params = {
        name: 'Test Host',
        contact_group: 'CG11111111111111111111111111111111'
      }
      handler.post('rbl/hosts', params)

      expect(WebMock).to have_requested(:post, 'https://api.generatorlabs.com/4.0/rbl/hosts.json')
        .with(body: hash_including(
          'contact_group' => 'CG11111111111111111111111111111111'
        ))
    end
  end
end
