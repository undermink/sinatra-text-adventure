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
  session['key'] ||= '0'
  session['geld'] ||= 0
  session.clear
  erb :login
end

post '/welcome' do
  	session['geld']= 0
	if params["username"] != "" #and params["username"]=~/[a-zA-Z0-9_]*/
		session['name'] = params["username"]
  	else session['name']="Mr. X" end
    	@dings = show(:welcome)
  	erb :welcome
end

get '/raum1' do
  if session['key'] != '1'
    show(:raum1)
  else
    show(:raum1a)
  end
end

get '/key01' do
  if session['key'] != '1'
  session['key'] = '1'
  show(:key01)
  else
    '<h1 align=center>Raum 1</h1><p align="center"><br><br>Du findest nichts...<br>Der Raum ist leer.<br><br><a class="link" href="raum1">Verflixt!</a>'
  end
end

get '/door1' do
  if session['key'] == '1'
    show(:raum2)
  else
   show(:doorclosed) 
  end
end

get '/schrank1' do
  if session['messer'] == '1'
    show(:messerweg)
   else
     session['messer'] = '1'
#     session['bag'] += 'ein altes, rostiges Messer<br>'
     show(:messer1)
  end
end

get '/raum3' do
  if session['durchbruch'] != '1' && session['goldbarren'] != '1'
    show(:raum3)
  elsif session['durchbruch'] != '1' && session['goldbarren'] == '1'
    show(:raum3b)
  elsif session['durchbruch'] == '1' && session['goldbarren'] != '1'
    show(:raum3a)
  else show(:raum3c)
  end
end

get '/kisten1' do
  if session['goldbarren'] == '1'
    show(:kisten1b)
  else
    show(:kisten1)    
  end
end 

get '/kisten1a' do
  if session['messer'] == '1' 
      session['geld'] = 10
      session['goldbarren'] = '1'
      session['holzwolle'] = '1'
#      session['bag'] += 'ein Goldbarren<br>Holzwolle<br>zehn Euro<br>'
      show(:kisten1a)
  else
    show(:kisten1c)
  end
end

get '/fenster1' do
  if session['mottek'] != '1'
    show(:fenster1)
  else
    if session['durchbruch'] != '1'
      show(:fenster1b)
    else show(:fenster1c)
    end
  end
end

get '/mottek' do
  if session['durchbruch'] != '1'
    session['durchbruch'] = '1'
    show(:mottek1)
  else
    show(:mottek)
  end
end

get '/hamburger' do
  if session['wasser']!='1'
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
  if session['eimer'] != '1'
    show(:eimer1)
  elsif session['zig1'] !='1' && session['eimer'] == '1'
      show(:eimer1b)
  elsif session['zig1'] =='1' && session['eimer'] == '1'
      '<p align="center"><br><br>Dort wo die Zigarette lag ist nichts mehr.<br>Den Eimer hast Du auch schon...<br><br><a class="link" href="/raum5">zurück</a></p>'
  else
    show(:eimer1)
  end
end

get '/eimer1a' do
  session['eimer'] = '1'
#  session['bag']+= 'ein Eimer<br>'
  show(:eimer1a)
end

get '/zig1' do
  if session['zig1'] != '1'
    session['zig1'] = '1'
#    session['bag'] +='eine selbstgedrehte Zigarette<br>'
    show(:zig1)
  else
    '<p align="center"><br><br>Dort wo die Zigarette lag ist nichts mehr<br><br><a class="link" href="/raum5">zurück</a></p>'   
  end
end

get '/zig1a' do
  if session['feuer'] != '1'
    '<p align="center"><br><br>Du hast kein Feuer...<br><br><a class="link" href="/raum5">zurück</a></p>'
  else
    session['zig1'] = '2'
    '<p align="center"><br><br>Du rauchst die Zigarette...<br>Sie schmeckt sehr gut.<br>Leicht beflügelt gehst Du weiter.<br>Ein wohliges Gefühl breites sich in Dir aus.<br>"Zweitgolf, ...so ein witziger Name...", denkst Du.<br><br><a class="link" href="/raum5">zurück</a></p>'
  end
end

