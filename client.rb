require "socket"

class Client

  Thread.abort_on_exception = true

  REGISTRATION = 'Type your username: '.freeze

  def initialize(server)
    @server = server
    @request = nil
    @response = nil
  end

  def run
    register
    get_messages
    send_message
    @request.join
    @response.join
  end

  def get_messages
    @response = Thread.new do
      loop do
        msg = @server.gets.chomp
        puts "#{msg}"
      end
    end
  end

  def register
    print REGISTRATION
    msg = $stdin.gets.chomp
    @server.puts msg
  end

  def send_message
    @request = Thread.new do
      loop do
        msg = $stdin.gets.chomp
        @server.puts msg
      end
    end
  end
end