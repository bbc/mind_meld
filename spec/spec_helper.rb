require 'webmock/rspec'

$LOAD_PATH << File.expand_path('../../lib', __FILE__)

RSpec.configure do |config|

  config.before(:each) do
    stub_request(:post, 'http://test.server/api/devices/register.json').
      with(body: 'device%5Bdevice_type%5D=Hive&device%5Bname%5D=Generic+Hive').
      to_return(
        status: 200,
        body: '{ "id": 101 }'
      )

    stub_request(:post, 'http://failing.test.server/api/devices/register.json').
      with(body: 'device%5Bdevice_type%5D=Hive&device%5Bname%5D=Generic+Hive').
      to_return(
        status: 500
      )

    stub_request(:post, 'http://test.server/api/devices/register.json').
      with(body: 'device%5Bdevice_type%5D=Tv&device%5Bname%5D=Generic+TV').
      to_return(
        status: 200,
        body: <<RESPONSE
{
  "id": 102
}
RESPONSE
      )

    stub_request(:put, "http://test.server/api/plugin/hive/connect.json").
      with(body: "connection%5Bdevice_id%5D%5Bdevice%5D=1&connection%5Bhive_id%5D=101").
      to_return(
        status: 200, :body => "{}", :headers => {})

    stub_request(:put, "http://test.server/api/plugin/hive/disconnect.json").
      with(body: "connection%5Bdevice_id%5D%5Bdevice%5D=1&connection%5Bhive_id%5D=101").
      to_return(
        status: 200, :body => "{}", :headers => {})

    stub_request(:post, 'http://test.server/api/devices/register.json').
      with(body: 'device%5Bname%5D=First+device').
      to_return(
        status: 200,
        body: <<RESPONSE
{
  "id": 1,
  "hive_queues": [
    {
      "id": 1,
      "name": "first_queue",
      "description": "The first test queue"
    },
    {
      "id": 2,
      "name": "second_queue",
      "description": "The second test queue"
    }
  ]
}
RESPONSE
      )
    stub_request(:put, 'http://test.server/api/devices/poll.json').
      with(:body => "device%5Bname%5D=First+device").
      to_return(
        :status => 200,
        :body => '[]'
      )

    stub_request(:post, 'http://test.server/api/devices/register.json').
      with(body: 'device%5Bname%5D=Second+device').
      to_return(
        status: 200,
        body: '{ "id": 2 }'
      )
    stub_request(:post, 'http://test.server/api/devices/register.json').
      with(body: 'device%5Bname%5D=Device+details+test').
      to_return(
        status: 200,
        body: <<RESPONSE
{
  "id": 235,
  "comment": "Details from register"
}
RESPONSE
    )
    stub_request(:get, 'http://test.server/api/devices/234.json?view=full').
      to_return(
        status: 200,
        body: <<RESPONSE
{
  "id": 234,
  "comment": "Details from device endpoint"
}
RESPONSE
      )
    stub_request(:get, 'http://test.server/api/devices/236.json?view=simple').
      to_return(
        status: 200,
        body: <<RESPONSE
{
  "id": 236,
  "comment": "Details without registering"
}
RESPONSE
      )
    stub_request(:get, 'http://test.server/api/devices/236.json?view=full').
      to_return(
        status: 200,
        body: <<RESPONSE
{
  "id": 236,
  "comment": "Details without registering"
}
RESPONSE
      )
  end

end
