require 'json'
require 'net/http'
require 'active_support/core_ext/object/to_query'

class MindMeld
  def initialize options
    if options[:url]
      uri = URI.parse(options[:url])
      @http = Net::HTTP.new(uri.host, uri.port)
    end
  end

  def register options
    post 'devices/register', { device: options }
  end

  def poll options
    put 'devices/poll', { device: options }
  end

  private

  def post call, params = {}
    if @http
      begin
        JSON.parse(@http.request_post("/api/#{call}.json", params.to_query).body)
      rescue StandardError => e
        puts e.message
        { error: e.message }
      end
    else
      { error: 'Mind Meld not configured' }
    end
  end

  def put(call, params={})
    begin
      JSON.parse(@http.request_put("/api/#{call}.json", params.to_query).body)
    rescue StandardError => e
      puts e.message
      { error: e.message }
    end
  end
end
