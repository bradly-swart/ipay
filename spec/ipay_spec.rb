require 'spec_helper'
require_relative '../lib/ipay/IpayRequest'

describe Ipay do
  subject { Ipay.new(true, "/Users/brad/projects/powerplus/ipay/lib/util/bizswitch.pem") }

  describe '#calc_vli' do
    time = Time.new
    rand_id = rand(999999999999).to_s.center(10, rand(9).to_s).to_i
    params = {term: "00001",
              client: "StonehouseSA",
              time: time.localtime("+02:00"),
              reference: rand_id,
              amount: "1337",
              currency: "ZAR",
              num_tokens: "1",
              meter: "A12C3456789",
              pay_type: "creditCard"}
    let(:vend_request) {IpayRequest.new(:vend_request, params)}
    let(:message_length) {subject.calc_vli(vend_request.result)}
    it "responds with message length, converted to network order bytes" do
      expect(message_length).to eq [vend_request.result.size].pack("n")
    end

    #test #calc_vli throws exception for messages with length larger than 65535
    let(:big_input) {"0" * 999999}
    context 'when message is too big' do
      it "should raise an error" do
        expect{subject.calc_vli(big_input)}.to raise_error(ArgumentError)
      end
    end
  end

  describe "vend" do
    context 'sending successful message to ipay' do
      time = Time.new
      rand_id = rand(999999999999).to_s.center(10, rand(9).to_s).to_i
      vend_params = {term: "00001",
                client: "StonehouseSA",
                seq_num: 1,
                time: time.localtime("+02:00"),
                ref: rand_id,
                amount: "1337",
                currency: "ZAR",
                num_tokens: "1",
                meter: "A12C3456789",
                pay_type: "creditCard"}
      # let(:vend_request){}
      # let(:vend_response){}

      it "should receive a response" do
        vend_request = subject.vend_request(vend_params)
        vend_response = subject.vend_request_send
        res_node = vend_response.xpath("//elecMsg/vendRes/res")
        expect(res_node.attribute('code').value).to eq("elec000")
      end
    end

    context 'response timeout' do
        time = Time.new
        rand_id = rand(999999999999).to_s.center(10, rand(9).to_s).to_i
        vend_params = {term: "00100",
                  client: "StonehouseSA",
                  time: time.localtime("+02:00"),
                  ref: rand_id,
                  seq_num: 1,
                  amount: "1337",
                  currency: "ZAR",
                  num_tokens: "1",
                  meter: "A12C3456789",
                  pay_type: "creditCard"}
      let(:vend_params){vend_params}
      let(:vend_request) {IpayRequest.new(:vend_request, vend_params)}
      let(:message_length) {subject.calc_vli(vend_request.result)}

      it "should raise a Timeout Exception after 20 seconds" do
        expect{subject.socket_send(message_length, vend_request.result)}.to raise_error(Net::TCPClient::ReadTimeout)
      end


      it "should send a vend reverse request" do
        time = Time.new
        rand_id = rand(999999999999).to_s.center(10, rand(9).to_s).to_i
        params = {term: '00001',
                  client: "StonehouseSA",
                  time: time,
                  seq_num: 2,
                  orig_time: vend_params[:time],
                  rep_count: 0,
                  ref: rand_id,
                  orig_ref: vend_params[:ref],
                  amount: vend_params[:amount],
                  currency: vend_params[:currency],
                  num_tokens: vend_params[:num_tokens],
                  meter: vend_params[:meter],
                  pay_type: vend_params[:pay_type]}
        vend_rev_xml = subject.vend_reverse_request(params)
        vend_rev_response = subject.vend_reverse_request_send

        res_node = vend_rev_response.xpath("//ipayMsg/elecMsg/vendRevRes/res")
        expect(res_node.attribute('code').value).to eq("elec003")
      end

      it "should retry twice" do
        time = Time.new
        rand_id = rand(999999999999).to_s.center(10, rand(9).to_s).to_i
        vend_params = {term: "00200",
                  seq_num: 1,
                  client: "StonehouseSA",
                  time: time.localtime("+02:00"),
                  ref: rand_id,
                  amount: "1337",
                  currency: "ZAR",
                  num_tokens: "1",
                  meter: "A12C3456789",
                  pay_type: "creditCard"}

      # vend_request = IpayRequest.new(:vend_request, vend_params)
      subject.vend_request(vend_params)
      expect{subject.vend_request_send}.to raise_error(Net::TCPClient::ReadTimeout)
      end
    end
    context 'Unable to connect' do
        time = Time.new
        rand_id = rand(999999999999).to_s.center(10, rand(9).to_s).to_i
        params = {term: "00001",
                  client: "StonehouseSA",
                  time: time.localtime("+02:00"),
                  ref: rand_id,
                  amount: "1337",
                  seq_num: 1,
                  currency: "ZAR",
                  num_tokens: "1",
                  meter: "A12C3456789",
                  pay_type: "creditCard"}
        let(:vend_request) {IpayRequest.new(:vend_request, params)}
        let(:message_length) {subject.calc_vli(vend_request.result)}
        let(:socket_response){ subject.socket_send(message_length, vend_request.result) }
      it "should raise connection timeout error" do
        subject.host = "127.1.1.1"
        expect{subject.socket_send(message_length, vend_request.result)}.to raise_error(Net::TCPClient::ConnectionTimeout)
      end
    end
  end
end
