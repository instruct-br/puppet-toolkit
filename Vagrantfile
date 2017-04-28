require 'yaml'

Vagrant.require_version '>= 1.9.2'

env = YAML.load_file('environment.yaml')
nodes = env['nodes']
defaults = env['defaults']
network_prefix = defaults['network_prefix']
synced_folder_type = defaults['synced_folder_type']
domain = defaults['domain']

Vagrant.configure('2') do |config|
  config.vm.synced_folder '.', '/vagrant', type: synced_folder_type

  config.vm.provision :hosts do |provisioner|
    provisioner.autoconfigure = true
    provisioner.sync_hosts = true
    provisioner.add_localhost_hostnames = false
  end

  nodes.each_with_index do |(node, data), index|
    config.vm.define node do |n|
      memory = if data.key?('memory')
                 data['memory']
               else
                 defaults['memory']
               end

      cpus = if data.key?('cpus')
               data['cpus']
             else
               defaults['cpus']
             end

      n.vm.provider 'virtualbox' do |v|
        v.customize ['modifyvm', :id, '--ioapic', 'on']
        v.memory = memory
        v.cpus = cpus
      end

      n.vm.box = data['box']
      n.vm.hostname = "#{node}.#{domain}"
      n.vm.network :private_network, ip: "#{network_prefix}.#{index + 100}"
      n.vm.provision 'shell', path: 'puppet-agent-installer.sh'
    end
  end
end
