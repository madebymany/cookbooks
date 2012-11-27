group(node[:redis][:group]) do
  gid 335
end

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

directory node[:redis][:run_dir] do
  owner node[:redis][:user]
  group node[:redis][:group]
  mode      "0755"
  action    :create
end

