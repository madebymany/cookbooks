template File.join(node[:redis][:conf_dir], "redis.conf") do

  owner node[:redis][:user]
  group node[:redis][:group]
end

if node.redis_sentinel[:masters]
  template File.join(node[:redis][:conf_dir], "sentinel.conf") do
    owner node[:redis][:user]
    group node[:redis][:group]
  end
end

template File.join(node[:redis][:conf_dir], "common.conf") do
  owner node[:redis][:user]
  group node[:redis][:group]
end

template "/etc/logrotate.d/redis" do
  source "logrotate.erb"
  mode "0644"
end

if node.redis_sentinel[:mysql_reconfiguration]
  template "/usr/local/bin/sentinel_mysql_reconfiguration.sh" do
    owner node[:redis][:user]
    group node[:redis][:group]
    mode "0755"
  end
end

if node.redis_sentinel[:email_notifications] && \
     node.redis_sentinel[:email_notifications][:from_address]

  template "/usr/local/bin/sentinel_email_notification.sh" do
    owner node[:redis][:user]
    group node[:redis][:group]
    mode "0755"
  end
end