get '/raum6' do
  if session['key2'] == '1'
    show(:raum6a)
  else
    show(:raum6)
  end
end
 
get '/tisch1' do
  if session['key2'] != '1'
    session['key2'] = '1'
#    session['bag'] += 'ein großer, alter Schlüssel<br>'
    show(:tisch1)
  else 
    '<p align="center"><br><br>Der Tisch ist leer <br><br><a class="link" href="raum6">weiter</a> '
  end
end

get '/radio1' do
  session['kandahar'] = '1'
  show(:radio1)
end

get '/raum7' do
#  session['phones'] ='0'
#  session['map1'] ='0'
  if session['phones'] != '1' && session['map1'] != '1'
    show(:raum7)
  elsif session['phones'] != '1' && session['map1'] == '1' 
    show(:raum7a)
  elsif session['phones'] == '1' && session['map1'] != '1'
    show(:raum7b)
#  elsif session['phones'] == '1' && session['map1'] == '1'
  else show(:raum7c) 
  end
end

get '/schreibtisch1' do
  if session['map1'] != '1'
    session['map1'] = '1'
#    session['bag'] += '<a class="link" href="/map1">eine Karte</a><br>'
    show(:schreibtisch1)
  else
    '<p align="center"><br><br>Der Schreibtisch ist leer...<br>Er hat keine Schubladen oder weiteren Fächer.<br><br><a class="link" href="raum7">weiter</a> '
  end
end

get '/regal1' do
  session['phones'] = '1'
#  session['bag'] += 'ein Paar Kopfhörer<br>'
  if session['walkman'] != '1'
    show(:regal1)
  else
    show(:regal2)
  end
end

get '/raum8' do
  if session['map1'] != '1'
    show(:raum8)
  else
    show(:raum8a)
  end
end

get '/raum8b' do
  if session['walkman'] != '1' && session['phones'] != '1'
    session['walkman'] = '1'
    show(:raum8b)
  elsif session['walkman'] != '1' && session['phones'] == '1'
    session['walkman'] = '1'
    show(:raum8c)
  elsif session['walkman'] == '1' 
    '<p align="center"><br><br>Auf dem Boden liegt nichts mehr...<br><br><a href="#" onclick="history.go(-1)">Ok</a> :/</p></a>'
  end
end

get '/walkman' do
  if session['walkman'] != '1'
    '<p align="center"><br><br>Leider hast Du keinen Walkman...<br><br><a href="#" onclick="history.go(-1)">Zurück</a></p></a>'
  elsif session['phones'] != '1'
    '<p align="center"><br><br>Leider hast Du keine Köpfhörer...<br><br><a href="#" onclick="history.go(-1)">Zurück</a></p></a>'
  else
    erb :walkman
  end
end

get '/schrank2' do
  if session['mottek'] != '1'
    session['mottek'] = '1'
#    session['bag'] += 'ein Mottek<br>'
    show(:schrank2)
  else
    show(:schrank2a)
  end
end

get '/raum10' do
  if session['intro'] != '1'
    show(:raum10)
  else
    show(:raum10a)
  end
end

get '/raum10b' do
  session['telefon'] = 1
  if session['intro'] != '1'
    session['intro'] = '1'
#    session['bag'] += 'eine Kassette<br>'
    show(:raum10b)
  else
  '<p align="center"><br><br>Der Raum ist absolut leer...<br>Das einzig interessante ist das Treppenhaus...<br><br><a class="link" href="raum10a">ok</a> '  
  end
end

get '/telefon' do
  if session['arrogant'] != '1' && session['telefon'] != 3
      session['telefon']+=1
      pp session['telefon'] 
      show(:telefon1)
  elsif session['arrogant'] != '1' && session['telefon'] == 3
      session['arrogant'] = '1'
      show(:arrogant) 
  elsif session['arrogant'] == '1'
    erb :telefon
  end
end

