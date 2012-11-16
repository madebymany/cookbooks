include_recipe "monit"
include_recipe "elasticsearch::server"

monitrc "elasticsearch", {}, :immediately, "elasticsearch.monit.conf.erb"
