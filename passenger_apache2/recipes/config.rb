template "/usr/bin/ruby_with_gc_tuning" do
  source "ruby_wrapper.erb"
  owner "root"
  group "root"
  mode 0755
end

template "#{node[:apache][:dir]}/mods-available/passenger.conf" do
  cookbook "passenger_apache2"
  source "passenger.conf.erb"
  owner "root"
  group "root"
  mode 0644
end

