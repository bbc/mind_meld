require 'mind_meld/device'

class MindMeld::Hive < MindMeld::Device
  def initialize options
    options[:device][:device_type] = 'Hive'
    super options
  end

  def connect device_id
    request :put, 'plugin/hive/connect', { connection: { hive_id: self.id, device_id: device_id } }
  end

  def disconnect device_id
    request :put, 'plugin/hive/disconnect', { connection: { hive_id: self.id, device_id: device_id } }
  end

  def device_details(refresh = false)
    super(refresh)
    @device_details['connected_devices'] = [] if not (@device_details.has_key? 'connected_devices' or @device_details.has_key? 'error')
    @device_details
  end
end
