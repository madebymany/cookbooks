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
lsb_release -d | grep -q "Ubuntu" || croak

command -v chef-solo >/dev/null && \
happy_ending "Chef is already bootstrapped. Nothing more to do."

inform "Updating package index"
apt-get update || croak

inform "Setting up build environment"
apt-get install -y build-essential curl || croak

inform "Installing Ruby ${INSTALL_RUBY}"
case "$INSTALL_RUBY" in
  '1.9.2')
    case `uname -m` in
      x86_64)
        RDEB=""
        ;;
      *)
        RDEB="https://github.com/downloads/madebymany/cookbooks/ruby-1.9.2-p290_i386.deb"
        ;;
    esac
    ;;
    *)
      case `uname -m` in
        x86_64)
          RDEB="http://rubyenterpriseedition.googlecode.com/files/ruby-enterprise_1.8.7-2011.03_amd64_ubuntu10.04.deb"
          ;;
        *)
          RDEB="http://rubyenterpriseedition.googlecode.com/files/ruby-enterprise_1.8.7-2011.03_i386_ubuntu10.04.deb"
          ;;
      esac
      ;;
  esac

echo "Fetching ${RDEB}"
curl -s -L -o rdeb.deb "${RDEB}" || croak
dpkg -i rdeb.deb || croak
rm rdeb.deb

inform "Installing Chef"
gem install -v 0.10.4 chef --no-rdoc --no-ri || croak

inform "Creating directory for Chef files"
mkdir -p /etc/chef || croak

happy_ending "Chef has been bootstrapped!"
