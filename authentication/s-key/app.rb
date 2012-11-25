require 'digest'
require 'json'

require 'sinatra'
require 'daybreak'

before do
  @db = Daybreak::DB.new "s-key.db"
  @client_id = params[:client_id]
end

post '/initialize' do
  content_type :json

  secret = params[:secret]
  n      = params[:n]

  @db.set!("#{@client_id}_n", n)
  @db.set!("#{@client_id}_secret", secret)
end

get '/pre_sign_in' do
  content_type :json

  {n: @db["#{@client_id}_n"].to_i - 1}.to_json
end

post '/sign_in' do
  content_type :json

  secret = params[:secret]

  if (new_secret = Digest::MD5.hexdigest(secret)) == @db["#{@client_id}_secret"]
    @db.set!("#{@client_id}_secret", secret)
    @db.set!("#{@client_id}_n", @db["#{@client_id}_n"].to_i - 1)

    {authenticated: true}.to_json
  else
    {authenticated: false}.to_json
  end
end
