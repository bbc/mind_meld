require 'spec_helper'
require 'mind_meld/hive'

describe MindMeld::Hive do
  describe '.new' do
    it 'registers the device as a hive' do
      expect(MindMeld::Hive.new(url: 'http://test.server/', device: { name: 'Generic Hive' }).device_details).to include('id' => 101)
    end
  end

  describe '#connect' do
    let(:hive_api) { MindMeld::Hive.new(url: 'http://test.server/', device: { name: 'Generic Hive' }) }
    it 'connects a device to a hive' do
      expect(hive_api.connect(device: 1)).to eq({})
    end
  end

  describe '#disconnect' do
    let(:hive_api) { MindMeld::Hive.new(url: 'http://test.server/', device: { name: 'Generic Hive' }) }
    it 'disconnects a device to a hive' do
      expect(hive_api.disconnect(device: 1)).to eq({})
    end
  end

  describe "#device_details['connected_devices']" do
    let(:hive_api) { MindMeld::Hive.new(url: 'http://test.server/', device: { name: 'Generic Hive' }) }
    it 'returns an empty string if it is not set' do
      expect(hive_api.device_details['connected_devices']).to eq([])
    end
  end
end
