directory node[:robotstxt][:location] do
  owner node[:robotstxt][:user]
  group node[:robotstxt][:group] 
  mode "0755"
  action :create
end

template "#{node[:robotstxt][:location]}/robots.txt" do
  source "robots.txt.erb"
  mode "0644"
  owner node[:robotstxt][:user]
  group node[:robotstxt][:group]
end
