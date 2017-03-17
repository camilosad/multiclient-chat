require "socket"

class Client

  def initialize( server )
    @server = server
    @request = nil
    @response = nil
    listen
    send_message
  end

  def listen
    @response = Thread.new do
      loop do
        msg = @server.gets.chomp
        puts "#{msg}"
      end
    end
    @response.join
  end

  def send_message
    print "Username: "
    @request = Thread.new do
      loop do
        msg = $stdin.gets.chomp
        @server.puts msg
      end
    end
    @request.join
  end
end