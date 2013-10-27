require './parse.rb'
require 'sinatra'

#enable :sessions
#disable :protection
set :show_exceptions, false
use Rack::Session::Cookie, :key => 'rack.session',
                           :domain => 'zweitgolf.tk',
                           :path => '/',
                           :expire_after => 2592000, # In seconds
                           :secret => 'zweitgolf'
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

  def bpchk(load)
    pp load
    if load.to_i >= 105.to_i then
      pp 'trigger.....................'
      redirect 'voll'
    end
  end

  def truhenchk(stuff,weight)
    pp stuff
    if stuff != 'truhe'
      stuff = 'truhe'
      session['bag'] -= weight
    elsif stuff == 'truhe'
      stuff = '1'
      session['bag'] += weight      
    end
    pp stuff
    return stuff
  end
end

error 400..510 do
  show(:what)
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
  unless ['1','2'].member?(session['key'])
    show(:raum1)
  else
    show(:raum1a)
  end
end

get '/key01' do
  unless ['1','2'].member?(session['key'])
    session['bag'] = 5
    session['key'] = '1'
    show(:key01)
  else
    '<h1 align=center>erster Raum</h1><p align="center"><br><br>Du findest nichts...<br>Bis auf die beiden leeren Bierflaschen ist<br>der Raum leer.<br><br><a class="link" href="raum1">Verflixt!</a>'
  end
end

get '/door1' do
  if session['key'] == '1'
    session['key'] = '2'
    session['bag'] -= 5
    show(:raum2)
  elsif session['key'] == '2'
    show(:raum2)
  else
   show(:doorclosed) 
  end
end

get '/schrank1' do
  bpchk(session['bag'])
  if session['messer'] == '1'
    show(:messerweg)
   else
     session['messer'] = '1'
     session['bag'] += 5
     pp session['bag']
     show(:messer1)
  end
end

get '/raum3' do
  if session['durchbruch'] != '1' && !['1','truhe'].member?(session['goldbarren'])
    show(:raum3)
  elsif session['durchbruch'] != '1' && ['1','truhe'].member?(session['goldbarren']) 
    show(:raum3b)
  elsif session['durchbruch'] == '1' && !['1','truhe'].member?(session['goldbarren'])
    show(:raum3a)
  else show(:raum3c)
  end
end

get '/kisten1' do
  if ['1','truhe'].member?(session['goldbarren'])
    show(:kisten1b)
  else
    show(:kisten1)    
  end
end 

get '/kisten1a' do
  bpchk(session['bag'])
  if session['messer'] == '1' 
      session['geld'] = 10
      session['goldbarren'] = '1'
      session['holzwolle'] = '1'
      session['bag'] += 25 + 10
      pp session['bag']
      show(:kisten1a)
  else
    show(:kisten1c)
  end
end

get '/fenster1' do
  if ['1','2'].member?(session['mottek'])
    if session['durchbruch'] != '1'
      show(:fenster1b)
    else
      show(:fenster1c)
    end
  else
    show(:fenster1)
  end
end

get '/mottek' do
  if session['durchbruch'] != '1'
    session['bag'] -= 25
    session['mottek'] = '2'
    session['durchbruch'] = '1'
    show(:mottek1)
  else
    show(:mottek)
  end
end

get '/waschbecken' do
  erb :waschbecken
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
  bpchk(session['bag'])  
  if !['1','2'].member?(session['eimer'])
    show(:eimer1)
  elsif session['zig1'] !='1' && ['1','2'].member?(session['eimer'])
      show(:eimer1b)
  elsif ['1','2'].member?(session['zig1']) && ['1','2'].member?(session['eimer'])
      '<p align="center"><br><br>Dort wo die Zigarette lag ist nichts mehr.<br>Den Eimer hast Du auch schon...<br><br><a class="link" href="/raum5">zurück</a></p>'
  else
    show(:eimer1)
  end
end

get '/eimervoll' do
  if session['eimer'] != '2'
    session['eimer'] = '2'
    session['bag'] += 50
    show(:eimervoll)
  else
    show(:eimervoll1)
  end
