#
# Cookbook Name:: scout_agent
# Recipe:: activemq_plugin

if node[:recipes].include?('activemq')

  # In case it doesn't already exist
  directory "/home/#{node.scout_agent.user}/.scout" do
    mode "0755"
    user node.scout_agent.user
    group node.scout_agent.group
  end

  cookbook_file "/home/#{node.scout_agent.user}/.scout/activemq_queue.rb" do
    source "plugins/activemq_queue.rb"
    mode "0755"
    user node.scout_agent.user
    group node.scout_agent.group
  end

end
