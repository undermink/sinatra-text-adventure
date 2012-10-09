require './parse.rb'
require 'sinatra'

enable :sessions

helpers do
  def show(room)
    @room=$rooms.select{|r|r.name==room.to_s}[0]
    erb :room
  end
end

get '/' do
  session['key'] ||= 0
  erb :login
end

post '/welcome' do
  if params["username"] != "" #and params["username"]=~/[a-zA-Z0-9_]*/
  @username = params["username"]
  else @username="Mr. X" end
    @dings = show(:welcome)
  erb :welcome
end

get '/key01' do
  session['key'] = 1
  show(:key01)
end

get '/door1' do
  if session['key'] == 1
    show(:raum2)
  else
   show(:doorclosed) 
  end
end

get '/bagpack' do
  if session['key'] == 1
    @bag= 'ein Schlüssel'
  else @bag = 'nichts'
  end
    @dings = show(:bagpack)
    erb :bagpack
end

get '/:room' do
  show(params[:room])
end



run Sinatra::Application
