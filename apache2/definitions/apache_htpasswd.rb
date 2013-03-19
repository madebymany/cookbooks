define :apache_htpasswd, :add_users => [], :remove_users => [], \
                         :set_users => [],
                         :truncate => false, \
                         :path => nil do

  path = params[:path] || File.join(node[:apache][:dir], 'htpasswd')
  normalise_params = lambda { |p|
    (Array === p ? p : [p]).map do |q|
      q ? Hash[q.map { |k, v| [k.to_sym, v] }] : nil
    end.compact
  }

  set_users = normalise_params[params[:set_users]]
  add_users = normalise_params[params[:add_users]]
  remove_users = normalise_params[params[:remove_users]]

  remove_users.each { |u| u[:remove] = true }

  truncate = set_users.size > 0 || params[:truncate]

  (set_users | add_users | remove_users).each do |u|
    flags = '-b'
    if u[:remove]
      flags << ' -D'
      verb = 'remove'
      preposition = 'from'
    else
      verb = 'add'
      preposition = 'to'
    end

    truncate_test = if truncate
                      "truncate=-c"
                    else
                      <<-END
                      if [ -r "#{path}" ]; then
                        truncate=""
                      else
                        truncate=-c
                      fi
                      END
                    end

    bash "#{verb} #{u[:username]} #{preposition} #{path}" do
      code %{ #{truncate_test}\nhtpasswd #{flags} $truncate "#{path}" "#{u[:username]}" "#{u[:password]}" }
    end

    truncate = false
  end
end