post '/telefonieren' do
  if params['nummer'] == '110'
    session['polizei'] = '1'
    show(:polizei)
  elsif params['nummer'] == '112' || params['nummer'] == '911'
    show(:notruf)
  elsif params['nummer'] == '666'
    show(:satan)
  elsif params['nummer'] == ''
    pp'<p align="center"><br><br>Du h&ouml;rst das Freizeichen...<br><br>Scheinbar ein A.<br>Du lauscht noch ein Wenig und legst dann wieder auf.<br><br><a class="link" href="raum22">ok</a>'
  else pp'<p align="center"><br><br>Es tutet...<br><br>Niemand antwortet.<br>Du wartest noch eine Weile und legst dann wieder auf.<br><br><a class="link" href="raum22">ok</a>'
  end
end

get '/raum22' do
  if session['arrogant'] != '1'
    show(:raum22)
  else
    show(:raum22a)
  end
end

get '/raum23' do
  if session['entfinden'] != '1'
    show(:raum23)
  else
    show(:raum23a)
  end
end

get '/kaefig' do
  if session['entfinden'] != '1'
    show(:kaefig)
  else
    redirect 'kaefig1'
  end
end

get '/kaefig1' do
  if session['entfinden'] != '1'
    session['entfinden'] = '1'
    show(:kaefig1)
  elsif session['map2'] != '1'
    session['map2'] = '1'
    show(:kaefig1a)
  else
     '<p align="center"><br><br>Du hast den Vogel bereits frei gelassen...<br>Der Käfig ist leer.<br><br><a class="link" href="raum23a">ok</a>'
  end
end

get '/raum24a' do
  if session['dieter'] != '1'
    session['dieter'] = '1'
    '<h1 align=center>Raum 4 EG</h1><p align="center"><br><br>In einer unbeleuchteten Ecke des Raumes<br>findest Du einen Notizzettel, auf dem steht:<br><br>   "Dieter: 505151"<br><br>Du steckst ihn ein.<br><br><a class="link" href="raum24">ok</a>'
  else 
    '<p align="center"><br><br>Der Raum ist leer...<br><br><a class="link" href="raum24">ok</a>'
  end
end

get '/raum25' do
  if session['key3'] != '1'
    '<h1 align=center>Raum 5 EG</h1><p align="center"><br><br>Die Tür zum 5. Raum ist verschlossen...<br><br><a class="link" href="raum24">Mist!</a>'
  else
    show(:raum25)
  end
end

get '/raum26' do
  @linesp='Du bist jetzt im sechsten Raum im Erdgeschoss.<br><br>Möchtest Du:<br><br>
  <a class="link" href="fenster3">Zum Fenster gehen?</a><br><a class="link" href="raum26a">Den Raum durchsuchen?</a><br><a class="link" href="bagpack">Deinen Rucksack durchsuchen?</a><br><a class="link" href="raum28">Durch die Tür gehen?</a><br><a class="link" href="raum24">Zurück in den vierten Raum?</a>'
  erb :raum26
end

get '/raum26a' do
  @linesp='<br>Du durchsuchst den Raum...<br>Hier im Raum ist ein Fenster und eine weitere Tür.<br>Möchtest Du:<br><br>
  <a class="link" href="fenster3">Zum Fenster gehen?</a><br><a class="link" href="bagpack">Deinen Rucksack durchsuchen?</a><br><a class="link" href="raum28">Durch die Tür gehen?</a><br><a class="link" href="raum24">Zurück in den vierten Raum?</a>'
  erb :raum26
end

get '/fenster3' do
  if session['fenster3'] != '1'
    show(:fenster3)
  else
    show(:fenster3c)
  end
end

get '/fenster3a' do
  if session['fenster3'] != '1'
    session['fenster3'] = '1'
    '<h1 align=center>Raum 6 EG: Am Fenster</h1><p align="center"><br><br>Du ziehst kräftig an dem Band und das Rollo bewegt sich einige Zentimeter nach oben.<br>Dann reißt der Zug und die Rolladen krachen runter.<br><br><a class="link" href="fenster3">Verdammt!</a>'
  else
    '<h1 align=center>Raum 6 EG: Am Fenster</h1><p align="center"><br><br>Du kommst beim besten Willen nicht mehr an das Ende vom Band und<br>kannst das Rollo darum nicht mehr bewegen.<br><br><a class="link" href="raum26">Och nö!</a> :('
  end
end

