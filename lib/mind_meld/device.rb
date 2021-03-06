require 'json'
require 'net/http'
require 'mind_meld'

class MindMeld::Device < MindMeld
  def initialize options
    super

    @device = options[:device]
    # To trigger registration (is this needed?)
    @device_details = {}.with_indifferent_access
    device_details(view: 'simple')
  end

  def id
    device_details['id']
  end

  def name
    device_details['name']
  end

  def hive_queues(refresh = false)
    device_details(refresh: refresh)['hive_queues'] ? device_details['hive_queues'].map { |hq| hq['name'] } : []
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

  def send_screenshot options
    encoded = nil
    encoded = Base64.encode64(File.open(options[:screenshot], "rb").read) if File.exists?(options[:screenshot])
    response = request :put, 'devices/screenshot', { device_action: { screenshot: encoded, device_id: options[:device_id] } }
    response
  end

  def device_details(options = {refresh: false})
    if options.is_a? Hash
      refresh = options[:refresh] || false
      view = options[:view] || 'full'
    else
      puts "[DEPRECATION WARNING] device_details(true) replaced by device_details(refresh: true) in Mind Meld"
      refresh = options
      view = 'full'
    end

    if refresh || ! @device_details.has_key?(:id)
      if @device_details.has_key? :id
        @device_details = request :get, "devices/#{@device_details[:id]}", { view: view }
      elsif @device.has_key? :id
        @device_details = request :get, "devices/#{@device[:id]}", { view: view }
      else
        @device_details = register @device
      end
    else
      @device_details
    end
  end

  def add_statistics data
    if ! data.is_a? Array
      data = [ data ]
    end

    id = self.id
    data.each do |d|
      d[:device_id] = id if ! d[:device_id]
    end

    super data
  end

  def clear_state options = {}
    state_params = {
      device_id: self.id,
      state: 'clear'
    }
    state_params[:level] = options[:level] if options.has_key? :level
    state_params[:component] = options[:component] if options.has_key? :component
    request :put, 'devices/update_state', { device_state: state_params }
  end

  def set_state options
    request :put, 'devices/update_state',
      { device_state: {
          device_id: self.id,
          state: options[:state] || 'info',
          component: options[:component] || '[None]',
          message: options[:message]
        }
      }
  end
end
