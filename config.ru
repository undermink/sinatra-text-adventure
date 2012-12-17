require './parse.rb'
require 'sinatra'

enable :sessions

helpers do
  def show(room)
    @room=$rooms.select{|r|r.name==room.to_s}[0]
    erb :room
  end

  def translate(key)
    key=key.to_s
    hash={"key"=>"Schlüssel","1"=>"ein","gold"=>"Goldbarren"}
    if hash[key]
      hash[key]
    else
      "____"+key
    end
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

get '/hamburger' do
  if session['wasser']=='0'
    show(:hamburger)
  else show(:hamburger2)
  end
end

get '/hamburger1' do
  if session['wasser'] == '0' 
    session['wasser']='1'
    show(:hamburger1)
  else
  if session['wasser'] == '1'
    session['wasser']='0'
    show(:hamburger1a)
  else
    session['wasser']='1'
    show(:hamburger1)
  end
  end
end

get '/eimer1' do
  if session['eimer'] == '1'
    '<p align="center">Der Eimer ist weg...<br><br><a class="link" href="/raum5">zurück</a></p>'
  else
    show(:eimer1);
  end
end

get '/eimer1a' do
  session['eimer'] = '1'
  session['bag']+= 'ein Eimer<br>'
  show(:eimer1a)
end

get '/bagpack' do
#  @bag=session.keys.map{|k|translate(k)+" "+translate(session[k])}.join(", ")
#  if @bag==""
#    @bag='nichts'
#  end

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
