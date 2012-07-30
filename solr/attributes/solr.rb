default.solr[:user] = "solr"
default.solr[:group] = "solr"

default[:solr][:conf_dir]          = "/etc/solr"
default[:solr][:log_dir]           = "/var/log/solr"
default[:solr][:data_dir]          = "/var/lib/solr"

default[:solr][:home_dir]          = "/usr/local/share/solr"
default[:solr][:pid_dir]           = "/var/run/solr"

default[:solr][:version] = "3.6.1"

