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
  session.clear
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
  session['bag'] = 'ein Schlüssel<br>'
  show(:key01)
end

get '/door1' do
  if session['key'] == 1
    show(:raum2)
  else
   show(:doorclosed) 
  end
end

get '/schrank1' do
  if session['messer'] == 1
    show(:messerweg)
   else
     session['messer'] = 1
     session['bag'] += 'ein altes, rostiges Messer<br>'
     show(:messer1)
  end
end

get '/kisten1' do
  if session['goldbarren'] == 1
    show(:kisten1b)
  else
    show(:kisten1)    
  end
end 

get '/kisten1a' do
  if session['messer'] == 1
      session['geld'] = 10
      session['goldbarren'] = 1
      session['holzwolle'] = 1
      session['bag'] += 'ein Goldbarren<br>Holzwolle<br>zehn Euro<br>'
      show(:kisten1a)
  else
    show(:kisten1c)
  end
end

get '/bagpack' do
  if session['key'] == 1
    @bag = session['bag']
  else @bag = 'nichts'
  end
  @dings = show(:bagpack)
  erb :bagpack
end

get '/:room' do
  show(params[:room])
end



run Sinatra::Application
