require 'mind_meld'

class MindMeld::Hive < MindMeld
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
end
