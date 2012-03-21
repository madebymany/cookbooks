#
# Cookbook Name:: scout_agent
# Recipe:: redis_plugin

if node[:recipes].include?('redis')

  # In case it doesn't already exist
  directory "/home/#{node.scout_agent.user}/.scout" do
    mode "0755"
    owner node.scout_agent.user
    group node.scout_agent.group
  end

  cookbook_file "/home/#{node.scout_agent.user}/.scout/redis_monitoring.rb" do
    source "plugins/redis_monitoring.rb"
    mode "0644"
    owner node.scout_agent.user
    group node.scout_agent.group
  end
end
