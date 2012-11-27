include_recipe "monit"

monitrc "redis-server", {:pidfile => node[:redis][:pid_file], :confdir => node[:redis][:conf_dir]}, :immediately, 'redis-server.conf.erb'
