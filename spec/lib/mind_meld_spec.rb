require 'spec_helper'
require 'mind_meld'

describe MindMeld do
  let(:device1) {
    { name: 'First device' }
  }
  let(:device2) {
    { name: 'Second device' }
  }
  let(:api) { MindMeld.new(
      url: 'http://test.server/',
      device: {
        name: 'Controlling device'
      }
    )
  }

  before(:each) do
    stub_request(:post, 'http://test.server/api/devices/register.json').
      with(body: 'device%5Bname%5D=Controlling+device').
      to_return(
        status: 200,
        body: '{ "id": 876 }'
      )
    stub_request(:post, 'http://test.server/api/devices/register.json').
      with(body: 'device%5Bname%5D=First+device').
      to_return(
        status: 200,
        body: '{ "id": 1 }'
      )
    stub_request(:post, 'http://test.server/api/devices/register.json').
      with(body: 'device%5Bname%5D=Second+device').
      to_return(
        status: 200,
        body: '{ "id": 2 }'
      )
    stub_request(:put, 'http://test.server/api/devices/poll.json').
      with(:body => "device%5Bname%5D=First+device").
      to_return(
        :status => 200,
        :body => '[]'
      )

  end

  describe '#register' do
    it 'registers a valid device' do
      expect(api.register( device1 )).to be_a Hash
    end

    it 'returns the id of a device' do
      expect(api.register( device1 )['id']).to eq 1
      expect(api.register( device2 )['id']).to eq 2
    end
  end

  describe '#id' do
    let(:api) {
                MindMeld.new(
                              url: 'http://test.server/',
                              device: {
                                name: 'Test host',
                              }
                            )
              }
    let(:api_fail) {
                MindMeld.new(
                              url: 'http://test.server/',
                              device: {
                                name: 'Test host fail',
                              }
                            )
              }
    before(:each) do
      stub_request(:post, 'http://test.server/api/devices/register.json').
        with(body: 'device%5Bname%5D=Test+host').
        to_return(
          status: 200,
          body: '{ "id": 76 }'
        )
      stub_request(:post, 'http://test.server/api/devices/register.json').
        with(body: 'device%5Bname%5D=Test+host+fail').
        to_return(
          status: 500
        )
    end

    it 'returns the id of the device' do
      expect(api.id).to eq 76
    end

    it 'returns nil if device cannot register' do
      expect(api_fail.id).to be_nil
    end

    it 'retries registration' do
      api_fail # Cater for lazy loading
      stub_request(:post, 'http://test.server/api/devices/register.json').
        with(body: 'device%5Bname%5D=Test+host+fail').
        to_return(
          status: 200,
          body: '{ "id": 83 }'
        )
      expect(api_fail.id).to eq 83
    end
  end

  describe '#poll' do
    let(:api) {
                MindMeld.new(
                              url: 'http://test.server/',
                              device: {
                                name: 'Test host',
                              }
                            )
              }

    before(:each) do
      stub_request(:post, 'http://test.server/api/devices/register.json').
        with(body: 'device%5Bname%5D=Test+host').
        to_return(
          status: 200,
          body: '{ "id": 76 }'
        )
      stub_request(:put, 'http://test.server/api/devices/poll.json').
        with(body: 'poll%5Bid%5D=76').
        to_return(
          status: 200,
          body: '{}'
        )
      stub_request(:put, 'http://test.server/api/devices/poll.json').
        with(body: 'poll%5Bdevices%5D%5B%5D=76&poll%5Bid%5D=76').
        to_return(
          status: 200,
          body: '{}'
        )
    end

    it 'polls the controlling device' do
      expect(api.poll).to eq({})
    end

    it 'polls another device' do
      expect(api.poll(123)).to eq({})
    end
  end
end
