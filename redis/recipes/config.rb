template "#{node[:redis][:conf_dir]}/redis.conf" do
  owner node[:redis][:user]
  group node[:redis][:group]
end

monitrc "redis-server", {:pidfile => node[:redis][:pid_file], :confdir => node[:redis][:conf_dir]}, :immediately, 'redis-server.conf.erb'

template "/etc/logrotate.d/redis" do
  source "logrotate.erb"
  mode "0644"
end
