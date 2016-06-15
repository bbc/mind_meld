require 'spec_helper'
require 'mind_meld/device'

describe MindMeld::Device do
  let(:device1) {
    { name: 'First device' }
  }
  let(:device2) {
    { name: 'Second device' }
  }
  let(:api) { MindMeld::Device.new(
      url: 'http://test.server/',
      device: {
        name: 'Controlling device'
      }
    )
  }

  before(:each) do
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

  let(:api) {
              MindMeld::Device.new(
                            url: 'http://test.server/',
                            device: {
                              name: 'Test host',
                            }
                          )
            }
  let(:api_fail) {
              MindMeld::Device.new(
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
        body: '{ "id": 76, "name": "Name returned from server" }'
      )
    stub_request(:post, 'http://test.server/api/devices/register.json').
      with(body: 'device%5Bname%5D=Test+host+fail').
      to_return(
        status: 500
      )
  end

  describe '#id' do
    it 'returns the id of the device' do
      expect(api.id).to eq 76
    end

    it 'returns nil if device cannot register' do
      expect(api_fail.id).to be_nil
    end
  end

  describe '#name' do
    it 'returns the name of the device' do
      expect(api.name).to eq 'Name returned from server'
    end
  end

  describe '#poll' do
    let(:api) {
                MindMeld::Device.new(
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
    end

    it 'polls the controlling device' do
      stub_request(:put, 'http://test.server/api/devices/poll.json').
        with(body: 'poll%5Bid%5D=76').
        to_return(
          status: 200,
          body: '{}'
        )
      expect(api.poll).to eq({})
    end

    it 'polls another device' do
      stub_request(:put, 'http://test.server/api/devices/poll.json').
        with(body: 'poll%5Bdevices%5D%5B%5D=123&poll%5Bid%5D=76').
        to_return(
          status: 200,
          body: '{}'
        )
      expect(api.poll(123)).to eq({})
    end

    it 'polls multiple devices' do
      stub_request(:put, "http://test.server/api/devices/poll.json").
        with(:body => "poll%5Bdevices%5D%5B%5D=123&poll%5Bdevices%5D%5B%5D=364&poll%5Bdevices%5D%5B%5D=7&poll%5Bid%5D=76").
        to_return(
          status: 200,
          body: '{}'
        )
      expect(api.poll(123, 364, 7)).to eq({})
    end
  end

  describe '#create_action' do
    it 'submits a new action for a device' do
      stub_request(:put, 'http://test.server/api/devices/action.json').
        with(body: 'device_action%5Baction_type%5D=redirect&device_action%5Bbody%5D=http%3A%2F%2Fexample.com&device_action%5Bdevice_id%5D=76').
        to_return(
          status: 200,
          body: '{ }'
        )
      expect(api.create_action(action_type: 'redirect', body: 'http://example.com')).to eq({})
    end
  end

  describe '#hive_queues' do
    let(:api) {
                MindMeld::Device.new(
                              url: 'http://test.server/',
                              device: {
                                name: 'First device',
                              }
                            )
              }
    let(:api2) {
                MindMeld::Device.new(
                              url: 'http://test.server/',
                              device: {
                                name: 'Second device',
                              }
                            )
              }

    it 'returns a list of hive queues' do
      expect(api.hive_queues).to match_array(['first_queue', 'second_queue'])
    end

    it 'returns an empty list of hive queues for nil value' do
      expect(api2.hive_queues).to eq []
    end
  end

  describe '#device_details' do
    let(:api_good) {
                MindMeld::Device.new(
                              url: 'http://test.server/',
                              device: {
                                name: 'Device details test',
                              }
                            )
    }
    let(:api_bad) {
                MindMeld::Device.new(
                              url: 'http://test.server/',
                              device: {
                                name: 'Device details test',
                              }
                            )
    }
    let(:api_ugly) {
                MindMeld::Device.new(
                              url: 'http://test.server/',
                              device: {
                                name: 'Device details test',
                              }
                            )
    }
    let(:api_with_id) {
                MindMeld::Device.new(
                              url: 'http://test.server/',
                              device: {
                                id: 236
                              }
                            )
    }
    before(:each) do
      api_good.instance_variable_set(:@device_details, { id: 234 })
      api_bad.instance_variable_set(:@device_details, { })
      api_ugly.instance_variable_set(:@device_details, { error: 'An error' })
    end

    it 'returns the cached details' do
      expect(api_good.device_details).to eq({ id: 234 })
    end

    it 'refreshes the details without polling' do
      expect(api_good.device_details(refresh: true)).to match_array({ "id" => 234, "comment" => "Details from device endpoint" })
    end

    it 'registers for missing details' do
      expect(api_ugly.device_details).to match_array({ "id" => 235, "comment" => 'Details from register' })
    end

    it 'registers for broken details' do
      expect(api_ugly.device_details).to match_array({ "id" => 235, "comment" => 'Details from register' })
    end

    it 'gets details without registering' do
      expect(api_with_id.device_details(refresh: true)).to match_array({ "id" => 236, "comment" => "Details without registering" })
    end
  end

  let(:one_valid_current_device) {
    {
      timestamp: '2016-06-07 16:59:01 +0100',
      label: 'Test key',
      value: 987.654,
      format: 'float'
    }
  }

  let(:one_valid_other_device) {
    {
      device_id: 12345,
      timestamp: '2016-06-07 16:59:01 +0100',
      label: 'Test key',
      value: 987.654,
      format: 'float'
    }
  }

  let(:five_valid) {
    [
      {
        timestamp: '2016-06-07 16:59:37 +0100',
        label: 'Test key',
        value: 987.654,
        format: 'float'
      },
      {
        device_id: 2,
        timestamp: '2016-06-07 16:43:59 +0100',
        label: 'Test key 2',
        value: 66,
        format: 'integer'
      },
      {
        timestamp: '2016-06-07 16:59:01 +0100',
        label: 'Test key 3',
        value: -5.2,
        format: 'float'
      },
      {
        device_id: 3,
        timestamp: '2016-06-07 17:59:01 +0100',
        label: 'Test key',
        value: 11.22,
        format: 'float'
      },
      {
        device_id: 3,
        timestamp: '2016-06-07 18:37:44 +0100',
        label: 'Test key 3',
        value: 0.0,
        format: 'float'
      }
    ]
  }

  describe '#add_statistics' do
    it 'adds a valid statistic for the current device' do
      expect{api.add_statistics one_valid_current_device}
        .to change(api.instance_variable_get(:@statistics), :count).by 1
      expect(api.instance_variable_get(:@statistics)[-1][:device_id]).to eq api.id
    end

    it 'adds a valid statistic for another device' do
      expect{api.add_statistics one_valid_other_device}
        .to change(api.instance_variable_get(:@statistics), :count).by 1
      expect(api.instance_variable_get(:@statistics)[-1][:device_id]).to eq 12345
    end

    it 'adds five valid statistics ' do
      expect{api.add_statistics five_valid}
        .to change(api.instance_variable_get(:@statistics), :count).by 5
      expect(api.instance_variable_get(:@statistics).map{|d| d[:device_id]}).to match_array [api.id, api.id, 2, 3, 3]
    end
  end

end
