require 'mind_meld/device'

class MindMeld::Tv < MindMeld::Device
  def initialize options
    options[:device][:device_type] ||= 'Tv'
    super options
  end

  def set_application application
    request :put, 'plugin/tv/set_application',
      {
        device: {
            id: device_details['id'],
            application: application
        }
      }
  end
end
