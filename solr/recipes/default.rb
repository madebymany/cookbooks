require 'digest/sha1'
SOLR_VERSION = node[:solr][:version]
JETTY_DIR = "#{node[:solr][:home_dir]}/#{node[:solr][:application]}/jettyapps"

include_recipe "install_from"
include_recipe "monit"

group(node[:solr][:group]){ gid 365 }
user node[:solr][:user] do
    comment   "solr runner"
    uid       365
    gid       node[:solr][:group]
    shell     "/bin/false"
end
 
  directory JETTY_DIR do
    owner node[:solr][:user]
    group node[:solr][:group]
    mode 0755
    recursive true
  end
 
  directory node[:solr][:pid_dir] do
    owner node[:solr][:user]
    group node[:solr][:group]
    mode 0755
    recursive true
  end
  
  
  directory node[:solr][:log_dir] do
    owner node[:solr][:user]
    group node[:solr][:group]
    mode 0755
    recursive true
  end
 
 
  template "/etc/init.d/solr" do
    source "solr.erb"
    owner node[:solr][:user]
    group node[:solr][:group]
    mode 0755
    variables({
      :rails_env => 'production',
      :app_dir => JETTY_DIR,
      :log_dir => node[:solr][:log_dir],
      :pid_dir => node[:solr][:pid_dir],
      :app => node[:solr][:application]
    })
  end
 
  execute "install solr example package" do
    user node[:solr][:user]
    group node[:solr][:gorup]
    command("if [ ! -e #{JETTY_DIR} ]; then cd #{JETTY_DIR} && " +
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
    user node[:solr][:user]
    group node[:solr][:group]
    command "sunspot-installer -f #{JETTY_DIR}/solr/solr"
    action :run
  end
  
  monitrc "solr-monit", {:pidfile => "#{node[:solr][:pid_dir]}/${node[:solr][:application]}.pid", :appdir => JETTY_DIR}, :immediately

  execute "restart-monit-solr" do
     command "/usr/bin/monit reload && " +
             "/usr/bin/monit restart all -g solr_#{node[:solr][:application]}"
     action :run
  end
 
