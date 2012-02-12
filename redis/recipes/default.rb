group(node[:redis][:group]){ gid 335 }
user node[:redis][:user] do
    comment   "Redis-server runner"
    uid       335
    gid       node[:redis][:group]
    shell     "/bin/false"
end

directory "/var/log/redis" do
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

directory "/etc/redis" do
  owner node[:redis][:user]
  group node[:redis][:group]
  mode      "0755"
  action    :create
end

package "redis-server" do
  version node[:redis][:version]
end

service "redis-server" do
  action :enable
end

template "/etc/redis/redis.conf" do
  owner node[:redis][:user]
  group node[:redis][:group]
  notifies :restart, resources(:service => "redis-server")
end

service "redis-server" do
  action :start
end
