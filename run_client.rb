require_relative './client.rb'

client = Client.new "localhost", 4000
client.run