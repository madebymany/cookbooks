class Chef
  class Recipe
    # name        The name of the service.  Looks for a template named NAME.conf
    # variables   Hash of variables to pass to the template
    # reload      Reload monit so it notices the new service.  :delayed (default) or :immediately. (actually doesn't do anything, doing restarts immediately as only this seems to work)
    def monitrc(name, variables={}, reload = :delayed, template_source = nil) 
      template_source = "#{name}.conf.erb}" if template_source.nil?
      log "Making monitrc for: #{name}"
      template "/etc/monit/conf.d/#{name}.conf" do
        owner "root"
        group "root"
        mode 0644
        source template_source
        variables variables
        notifies :restart, resources(:service => "monit"), :immediate
        action :create
      end
    end
  end
end  
