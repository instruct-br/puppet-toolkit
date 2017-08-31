# Toolkit for Puppet module development

[![Build Status](https://travis-ci.org/instruct-br/puppet-toolkit.svg?branch=master)](https://travis-ci.org/instruct-br/puppet-toolkit)

This is a simple toolkit that uses Vagrant to setup virtual machines for Puppet module development and is used by [Instruct](http://instruct.com.br) developers.

It is very opinionated and based on our workflow, although it should be very useful for many people.

## Quick start

1. Make sure VirtualBox and Vagrant are installed
2. Clone the project repository
3. Edit `environment.yaml` to your needs if needed
4. Run `vagrant up <VM>`

The virtual machine will have the puppet-agent package installed and ready to go.

## Configuration

All configuration is loaded from `environment.yaml` file. There are two main keys: `defaults` and `nodes`.

```
---
defaults:
  memory: 1024
  cpus: 1
  domain: 'dev'
  network_prefix: '172.22.0'
  synced_folder_type: 'nfs'
  puppet_agent_version: '1.10.0'
nodes:
  puppet:
    memory: 2048
    cpus: 2
    box: centos/7
  centos-7:
    box: centos/7
  centos-6:
    box: centos/6
  ubuntu-16.04:
    box: ubuntu/xenial64
  ubuntu-14.04:
    box: ubuntu/trusty64
  ubuntu-12.04:
    box: ubuntu/precise64
  debian-9:
    box: debian/stretch64
    puppet_agent_version: '1.10.6'
  debian-8:
    box: debian/jessie64
  debian-7:
    box: debian/whezzy64
  sles-11:
    box: elastic/sles-11-x86_64
  sles-12:
    box: elastic/sles-12-x86_64
  windows-2012:
    memory: 2048
    cpus: 2
    type: windows
    box: opentable/win-2012r2-standard-amd64-nocm
  windows-2008:
    memory: 2048
    cpus: 2
    type: windows
    box: opentable/win-2008r2-standard-amd64-nocm
```

The `defaults` hash has keys that configure how VirtualBox and Vagrant will work and also values that configure the VMs specified in the `nodes` hash.

On the `nodes` hash there is the definition of the VMs that will be managed by Vagrant.

The `puppet` VM is the one that we use to setup Puppet Server and has more memory and CPUs than the other nodes, which will use the values from `defaults` if not specified.

## Boxes

We chose Vagrant boxes that are as close as possible to a vanilla and minimal installation of the corresponding operating system. Better yet if the box is built and maintained by the vendor itself.

This choice helps us greatly reduce the risk of developing code that might fail on other people's systems and also have less assumptions about what is or not installed.

## TODO

* Document our workflow
* Document `local.yaml` usage
* Instructions on how to configure text editor, tests, etc.
* Minimalistic Puppet module to configure Puppet Server
* Rake task for installing puppet agent on developers system
* Rake task for deploying tools (r10k, puppet-lint, rspec, etc)
* Rake task that deploy puppetserver into the Puppet vm
* Rake task to setup control-repo (links inside the puppet vm)
* Rake task that call vagrant (in case we replace vagrant with AWS or DO)
