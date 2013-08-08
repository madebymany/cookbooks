include_recipe "monit"
include_recipe "elasticsearch::server"

monitrc "elasticsearch", {}, :immediately, "elasticsearch.monit.conf.erb"

#bash "starting monit process" do
  #code <<-EOH
  #monit start elasticsearch
  #EOH
#end
