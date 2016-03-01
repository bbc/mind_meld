require 'spec_helper'
require 'mind_meld/tv'

describe MindMeld::Tv do
  let(:tv_api) { MindMeld::Tv.new(url: 'http://test.server/', device: { name: 'Generic TV' }) }

  describe '#set_application' do

    before(:each) do
      stub_request(:put, 'http://test.server/api/plugin/tv/set_application.json').
        with(body: 'device%5Bapplication%5D=Test+app&device%5Bid%5D=102').
        to_return(
          status: 200,
          body: '{}'
        )
    end

    it 'sets the application of a device' do
      expect(tv_api.set_application 'Test app').to be_truthy
    end
  end
end
