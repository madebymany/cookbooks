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

inform "Installing base packages"
apt-get install -y build-essential curl ruby1.8 || croak

inform "Installing RubyGems for system Ruby interpreter"
( mkdir -p $HOME/src && \
  cd $HOME/src && \
  curl -L 'http://production.cf.rubygems.org/rubygems/rubygems-1.8.7.tgz' | tar zx && \
  cd rubygems-1.8.7 && \
  ruby1.8 setup.rb --format-executable ) || croak

inform "Installing Chef"
gem1.8 install -v 0.10.4 chef --no-rdoc --no-ri || croak

inform "Creating directory for Chef files"
mkdir -p /etc/chef || croak

happy_ending "Chef has been bootstrapped!"
