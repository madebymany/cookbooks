return unless node[:papertrail][:logger] == "rsyslog"

syslogger = "rsyslog"
syslogdir = "/etc/rsyslog.d"

include_recipe "rsyslog"
include_recipe "monit"

gem_package "remote_syslog" do
  action :install
end

remote_file node[:papertrail][:cert_file] do
  source node[:papertrail][:cert_url]
  mode "0444"
end

template "/etc/log_files.yml" do
  source "log_files.yml.erb"
  owner "root"
  group "root"
  mode "0644"
  variables({:watch_files=> node[:papertrail][:watch_files],
             :host => node[:papertrail][:remote_host],
             :port => node[:papertrail][:remote_port],
             :ssl_server_cert => node[:papertrail][:cert_file]
             })
end

template "/etc/init.d/remote_syslog" do
  source "remote_syslog.init.erb"
  owner "root"
  group "root"
  mode "0644"
end

monitrc "remote_syslog", {}, :immediately, 'remote_syslog.monit.erb'

template "#{syslogdir}/65-papertrail.conf" do
  source "papertrail.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  variables({ :cert_file => node[:papertrail][:cert_file],
              :host => node[:papertrail][:remote_host],
              :port => node[:papertrail][:remote_port]
            })
  notifies  :restart, resources(:service => syslogger)
end
