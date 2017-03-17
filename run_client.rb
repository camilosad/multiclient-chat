require_relative './client.rb'


server = TCPSocket.open "localhost", 4000
Client.new server