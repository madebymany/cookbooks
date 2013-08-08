Chef::Log.info(node["apts3"])

access_id = node["apts3"]["access_id"]
secret_key = node["apts3"]["access_id"]
bucket = node["apts3"]["bucket"]
distribution = node["apts3"]["distribution"]
components = node["apts3"]["components"]
architectures = node["apts3"]["architectures"]

bash "installing apt-s3 package" do 
  code <<-EOH
  add-apt-repository -y ppa:mxmops/packages 
  apt-get update -qq
  apt-get install -y --force-yes apt-transport-s3
  echo "deb [arch=#{architectures}] s3://#{access_id}:[#{secret_key}]@s3.amazonaws.com/#{bucket} #{distribution} #{components}" | sudo tee /etc/apt/sources.list.d/s3.amazonaws.com.#{bucket}.list
  EOH
  action :run
end
