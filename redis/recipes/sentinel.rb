include_recipe "redis::source_install_requirements"

bash "install redis-sentinel" do
  cwd "/tmp"
  code <<-END
    rm -rf redis-unstable >/dev/null 2>&1
    set -e
    git clone git://github.com/antirez/redis.git redis-unstable
    cd redis-unstable
    git checkout 58708fa65a30920b97a1df07d8549f5b61810ce0
    make install
  END
  not_if "which redis-server"
end

bash "restart redis-sentinel" do
  code "monit restart redis-sentinel"
  action :nothing
end

if node.redis_sentinel[:mysql_reconfiguration]
  package "mysql-client" do
    action :install
  end
end

include_recipe "redis::sentinel_monit"
include_recipe "redis::config"
