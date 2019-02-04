# Toolkit for Puppet module development

[![Build Status](https://travis-ci.org/instruct-br/puppet-toolkit.svg?branch=master)](https://travis-ci.org/instruct-br/puppet-toolkit)

This is a simple toolkit that uses [Vagrant](https://www.vagrantup.com/) to setup virtual machines for Puppet module development and is used by [Instruct](http://instruct.com.br) developers.

It is very opinionated and based on our workflow, although it should be very useful for many people.

## Quick start

1. Make sure [VirtualBox](https://www.virtualbox.org/) and [Vagrant](https://www.vagrantup.com/) are installed
2. Clone the project repository
3. Edit `environment.yaml` to your needs if needed
4. Run `vagrant up <VM>`

The virtual machine will have the puppet-agent package installed and ready to go.

## 10-min Puppet Server start

1. Make sure [VirtualBox](https://www.virtualbox.org/) and [Vagrant](https://www.vagrantup.com/) are installed
1. Clone the project repository
1. Edit `environment.yaml` to your needs if needed
1. Copy `scripts/puppet.sh.sample` to `scripts/puppet.sh` and edit it to config the controlrepo name and Puppet Server role
1. Run `vagrant up puppet`

The virtual machine will have the Puppet Server installed and configured, ready to configure the clients VMs.

## Configuration

All configuration is loaded from `environment.yaml` file. There are two main keys: `defaults` and `nodes`.

```yaml
---
defaults:
  memory: 1024
  cpus: 1
  domain: 'dev'
  network_prefix: '172.22.0'
  synced_folder_type: 'nfs'
  puppet_agent_version: '5.5.4'
nodes:
  puppet:
    memory: 2048
    cpus: 2
    box: centos/7
  centos-7:
    box: centos/7
  centos-6:
    box: centos/6
  centos-5:
    box: gutocarvalho/centos5x64nocm
  ubuntu-18.04:
    box: ubuntu/bionic64
  ubuntu-16.04:
    box: ubuntu/xenial64
  ubuntu-14.04:
    box: ubuntu/trusty64
  ubuntu-12.04:
    box: ubuntu/precise64
    puppet_agent_version: '1.10.0' # Latest release
  debian-9:
    box: debian/stretch64
  debian-8:
    box: debian/jessie64
  debian-7:
    box: debian/wheezy64
    puppet_agent_version: '5.5.1' # Latest release
  debian-6:
    box: gutocarvalho/debian6x64nocm
    puppet_agent_version: '1.4.1' # Latest release
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
  oracle-7:
    box: oracle/7
    box_url: https://yum.oracle.com/boxes/oraclelinux/ol75/ol75.box
  oracle-6:
    box: oracle/6
    box_url: https://yum.oracle.com/boxes/oraclelinux/ol610/ol610.box
  oracle-5:
    box: gutocarvalho/oracle5x64nocm
  windows-2016:
    memory: 2048
    cpus: 2
    type: windows
    box: mwrock/Windows2016
```

The `defaults` hash has keys that configure how [VirtualBox](https://www.virtualbox.org/) and [Vagrant](https://www.vagrantup.com/) will work and also values that configure the VMs specified in the `nodes` hash.

On the `nodes` hash there is the definition of the VMs that will be managed by Vagrant.

The `puppet` VM is the one that we use to setup Puppet Server and has more memory and CPUs than the other nodes, which will use the values from `defaults` if not specified.

You can use Puppet agent from 4 to 6.

## Boxes

We chose [Vagrant](https://www.vagrantup.com/) boxes that are as close as possible to a vanilla and minimal installation of the corresponding operating system. Better yet if the box is built and maintained by the vendor itself.

This choice helps us greatly reduce the risk of developing code that might fail on other people's systems and also have less assumptions about what is or not installed.

You can use the `box_version` parameter to use a box specific version. By default all boxes try to use the latest version available *in the host*. Vagrant will try to download the box if you do not have the choosen version in your environment, and an error will be throw if the version is not available. To declare a version, follow this example in your `local.yaml` (preferred) or `environment.yaml`:

```yaml
...
  centos-7-2018:
    box: centos/7
    box_version: '1812.01'
  bionic-64-newyear:
    box: ubuntu/bionic64
    box_version: '20190101.0.0'
...
```

## TODO

* Minimalistic Puppet module to configure Puppet Server
* Rake task for installing puppet agent on developers system
* Rake task for deploying tools (r10k, puppet-lint, rspec, etc)
* Rake task that deploy puppetserver into the Puppet vm
* Rake task to setup control-repo (links inside the puppet vm)
* Rake task that call vagrant (in case we replace vagrant with AWS or DO)
