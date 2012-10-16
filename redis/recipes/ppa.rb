raise "Unsupported platform" unless node[:platform] == 'ubuntu'

bash "add redis repository" do
  code <<-END
  set -e
  apt-get install -y python-software-properties
  apt-add-repository -y ppa:rwky/redis
  apt-get update
  END

  not_if "grep -R redis /etc/apt/sources.list /etc/apt/sources.list.d >/dev/null"
end

package 'redis-server' do
  action :upgrade
end

node[:redis][:conf_dir] = "/etc/redis"
node[:redis][:log_dir]  = "/var/log/redis"
node[:redis][:data_dir] = "/var/lib/redis"
node[:redis][:home_dir] = "/var/log/redis"
node[:redis][:pid_file] = "/var/run/redis/redis.pid"

include_recipe 'redis::config'
