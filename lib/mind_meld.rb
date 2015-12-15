require 'json'
require 'net/http'
require 'active_support/core_ext/object/to_query'

class MindMeld
  def initialize options
    if options[:url]
      uri = URI.parse(options[:url])
      @http = Net::HTTP.new(uri.host, uri.port)

      @device = options[:device]

      # To initialize @id (is this needed?)
      self.id
    end
  end

  def id
    @id ||= register(@device)['id']
  end

  def register options
    request :post, 'devices/register', { device: options }
  end

  def poll dev_id = nil
    args = {
      poll: dev_id ? { id: self.id, devices: [ self.id ] } : { id: self.id }
    }
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
end