end

get '/eimer1a' do
  bpchk(session['bag'])
  session['eimer'] = '1'
  session['bag'] += 20
  pp session['bag']
  show(:eimer1a)
end

get '/zig1' do
  bpchk(session['bag'])
  if session['zig1'] != '1'
    session['zig1'] = '1'
    session['bag'] += 5
    pp session['bag']
    show(:zig1)
  else
    '<p align="center"><br><br>Dort wo die Zigarette lag ist nichts mehr<br><br><a class="link" href="/raum5">zurück</a></p>'   
  end
end

get '/zig1a' do
  if session['feuer'] != '1'
    '<p align="center"><br><br>Du hast kein Feuer...<br><br><a class="link" href="/raum5">zurück</a></p>'
  else
    session['bag'] -= 5
    session['zig1'] = '2'
    erb :rauchen
#    '<p align="center"><br><br>Du rauchst die Zigarette...<br>Sie schmeckt sehr gut.<br>Leicht beflügelt gehst Du weiter.<br>Ein wohliges Gefühl breites sich in Dir aus.<br>"Zweitgolf, ...so ein witziger Name...", denkst Du.<br><br><a class="link" href="/raum5">zurück</a></p>'
  end
end

get '/raum6' do
  if session['key2'] == '1'
    show(:raum6a)
  elsif
    session['key2'] == '2'
    show(:raum6a)
  else
    show(:raum6)
  end
end
 
get '/tisch1' do
  bpchk(session['bag'])
  if session['key2'] != '1'
    session['key2'] = '1'
    session['bag'] += 5
    pp session['bag']
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
  if session['phones'] != '1' && !['1','truhe'].member?(session['map1'])
    show(:raum7)
  elsif session['phones'] != '1' && ['1','truhe'].member?(session['map1'])
    show(:raum7a)
  elsif session['phones'] == '1' && !['1','truhe'].member?(session['map1'])
    show(:raum7b)
#  elsif session['phones'] == '1' && session['map1'] == '1'
  else show(:raum7c) 
  end
end

get '/schreibtisch1' do
  bpchk(session['bag'])
  unless ['1','truhe'].member?(session['map1'])
    session['map1'] = '1'
     session['bag'] += 1
    show(:schreibtisch1)
  else
    '<p align="center"><br><br>Der Schreibtisch ist leer...<br>Er hat keine Schubladen oder weiteren Fächer.<br><br><a class="link" href="raum7">weiter</a> '
  end
end

get '/regal1' do
  bpchk(session['bag'])
  session['phones'] = '1'
     session['bag'] += 5
     pp session['bag']
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
  bpchk(session['bag'])
  if session['walkman'] != '1' && session['phones'] != '1'
    session['walkman'] = '1'
    session['bag'] += 5
    pp session['bag']
    show(:raum8b)
  elsif session['walkman'] != '1' && session['phones'] == '1'
    session['walkman'] = '1'
    session['bag'] += 5
    pp session['bag']
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
  bpchk(session['bag'])
  unless ['1','2'].member?(session['mottek'])
    session['mottek'] = '1'
    session['bag'] += 25
    pp session['bag']
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
    session['bag'] += 2
    session['intro'] = '1'
    show(:raum10b)
  else
  '<p align="center"><br><br>Der Raum ist absolut leer...<br>Das einzig interessante ist das Treppenhaus...<br><br><a class="link" href="raum10a">ok</a> '  
  end
end

get '/telefon' do
  if !session['telefon']
    session['telefon'] = 0
  end 
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
  elsif params['nummer'] == '702300' || params['nummer'] == '0202702300'
    #session['poller'] = 0
    redirect 'poller'
  elsif params['nummer'] == ''
    pp'<p align="center"><br><br>Du h&ouml;rst das Freizeichen...<br><br>Scheinbar ein A.<br>Du lauscht noch ein Wenig und legst dann wieder auf.<br><br><a class="link" href="raum22">ok</a>'
  else pp'<p align="center"><br><br>Es tutet...<br><br>Niemand antwortet.<br>Du wartest noch eine Weile und legst dann wieder auf.<br><br><a class="link" href="raum22">ok</a>'
  end
