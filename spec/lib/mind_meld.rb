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

    stub_request(:post, "http://test.server/api/device_statistics/upload.json").
         with(body: "data%5B%5D%5Bdevice_id%5D=1&device%5B%5D%5Bformat%5D=float&device%5B%5D%5Blabel%5D=Test+key&device%5B%5D%5Btimestamp%5D=2016-06-07+16%3A59%3A37+%2B0100&device%5B%5D%5Bvalue%5D=987.654&device%5B%5D%5Bdevice_id%5D=2&device%5B%5D%5Bformat%5D=integer&device%5B%5D%5Blabel%5D=Test+key+2&device%5B%5D%5Btimestamp%5D=2016-06-07+16%3A43%3A59+%2B0100&device%5B%5D%5Bvalue%5D=66&device%5B%5D%5Bdevice_id%5D=1&device%5B%5D%5Bformat%5D=float&device%5B%5D%5Blabel%5D=Test+key+3&device%5B%5D%5Btimestamp%5D=2016-06-07+16%3A59%3A01+%2B0100&device%5B%5D%5Bvalue%5D=-5.2&device%5B%5D%5Bdevice_id%5D=3&device%5B%5D%5Bformat%5D=float&device%5B%5D%5Blabel%5D=Test+key&device%5B%5D%5Btimestamp%5D=2016-06-07+17%3A59%3A01+%2B0100&device%5B%5D%5Bvalue%5D=11.22&device%5B%5D%5Bdevice_id%5D=3&device%5B%5D%5Bformat%5D=float&device%5B%5D%5Blabel%5D=Test+key+3&device%5B%5D%5Btimestamp%5D=2016-06-07+18%3A37%3A44+%2B0100&device%5B%5D%5Bvalue%5D=0.0").
         to_return(status: 200, body: "{}", headers: {})

    stub_request(:post, "http://test.server/api/device_statistics/upload.json").
         with(body: "data%5B%5D%5Bdevice_id%5D=1&device%5B%5D%5Bformat%5D=float&device%5B%5D%5Blabel%5D=Test+key&device%5B%5D%5Btimestamp%5D=2016-06-07+16%3A59%3A37+%2B0100&device%5B%5D%5Bvalue%5D=987.654&device%5B%5D%5Bdevice_id%5D=2&device%5B%5D%5Bformat%5D=integer&device%5B%5D%5Blabel%5D=Test+key+2&device%5B%5D%5Btimestamp%5D=2016-06-07+16%3A43%3A59+%2B0100&device%5B%5D%5Bvalue%5D=66&device%5B%5D%5Bdevice_id%5D=1&device%5B%5D%5Bformat%5D=float&device%5B%5D%5Blabel%5D=Test+key+3&device%5B%5D%5Btimestamp%5D=2016-06-07+16%3A59%3A01+%2B0100&device%5B%5D%5Bvalue%5D=-5.2&device%5B%5D%5Bdevice_id%5D=3&device%5B%5D%5Bformat%5D=float&device%5B%5D%5Blabel%5D=Test+key&device%5B%5D%5Btimestamp%5D=2016-06-07+17%3A59%3A01+%2B0100&device%5B%5D%5Bvalue%5D=11.22&device%5B%5D%5Bdevice_id%5D=3&device%5B%5D%5Bformat%5D=float&device%5B%5D%5Blabel%5D=Test+key+3&device%5B%5D%5Btimestamp%5D=2016-06-07+18%3A37%3A44+%2B0100&device%5B%5D%5Bvalue%5D=0.0&device%5B%5D%5Bdevice_id%5D=1&device%5B%5D%5Bformat%5D=float&device%5B%5D%5Blabel%5D=Test+key&device%5B%5D%5Btimestamp%5D=2016-06-07+16%3A59%3A01+%2B0100&device%5B%5D%5Bvalue%5D=987.654").
         to_return(status: 500, body: "{}", headers: {})
  end

  describe '#devices' do
    it 'returns a list of all devices' do
      expect(api.devices).to match devices_list
    end
  end

  context 'Statistics' do
    let(:one_valid) {
      {
        device_id: 1,
        timestamp: '2016-06-07 16:59:01 +0100',
        label: 'Test key',
        value: 987.654,
        format: 'float'
      }
    }

    let(:five_valid) {
      [
        {
          device_id: 1,
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
          device_id: 1,
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
      it 'adds a valid statistic to the buffer' do
        expect{api.add_statistics one_valid}
          .to change(api.instance_variable_get(:@statistics), :count).by 1
      end

      it 'adds multiple valid statistics to the buffer' do
        expect{api.add_statistics five_valid}
          .to change(api.instance_variable_get(:@statistics), :count).by 5
      end

      it 'raises an ArgumentError exceptions for missing device id' do
        one_valid.delete(:device_id)
        expect{api.add_statistics one_valid}
          .to raise_error(ArgumentError)
        five_valid[2].delete(:device_id)
        expect{api.add_statistics five_valid}
          .to raise_error(ArgumentError)
      end

      it 'raises an ArgumentError exceptions for missing label' do
        one_valid.delete(:label)
        expect{api.add_statistics one_valid}
          .to raise_error(ArgumentError)
        five_valid[2].delete(:label)
        expect{api.add_statistics five_valid}
          .to raise_error(ArgumentError)
      end

      it 'raises an ArgumentError exceptions for missing value' do
        one_valid.delete(:label)
        expect{api.add_statistics one_valid}
          .to raise_error(ArgumentError)
        five_valid[2].delete(:value)
        expect{api.add_statistics five_valid}
          .to raise_error(ArgumentError)
      end
    end

    describe '#flush_statistics' do
      it 'uploads the data in the buffer' do
        api.add_statistics five_valid
        api.flush_statistics
        expect(api.instance_variable_get(:@statistics).count).to eq 0
      end

      it 'does not clear the buffer if upload fails' do
        api.add_statistics five_valid
        api.add_statistics one_valid
        api.flush_statistics
        expect(api.instance_variable_get(:@statistics).count).to eq 6
      end
    end
  end

end
