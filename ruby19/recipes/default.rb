include_recipe "build-essential"

%w[
  libncurses5-dev
  libreadline5-dev
  libcurl4-openssl-dev
  curl
].each do |pkg|
  package pkg do
    action :install
  end
end

bash "install_ruby19" do
  user "root"
  cwd "/tmp"
  code <<-EOS
    curl -L http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.2-p290.tar.gz | tar zx
    cd ruby-1.9.2*
    ./configure --prefix=/opt/ruby19
    make
    make install
    cd ext/readline/
    /opt/ruby19/bin/ruby extconf.rb
    make
    make install
  EOS
  not_if { File.exist?("/opt/ruby19/bin/ruby") }
end

bash "install_rubygems" do
  user "root"
  cwd "/tmp"
  code <<-EOS
    curl -L http://production.cf.rubygems.org/rubygems/rubygems-1.8.7.tgz | tar zx
    cd rubygems-1.8.7
    /opt/ruby19/bin/ruby setup.rb
  EOS
  not_if { File.exist?("/opt/ruby19/bin/gem") }
end

bash "install_bundler" do
  user "root"
  code <<-EOS
    /opt/ruby19/bin/gem install bundler --no-rdoc --no-ri
  EOS
  not_if { File.exist?("/opt/ruby19/bin/bundle") }
end

bash "install_chef" do
  user "root"
  code <<-EOS
    /opt/ruby19/bin/gem install -v 0.10.4 chef --no-rdoc --no-ri
  EOS
  not_if { File.exist?("/opt/ruby19/bin/chef") }
end

bash "update_path" do
  user "root"
  code <<-EOS
    grep -v 'PATH=' > /tmp/etc_environment_tmp
    echo 'PATH="/opt/ruby19/bin:#{ENV['PATH']}"' >> /tmp/etc_environment_tmp
    mv /tmp/etc_environment_tmp /etc/environment
    source /etc/environment
  EOS
  not_if { `which ruby` =~ %r{/opt/ruby19/bin/ruby} }
end

bash "install_passenger" do
  user "root"
  code <<-EOS
    /opt/ruby19/bin/gem install -v #{node[:passenger][:version]} passenger --no-rdoc --no-ri
    /opt/ruby19/bin/passenger-install-apache2-module -a
  EOS
  not_if { File.exist?("/opt/ruby19/bin/passenger-install-apache2-module") }
end
