#
# Cookbook Name:: elasticsearch
# Recipe:: server
#
# Copyright 2012, SourceIndex IT-Serives
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
#

require 'net/http'

server_user                 = node['elasticsearch']['server_user']
server_group                = node['elasticsearch']['server_group']
server_download             = node['elasticsearch']['server_download']
server_version              = node['elasticsearch']['server_version']
server_file                 = node['elasticsearch']['server_file']
server_checksum             = node['elasticsearch']['server_checksum']
server_path                 = node['elasticsearch']['server_path']
server_etc                  = node['elasticsearch']['server_etc']
server_pid                  = node['elasticsearch']['server_pid']
server_lock                 = node['elasticsearch']['server_lock']
server_plugins              = node['elasticsearch']['server_plugins']
server_logs                 = node['elasticsearch']['server_logs']
server_data                 = node['elasticsearch']['server_data']
plugins                     = node['elasticsearch']['plugins']

include_recipe "java"

bash "install debian package" do
  code <<-EOH
  wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-0.90.3.deb
  dpkg -i elasticsearch-0.90.3.deb
  EOH
  not_if { ::File.exists?("/usr/share/elasticsearch") } 
end

group server_group do
  system true
end

user server_user do
  home server_data
  gid server_group
  shell "/bin/bash"
end

[server_path, server_etc, server_plugins].each do |folder|
  directory folder do
    owner "root"
    group "root"
    mode "0755"
  end
end

[server_pid, server_lock, server_data, server_logs].each do |folder|
  directory folder do
    owner server_user
    group server_group
    mode "0755"
  end
end


template "#{server_etc}/logging.yml" do
  source "logging.yml.erb"
  owner "root"
  group "root"
  mode 0644
end

template "#{server_etc}/elasticsearch.yml" do
  source "elasticsearch.yml.erb"
  owner "root"
  group "root"
  mode 0644
end

template "#{server_etc}/elasticsearch.conf" do
  source "elasticsearch.conf.erb"
  owner "root"
  group "root"
  mode 0644
end

ruby_block "install elasticsearch plugins" do
  block do
    plugins_installed = Dir.foreach(server_plugins)

    if plugins.is_a?(String)
      plugins = plugins.split(/[,;]\s*|\s+/)
    end

    plugins.each do |plugin|
      name = plugin

      installed_name = name.sub!("elasticsearch", "")
      unless plugins_installed.include?(installed_name)
        Chef::Log.info("install elasticsearch plugin #{name}")
        cmd = "/usr/share/elasticsearch/bin/plugin --install #{name}"
        Chef::ShellOut.new(cmd).run_command
      end
    end
  end

  action :create
end

service "elasticsearch" do
  supports :restart => true, :status => true
  action [:enable, :start]
end
