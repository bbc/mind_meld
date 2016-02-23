require 'json'
require 'net/http'
require 'active_support/core_ext/object/to_query'

class MindMeld
  def initialize options
    if options[:url]
      uri = URI.parse(options[:url])
      @http = Net::HTTP.new(uri.host, uri.port)
      if options.key?(:pem)
        pem = File.read(options[:pem])
        @http.use_ssl = true if uri.scheme == 'https'
        @http.cert = OpenSSL::X509::Certificate.new(pem)
        @http.key = OpenSSL::PKey::RSA.new(pem)
        @http.ca_file = options[:ca_file] if options.key?(:ca_file)
        @http.verify_mode = options[:verify_mode] if options.key?(:verify_mode)
      end

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
    if refresh or not @device_details or @device_details.has_key? :error
      @device_details = register(@device)
    else
      @device_details
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
