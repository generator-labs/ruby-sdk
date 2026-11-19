# frozen_string_literal: true

require 'spec_helper'
require 'webmock/rspec'

RSpec.describe 'Request options' do
  let(:client) do
    GeneratorLabs::Client.new(
      'AC0123456789abcdef0123456789abcdef',
      '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
    )
  end
  let(:base) { 'https://api.generatorlabs.com/4.0' }
  let(:ok) { { status: 200, body: { status_code: 200, status_message: 'OK' }.to_json } }

  def error(status, headers = {})
    { status: status, headers: headers, body: { status_code: status, status_message: 'Request failed.' }.to_json }
  end

  def options(**values)
    GeneratorLabs::RequestOptions.new(**values)
  end

  describe 'Idempotency-Key' do
    it 'sends the same key on every retry' do
      keys = []
      stub_request(:post, "#{base}/rbl/hosts.json")
        .with { |request| keys << request.headers['Idempotency-Key'] }
        .to_return(error(500), ok)

      client.rbl.hosts.create(name: 'Test', host: '192.0.2.1')

      expect(keys.length).to eq(2)
      expect(keys[0].length).to eq(36)
      expect(keys[1]).to eq(keys[0])
    end

    it 'sends a new key for each call' do
      keys = []
      stub_request(:post, "#{base}/rbl/hosts.json")
        .with { |request| keys << request.headers['Idempotency-Key'] }
        .to_return(ok)

      client.rbl.hosts.create(name: 'One')
      client.rbl.hosts.create(name: 'Two')

      expect(keys[0]).not_to eq(keys[1])
    end

    it 'sends the key the caller gave' do
      stub = stub_request(:post, "#{base}/rbl/check/start.json")
             .with(headers: { 'Idempotency-Key' => 'my-key' })
             .to_return(ok)

      client.rbl.check.start({ host: '192.0.2.1' }, options(idempotency_key: 'my-key'))

      expect(stub).to have_been_requested
    end

    it 'sends a key on the endpoints that accept one' do
      keys = []
      stub_request(:any, /#{base}/)
        .with { |request| keys << request.headers['Idempotency-Key'] }
        .to_return(ok)

      client.contact.contacts.resend('COx')
      client.contact.contacts.confirm('COx', authcode: '1234')
      client.cert.monitors.delete('CMx')
      client.cert.monitors.check('CMx')

      expect(keys.length).to eq(4)
      expect(keys).to all(be_a(String))
    end

    it 'sends no key on other writes' do
      keys = []
      stub_request(:any, /#{base}/)
        .with { |request| keys << request.headers['Idempotency-Key'] }
        .to_return(ok)

      client.rbl.hosts.update('HTx', name: 'Test')
      client.rbl.hosts.pause('HTx')
      client.rbl.hosts.delete('HTx')

      expect(keys).to eq([nil, nil, nil])
    end

    it 'reports a replayed answer' do
      stub_request(:post, "#{base}/rbl/hosts.json")
        .to_return(ok.merge(headers: { 'Idempotent-Replayed' => 'true' }), ok)

      expect(client.rbl.hosts.create(name: 'Test').replayed).to be(true)
      expect(client.rbl.hosts.create(name: 'Test').replayed).to be(false)
    end
  end

  describe 'request ids, conditional requests and field selection' do
    it 'sends and returns the request id' do
      stub = stub_request(:get, "#{base}/rbl/hosts.json")
             .with(headers: { 'X-Request-Id' => 'req-1' })
             .to_return(ok.merge(headers: { 'X-Request-Id' => 'req-1' }))

      response = client.rbl.hosts.get(options(request_id: 'req-1'))

      expect(stub).to have_been_requested
      expect(response.request_id).to eq('req-1')
    end

    it 'carries the request id on an error' do
      stub_request(:get, "#{base}/rbl/hosts/HTx.json").to_return(error(404, 'X-Request-Id' => 'req-2'))

      expect { client.rbl.hosts.get('HTx') }.to raise_error(GeneratorLabs::Error) do |e|
        expect(e.status_code).to eq(404)
        expect(e.request_id).to eq('req-2')
      end
    end

    it 'returns the ETag and reports 304 as not modified' do
      stub_request(:get, "#{base}/rbl/hosts.json")
        .to_return(ok.merge(headers: { 'ETag' => 'W/"abc"' }))
      stub_request(:get, "#{base}/rbl/hosts.json")
        .with(headers: { 'If-None-Match' => 'W/"abc"' })
        .to_return(status: 304, headers: { 'ETag' => 'W/"abc"' })

      first = client.rbl.hosts.get
      second = client.rbl.hosts.get(options(if_none_match: first.etag))

      expect(first.etag).to eq('W/"abc"')
      expect(first.not_modified).to be(false)
      expect(second.not_modified).to be(true)
      expect(second.to_h).to eq({})
    end

    it 'selects fields on a single get' do
      stub = stub_request(:get, "#{base}/rbl/hosts/HTx.json").with(query: { fields: 'id,host' }).to_return(ok)

      client.rbl.hosts.get('HTx', options(fields: %w[id host]))

      expect(stub).to have_been_requested
    end

    it 'selects fields on a list' do
      stub = stub_request(:get, "#{base}/rbl/hosts.json").with(query: { page: 2, fields: 'id,host' }).to_return(ok)

      client.rbl.hosts.get({ page: 2 }, options(fields: 'id,host'))

      expect(stub).to have_been_requested
    end

    it 'takes one id' do
      expect { client.rbl.hosts.get('HTx', 'HTy') }.to raise_error(ArgumentError)
    end

    it 'pages the listings' do
      stub = stub_request(:get, "#{base}/rbl/listings.json").with(query: { page: 2 }).to_return(ok)

      client.rbl.listings(page: 2)

      expect(stub).to have_been_requested
    end
  end

  describe 'Retry-After' do
    it 'retries a short wait' do
      stub = stub_request(:get, "#{base}/rbl/hosts.json")
             .to_return(error(429, 'Retry-After' => '1', 'RateLimit-Reset' => '3600'), ok)

      client.rbl.hosts.get

      expect(stub).to have_been_requested.twice
    end

    it 'raises a long wait as the error' do
      stub = stub_request(:post, "#{base}/cert/monitors/CMx/check.json")
             .to_return(error(429, 'Retry-After' => '3600'))

      expect { client.cert.monitors.check('CMx') }.to raise_error(GeneratorLabs::Error) do |e|
        expect(e.status_code).to eq(429)
      end
      expect(stub).to have_been_requested.once
    end
  end

  describe GeneratorLabs::Account do
    it 'gets the account' do
      stub_request(:get, "#{base}/account.json")
        .to_return(status: 200, body: { status_code: 200, data: { balance: 80.1226 } }.to_json)

      expect(client.account.get['data']['balance']).to eq(80.1226)
    end

    it 'gets the balance' do
      stub_request(:get, "#{base}/account/balance.json").to_return(status: 200, body: "80.1226\n")

      expect(client.account.balance).to eq(80.1226)
    end

    it 'raises when the balance is refused' do
      stub_request(:get, "#{base}/account/balance.json").to_return(status: 401, body: "-1\n")

      expect { client.account.balance }.to raise_error(GeneratorLabs::Error) do |e|
        expect(e.status_code).to eq(401)
      end
    end

    it 'gets the usage' do
      stub = stub_request(:get, "#{base}/account/usage.json").with(query: { months: 3 }).to_return(ok)

      client.account.usage(months: 3)

      expect(stub).to have_been_requested
    end

    it 'pauses and resumes the checks' do
      pause = stub_request(:post, "#{base}/account/checks/pause.json").to_return(ok)
      resume = stub_request(:post, "#{base}/account/checks/resume.json").to_return(ok)

      client.account.pause_checks
      client.account.resume_checks

      expect(pause).to have_been_requested
      expect(resume).to have_been_requested
    end
  end

  describe 'certificate findings, check and count' do
    it 'lists the findings' do
      stub = stub_request(:get, "#{base}/cert/findings.json").with(query: { dismissed: 1 }).to_return(ok)

      client.cert.findings.get(dismissed: 1)

      expect(stub).to have_been_requested
    end

    it 'pages through the findings' do
      page = ->(id) { { status: 200, body: { status_code: 200, total_pages: 2, data: [{ id: id }] }.to_json } }
      stub_request(:get, "#{base}/cert/findings.json").with(query: { page: 1 }).to_return(page.call('CM1'))
      stub_request(:get, "#{base}/cert/findings.json").with(query: { page: 2 }).to_return(page.call('CM2'))

      expect(client.cert.findings.get_all).to eq([{ 'id' => 'CM1' }, { 'id' => 'CM2' }])
    end

    it 'dismisses and restores findings' do
      dismiss = stub_request(:post, "#{base}/cert/findings/dismiss.json")
                .with(body: { 'finding_id' => 'CERT_CAA01,CERT_CAA02', 'monitors' => 'CM1,CM2' })
                .to_return(ok)
      restore = stub_request(:post, "#{base}/cert/findings/restore.json")
                .with(body: { 'finding_id' => 'CERT_CAA01' })
                .to_return(ok)

      client.cert.findings.dismiss(finding_id: %w[CERT_CAA01 CERT_CAA02], monitors: %w[CM1 CM2])
      client.cert.findings.restore(finding_id: 'CERT_CAA01')

      expect(dismiss).to have_been_requested
      expect(restore).to have_been_requested
    end

    it 'queues a monitor check' do
      stub = stub_request(:post, "#{base}/cert/monitors/CMx/check.json").to_return(ok)

      client.cert.monitors.check('CMx')

      expect(stub).to have_been_requested
    end

    it 'counts the errors' do
      stub_request(:get, "#{base}/cert/errors/count.json").to_return(status: 200, body: "3\n")

      expect(client.cert.errors.count).to eq(3)
    end
  end
end
