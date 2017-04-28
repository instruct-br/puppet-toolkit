#!/bin/bash

set -e
set -u
set -o pipefail

detect_rhel_7 ( ) {

  if egrep ' 7\.' /etc/redhat-release &> /dev/null; then
    rpm -Uvh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
    yum install -y puppet-agent
  fi

}

detect_rhel_6 ( ) {

  if egrep ' 6\.' /etc/redhat-release &> /dev/null; then
    rpm -Uvh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-6.noarch.rpm
    yum install -y puppet-agent
  fi

}

detect_ubuntu_1604 ( ) {

  if egrep 'DISTRIB_RELEASE=16.04' /etc/lsb-release &> /dev/null; then
    cd /tmp
    curl -O http://apt.puppetlabs.com/puppetlabs-release-pc1-xenial.deb
    dpkg -i puppetlabs-release-pc1-xenial.deb
    apt-get update
    apt-get install puppet-agent
  fi

}

detect_ubuntu_1404 ( ) {

  if egrep 'DISTRIB_RELEASE=14.04' /etc/lsb-release &> /dev/null; then
    cd /tmp
    curl -O http://apt.puppetlabs.com/puppetlabs-release-pc1-trusty.deb
    dpkg -i puppetlabs-release-pc1-trusty.deb
    rm puppetlabs-release-pc1-trusty.deb
    apt-get update
    apt-get install -y puppet-agent # Confirm because the box already comes with a puppet package installed
    apt-get autoremove -y # The box comes with lots of not needed stuff
  fi

}

detect_ubuntu_1204 ( ) {

  if egrep 'DISTRIB_RELEASE=12.04' /etc/lsb-release &> /dev/null; then
    cd /tmp
    curl -O http://apt.puppetlabs.com/puppetlabs-release-pc1-precise.deb
    dpkg -i puppetlabs-release-pc1-precise.deb
    rm puppetlabs-release-pc1-precise.deb
    apt-get update
    apt-get install -y puppet-agent # Confirm because the box already comes with a puppet package installed
    apt-get autoremove -y # The box comes with lots of not needed stuff
  fi

}

detect_debian_8 ( ) {

  if egrep '^8\.[0-9]' /etc/debian_version &> /dev/null; then
    cd /tmp
    wget http://apt.puppetlabs.com/puppetlabs-release-pc1-wheezy.deb
    dpkg -i puppetlabs-release-pc1-wheezy.deb
    rm puppetlabs-release-pc1-wheezy.deb
    apt-get update
    apt-get install puppet-agent 
  fi

}

detect_rhel_6
detect_rhel_7
detect_ubuntu_1604
detect_ubuntu_1404
detect_ubuntu_1204
detect_debian_8

