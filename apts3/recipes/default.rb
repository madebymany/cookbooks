include_recipe "build-essential"

access_id = node["apts3"]["access_id"]
secret_key = node["apts3"]["secret_key"]
bucket = node["apts3"]["bucket"]
distribution = node["apts3"]["distribution"]
components = node["apts3"]["components"]
architectures = node["apts3"]["architectures"]

apt_package "python-software-properties" do
  action :install
end

bash "adding mxm repo" do 
  code <<-EOH
  add-apt-repository -y ppa:mxmops/packages 
  apt-get update -qq
  EOH
  action :run
end

bash "install apt-s3 method" do
  code <<-EOH
    apt-get install -y --force-yes apt-transport-s3
  EOH
  action :run

end
bash "add S3 repository" do
  code <<-EOH
  echo "deb [arch=#{architectures}] s3://#{access_id}:[#{secret_key}]@s3.amazonaws.com/#{bucket} #{distribution} #{components}" | sudo tee /etc/apt/sources.list.d/s3.amazonaws.com.#{bucket}.list
  EOH
  action :run
end
