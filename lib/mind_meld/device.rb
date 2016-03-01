require 'json'
require 'net/http'
require 'active_support/core_ext/object/to_query'
require 'mind_meld'

class MindMeld::Device < MindMeld
  def initialize options
    super

    @device = options[:device]
    # To trigger registration (is this needed?)
    device_details
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
end
