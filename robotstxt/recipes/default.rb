template "#{node[:robotstxt][:location]}/robots.txt" do
  source "robots.txt.erb"
  mode 0440
  owner node[:robotstxt][:user]
  group node[:robotstxt][:group]
end
