require 'socket'
delay = 10

server = TCPServer.new 2000

loop do
  begin
    client = server.accept
    puts "#{Time.now} > Client arrived. Sleeping for #{delay}s."
    sleep delay
    puts "#{Time.now} > Done, replying."
    client.puts "Done. Bye!"
    client.close
  rescue Errno::EPIPE => exception
    p "Looks like the client disconnected."
    p exception.message
  end
end
