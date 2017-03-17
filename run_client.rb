require_relative './client.rb'


server = TCPSocket.open "localhost", 4000
client = Client.new server
client.run