include_recipe "apts3"

bash "installing ruby 2" do
  code <<-EOH
  apt-get install -y --force-yes ruby-2-mxm
  EOH
  action :run
end

bash "testing ruby install" do
  code <<-EOH
  ruby -ropenssl -rzlib -rreadline -e "puts 'Hello Ruby World!'"
  EOH
  action :run
end
