require 'spec_helper'
require 'mind_meld'

describe MindMeld do
  let(:device1) {
    { name: 'First device' }
  }
  let(:device2) {
    { name: 'Second device' }
  }
  let(:api) { MindMeld.new(url: 'http://test.server/') }

  before(:each) do
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

  describe '#poll' do
    it 'polls a valid device' do
      api.register(device1)
      expect(api.poll(device1)).to eq []
    end
  end
end
