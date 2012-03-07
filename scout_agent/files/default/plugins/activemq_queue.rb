class ActivemqQueue < Scout::Plugin
  needs 'net/http'
  needs 'rexml/document'

  OPTIONS = <<-EOS
    management_url:
      default: http://localhost:8161/admin
      notes: The base URL of your ActiveMQ Web Console
      attributes: required
  EOS

  def build_report
    xml = get(:queues)

    doc = REXML::Document.new xml
    doc.elements.to_a("/queues/queue").each_with_index do |queue, i|
      if i >= 5
        alert "This server has more than 5 queues, only the first 5 will be monitored"
        break
      end
      name = queue.attributes["name"].gsub(/[^a-z0-9]/i, '_')
      stats = queue.elements["stats"]
      report :"#{name}_size" => stats.attributes['size'].to_i
      report :"#{name}_consumers" => stats.attributes['consumerCount'].to_i
      counter :"#{name}_enqueue_rate", stats.attributes['enqueueCount'].to_i, :per => :second, :round => 2
      counter :"#{name}_dequeue_rate", stats.attributes['dequeueCount'].to_i, :per => :second, :round => 2
    end

  rescue Errno::ECONNREFUSED
    error("Unable to connect to ActiveMQ Management server", "Please ensure the connection details are correct in the plugin settings.\n\nException: #{$!.message}\n\nBacktrace:\n#{$!.backtrace}")
  end
  
  private
  
  def get(name)
    url = option('management_url').to_s.strip
    case name
    when :queues
      url << '/xml/queues.jsp'
    else
      raise "Invalid name"
    end
    result = query_api(url)
  end

  def query_api(url)
    parsed = URI.parse(url)
    http = Net::HTTP.new(parsed.host, parsed.port)
    req = Net::HTTP::Get.new(parsed.path)
    #req.basic_auth option(:username), option(:password)
    response = http.request(req)
    data = response.body
  end
end
