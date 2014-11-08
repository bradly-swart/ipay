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

  def initialize
    @host = "41.204.194.188"
    @port = 8955

    # @host= "localhost"
    # @port = 2000
    @timeout = 10
  end

  def socket_send(vli, message)
    Net::TCPClient.connect(
      server:                 "#{@host}:#{@port}",
      connect_retry_interval: 0.5,
      connect_retry_count:    3,
      read_timeout:           @timeout
    ) do |client|
      # If the connection is lost, create a new one and retry the send
      client.retry_on_connection_failure do
        puts "sending: #{vli.to_s}#{message}"
        client.write("#{vli}#{message}")
      end
      response_length = client.read(2)
      len = response_length.unpack("n")
      bytes_to_read = len[0]
      response = client.read(bytes_to_read)
      # puts "ipay response = #{response}"
    end
  end

  def vend_request(vend_params)
    response = nil
    vr = nil
    begin
      vr = IpayRequest.new(:vend_request, vend_params)
      raw_response = socket_send(calc_vli(vr.result), vr.result)
      response = Nokogiri::XML(raw_response)
    rescue Net::TCPClient::ReadTimeout => ex
      p "request timed out."
      #rollback and return.
      raise
    end
    return vr.result, response
  end

  def vend_reverse_request(params)
    response = nil
    begin
      vr = IpayRequest.new(:vend_rev_request, params)
      raw_response = socket_send(calc_vli(vr.result), vr.result)
      response = Nokogiri::XML(raw_response)
    rescue Net::TCPClient::ReadTimeout => ex
      p "request timed out."
      raise
    end
    return vr.result, response
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
