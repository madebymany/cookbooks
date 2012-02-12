default.redis[:user] = "redis"
default.redis[:group] = "redis"

default[:redis][:home_dir] = "/usr/local/share/redis"
default[:redis][:install_url] = 'http://redis.googlecode.com/files/redis-2.4.7.tar.gz'
default[:redis][:version] = "2.4.7"

default.redis[:port] = 6379
default.redis[:bind_address] = "0.0.0.0"
default.redis[:timeout] = 300
default.redis[:databases] = 16

default.redis[:data_dir] = "/var/lib/redis"

# max memory in MB
default.redis[:max_memory] = "250"

#  db snapshots to disk
#  after 900 sec (15 min) if at least 1 key changed
#  after 300 sec (5 min) if at least 10 keys changed
#  after 60 sec if at least 10000 keys changed

default.redis[:snapshots] = {900 => 1, 300 => 10, 60 => 10000}
