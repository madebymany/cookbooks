default.redis.enable = false
default.redis[:user] = "redis"
default.redis[:group] = "redis"

default[:redis][:conf_dir]          = "/etc/redis"
default[:redis][:log_dir]           = "/var/log/redis"
default[:redis][:data_dir]          = "/var/lib/redis"
default[:redis][:run_dir]          = "/var/run/redis"

default[:redis][:home_dir]          = "/usr/local/share/redis"
old_pid_file = "/var/log/redis/redis.pid"
default[:redis][:pid_file] = File.exist?(old_pid_file) ? \
  old_pid_file : File.join(default.redis.run_dir, "redis.pid")

default[:redis][:home_dir] = "/usr/local/share/redis"
default[:redis][:version] = "2.4.14"
default[:redis][:release_url] = "http://redis.googlecode.com/files/redis-2.4.14.tar.gz"

default.redis[:port] = 6379
default.redis[:bind_address] = nil
default.redis[:timeout] = 300
default.redis[:databases] = 16

# max memory in MB
default.redis[:limit_memory] = false
default.redis[:max_memory] = "250"

#  db snapshots to disk
#  after 900 sec (15 min) if at least 1 key changed
#  after 300 sec (5 min) if at least 10 keys changed
#  after 60 sec if at least 10000 keys changed

default.redis[:snapshots] = {900 => 1, 300 => 10, 60 => 10000}

default.redis_sentinel.enable = false
default.redis_sentinel.port = 26379
default.redis_sentinel.pid_file = File.join(default.redis.run_dir, 'redis-sentinel.pid')
default.redis_sentinel.master_defaults = {
  'down-after-milliseconds' => 30_000,
  'parallel-syncs' => 1,
  'failover-timeout' => 900_000,
  'can-failover' => 'yes'
}

