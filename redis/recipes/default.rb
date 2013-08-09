include_recipe "redis::source_install_requirements"
include_recipe "git"

bash "install redis" do
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

include_recipe 'redis::config'
include_recipe 'redis::server_monit'
