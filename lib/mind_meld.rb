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
      poll: dev_ids.length > 0 ? { device_id: self.id, devices: dev_ids } : { id: self.id }
    }
    response = request :put, 'devices/poll', args
    if dev_ids.length == 0
      @device_details = response
    end
    response
  end

  def create_action options
    response = request :put, 'devices/action', { device_action: { device_id: self.id }.merge(options) }
    response
  end

  def device_details(refresh = false)
    if refresh
      @device_details = register(@device)
    else
      @device_details ||= register(@device)
    end
  end

  private
  def request type, call, params = {}
    if @http
      begin
        JSON.parse(@http.send("request_#{type}", "/api/#{call}.json", params.to_query).body)
      rescue => e
        { error: e.message }
      end
    else
      { error: 'Mind Meld not configured' }
    end
  end
end
