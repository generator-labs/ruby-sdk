# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GeneratorLabs::Client do
  let(:valid_sid) { 'AC0123456789abcdef0123456789abcdef' }
  let(:valid_token) { '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef' }

  describe '#initialize' do
    it 'creates a client with valid credentials' do
      client = described_class.new(valid_sid, valid_token)
      expect(client).to be_a(GeneratorLabs::Client)
      expect(client.account_sid).to eq(valid_sid)
    end

    it 'raises an error with invalid account SID format' do
      expect do
        described_class.new('invalid', valid_token)
      end.to raise_error(GeneratorLabs::Error, /Invalid account SID format/)
    end

    it 'raises an error with invalid auth token format' do
      expect do
        described_class.new(valid_sid, 'invalid')
      end.to raise_error(GeneratorLabs::Error, /Invalid auth token format/)
    end
  end

  describe 'namespaces' do
    let(:client) { described_class.new(valid_sid, valid_token) }

    it 'provides access to RBL namespace' do
      expect(client.rbl).to be_a(GeneratorLabs::RBL)
    end

    it 'provides access to Contact namespace' do
      expect(client.contact).to be_a(GeneratorLabs::Contact)
    end

    it 'provides access to Cert namespace' do
      expect(client.cert).to be_a(GeneratorLabs::Cert)
    end

    it 'provides access to Cert errors endpoint' do
      expect(client.cert.errors).not_to be_nil
    end

    it 'provides access to Cert monitors endpoint' do
      expect(client.cert.monitors).not_to be_nil
    end

    it 'provides access to Cert profiles endpoint' do
      expect(client.cert.profiles).not_to be_nil
    end
  end

  describe 'version' do
    it 'has the correct version' do
      expect(GeneratorLabs::VERSION).to eq('2.0.0')
    end
  end
end