end

get '/poller' do
  pp session['poller']
  if !session['poller'] then session['poller'] = 0 end 
  session['poller'] += 1
  if session['poller'] >= 6
    '<p align="center"><br><br>Es tutet...<br><br>Niemand antwortet.<br>Du wartest noch eine Weile und legst dann wieder auf.<br><br><a class="link" href="raum22">ok</a>'
  else
    erb :poller
  end
end

get '/poller1' do
  if !session['poller'] then session['poller'] = 0 end
  pp session['poller']
  session['poller'] += 5
  erb :poller
end

get '/raum22' do
  if session['arrogant'] != '1'
    show(:raum22)
  else
    show(:raum22a)
  end
end

get '/raum23' do
  if session['sonnenherzen'] != '1'
    show(:raum23)
  else
    show(:raum23a)
  end
end

get '/fenster2' do
  pp session['typ']
  if session['typ'] == 9
    session['typ'] = 10
    show(:fenster2a)
  elsif session['typ'] == 10
    show(:fenster2b)
  else
    show(:fenster2)
  end
end

get '/kaefig' do
  if session['sonnenherzen'] != '1'
    show(:kaefig)
  else
    redirect 'kaefig1'
  end
end

get '/kaefig1' do
  if session['sonnenherzen'] != '1'
    session['sonnenherzen'] = '1'
    show(:kaefig1)
  elsif session['map2'] != '1'
    bpchk(session['bag'])
    session['map2'] = '1'
    session['bag'] += 1
    pp session['bag']
    show(:kaefig1a)
  else
     '<p align="center"><br><br>Du hast den Vogel bereits frei gelassen...<br>Der Käfig ist leer.<br><br><a class="link" href="raum23a">ok</a>'
  end
end

get '/raum24a' do
  bpchk(session['bag'])
  if session['dieter'] != '1'
    session['dieter'] = '1'
     session['bag'] += 1
     pp session['bag']    
    '<h1 align=center>Raum 4 EG</h1><p align="center"><br><br>In einer unbeleuchteten Ecke des Raumes<br>findest Du einen Notizzettel, auf dem steht:<br><br>   "Dieter: 505151"<br><br>Du steckst ihn ein.<br><br><a class="link" href="raum24">ok</a>'
  else 
    '<p align="center"><br><br>Der Raum ist leer...<br><br><a class="link" href="raum24">ok</a>'
  end
end

get '/raum25' do
  if session['key2'] == '1'
    session['key2'] = '2'
    session['bag'] -= 5
    show(:raum25)
  elsif session['key'] == '2' 
    show(:raum25)
  else
    '<h1 align=center>Raum 5 EG</h1><p align="center"><br><br>Die Tür zum 5. Raum ist verschlossen...<br><br><a class="link" href="raum24">Mist!</a>'
    
  end
end

get '/rad' do
  if session['wrad'] != '1'
    session['wrad'] = '1'
    '<h1 align=center>Der Heizungskeller</h1><p align="center"><br><br>Du drehst das große Rad und hörst Wasser rauschen.<br>Wofür das wohl gut war?<br><br><a class="link" href="raum25">hm...ok</a>'
  else
    session['wrad'] = '0'
    '<h1 align=center>Der Heizungskeller</h1><p align="center"><br><br>Du drehst das große Rad und es wird wieder still.<br>Jetzt ist der Wasserzulauf wieder unterbrochen<br><br><a class="link" href="raum25">Sehr gut!</a>'
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
  unless ['1','2'].member?(session['seil'])
    show(:kiste2)
  else
    '<h1 align=center>Raum 8 EG: Die Kiste</h1><p align="center"><br><br>Die Kiste ist leer.<br><br><a class="link" href="raum28">Hmpf...</a>'
  end
end

