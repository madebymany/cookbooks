raise "Unsupported platform" unless node[:platform] == 'ubuntu'

bash "add node.js repository" do
  code <<-END
  set -e
  apt-get install -y python-software-properties
  apt-add-repository -y ppa:chris-lea/node.js
  apt-get update
  END

  not_if "grep -R node.js /etc/apt/sources.list /etc/apt/sources.list.d >/dev/null"
end

package 'nodejs' do
  action :upgrade
end

