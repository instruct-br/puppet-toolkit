#!/bin/bash

set -e
set -u
set -o pipefail

PUPPET_AGENT_VERSION=$1

if [[ ${PUPPET_AGENT_VERSION:0:1} == "5" ]] ; then
  PUPPET_5=0 # true
else
  PUPPET_5=1 # false
fi

detect_rhel_or_oracle_7 ( ) {

  if grep -E ' 7\.' /etc/redhat-release &> /dev/null; then
    if [[ ${PUPPET_5} -eq 0 ]] ; then
      yum install -y http://yum.puppet.com/puppet5/puppet5-release-el-7.noarch.rpm
    else
      yum install -y http://yum.puppet.com/puppetlabs-release-pc1-el-7.noarch.rpm
    fi
    yum install -y "puppet-agent-${PUPPET_AGENT_VERSION}"
  fi

}

detect_rhel_or_oracle_6 ( ) {

  if grep -E ' 6\.' /etc/redhat-release &> /dev/null; then
    if [[ ${PUPPET_5} -eq 0 ]] ; then
      yum install -y http://yum.puppet.com/puppet5/puppet5-release-el-6.noarch.rpm
    else
      yum install -y http://yum.puppet.com/puppetlabs-release-pc1-el-6.noarch.rpm
    fi
    yum install -y "puppet-agent-${PUPPET_AGENT_VERSION}"
  fi

}

detect_rhel_or_oracle_5 ( ) {

  if grep -E ' 5\.' /etc/redhat-release &> /dev/null; then
    cd /tmp
    curl -s -O http://yum.puppetlabs.com/RPM-GPG-KEY-puppet \
      && rpm --import RPM-GPG-KEY-puppet \
      && rm -f RPM-GPG-KEY-puppet

    if [[ ${PUPPET_5} -eq 0 ]] ; then
      curl -s -O http://yum.puppet.com/puppet5/puppet-release-el-5.noarch.rpm \
        && yum install -y puppet-release-el-5.noarch.rpm \
        && rm -f puppet-release-el-5.noarch.rpm
    else
      curl -s -O http://yum.puppet.com/puppetlabs-release-pc1-el-5.noarch.rpm \
        && yum install -y puppetlabs-release-pc1-el-5.noarch.rpm \
        && rm -f puppetlabs-release-pc1-el-5.noarch.rpm
    fi

    yum install -y "puppet-agent-${PUPPET_AGENT_VERSION}"
  fi

}

detect_ubuntu_1804 ( ) {

  if grep -E 'DISTRIB_RELEASE=18.04' /etc/lsb-release &> /dev/null; then
    cd /tmp
    curl -s -O http://apt.puppet.com/puppet5-release-bionic.deb
    dpkg -i puppet5-release-bionic.deb
    rm -f puppet5-release-bionic.deb
    apt-get update
    apt-get install "puppet-agent=${PUPPET_AGENT_VERSION}*"
  fi

}

detect_ubuntu_1604 ( ) {

  if grep -E 'DISTRIB_RELEASE=16.04' /etc/lsb-release &> /dev/null; then
    cd /tmp
    if [[ ${PUPPET_5} -eq 0 ]] ; then
      curl -s -O http://apt.puppet.com/puppet5-release-xenial.deb
      dpkg -i puppet5-release-xenial.deb
      rm -f puppet5-release-xenial.deb
    else
      curl -s -O http://apt.puppet.com/puppetlabs-release-pc1-xenial.deb
      dpkg -i puppetlabs-release-pc1-xenial.deb
      rm -f puppetlabs-release-pc1-xenial.deb
    fi
    apt-get update
    apt-get install "puppet-agent=${PUPPET_AGENT_VERSION}*"
  fi

}

detect_ubuntu_1404 ( ) {

  if grep -E 'DISTRIB_RELEASE=14.04' /etc/lsb-release &> /dev/null; then
    cd /tmp
    if [[ ${PUPPET_5} -eq 0 ]] ; then
      curl -s -O http://apt.puppet.com/puppet5-release-trusty.deb
      dpkg -i puppet5-release-trusty.deb
      rm -f puppet5-release-trusty.deb
    else
      curl -s -O http://apt.puppet.com/puppetlabs-release-pc1-trusty.deb
      dpkg -i puppetlabs-release-pc1-trusty.deb
      rm -f puppetlabs-release-pc1-trusty.deb
    fi
    apt-get update
    # Confirm because the box already comes with a puppet package installed
    apt-get install -y "puppet-agent=${PUPPET_AGENT_VERSION}*"
    apt-get autoremove -y # The box comes with lots of not needed stuff
  fi

}

detect_ubuntu_1204 ( ) {

  if grep -E 'DISTRIB_RELEASE=12.04' /etc/lsb-release &> /dev/null; then
    cd /tmp
    if [[ ${PUPPET_5} -eq 0 ]] ; then
      echo '[Warning] There are no packages for Puppet 5 available! Installing the last one!'
      PUPPET_AGENT_VERSION="1.10.0"
    fi
    curl -O http://apt.puppetlabs.com/puppetlabs-release-pc1-precise.deb
    dpkg -i puppetlabs-release-pc1-precise.deb
    rm puppetlabs-release-pc1-precise.deb
    apt-get update
    # Confirm because the box already comes with a puppet package installed
    apt-get install -y "puppet-agent=${PUPPET_AGENT_VERSION}*"
    apt-get autoremove -y # The box comes with lots of not needed stuff
  fi

}

