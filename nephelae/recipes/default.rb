include_recipe "monit"

gem_package "nephelae" do
  action :install
end

template node[:nephelae][:conf_file] do
  source "nephelae.yml.erb"
  variables( :config => fix_mash_to_hash(node[:nephelae][:config]) )
end

monitrc "nephelae", {:piddir => node[:nephelae][:pid_dir], 
                     :conffile => node[:nephelae][:conf_file],
                     :logdir => node[:nephelae][:log_dir],
                     :loglevel => node[:nephelae][:log_level]}, :immediately, 'nephelae.conf.erb'

template "/etc/logrotate.d/nephelae" do
  source "logrotate.erb"
  mode "0644"
end
