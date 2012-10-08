require './parse.rb'
require 'sinatra'

helpers do
  def show(room)
    @room=$rooms.select{|r|r.name==room.to_s}[0]
    erb :room
  end
end

get '/' do
  @key1=0
  erb :login
end

post '/welcome' do
  if params["username"] != "" #and params["username"]=~/[a-zA-Z0-9_]*/
  @username = params["username"]
  else @username="Mr. X" end
  pp @username
  show(:welcome)
end

get '/key01' do
  @key1=1
  pp @key1
  show(:key01)
end

get '/door1' do
  pp @key1
  if @key1==1
    show(:raum2)
   else 
     show(:doorclosed)
  end
end

get '/:room' do
  show(params[:room])
end

run Sinatra::Application