detect_debian_6 ( ) {

  if grep -E '^6\.[0-9]' /etc/debian_version &> /dev/null; then
    cd /tmp
    if [[ ${PUPPET_5} -eq 0 ]] ; then
      echo '[Warning] There are no packages for Puppet 5 available! Installing the last one!'
      PUPPET_AGENT_VERSION="1.4.1"
    fi
    wget http://apt.puppetlabs.com/puppetlabs-release-pc1-squeeze.deb
    dpkg -i puppetlabs-release-pc1-squeeze.deb
    rm puppetlabs-release-pc1-squeeze.deb
    apt-get update
    apt-get install "puppet-agent=${PUPPET_AGENT_VERSION}*"
  fi

}

detect_debian_7 ( ) {

  if grep -E '^7\.[0-9]' /etc/debian_version &> /dev/null; then
    cd /tmp
    if [[ ${PUPPET_5} -eq 0 ]] ; then
      wget http://apt.puppet.com/puppet5-release-wheezy.deb
      dpkg -i puppet5-release-wheezy.deb
      rm -f puppet5-release-wheezy.deb
    else
      wget http://apt.puppet.com/puppetlabs-release-pc1-wheezy.deb
      dpkg -i puppetlabs-release-pc1-wheezy.deb
      rm -f puppetlabs-release-pc1-wheezy.deb
    fi
    apt-get update
    apt-get install "puppet-agent=${PUPPET_AGENT_VERSION}*"
  fi

}

detect_debian_8 ( ) {

  if grep -E '^8\.[0-9]' /etc/debian_version &> /dev/null; then
    cd /tmp
    if [[ ${PUPPET_5} -eq 0 ]] ; then
      wget http://apt.puppet.com/puppet5-release-jessie.deb
      dpkg -i puppet5-release-jessie.deb
      rm -f puppet5-release-jessie.deb
    else
      wget http://apt.puppet.com/puppetlabs-release-pc1-jessie.deb
      dpkg -i puppetlabs-release-pc1-jessie.deb
      rm -f puppetlabs-release-pc1-jessie.deb
    fi
    apt-get update
    apt-get install "puppet-agent=${PUPPET_AGENT_VERSION}*"
  fi

}

detect_debian_9 ( ) {

  if grep -E '^9\.[0-9]' /etc/debian_version &> /dev/null; then
    cd /tmp
    if [[ ${PUPPET_5} -eq 0 ]] ; then
      wget http://apt.puppet.com/puppet5-release-stretch.deb
      dpkg -i puppet5-release-stretch.deb
      rm -f puppet5-release-stretch.deb
    else
      wget http://apt.puppet.com/puppetlabs-release-pc1-stretch.deb
      dpkg -i puppetlabs-release-pc1-stretch.deb
      rm -f puppetlabs-release-pc1-stretch.deb
    fi
    apt-get update
    apt-get install "puppet-agent=${PUPPET_AGENT_VERSION}*"
  fi

}

detect_sles_12 ( ) {

  if grep -E 'VERSION="12-' /etc/os-release &> /dev/null; then
    curl -s -O http://yum.puppetlabs.com/RPM-GPG-KEY-puppet \
      && rpm --import RPM-GPG-KEY-puppet \
      && rm -f RPM-GPG-KEY-puppet
    if [[ ${PUPPET_5} -eq 0 ]] ; then
      zypper install --no-confirm http://yum.puppet.com/puppet5/puppet5-release-sles-12.noarch.rpm
    fi
    zypper install --oldpackage --no-recommends --no-confirm "puppet-agent=${PUPPET_AGENT_VERSION}"
  fi

}

detect_sles_11 ( ) {

  if grep -E 'VERSION_ID="11' /etc/os-release &> /dev/null; then
    curl -s -O http://yum.puppetlabs.com/RPM-GPG-KEY-puppet \
      && rpm --import RPM-GPG-KEY-puppet \
      && rm -f RPM-GPG-KEY-puppet
    gem uninstall --all --executables facter hiera puppet
    if [[ ${PUPPET_5} -eq 0 ]] ; then
      zypper install --no-confirm http://yum.puppet.com/puppet5/puppet5-release-sles-11.noarch.rpm
    else
      zypper install --no-confirm http://yum.puppet.com/puppetlabs-release-pc1-sles-11.noarch.rpm
    fi
    zypper install --oldpackage --no-recommends --no-confirm "puppet-agent=${PUPPET_AGENT_VERSION}"
  fi

}

detect_rhel_or_oracle_5
detect_rhel_or_oracle_6
detect_rhel_or_oracle_7
detect_ubuntu_1804
detect_ubuntu_1604
detect_ubuntu_1404
detect_ubuntu_1204
detect_debian_6
detect_debian_7
detect_debian_8
detect_debian_9
detect_sles_11
detect_sles_12
