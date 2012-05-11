script "add pam_limits" do
    interpreter "bash"
    user "root"
    cwd "/etc/pam.d"
    code "echo 'session    required   pam_limits.so' >> /etc/pam.d/su"
    not_if "grep -E '^session    required   pam_limits.so' /etc/pam.d/su"
end

if node[:ulimit]
  node[:ulimit].each do |userconf|
    template "/etc/security/limits.d/#{userconf[:user]}.conf" do
      source "limits.erb"
      mode 0440
      owner "root"
      group "root"
      variables(:userconf => userconf)
    end
  end
end

