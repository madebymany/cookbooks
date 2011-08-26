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
    ./configure --prefix=/usr/local
    make
    make install
    cd ext/readline/
    /usr/local/bin/ruby extconf.rb
    make
    make install
  EOS
  not_if "/usr/bin/test -f /usr/local/bin/ruby"
end

bash "install_rubygems" do
  user "root"
  cwd "/tmp"
  code <<-EOS
    curl -L http://production.cf.rubygems.org/rubygems/rubygems-1.8.7.tgz | tar zx
    cd rubygems-1.8.7
    /usr/local/bin/ruby setup.rb
  EOS
  not_if "/usr/bin/test -f /usr/local/bin/gem"
end

bash "install_bundler" do
  user "root"
  code <<-EOS
    /usr/local/bin/gem install bundler --no-rdoc --no-ri
  EOS
  not_if "/usr/bin/test -f /usr/local/bin/bundle"
end

bash "install_chef" do
  user "root"
  code <<-EOS
    /usr/local/bin/gem install -v 0.10.4 chef --no-rdoc --no-ri
  EOS
  not_if "/usr/bin/test -f /usr/local/bin/chef"
end
