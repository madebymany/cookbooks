include_recipe "apt-s3"

apt_package "installing libopenssl debian" do
  name "libopenssl-ruby"
  action :install
end

apt_package "installing libreadline debian" do
  name "libreadline-ruby"
  action :install
end

apt_package "installing ruby2 debian" do
  name "ruby-2-mxm"
  action :install
end

bash "testing ruby install" do
  code <<-EOH
  ruby -ropenssl -rzlib -rreadline -e "puts 'Hello Ruby World!'"
  EOH
  action :run
end

include_recipe "passenger_apache2::default"
include_recipe "passenger_apache2::config"
include_recipe "passenger_apache2::mod_rails"
