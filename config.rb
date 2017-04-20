# Size of the CoreOS cluster created by Vagrant
$num_instances=3

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

$instance_name_prefix="core"
$update_channel='stable'

#$enable_serial_logging=false
#$expose_docker_tcp=2375
#$share_home=false

# Customize VMs
#$vm_gui = false
#$vm_memory = 1024
#$vm_cpus = 1
#$vb_cpuexecutioncap = 100

# Share folders
#$shared_folders = {}

# Enable port forwarding from guest(s) to host machine, syntax is: { 80 => 8080 }, auto correction is enabled by default.
#$forwarded_ports = {}

$insert_vagrant_insecure_key = true
$private_vm_network_prefix = "192.168.211"
$starting_ip_address = 11

# Node number is added to this and therefore we need to reduce this by one
$starting_ip_address -= 1
