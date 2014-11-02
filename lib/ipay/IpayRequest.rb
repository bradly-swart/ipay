require 'erb'
require 'pathname'

class IpayRequest < ERB
  @@request_template_path = Pathname.new "./lib/ipay/requests/"
  # @@request_template_path = "./ipay/requests/"
  # def method_missing(method, *args, &block)
  #   p "no template #{method} found"
  # end

  def initialize(template = nil, params = {})
    @params = params
    @template = self.send(template)
    super(@template)
  end

  def vend_request
    template_file = File.read("#{@@request_template_path}vend_request.erb")
    template_file.gsub!("\n", '')

    return template_file
  end

  def vend_rev_request
    template_file = File.read("#{@@request_template_path}vend_rev_request.erb")
    template_file.gsub!("\n", '')

    return template_file
  end

  def result
    super(binding)
  end

end
