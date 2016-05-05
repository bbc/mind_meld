require 'json'
require 'net/http'
require 'active_support/core_ext/object/to_query'
require 'active_support/core_ext/hash/indifferent_access'
require 'openssl'

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
        path = "/api/#{call}.json"
        params_query = params.to_query
        # Apparently request_get is inconsistent with request_<everything else>
        # (Great)
        case type
        when :get
          response = @http.request_get("#{path}?#{params_query}")
        else
          response = @http.send(
              "request_#{type}",
              path,
              params_query
            )
        end
        # Allow for 'array with indifferent access'
        { reply: JSON.parse(response.body) }.with_indifferent_access[:reply]
      rescue => e
        { error: e.message }.with_indifferent_access
      end
    else
      { error: 'Mind Meld not configured' }.with_indifferent_access
    end
  end
end
