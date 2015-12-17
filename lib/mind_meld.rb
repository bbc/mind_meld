require 'json'
require 'net/http'
require 'active_support/core_ext/object/to_query'

class MindMeld
  def initialize options
    if options[:url]
      uri = URI.parse(options[:url])
      @http = Net::HTTP.new(uri.host, uri.port)

      @device = options[:device]

      # To trigger registration (is this needed?)
      device_details
    end
  end

  def id
    device_details['id']
  end

  def name
    device_details['name']
  end

  def register options
    request :post, 'devices/register', { device: options }
  end

  def poll *dev_ids
    args = {
      poll: dev_ids.length > 0 ? { id: self.id, devices: dev_ids } : { id: self.id }
    }
puts args
    request :put, 'devices/poll', args
  end

  private
  def request type, call, params = {}
    if @http
      begin
        JSON.parse(@http.send("request_#{type}", "/api/#{call}.json", params.to_query).body)
      rescue => e
        puts e.message
        { error: e.message }
      end
    else
      { error: 'Mind Meld not configured' }
    end
  end

  def device_details
    device_details ||= register(@device)
  end
end
