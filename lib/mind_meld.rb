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
      
      if options.key?(:cert) and options[:cert]
        type = options[:cert].split('/').last.split('.').last == "p12" ? "p12" : "pem" 
        if type == "pem" 
          pem = File.read(options[:cert])
          @http.cert = OpenSSL::X509::Certificate.new(pem)
          @http.key = OpenSSL::PKey::RSA.new(pem)
        elsif type == "p12" 
          p12 = OpenSSL::PKCS12.new(File.binread(options[:cert]))
          @http.cert = p12.certificate
          @http.key = p12.key
        end
        @http.use_ssl = true if uri.scheme == 'https'
        @http.ca_file = options[:ca_file] if options.key?(:ca_file)
        @http.verify_mode = options[:verify_mode] if options.key?(:verify_mode)
      elsif options.key?(:pem) and options[:pem]
        warn "["DEPRECATION"] Key [:pem] is deprecated in Mind Meld. Use [:cert] instead."
        pem = File.read(options[:pem])
        @http.cert = OpenSSL::X509::Certificate.new(pem)
        @http.key = OpenSSL::PKey::RSA.new(pem)
        @http.use_ssl = true if uri.scheme == 'https'
        @http.ca_file = options[:ca_file] if options.key?(:ca_file)
        @http.verify_mode = options[:verify_mode] if options.key?(:verify_mode)
      end
    end

    @statistics = []
  end

  def devices
    request :get, 'devices'
  end

  def add_statistics data
    data = [ data ] if ! data.is_a? Array

    verify_statistics_arguments data
    @statistics.concat data
  end

  def flush_statistics
    response = request :post, 'device_statistics/upload', { data: @statistics }
    @statistics = [] if ! response.has_key? :error
    response
  end

  private
  def verify_statistics_arguments data
    data.each do |d|
      if ! d.has_key? :timestamp
        d[:timestamp] = Time.now
      end
      [:device_id, :label, :value].each do |key|
        raise ArgumentError, "Missing #{key}" if ! d.has_key? key
      end
    end
  end

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
        reply = { reply: JSON.parse(response.body) }.with_indifferent_access[:reply]
        reply[:error] = "Status: #{response.code}" if ! response.kind_of? Net::HTTPSuccess
        reply
      rescue => e
        { error: e.message }.with_indifferent_access
      end
    else
      { error: 'Mind Meld not configured' }.with_indifferent_access
    end
  end
end
