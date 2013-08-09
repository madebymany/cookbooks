#
# Cookbook Name:: passenger_apache2
# Recipe:: default
#
# Author:: Joshua Timberman (<joshua@opscode.com>)
# Author:: Joshua Sierles (<joshua@37signals.com>)
# Author:: Michael Hale (<mikehale@gmail.com>)
#
# Copyright:: 2009, Opscode, Inc
# Copyright:: 2009, 37signals
# Coprighty:: 2009, Michael Hale
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include_recipe "apache2"

  bash "install passenger module" do
    code <<-EOH
    apt-get install -y apache2-mpm-prefork
    apt-get install -y apache2-prefork-dev
    apt-get install -y libapr1-dev
    apt-get install -y libaprutil1-dev
    apt-get install -y libcurl4-openssl-dev 
    gem install passenger -v #{node[:passenger][:version]}
    $(gem environment | awk '/INSTALLATION DIRECTORY/{print $4}')/../../../../bin/passenger-install-apache2-module -a
    EOH
  end
