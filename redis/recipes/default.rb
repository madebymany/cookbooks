include_recipe "redis::source_install_requirements"
include_recipe "install_from"

install_from_release('redis') do
    release_url  node[:redis][:release_url]
    home_dir     node[:redis][:home_dir]
    version      node[:redis][:version]
    action       [ :install, :install_with_make ]
    not_if do
      File.exists?("#{node[:redis][:home_dir]}-#{node[:redis][:version]}")
    end
end

include_recipe 'redis::config'
include_recipe 'redis::server_monit'
