class User

  attr_reader :username, :client

  def initialize(username, client)
    @username = username
    @client = client
  end

  def client_info
    @client.addr
  end

end