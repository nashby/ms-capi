require 'httparty'
require 'digest'

class Client
  include HTTParty

  base_uri 'localhost:4567'
  format :json

  attr_reader :n, :secret, :key

  def initialize(id, n, key)
    @n = n
    @id = id
    @key = key
  end

  def initial_phase
    @secret = @key

    @n.times do
      @secret = Digest::MD5.hexdigest(@secret)
    end

    self.class.post('/initialize', body: { secret: @secret, n: @n, client_id: @id })
  end

  def get_counter
    @n = self.class.get('/pre_sign_in', body: { client_id: @id }).parsed_response["n"].to_i
  end

  def sign_in
    @secret = @key

    @n.times do
      @secret = Digest::MD5.hexdigest(@secret)
    end

    p self.class.post('/sign_in', body: { secret: @secret, client_id: @id }).parsed_response
  end
end

client = Client.new(666, 1000, 'matz is nice so we are nice')
client.initial_phase

# first sign in
client.get_counter
client.sign_in

# second sign in
client.get_counter
client.sign_in

# ...
