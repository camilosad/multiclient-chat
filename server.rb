require "socket"

class Server

  # system messages
  USERNAME_ALREADY_TAKEN = "This username already exist".freeze
  NEW_CONNECTION = 'New user connected: '.freeze
  SUCCESSFULLY_CONNECTED = 'Successfully connected!'.freeze
  SERVER_RUNNING = 'Server started successfully. Waiting for clients to connect...'.freeze


  def initialize(ip, port)
    @server = TCPServer.open(ip, port)
    @connections  = {}
    @clients = {}
    @connections[:server] = @server
    @connections[:clients] = @clients
  end

   def run
    puts SERVER_RUNNING
    loop do
      # for each user connected and accepted by server, it will create a new thread object
      # and which pass the connected client as an instance to the block
      Thread.start(@server.accept) do | client |
        username = get_username client
        unless can_create_client username, client
          send_alert_to_client client, USERNAME_ALREADY_TAKEN
          Thread.kill self
        end
        create_client username, client
        show_connection username, client
        send_alert_to_client client, SUCCESSFULLY_CONNECTED
        listen_to_user username, client
      end
    end
  end

  private

  def listen_to_user(username, client)
    loop do
      msg = client.gets.chomp
      send_broadcast_message username, msg
    end
  end

  def send_broadcast_message(username, message)
    @connections[:clients].each do |other_name, other_client|
      unless other_name == username
        other_client.puts formatted_message username, message
      end
    end
  end

  def formatted_message(username, message)
    "#{Time.now} - #{username.to_s}: #{message}"
  end

  def can_create_client(username, client)
    return check_uniqueness username, client
  end

  def get_username(client)
    client.gets.chomp.to_sym
  end

  def create_client(username, client)
    @connections[:clients][username] = client
  end

  def send_alert_to_client(client, alert_message)
    client.puts alert_message
  end

  def check_uniqueness(nick_name, client)
    @connections[:clients].each do |other_name, other_client|
      return false if nick_name == other_name || client == other_client
    end
    return true
  end

  def show_connection(username, client)
    puts NEW_CONNECTION, "#{client} as #{username}"
  end
end