# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GeneratorLabs::Client do
  describe '#initialize' do
    it 'creates a client with valid credentials' do
      client = described_class.new('AC0123456789abcdef0123456789abcdef', '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef')
      expect(client).to be_a(GeneratorLabs::Client)
      expect(client.account_sid).to eq('AC0123456789abcdef0123456789abcdef')
    end

    it 'raises an error with invalid account SID format' do
      expect do
        described_class.new('invalid', '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef')
      end.to raise_error(GeneratorLabs::Error, /Invalid account SID format/)
    end

    it 'raises an error with invalid auth token format' do
      expect do
        described_class.new('AC0123456789abcdef0123456789abcdef', 'invalid')
      end.to raise_error(GeneratorLabs::Error, /Invalid auth token format/)
    end
  end

  describe 'namespaces' do
    let(:client) do
      described_class.new('AC0123456789abcdef0123456789abcdef', '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef')
    end

    it 'provides access to RBL namespace' do
      expect(client.rbl).to be_a(GeneratorLabs::RBL)
    end

    it 'provides access to Contact namespace' do
      expect(client.contact).to be_a(GeneratorLabs::Contact)
    end
  end

  describe 'version' do
    it 'has the correct version' do
      expect(GeneratorLabs::VERSION).to eq('2.0.0')
    end
  end
end
