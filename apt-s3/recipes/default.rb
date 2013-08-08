Chef::Log.info(node["apts3"])

access_id = node["apts3"]["access_id"]
secret_key = node["apts3"]["access_id"]
bucket = node["apts3"]["bucket"]
distribution = node["apts3"]["distribution"]
components = node["apts3"]["components"]
architectures = node["apts3"]["architectures"]

bash "add mxm package repo" do 
  code <<-EOH
  add-apt-repository -y ppa:mxmops/packages 
  apt-get update -qq
  EOH
  action :run
end

apt_package "installing apt-s3 method for apt" do
  name "apt-transport-s3"
  action :install
end

bash "adding s3 apt repo" do
  code <<-EOH
    echo "deb [arch=#{architectures}] s3://#{access_id}:[#{secret_key}]@s3.amazonaws.com/#{bucket} #{distribution} #{components}" | sudo tee /etc/apt/sources.list.d/s3.amazonaws.com.#{bucket}.list
  EOH
  action :run
end
