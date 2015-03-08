require_relative "./ipay/version.rb"
require_relative './ipay/IpayRequest.rb'
require 'socket'
require 'erb'
require 'net/tcp_client'
require 'json'
require 'nokogiri'
require 'active_support/core_ext/hash/conversions'
require 'pry'

class Ipay
  attr_accessor :port,:host, :timeout, :stream_sock
  attr_reader :vend_request_xml, :vend_reverse_request_xml

  def initialize(use_ssl=false, cert_path='/etc/ssl/certs', cert_key_path='/etc/ssl/certs', expected_cert_path='/etc/ssl/certs')
    @host               = "41.204.194.188"
    @port               = 8955
    @use_ssl            = use_ssl
    @cert_path          = cert_path
    @cert_key_path      = cert_key_path
    @expected_cert_path = expected_cert_path
    @timeout            = 10
  end

  def socket_send(vli, message)
    Net::TCPClient.connect(
      server:                 "#{@host}:#{@port}",
      connect_retry_interval: 0.5,
      connect_retry_count:    3,
      read_timeout:           @timeout,
      use_ssl:                @use_ssl,
      check_length:           true,
      cert_path:              @cert_path,
      cert_key_path:          @cert_key_path,
      expected_cert_path:     @expected_cert_path
    ) do |client|
      # If the connection is lost, create a new one and retry the send
      client.retry_on_connection_failure do
        puts "sending: #{vli}#{message}"
        client.write("#{vli}#{message}")
      end
      # response_length = client.read(2)
      # len = response_length.unpack("n")
      # bytes_to_read = len[0]
      response = client.read()
    end
  end

  def vend_request(vend_params)
    vr = nil
    begin
      vr = IpayRequest.new(:vend_request, vend_params)
      @vend_request_xml = vr.result
    rescue => e
      p "Error reading template: #{e.message}"
      #rollback and return.
    end
    return @vend_request_xml
  end

  def vend_request_send
    response = nil
    begin
      raw_response = socket_send(calc_vli(@vend_request_xml), @vend_request_xml)
      response = Nokogiri::XML(raw_response)
    rescue Net::TCPClient::ReadTimeout => ex
      p "request timed out."
      #rollback and return.
      raise
    end
    return response
  end

  def vend_reverse_request(params)
    begin
      vr = IpayRequest.new(:vend_rev_request, params)
      @vend_reverse_request_xml = vr.result
    rescue => e
      p "Error reading template: #{e.message}"
    end
    return @vend_reverse_request_xml
  end

  def vend_reverse_request_send
    response = nil
    begin
      p "** #{@vend_reverse_request_xml}"
      raw_response = socket_send(calc_vli(@vend_reverse_request_xml), @vend_reverse_request_xml)
      response = Nokogiri::XML(raw_response)
    rescue Net::TCPClient::ReadTimeout => ex
      p "request timed out."
      #rollback and return.
      raise
    end
    return response
  end

  def calc_vli(message)
    length = message.size
    if length > 65535
      raise ArgumentError, "Message too big"
    end
    vli = [length].pack("n")
    return vli
  end

end
