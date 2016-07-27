require 'mind_meld/hive'
require 'mind_meld/tv'
#hive_mind_url = 'http://localhost:3001/'
hive_mind_url = 'HIVEMIND URL'
pem_file = 'CLIENT CERT'
ca_file = 'CA FILE'

def run_client device, actions
  loop do
    actions.sort! { |a, b| a[:at] <=> b[:at] }
    s = actions[0][:at] - Time.now.to_f
    sleep s if s > 0
    actions[0][:at] += actions[0][:period]

    puts "#{Time.now}: #{device.device_details[:name]} #{actions[0][:action]}"

    case actions[0][:action]
    when 'poll'
      device.poll
    when 'refresh'
      device.device_details(refresh: true, view: 'simple')
    end
  end
end

hives = 8.times.collect { |i|
  MindMeld::Hive.new(
    url: hive_mind_url,
    pem: pem_file,
    ca_file: ca_file,
    verify_mode: 0,
    device: {
      name: "Test Hive ##{i}",
      macs: [ "00:11:22:33:44:#{i}#{i}" ],
      ips: [ "10.100.100.#{i}" ],
      brand: 'BBC',
      model: 'Hive'
    }
  )
}

tvs = 30.times.collect { |i|
  MindMeld::Tv.new(
    url: hive_mind_url,
    pem: pem_file,
    ca_file: ca_file,
    verify_mode: 0,
    device: {
      name: "Test TV ##{i}",
      macs: [ "00:11:22:33:55:%02d" % i ],
      ips: [ "10.100.100.#{i}" ],
      brand: 'TV Brand',
      model: 'TV Model'
    }
  )
}

pids = []

hives.each do |d|
  pids << Process.fork do
    run_client d, [
      {
        at: Time.now.to_f + 10 + rand(60),
        period: 10 + rand(300000)/10000.0,
        action: 'poll'
      },
      {
        at: Time.now.to_f + 10 + rand(20),
        period: 3 + rand(10000)/1000.0,
        action: 'refresh'
      },
      {
        at: Time.now.to_f + 10 + rand(20),
        period: 3 + rand(10000)/1000.0,
        action: 'refresh'
      },
    ]
  end
end

tvs.each do |d|
  pids << Process.fork do
    run_client d, [
      {
        at: Time.now.to_f + 10 + rand(60),
        period: 3 + rand(5000)/1000.0,
        action: 'poll'
      },
      {
        at: Time.now.to_f + 10 + rand(20),
        period: 3 + rand(10000)/1000.0,
        action: 'refresh'
      },
      {
        at: Time.now.to_f + 10 + rand(20),
        period: 3 + rand(10000)/1000.0,
        action: 'refresh'
      },
    ]
  end
end

while pids.length > 0
  sleep 60 
  pids = pids.select do |p|
    begin
      Process.kill 0, p
      true
    rescue Errno::ESRCH
      false
    end
  end
  puts pids.join(',')
end
