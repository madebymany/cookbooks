include_recipe "apache2"
include_recipe "apache2::mod_headers"
include_recipe "apache2::mod_rewrite"
include_recipe(node[:rails_app][:passenger_recipe] ||
               "passenger_apache2::mod_rails")
include_recipe "monit"

gem_package "bundler" do
  version "1.2.1"
  action :install
end

node[:rails_app][:packages].each do |pkg_name|
  package pkg_name
end

user node[:rails_app][:user] do
  home node[:rails_app][:home]
end

directory "#{node[:rails_app][:home]}" do
  owner node[:rails_app][:user]
  action :create
  recursive true
end

directory "#{node[:rails_app][:home]}/.ssh" do
  owner node[:rails_app][:user]
end

bash "copy_authorized_keys" do
  code <<-END
    cp /home/ubuntu/.ssh/authorized_keys #{node[:rails_app][:home]}/.ssh/authorized_keys
    chown #{node[:rails_app][:user]} #{node[:rails_app][:home]}/.ssh/authorized_keys
  END
  not_if { File.exist?("#{node[:rails_app][:home]}/.ssh/authorized_keys") }
end

htpasswd_file = "/etc/apache2/htpasswd-#{node[:rails_app][:name]}"

apache_htpasswd do
  path htpasswd_file
  set_users node[:rails_app][:htpasswd]
end

template "/etc/apache2/sites-available/#{node[:rails_app][:name]}" do
  source "vhost.erb"
  variables htpasswd_file: htpasswd_file
end

%w[
  releases
  shared
  shared/config
  shared/log
  shared/system
  shared/public
  shared/pids
].each do |path|
  directory "#{node[:rails_app][:home]}/#{path}" do
    owner node[:rails_app][:user]
  end
end

if node[:rails_app][:database]
  template "#{node[:rails_app][:home]}/shared/config/database.yml" do
    source "database.yml.erb"
    owner node[:rails_app][:user]
  end
end

if node[:rails_app][:s3]
  template "#{node[:rails_app][:home]}/shared/config/amazon_s3.yml" do
    source "amazon_s3.yml.erb"
    owner node[:rails_app][:user]
  end
end

if node[:rails_app][:new_relic]
  template "#{node[:rails_app][:home]}/shared/config/newrelic.yml" do
    source "newrelic.yml.erb"
    owner node[:rails_app][:user]
  end
end

if node[:rails_app][:other_configs]
  node[:rails_app][:other_configs].each do |name, config|
    template "#{node[:rails_app][:home]}/shared/config/#{name}.yml" do
      source "yamliser.erb"
      owner node[:rails_app][:user]
      variables( :config => fix_mash_to_hash(config) )
    end
  end
end

if node[:rails_app][:activemq]
  if node[:rails_app][:activemq][:database] and node[:rails_app][:database]
    node[:activemq][:database][:name] = node[:rails_app][:activemq][:database]
    node[:activemq][:database][:host] = node[:rails_app][:database][:host]
    node[:activemq][:database][:user] = 'activemq'
    node[:activemq][:database][:password] = 'activemq'

    execute "create activemq mysql db" do
      command "/usr/bin/mysql -h #{node.rails_app.database.host} -u root -p#{node.rails_app.database.password} -e " +
          "'CREATE DATABASE IF NOT EXISTS `#{node.activemq.database.name}`;" +
          " GRANT ALL on `#{node.activemq.database.name}`.* TO activemq IDENTIFIED BY \"activemq\";'"
    end
  end
end

bash "placate_apache" do
  user node[:rails_app][:user]
  code %{ ln -s #{ node[:rails_app][:home] }/releases #{ node[:rails_app][:home] }/current }
  not_if { File.exist?("#{ node[:rails_app][:home] }/current") }
end

bash "enable_site" do
  code "a2ensite #{node[:rails_app][:name]}"
end

bash "reload_apache" do
  code "/etc/init.d/apache2 start"
  code "/etc/init.d/apache2 reload"
end

template "/etc/logrotate.d/rails_app" do
  source "logrotate.erb"
  mode "0644"
end

template "/etc/logrotate.d/apache2" do
  source "apache-logrotate.erb"
  mode "0644"
end

if node[:rails_app][:zombie_passenger_killer]
  gem_package "zombie_passenger_killer" do
    action :install
  end

  monitrc "zombie-killer", {:conf => node[:rails_app][:zombie_passenger_killer]}, :immediately, 'zombie-killer.conf.erb'


end
