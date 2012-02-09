require 'digest/sha1'
SOLR_VERSION = '1.4.1'
 
node[:applications].each do |app|
 
  directory "/data/#{app}/jettyapps" do
    owner node[:rails_app][:user]
    group node[:rails_app][:user]
    mode 0755
    recursive true
  end
 
  directory "/var/run/solr" do
    owner node[:rails_app][:user]
    group node[:rails_app][:user]
    mode 0755
    recursive true
  end
  
  
  directory "/var/log/solr" do
    owner node[:rails_app][:user]
    group node[:rails_app][:user]
    mode 0755
    recursive true
  end
 
 
  template "/usr/bin/solr" do
    source "solr.erb"
    owner node[:rails_app][:user]
    group node[:rails_app][:user]
    mode 0755
    variables({
      :rails_env => 'production',
      :app => app
    })
  end
 
  # template "/etc/monit.d/solr.#{app}.monitrc" do
  #   source "solr.monitrc.erb"
  #   owner node[:rails_app][:user]
  #   group node[:rails_app][:user]
  #   mode 0644
  #   variables({
  #     :app => app,
  #     :user => node[:rails_app][:user],
  #     :group => node[:rails_app][:user]
  #   })
  # end
 
  execute "install solr example package" do
    user node[:rails_app][:user]
    group node[:rails_app][:user]
    command("if [ ! -e /data/#{app}/jettyapps/solr ]; then cd /data/#{app}/jettyapps && " +
            "wget -O apache-solr-#{SOLR_VERSION}.tgz http://mirror.cc.columbia.edu/pub/software/apache/lucene/solr/#{SOLR_VERSION}/apache-solr-#{SOLR_VERSION}.tgz && " +
            "tar -xzf apache-solr-#{SOLR_VERSION}.tgz && " +
            "mv apache-solr-#{SOLR_VERSION}/example solr && " +
            "rm -rf apache-solr-#{SOLR_VERSION}; fi")
    action :run
  end
 
  gem_package "sunspot_rails" do
    source "http://gemcutter.org"
    action :install
    ignore_failure true
  end
  
  gem_package "sunspot_solr" do
    source "http://gemcutter.org"
    action :install
    ignore_failure true
  end
  
  gem_package "nokogiri" do
    source "http://gemcutter.org"
    ignore_failure true
    action :install
  end
 
  execute "install-sunspot-solr" do
    user node[:rails_app][:user]
    group node[:rails_app][:user]
    command "sunspot-installer -f /data/#{app}/jettyapps/solr/solr"
    action :run
  end
  
  # execute "restart-monit-solr" do
  #   command "/usr/bin/monit reload && " +
  #           "/usr/bin/monit restart all -g solr_#{app}"
  #   action :run
  # end
 
end