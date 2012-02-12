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

install_from_release('redis') do
    prefix_root  "/usr"
    release_url  node[:redis][:install_url]
    version      node[:redis][:version]
    home_dir     node[:redis][:home_dir]
    action       [ :install, :install_with_make ]
    not_if{      File.exists?(File.join(node[:redis][:home_dir], "redis-server")) }
end

%w[ redis-benchmark redis-cli redis-server ].each do |redis_cmd|
    link File.join("/usr/bin", redis_cmd) do
      to File.join(node[:redis][:home_dir], redis_cmd)
      action :create
    end
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
