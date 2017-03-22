require "socket"
require_relative './user.rb'

class Server

  # system messages
  USERNAME_ALREADY_TAKEN = "Username already taken, please try again with another one.".freeze
  NEW_CONNECTION = 'New user connected'.freeze
  SUCCESSFULLY_CONNECTED = 'Successfully connected!'.freeze
  SERVER_RUNNING = 'Server started successfully. Waiting for clients to connect...'.freeze
  CONNECTIONS_COUNTER = 'Connections: '.freeze


  def initialize(ip, port)
    @server = TCPServer.open(ip, port)
    @connections  = []
  end

   def run
    puts SERVER_RUNNING

    loop do
      Thread.start(@server.accept) do | client |

        username = get_username client
        user = User.new username, client

        unless can_create_user user
          send_message_to_user user, USERNAME_ALREADY_TAKEN
          Thread.kill self
        end

        create_connection user
        listen user
      end
    end

  end

  private

  def listen(user)
    loop do
      msg = user.client.gets.chomp
      send_broadcast_message user, msg
    end
  end

  def send_broadcast_message(sender, message)
    @connections.each do |user|
      user.client.puts formatted_message sender.username, message unless user.username == sender.username
    end
  end

  def formatted_message(username, message)
    "#{Time.now} - #{username}: #{message}"
  end

  def can_create_user(user)
    return unique? user.username
  end

  def get_username(client)
    client.gets.chomp.to_sym
  end

  def create_connection(user)
    @connections.push user
    show_connection user
    show_connections_counter
    send_message_to_user user, SUCCESSFULLY_CONNECTED
  end

  def send_message_to_user(user, message)
    user.client.puts message
  end

  def unique?(username)
    user = @connections.find { |user| user.username == username }
    user.nil? ? true : false
  end

  def show_connection(user)
    puts "#{NEW_CONNECTION}: #{user.client_info} as #{user.username}"
  end

  def show_connections_counter
    puts "#{CONNECTIONS_COUNTER} #{@connections.count}"
  end
end