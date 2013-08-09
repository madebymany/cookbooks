#!/bin/bash
# Bootstrap Chef on Ubuntu

set -e

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
OS=$(lsb_release -d)
echo "${OS}" | grep -q "Ubuntu" || croak

command -v chef-solo >/dev/null && \
happy_ending "Chef is already bootstrapped. Nothing more to do."

inform "Updating package index"
apt-get update || croak

inform "installing en language pack"
apt-get install -y language-pack-en || croak

inform "Setting up build environment"
apt-get install -y build-essential openssl libreadline6 libreadline6-dev curl git-core \
  zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-0 libsqlite3-dev sqlite3 libxml2-dev \
  libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison || croak

inform "Installing Chef"
curl -L https://www.opscode.com/chef/install.sh | sudo bash || croak

inform "Creating directory for Chef files"
mkdir -p /etc/chef || croak

happy_ending "Chef has been bootstrapped!"
