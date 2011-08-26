#!/bin/bash
# Bootstrap Chef on Ubuntu

function inform {
  status=$1
  echo
  echo -e "\e[33m• ${1}\e[0m"
  echo
}

function happy_ending {
  echo
  echo -e "\e[32m✓ ${1}\e[0m"
  exit 0
}

function croak {
  echo
  echo -e "\e[31m✗ $status failed. Aborting.\e[0m"
  exit 1
}

inform "Checking for supported OS installation."
lsb_release -d | grep -q "Ubuntu 10.04" || croak

command -v chef-solo >/dev/null && \
happy_ending "Chef is already bootstrapped. Nothing more to do."

inform "Updating package index"
apt-get update || croak

inform "Setting up build environment"
apt-get install -y build-essential curl || croak

inform "Installing Ruby Enterprise Edition"
case `uname -m` in
  x86_64)
    REE="http://rubyenterpriseedition.googlecode.com/files/ruby-enterprise_1.8.7-2011.03_amd64_ubuntu10.04.deb"
    ;;
  *)
    REE="http://rubyenterpriseedition.googlecode.com/files/ruby-enterprise_1.8.7-2011.03_i386_ubuntu10.04.deb"
    ;;
esac
echo "Fetching ${REE}"
curl -s -L -o ree.deb "${REE}" || croak
dpkg -i ree.deb || croak
rm ree.deb

inform "Installing Chef"
gem install -v 0.10.4 chef --no-rdoc --no-ri || croak

inform "Creating directory for Chef files"
mkdir -p /etc/chef || croak

happy_ending "Chef has been bootstrapped!"
