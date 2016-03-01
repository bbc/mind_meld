require 'spec_helper'
require 'mind_meld/device'
require 'JSON'

describe MindMeld do
  let(:api) { MindMeld.new(
      url: 'http://test.server/',
    )
  }

  let(:devices_list) {
    [
      {
        'id' => 1,
        'name' => 'First device'
      },
      {
        'id' => 2,
        'name' => 'Second device'
      }
    ]
  }

  before(:each) do
    stub_request(:get, 'http://test.server/api/devices.json').
      to_return(
        status: 200,
        body: devices_list.to_json
      )

  end

  describe '#devices' do
    it 'returns a list of all devices' do
      expect(api.devices).to match devices_list
    end
  end

end
