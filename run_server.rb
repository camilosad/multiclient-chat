require_relative './server.rb'

chat_server = Server.new "localhost", 4000
chat_server.run