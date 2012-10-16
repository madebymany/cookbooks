bash "add ruby-ng repository" do
  code <<-END
  set -e
  apt-get install -y python-software-properties
  apt-add-repository -y ppa:brightbox/ruby-ng
  apt-get update
  END

  not_if "grep -R ruby-ng /etc/apt/sources.list /etc/apt/sources.list.d >/dev/null"
end

%w{ruby1.9.1 passenger-common1.9.1 ruby-switch libapache2-mod-passenger}.each do |p|
  package p do
    action :upgrade
  end
end

bash "use ruby1.9.1" do
  code "ruby-switch --set ruby1.9.1"
end

ruby_block "get installed PassengerRoot" do
  block do
    passenger_conf = File.read(File.join(node[:apache][:dir],
                                         'mods-available/passenger.conf'))
    if passenger_conf =~ /^\s*PassengerRoot\s+"?(.+)("|$)/
      node[:passenger][:root_path] = $1
    else
      raise "PassengerRoot not found"
    end
  end
end

include_recipe "passenger_apache2::config"