get '/kiste2a' do
  bpchk(session['bag'])
  if session['messer'] == '1'
    session['seil'] = '1'
    session['bag'] += 20
    pp session['bag']
    show(:kiste2a)
  else
    '<h1 align=center>Raum 8 EG: Die Kiste</h1><p align="center"><br><br>Leider hast Du kein geeignetes Werkzeug dabei...<br><br><a class="link" href="raum28">Kacke!</a>'
  end
end

get '/schrank3' do
  bpchk(session['bag'])
  if session['feuer'] != '1'
    session['bag'] += 2
    session['feuer'] = '1'
    '<h1 align=center>Raum 8 EG: Der Schrank</h1><p align="center"><br><br>Im Schrank liegt ein Feuerzeug.<br>Du steckst es ein...<br><br><a class="link" href="raum28">ok</a>'
  else
    '<h1 align=center>Raum 8 EG: Der Schrank</h1><p align="center"><br><br>Der Schrank ist leer...<br><br><a class="link" href="raum28">ok</a>'
  end
end

get '/raum29a' do
  bpchk(session['bag'])
  unless ['1','truhe'].member?(session['draht'])
    session['bag'] += 3
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
  elsif session['seil'] == '2'
    session['fenster4'] = '2'
    show(:raum32c)
  end
end

get '/fenster4' do
  if session['fenster4'] == '1' && session['seil'] != '1'
    show(:fenster4a)
  elsif session['fenster4'] == '1' && session['seil'] == '1'
    show(:fenster4c)
  elsif session['seil'] == '2'
    show(:fenster4d)
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
    session['bag'] -= 20
    session['fenster4'] = '2'
    show(:fenster4d)
  else
    show(:fenster4d)
  end
end

get '/regal3' do
  bpchk(session['bag'])
  unless ['1','2'].member?(session['key4'])
    session['key4'] = '1'
    session['bag'] += 5
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

get '/raum33a' do
  if session['key3'] != '1' && session['stuhl1'] != '1'
    show(:raum33a)
  elsif session['key3'] != '1' && session['stuhl1'] == '1'
    show(:raum33a1)
  elsif session['key3'] == '1' && session['stuhl1'] != '1'
    show(:raum33b) 
  elsif session['key3'] == '1' && session['stuhl1'] == '1'
     show(:raum33b1)
  else show(:raum33a)
  end
end

get '/schrank4' do
  bpchk(session['bag'])
  unless ['1','2'].member?(session['key3'])
    session['bag'] += 2
    session['key3'] = '1'
    show(:schrank4)
  else
    '<h1 align=center>Raum 3 1.OG: Das Hängeschränkchen</h1><p align="center"><br><br>Das Schränkchen ist leer...<br><br><a class="link" href="raum33a">hmm...</a> :/'
  end
end

get '/schreibtisch2' do
  unless ['1','truhe'].member?(session['unterlagen'])
    show(:schreibtisch2)
  else
    show(:schreibtisch2a)
  end
end

get '/stuhl1' do
   erb :stuhl1
end

get '/unterlagen' do
  bpchk(session['bag'])
  session['bag'] += 10
  session['unterlagen'] = '1'
  '<h1 align=center>Raum 3 1.OG: Der Schreibtisch</h1><p align="center"><br><br>Du steckst die sinnlosen Unterlagen ein...<br><br><a class="link" href="schreibtisch2a">gut...</a>'
end

get '/stfach' do
  erb :stfach
end

get '/brief' do
  if session['brief'] != '1'
    session['bag'] += 2
    session['brief'] = '1'
    '<h1 align=center>Der Brief</h1><p align="center"><br><br>Du liest den Brief und steckst ihn ein...<br><br><a class="link" href="stfach">weiter</a> =)'
  else
    session['bag'] -= 2
    session['brief'] = '0'
    '<h1 align=center>Der Brief</h1><p align="center"><br><br>Du legst den Brief zurück...<br><br><a class="link" href="stfach">weiter</a> =)'
  end
end

get '/schatulle' do
  bpchk(session['bag'])
  if session['map3'] != '1'
    session['map3'] = '1'
     session['bag'] += 1
     pp session['bag']
    '<h1 align=center>Die Schatulle</h1><p align="center"><br><br>In der Schatulle ist eine Karte.<br>Du steckst sie ein...<br><br><a class="link" href="stfach">ok</a>'
  else
    '<h1 align=center>Die Schatulle</h1><p align="center"><br><br>Die Schatulle ist leer...<br><br><a class="link" href="stfach">ok</a>'
  end
