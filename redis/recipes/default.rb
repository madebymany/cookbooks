include_recipe "install_from"
include_recipe "monit"

group(node[:redis][:group]){ gid 335 }
user node[:redis][:user] do
    comment   "Redis-server runner"
    uid       335
    gid       node[:redis][:group]
    shell     "/bin/false"
end

directory node[:redis][:log_dir] do
  owner node[:redis][:user]
  group node[:redis][:group]
  mode      "0755"
  action    :create
end

directory node[:redis][:data_dir] do
  owner node[:redis][:user]
  group node[:redis][:group]
  mode      "0755"
  action    :create
  recursive true
end

directory node[:redis][:conf_dir] do
  owner node[:redis][:user]
  group node[:redis][:group]
  mode      "0755"
  action    :create
end

install_from_release('redis') do
    release_url  node[:redis][:release_url]
    home_dir     node[:redis][:home_dir]
    version      node[:redis][:version]
    action       [ :install, :install_with_make ]
    not_if{ File.exists?("#{node[:redis][:home_dir]}-#{node[:redis][:version]}") }
end

template "#{node[:redis][:conf_dir]}/redis.conf" do
  owner node[:redis][:user]
  group node[:redis][:group]
end

monitrc "redis-server", {:pidfile => node[:redis][:pid_file], :confdir => node[:redis][:conf_dir]}, :immediately, 'redis-server.conf.erb'

template "/etc/logrotate.d/redis" do
  source "logrotate.erb"
  mode "0644"
end
