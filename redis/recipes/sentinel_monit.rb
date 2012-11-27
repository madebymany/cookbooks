include_recipe "monit"

monitrc "redis-sentinel", {:pidfile => node.redis_sentinel.pid_file, :confdir => node[:redis][:conf_dir]}, :immediately, 'redis-sentinel.conf.erb'