end

get '/schublade' do
  if session['messer'] == '1'
    session['geld'] += 100
    session['schublade'] = '1'
    '<h1 align=center>Die Schublade</h1><p align="center"><br><br>Du schaffst es, mit Hilfe des rostigen Messers<br>die Schublade aufzubrechen.<br>Darin liegt ein Hundert-Euro-Schein.<br>Du steckst ihn ein.<br><br><a class="link" href="stfach">Hmkay...</a>'
  else
    '<h1 align=center>Die Schublade</h1><p align="center"><br><br>Leider hast Du nicht das geeignete Werkzeug dafür.<br>Du bräuchtest etwas wie ein Messer.<br><br><a class="link" href="stfach">Grr</a>'
  end
end

get '/wandteppich' do
  if session['key4'] != '2'
    show(:wandteppich)
  else 
    show(:raum34a)
  end
end

get '/raum34' do
  if session['key4'] == '1'
    session['key4'] = '2'
    session['bag'] -= 5
    show(:raum34)
  elsif session['key4'] == '2'
    show(:raum34a)
  else
    show(:doorclosed)
  end
end

get '/raum35' do
  if session['key3'] == '1'
    session['bag'] -= 5
    session['key3'] = '2'
    show(:raum35)    
  elsif session['key3'] == '2' 
    show(:raum35a)
  else
    show(:doorclosed)
  end
end

get '/schrank5' do
  if session['geb'] != '1'
    session['geb'] ='1'
    show(:schrank5)
  else
    '<h1 align=center>Der Schrank</h1><p align="center"><br><br>Der Schrank ist leer.<br><br><a class="link" href="raum35b">OK</a>'
  end
end

get '/einloggen' do
  erb :einloggen
end

post '/log' do
  if params['name'] == 'Dieter' && params['pw'] == '505151'
    erb :loggedin
  else '<h1 align=center>Der Rechner</h1><p align="center"><br><br>Das Passwort oder der Benutzername sind falsch.<br><br><a class="link" href="pc">grml...</a>'
  end 
end

get '/abmelden' do
  if session['logout'] != '1'
    session['logout'] = '1'
    show(:logout)
  else
    show(:pc)
  end
end

get '/truhe' do
  if ['2','truhe'].member?(session['draht'])
    erb :truhe
  else
    show(:truhe)
  end
end

get '/truhe1' do
  bpchk(session['bag'])
  if session['draht'] == '1'
    session['bag'] -= 3
    session['bag'] += 1
    session['draht'] = '2'
    show(:truhe1)
  else
    show(:truhe1a)
  end
end

post '/truhe/add/:name' do
  if params["name"]=='goldbarren'
    weight = 25
  elsif ['unterlagen','saege','holzwolle'].member?(params["name"])
    weight = 10
  elsif ['map1','map2','map3'].member?(params["name"])
    weight = 1
  else
    weight = 0
  end
  session[params["name"]]=truhenchk(session[params["name"]],weight)
  "ok"
end

post '/truhe/sub/:name' do
  session[params["name"]]=0
  "ok"
end


get '/polltruh' do
 if session['draht'] != 'truhe'
      session['draht'] = 'truhe'
      session['bag'] -= 3
    elsif session['draht'] == 'truhe'
      session['draht'] = '2'
      session['bag'] += 3      
    end
 erb :truhe
end

get '/raum37' do
#  if session['leiter'] == '1' && session['saege'] != '1' 
#    show(:raum37a)
#  elsif session['leiter'] == '2' && session['saege'] != '1'
#    show(:raum37a)
#  elsif session['leiter'] == '3' && session['saege'] != '1'
#    show(:raum37b)
#  elsif session['leiter'] == '1' && session['saege'] == '1'
#    show(:raum37c)
#  elsif session['leiter'] == '2' && session['saege'] == '1'
#    show(:raum37c)
#  elsif session['leiter'] == '3' && session['saege'] == '1'
#    show(:raum37d)
#  elsif session['leiter'] == '0' && session['saege'] == '1'
#    show(:raum37e)
#  else
#    show(:raum37)
#  end
  erb :raum37
