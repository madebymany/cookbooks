include_recipe "redis::client"

execute "ensure-redis-is-running" do
  command %Q{
    /etc/init.d/redis-server start /etc/redis.conf
  }
  not_if "pgrep redis-server"
end
