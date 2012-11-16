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
servicewrapper_path         = node['elasticsearch']['servicewrapper_path']
servicewrapper_download     = node['elasticsearch']['servicewrapper_download']
servicewrapper_version      = node['elasticsearch']['servicewrapper_version']
servicewrapper_file         = node['elasticsearch']['servicewrapper_file']
servicewrapper_checksum     = node['elasticsearch']['servicewrapper_checksum']
plugins                     = node['elasticsearch']['plugins']


should_upgrade = true
current_status = begin
                   Net::HTTP.get_response("localhost", "/",
                     node['elasticsearch']['port_http'].to_i)
                 rescue StandardError
                   nil
                 end
if current_status && current_status.code == '200'
  require 'json'
  require 'rubygems'

  current_status = JSON.load(current_status.body)
  install_version = Gem::Version.new(server_version)
  current_version = Gem::Version.new(current_status['version']['number'])
  should_upgrade = install_version > current_version
end


include_recipe "java"

group server_group do
  system true
end

user server_user do
  home server_data
  gid server_group
  #system true
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


if should_upgrade
  bash "extract elasticsearch sources" do
    cwd node.elasticsearch.server_versions_path
    code <<-EOH
    [ -x /etc/init.d/elasticsearch ] && /etc/init.d/elasticsearch stop
    [ -f /etc/monit/conf.d/elasticsearch.conf ] && monit stop elasticsearch
    [ ! -L elasticsearch ] && rm -rf elasticsearch
    set -e
    tar -zxf "#{server_file}"
    rm "#{server_file}"
    ln -snf elasticsearch-#{server_version} elasticsearch
    mkdir -p elasticsearch/plugins || true
    chown -Rf root:root "#{server_path}"
    rm -rf "#{server_path}/config"
    EOH
    action :nothing
  end

  remote_file "#{node.elasticsearch.server_versions_path}/#{server_file}" do
    source server_download
    checksum server_checksum
    action :create_if_missing
    notifies :run, 'bash[extract elasticsearch sources]', :immediately
  end

  link "#{server_path}/config" do
    to server_etc
  end

  link "#{server_path}/logs" do
    to server_logs
  end

  link "#{server_path}/data" do
    to server_data
  end

  link "/usr/bin/elasticsearch-plugins" do
    to "#{server_path}/bin/plugin"
  end
end


if node['elasticsearch']['update_config_files']
  template "#{server_etc}/elasticsearch.conf" do
    source "elasticsearch.conf.erb"
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

  template "#{server_etc}/logging.yml" do
    source "logging.yml.erb"
    owner "root"
    group "root"
    mode 0644
  end
end


ruby_block "install elasticsearch plugins" do
  block do
    plugins_installed = Dir.foreach(server_plugins)

    if plugins.is_a?(String)
      plugins = plugins.split(/[,;]\s*|\s+/)
    end

    plugins.each do |plugin|
      if plugin.is_a?(Hash)
        name = plugin['name']
        url = plugin['url']
      else
        name = plugin
        url = nil
      end

      installed_name = name[/[^\/]+\z/].sub(/\Aelasticsearch-/, '')
      unless plugins_installed.include?(installed_name)
        Chef::Log.info("install elasticsearch plugin #{name}")
        cmd = %Q[#{server_path}/bin/plugin -install #{name}]
        cmd << %Q[ -url "#{url}"] if url
        Chef::ShellOut.new(cmd).run_command
      end
    end
  end

  action :create
end


if node['elasticsearch']['install_servicewrapper']
  unless FileTest.exists?("#{server_path}/service/elasticsearch")
    remote_file "#{Chef::Config[:file_cache_path]}/#{servicewrapper_file}" do
      source servicewrapper_download
      checksum servicewrapper_checksum
      action :create_if_missing
    end

    bash "extract elasticsearch service wrapper" do
      cwd Chef::Config[:file_cache_path]
      code <<-EOH
      tar -zxf "#{servicewrapper_file}"
      mv "elasticsearch-elasticsearch-servicewrapper-#{servicewrapper_version}/service" "#{server_path}/bin"
      chown -Rf root:root "#{server_path}/bin/service"
      EOH
    end
  end

  template "/etc/init.d/elasticsearch" do
    source "elasticsearch-init.erb"
    owner "root"
    group "root"
    mode 0755
  end

  service "elasticsearch" do
    supports :restart => true, :status => true
    action [:enable, :start]
  end
end

