require 'json'
require 'net/http'
require 'active_support/core_ext/object/to_query'

class MindMeld
  def initialize options
    if options[:url]
      uri = URI.parse(options[:url])
      @http = Net::HTTP.new(uri.host, uri.port)
      if options.key?(:pem) and options[:pem]
        pem = File.read(options[:pem])
        @http.use_ssl = true if uri.scheme == 'https'
        @http.cert = OpenSSL::X509::Certificate.new(pem)
        @http.key = OpenSSL::PKey::RSA.new(pem)
        @http.ca_file = options[:ca_file] if options.key?(:ca_file)
        @http.verify_mode = options[:verify_mode] if options.key?(:verify_mode)
      end
    end
  end

  def devices
    request :get, 'devices'
  end

  private
  def request type, call, params = {}
    if @http
      begin
        JSON.parse(@http.send(
            "request_#{type}",
            "/api/#{call}.json",
            type == :get ? params : params.to_query
          ).body)
      rescue => e
        { error: e.message }
      end
    else
      { error: 'Mind Meld not configured' }
    end
  end
end
