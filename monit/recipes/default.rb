package "monit" do
  action :install
end

if platform?("ubuntu")
  cookbook_file "/etc/default/monit" do
    source "monit.default"
    owner "root"
    group "root"
    mode 0644
  end
end

service "monit" do
  action :start
  enabled true
  supports [:start, :restart, :stop]
end

template "/etc/monit/monitrc" do
  owner "root"
  group "root"
  mode 0700
  source 'monitrc.erb'
  notifies :restart, resources(:service => "monit"), :immediate
end

# We set the delay in the config now
file "/etc/monit/monit_delay" do
  action :delete
end
# template "/etc/monit/monit_delay" do
  # owner "root"
  # group "root"
  # mode 0700
  # source 'monit_delay.erb'
  # notifies :restart, resources(:service => "monit"), :immediate
# end

