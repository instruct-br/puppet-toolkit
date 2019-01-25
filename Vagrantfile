# frozen_string_literal: true

require 'yaml'

Vagrant.require_version '>= 2.0.1'
vagrant_root = File.dirname(__FILE__)

required_plugins = ['vagrant-hosts']
required_plugins.each do |plugin|
  raise "Run \'vagrant plugin install #{plugin}\'" unless Vagrant.has_plugin? plugin
end

env = YAML.load_file("#{vagrant_root}/environment.yaml")
nodes = env['nodes']
defaults = env['defaults']

if File.exist?("#{vagrant_root}/local.yaml")
  local = YAML.load_file("#{vagrant_root}/local.yaml")
  nodes.merge!(local['nodes']) if local.key?('nodes')
  defaults.merge!(local['defaults']) if local.key?('defaults')
end

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

      unless puppet_agent_version.match?(/\d\.\d{1,2}\.\d{1,2}/)
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

      network_address = if data.key?('network_suffix')
                          "#{network_prefix}.#{data['network_suffix']}"
                        else
                          "#{network_prefix}.#{index + 100}"
                        end

      n.vm.provider 'virtualbox' do |v|
        v.customize ['modifyvm', :id, '--ioapic', 'on']
        v.customize ['modifyvm', :id, '--audio', 'none']
        v.memory = memory
        v.cpus = cpus
      end

      n.vm.box = data['box']
      n.vm.box_url = data['box_url'] if data.key?('box_url')
      n.vm.box_version = data['box_version'] if data.key?('box_version')
      n.vm.network :private_network, ip: network_address

      if data.key?('type') && data['type'] == 'windows'
        n.vm.hostname = node
        n.vm.communicator = 'winrm'
        n.vm.synced_folder '.', '/vagrant', disabled: true
        rdp_port = "338#{index + 10}"
        n.vm.network 'forwarded_port', host: rdp_port, guest: 3389, auto_correct: true, id: 'rdp'
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
        if File.exist?("#{vagrant_root}/scripts/#{node}.sh")
          n.vm.provision 'shell' do |s|
            s.path = "#{vagrant_root}/scripts/#{node}.sh"
          end
        end
      end
    end
  end
end