end

get '/leiter' do
  if session['leiter'] != '1' && session['leiter'] != '2' && session['leiter'] != '3' 
    session['leiter'] = '1'
    show(:leiter1)
  elsif session['leiter'] == '2'
    session['leiter'] = '3'
    show(:leiter1a)
  elsif session['leiter'] == '1'
    session['leiter'] = '0'
    show(:leiter1a)
  else 
    show(:leiter1a)
  end
end

get '/tisch2' do
  if session['saege'] == '1'
    '<h1 align=center>Der Tisch</h1><p align="center"><br>Der Tisch ist bis auf einige Sägespäne leer...<br><br><a class="link" href="raum37">:()</a>'
  else
    show(:tisch2)
  end
end

get '/saege' do
  bpchk(session['bag'])
  session['bag'] += 10
  session['saege'] = '1'
  '<h1 align=center>Die Säge</h1><p align="center"><br>Du steckst die Säge ein...<br><br><a class="link" href="raum37">...</a>'
end

get '/garten' do
  if !session['pool'] then session['pool'] = 0 end
  erb :garten
end

get '/pool' do
  erb :pool
end

get '/pool1' do
  session['eimer'] = '1'
  session['bag'] -= 50
  session['pool'] += 10
  show(:pool1)
end

get '/poole' do
  if session['kaefer'] !='1'
    session['leiter'] = '2'
    show(:poole)
  else
    session['leiter'] = '2'
    show(:poole1)
  end
end

get '/kaefer1' do
    session['kaefer'] = '1'
    show(:kaefer1)
end

get '/kaefer2' do
    session['kaefer'] = '2'
    show(:kaefer2)
end

get '/knoepfe' do
  if session['wrad'] != '1'
    show(:knoepfe)
  else
    session['pool'] = 100
    show(:knoepfe1)
  end
end

get '/ampan' do
  if !['1','2'].member?(session['freesoft'])
    session['freesoft'] = '1'
    redirect 'fsws'
  elsif session['freesoft'] =='2'
    session['freesoft'] ='1'
    show(:ampan)
  elsif session['freesoft'] =='1'
    session['freesoft'] ='2'
    show(:ampaus)
  end
end

get '/back' do
  if !['1','2'].member?(session['back'])
    session['back'] = '1'
    redirect 'raum37'
  elsif session['back'] == '1'
    session['back'] = '2'
    redirect 'typ'
  elsif session['back'] == '2'
    redirect 'raum37'
  end
end

get '/apparat' do
  if session['blut'] != '1'
    session['blut'] = '1'
    show(:apparat)
  else 
    show(:apparat1)
  end
end

get '/apparat/aus' do
  if session['apparat'] == '0'
    session['apparat'] = '1'
    show(:apan)
  else
    session['apparat'] = '0'
    show(:apaus)
  end
end

get '/strassel1' do
  session.clear
  session['key'] ||= '0'
  session['geld'] ||= 0
  show(:strassel1)
end

get '/typ' do
  pp session['typ']
  if !session['typ']
    session['typ'] = 0
  end
  session['typ']+= 1
  erb :typ
end

get '/typ1' do
  pp session['typ']
  if !session['typ']
    session['typ'] = 0
  end
  session['typ']+= 5
  erb :typ
end

get '/rauchen' do
  if session['zig1'] == '1'
  session['zig1'] = '2'
  erb :rauchen
  else '<h1 align=center>Die selbstgedrehte Zigarette</h1><p align="center"><br><br>Du bist Dir nicht mehr sicher,<br>ob Du die selbstgedrehte Zigarette schon geraucht hast,<br>kannst sie aber nirgends finden...<br><br><a class="link" href="bagpack">im Rucksack nachsehen</a>'
  end
end

get '/map1' do
  erb :map
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
