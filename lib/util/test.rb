require '../ipay.rb'

ipay = Ipay.new
time = Time.new
rand_id = rand(999999999999).to_s.center(10, rand(9).to_s).to_i
vend_params = {client_id: "StonehouseSA",
          term: "00200",
          seq_num: 1,
          time: time.localtime("+02:00"),
          reference: rand_id,
          amount: "1337",
          currency: "ZAR",
          num_tokens: "1",
          meter: "A12C3456789",
          pay_type: "creditCard"}


begin
  retries ||= 0
  vend_xml = ipay.vend_request(vend_params)
  vend_response = ipay.vend_request_send
  p "initial vend response: #{vend_response}"
rescue Net::TCPClient::ReadTimeout => ex
  p "******RESCUING********"
  begin
    time = Time.new
    rand_id = rand(999999999999).to_s.center(10, rand(9).to_s).to_i
    params = {client_id: "StonehouseSA",
              term: '00200',
              time: time,
              orig_time: vend_params[:time],
              rep_count: 0,
              seq_num: 2,
              reference: rand_id,
              orig_reference: vend_params[:reference],
              amount: vend_params[:amount],
              currency: vend_params[:currency],
              num_tokens: vend_params[:num_tokens],
              meter: vend_params[:meter],
              pay_type: vend_params[:pay_type]}
    vend_rev_response = ipay.vend_reverse_request(params)
    vend_rev_response = ipay.vend_reverse_request(params)
    p "vend_rev_response = #{vend_rev_response}"
  rescue Net::TCPClient::ReadTimeout => e
    if retries < 2
      puts "\tTrying #{2-retries} more times"
      retries += 1
      #ToDo: calc rep_count based on retries
      params[:rep_count] = retries
      params[:seq_num] += 1
      retry
    else
      puts "retry failed #{retries}x, this vend_rev_requests needs to be logged & queued to be reversed later."
    end
  end
else
  p "successfull"
end