get '/kiste2' do
  if session['seil'] != '1'
    session['seil'] = '1'
    show(:kiste2)
  else
    '<h1 align=center>Raum 8 EG: Die Kiste</h1><p align="center"><br><br>Die Kiste ist leer.<br><br><a class="link" href="raum28">Hmpf...</a>'
  end
end

get '/kiste2a' do
  if session['messer'] == '1'
    session['seil'] = '1'
    show(:kiste2a)
  else
    '<h1 align=center>Raum 8 EG: Die Kiste</h1><p align="center"><br><br>Leider hast Du kein geeignetes Werkzeug dabei...<br><br><a class="link" href="raum28">Kacke!</a>'
  end
end

get '/schrank3' do
  if session['feuer'] != '1'
    session['feuer'] = '1'
    '<h1 align=center>Raum 8 EG: Der Schrank</h1><p align="center"><br><br>Im Schrank liegt ein Feuerzeug.<br>Du steckst es ein...<br><br><a class="link" href="raum28">ok</a>'
  else
    '<h1 align=center>Raum 8 EG: Der Schrank</h1><p align="center"><br><br>Der Schrank ist leer...<br><br><a class="link" href="raum28">ok</a>'
  end
end

get '/raum29a' do
  if session['draht'] != '1'
    session['draht'] = '1'
    show(:raum29a)
  else 
    show(:raum29b)
  end
end

get '/raum32' do
  if session['fenster4'] != '1' && session['seil'] != '2'
    show(:raum32)
  elsif session['fenster4'] == '1' && session['seil'] != '2'
    show(:raum32a)
  elsif session['fenster4'] == '2' && session['seil'] == '2'
    show(:raum32c)
  end
end

get '/fenster4' do
  if session['fenster4'] == '1' && session['seil'] != '1'
    show(:fenster4a)
  elsif session['fenster4'] == '1' && session['seil'] == '1'
    show(:fenster4c)
  else
    show(:fenster4)
  end
end

get '/fenster4a' do
  if session['fenster4'] != '1' && session['seil'] != '1'
    session['fenster4'] = '1'
    show(:fenster4a)
  elsif session['fenster4'] != '1' && session['seil'] == '1'
    session['fenster4'] = '1'
    show(:fenster4c)
  else 
    show(:fenster4)
  end
end

get '/fenster4b' do
  if session['fenster4'] == '1'
    session['fenster4'] = '0'
    show(:raum32)
  else
    show(:fenster4)
  end
end

get '/fenster4d' do
  if session['seil'] == '1' && session['fenster4'] == '1'
    session['seil'] = '2'
    session['fenster4'] = '2'
    show(:fenster4d)
  else
    show(:fenster4d)
  end
end

get '/regal3' do
  if session['key4'] != '1'
    session['key4'] = '1'
    '<h1 align=center>Raum 2 1.OG: Das LagerRegal</h1><p align="center"><br><br>Auf dem Regal liegt ein Schlüssel.<br>Du steckst ihn ein<br><br><a class="link" href="raum32">ok</a> :)'
  else
    '<h1 align=center>Raum 2 1.OG: Das LagerRegal</h1><p align="center"><br><br>Das Regal ist leer...<br><br><a class="link" href="raum32">na gut</a> :/'
  end
end

get '/jump' do
  session.clear
  session['key'] ||= '0'
  session['geld'] ||= 0
  show(:jump)
end

get '/rauchen' do
  if session['zig1'] == '1'
  session['zig1'] = '2'
  erb :rauchen
  else '<h1 align=center>Die selbstgedrehte Zigarette</h1><p align="center"><br><br>Du bist Dir nicht mehr sicher,<br>ob Du die selbstgedrehte Zigarette schon geraucht hast,<br>kannst sie aber nirgends finden...<br><br><a class="link" href="bagpack">im Rucksack nachsehen</a>'
  end
end

get '/bagpack' do
#  @bag=session.keys.map{|k|translate(k)+" "+translate(session[k])}.join(", ")
#  if @bag==""
#    @bag='nichts'
#  end

  if session['key'] != '1'
  	inventar = 'noch nichts...'
  end
#  @dings = show(:bagpack)

  erb :bagpack
end

get '/:room' do
  show(params[:room])
end



run Sinatra::Application
