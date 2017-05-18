require 'yaml'

Vagrant.require_version '>= 1.9.2'

env = YAML.load_file('environment.yaml')
nodes = env['nodes']
defaults = env['defaults']
network_prefix = defaults['network_prefix']
synced_folder_type = defaults['synced_folder_type']
domain = defaults['domain']

Vagrant.configure('2') do |config|
  config.vm.provision :hosts do |provisioner|
    provisioner.autoconfigure = true
    provisioner.sync_hosts = true
    provisioner.add_localhost_hostnames = false
  end

  nodes.each_with_index do |(node, data), index|
    config.vm.define node do |n|
      puppet_agent_version = if data.key?('puppet_agent_version')
                               data['puppet_agent_version']
                             else
                               defaults['puppet_agent_version']
                             end

      unless puppet_agent_version =~ /\d\.\d{1,2}\.\d{1,2}/
        raise "Invalid Puppet Agent version: #{puppet_agent_version}"
      end

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
      n.vm.network :private_network, ip: "#{network_prefix}.#{index + 100}"

      if data.key?('type') && data['type'] == 'windows'
        n.vm.hostname = node
        n.vm.communicator = 'winrm'
        n.vm.provider 'virtualbox' do |v|
          v.gui = true
        end
        n.vm.synced_folder '.', '/vagrant', disabled: true
        n.vm.network 'forwarded_port', host: 3389, guest: 3389, auto_correct: true
        n.vm.provision 'shell' do |s|
          s.path = 'puppet-agent-installer.ps1'
          s.args = ['-PuppetVersion', puppet_agent_version]
        end
      else
        n.vm.hostname = "#{node}.#{domain}"
        n.vm.synced_folder '.', '/vagrant', type: synced_folder_type
        n.vm.provision 'shell' do |s|
          s.path = 'puppet-agent-installer.sh'
          s.args = puppet_agent_version
        end
      end
    end
  end
end
