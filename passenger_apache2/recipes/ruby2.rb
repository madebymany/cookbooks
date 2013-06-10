bash "compile and install ruby 2" do
  code <<-END
  set -e
  apt-get install -y make
  cd /tmp
  mkdir install-ruby
  cd install-ruby
  wget ftp://ftp.ruby-lang.org/pub/ruby/2.0/ruby-2.0.0-p195.tar.gz

  tar zxvf ruby-2.0.0-p195.tar.gz
  cd ruby-2.0.0-p195
  ./configure --prefix=/usr/local
  make
  make install
  ruby -v
  ruby -ropenssl -rzlib -rreadline -e "puts 'Hello Ruby World!'"
  apt-get -y install libreadline-ruby libopenssl-ruby

  rm -rf /tmp/install-ruby
  END
end
#overide default chef ruby version to use new path
#node.override[:languages][:ruby][:ruby_bin] = "/usr/local/bin/ruby"

include_recipe "passenger_apache2::default"
include_recipe "passenger_apache2::config"
include_recipe "passenger_apache2::mod_rails"
