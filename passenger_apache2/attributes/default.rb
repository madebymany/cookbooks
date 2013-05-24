default[:passenger][:version]     = "4.0.2"
default[:passenger][:max_pool_size] = "6"
default[:passenger][:root_path]   = "#{languages[:ruby][:gems_dir]}/gems/passenger-#{passenger[:version]}"
default[:passenger][:module_path] = "#{passenger[:root_path]}/libout/apache2/mod_passenger.so"
default[:passenger][:from_system] = false
