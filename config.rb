# Size of the CoreOS cluster created by Vagrant
$num_instances=3

# Other parameters
$instance_name_prefix="core"
$update_channel='stable'

$insert_vagrant_insecure_key = true
$private_vm_network_prefix = "192.168.211"
$starting_ip_address = 11

$forwarded_ports = {}

# Used to fetch a new discovery token for a cluster of size $num_instances
$new_discovery_url="https://discovery.etcd.io/new?size=#{$num_instances}"

# Automatically replace the discovery token on 'vagrant up'
if File.exists?('user-data-master') && ARGV[0].eql?('up')
  require 'open-uri'
  require 'yaml'

  # token = open($new_discovery_url).read

  data = YAML.load(IO.readlines('user-data-master')[1..-1].join)

  # if data.key? 'coreos' and data['coreos'].key? 'etcd'
  #   data['coreos']['etcd']['discovery'] = token
  # end

  # if data.key? 'coreos' and data['coreos'].key? 'etcd2'
  #   data['coreos']['etcd2']['discovery'] = token
  # end

  # Fix for YAML.load() converting reboot-strategy from 'off' to `false`
  if data.key? 'coreos' and data['coreos'].key? 'update' and data['coreos']['update'].key? 'reboot-strategy'
    if data['coreos']['update']['reboot-strategy'] == false
      data['coreos']['update']['reboot-strategy'] = 'off'
    end
  end

  yaml = YAML.dump(data)
  File.open('user-data-master', 'w') { |file| file.write("#cloud-config\n\n#{yaml}") }
end

# Automatically replace the etcd2 endpoints for flanneld on 'vagrant up'
if File.exists?('user-data-worker') && ARGV[0].eql?('up')
  require 'open-uri'
  require 'yaml'

  # token = open($new_discovery_url).read

  data = YAML.load(IO.readlines('user-data-worker')[1..-1].join)

  # if data.key? 'coreos' and data['coreos'].key? 'etcd'
  #   data['coreos']['etcd']['discovery'] = token
  # end

  # if data.key? 'coreos' and data['coreos'].key? 'etcd2'
  #   data['coreos']['etcd2']['discovery'] = token
  # end

  if data.key? 'coreos' and data['coreos'].key? 'flannel'
    master_ip = $private_vm_network_prefix + ".#{$starting_ip_address}"
    etcd_endpoints = "http://" + master_ip + ":2379,http://" + master_ip + ":4001"
    data['coreos']['flannel']['etcd_endpoints'] = etcd_endpoints
  end

  # Fix for YAML.load() converting reboot-strategy from 'off' to `false`
  if data.key? 'coreos' and data['coreos'].key? 'update' and data['coreos']['update'].key? 'reboot-strategy'
    if data['coreos']['update']['reboot-strategy'] == false
      data['coreos']['update']['reboot-strategy'] = 'off'
    end
  end

  yaml = YAML.dump(data)
  File.open('user-data-worker', 'w') { |file| file.write("#cloud-config\n\n#{yaml}") }
end

# Node number is added to this and therefore we need to reduce this by one
$starting_ip_address -= 1