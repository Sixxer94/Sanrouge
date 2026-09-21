extends RefCounted

# ── Sokoban-Level-Sammlung (Staging) ──────────────────────────────────────────
# Level werden aus sokobanonline-Lektionen zeichengenau übernommen und hier
# gesammelt. Die Einsortierung in Welten (WELT_ZUORDNUNG) erfolgt später.
#
# Jedes Level hat ZWEI Raster gleicher Größe – genau wie sokobanonline es intern
# führt. So braucht es keine Kombi-Zeichen für "Eis mit Kiste drauf" o. ä.
#
#   boden    Untergrund: # Wand, Leerzeichen Boden, ~ Eis, O Loch,
#            % Bröckelboden (bricht ein, sobald der Spieler ihn verlässt),
#            . Ziel (ungefärbt), H C D S T Farbziele (Herz Kreuz Karo Pik Stern),
#            h c d s t Farbknöpfe, 1 2 3 4 5 Farbtüren (Ziffer = Farbcode),
#            Schienen in Rohrlabyrinth-Schreibweise: - waagerecht, | senkrecht,
#            F Ecke unten+rechts, 7 unten+links, L oben+rechts, J oben+links.
#            Eine Kiste AUF einer Schiene ist nur entlang dieser schiebbar.
#   objekte  Auflage:    Leerzeichen nichts, @ Spieler, $ Kiste (ungefärbt),
#            x Wild-Kiste (braucht kein Ziel), h c d s t Farbkisten
#
#   schritte  Optimallösung in EINZELNEN SCHRITTEN (jeder Tastendruck, Laufwege
#             eingerechnet), übernommen aus "Best Solution: N steps" auf
#             sokobanonline. Reine Kennzahl zur Einordnung – NICHT von uns
#             nachgerechnet. Die Level der Seite sind dort bereits getestet;
#             unsere Aufgabe ist allein die zeichengenaue Übernahme.

const SAMMLUNG = [
	{
		"name": "lesson-1-4",
		"schritte": 34,
		"boden": [
			"######   ",
			"#....####",
			"#   ##  #",
			"#       #",
			"#   #   #",
			"##  #####",
			" ####    ",
		],
		"objekte": [
			"         ",
			"         ",
			"   $     ",
			"  $$     ",
			" @$      ",
			"         ",
			"         ",
		],
	},
	{
		"name": "lesson-1-5",
		"schritte": 43,
		"boden": [
			"  ####  ",
			"  #  ###",
			"  #    #",
			"###  . #",
			"#... ###",
			"###  #  ",
			"  #  #  ",
			"  ####  ",
		],
		"objekte": [
			"        ",
			"    @   ",
			"   $$   ",
			"    $   ",
			"        ",
			"   $    ",
			"        ",
			"        ",
		],
	},
	{
		# Die drei Ziele starten unter den Wild-Kisten: erst die Wild-Kisten
		# runter- und aus der Bahn schieben, dann die Farbkisten setzen.
		"name": "lesson-3-7",
		"schritte": 40,
		"boden": [
			"##########",
			"# H      #",
			"# C      #",
			"# D     ##",
			"######### ",
		],
		"objekte": [
			"          ",
			"  x  h    ",
			" @x   c   ",
			"  x  d    ",
			"          ",
		],
	},
	{
		# Eis: Kisten UND Spieler rutschen weiter, bis sie ein Feld ohne Eis
		# erreichen oder auf Wand/Kiste treffen. Die drei Ziele liegen auf
		# festem Boden – die wenigen eisfreien Felder sind die Bremspunkte.
		"name": "lesson-4-9",
		"schritte": 19,
		"boden": [
			" ####  ",
			" #  ###",
			" #~~~~#",
			"##~~#~#",
			"#D~~~ #",
			"# ~~~~#",
			"##CH ##",
			" ##### ",
		],
		"objekte": [
			"       ",
			"       ",
			"   c   ",
			"       ",
			"  h@   ",
			"    d  ",
			"       ",
			"       ",
		],
	},
	{
		# Löcher: die beiden Ziele liegen in einer Nische dahinter. Vier Löcher,
		# exakt vier Wild-Kisten – jede muss sitzen, sonst kommt weder Spieler
		# noch Farbkiste hindurch.
		"name": "lesson-5-4",
		"schritte": 63,
		"boden": [
			"########",
			"#   OOH#",
			"#   OOC#",
			"#    ###",
			"#    #  ",
			"##   #  ",
			" #####  ",
		],
		"objekte": [
			"        ",
			"  h     ",
			"  c     ",
			"   x    ",
			"  xxx   ",
			"    @   ",
			"        ",
		],
	},
	{
		# Bröckelboden: der Spieler darf jedes der sechs Felder genau einmal
		# überqueren. Der erste Schub der Herzkiste dient nur dazu, sich den Weg
		# in den oberen Korridor freizumachen – schiebt man sie gleich durch,
		# versperren die eigenen Kisten den Weg nach außen.
		"name": "lesson-5-6",
		"schritte": 23,
		"boden": [
			" ####### ",
			" #     # ",
			"## ### ##",
			"#  %%% H#",
			"#C %%%  #",
			"#########",
		],
		"objekte": [
			"         ",
			"         ",
			"         ",
			"  h      ",
			"  @   c  ",
			"         ",
		],
	},
	{
		# Die Bröckelnische oben links hat zwei Ausgänge: der Spieler geht auf
		# der einen Seite hinein und auf der anderen hinaus, dann sind beide
		# Felder Gruben – und damit der Abfalleimer für die zwei Wild-Kisten.
		"name": "lesson-5-9",
		"schritte": 59,
		"boden": [
			"####      ",
			"#%%#######",
			"#D       #",
			"#C       #",
			"#H    ####",
			"#######   ",
		],
		"objekte": [
			"          ",
			"          ",
			"   h c d  ",
			"  x x     ",
			"     @    ",
			"          ",
		],
	},
	{
		# Die Farbkammer links ist durch ein Loch abgeriegelt. Der Spieler steht
		# selbst auf Bröckelboden: sein erster Zug kann nur nach rechts gehen und
		# reißt sofort ein zweites Loch hinter ihm auf. Beide müssen mit
		# Wild-Kisten verfüllt werden, bevor er überhaupt nach links kommt.
		"name": "lesson-5-10",
		"schritte": 62,
		"boden": [
			"######      ",
			"#HCDS#      ",
			"#    #######",
			"#    #     #",
			"### ##     #",
			"  #O%%%    #",
			"  ##########",
		],
		"objekte": [
			"            ",
			"            ",
			" hcds       ",
			"            ",
			"       xxx  ",
			"    @x      ",
			"            ",
		],
	},
	{
		# Die vier Ziele liegen hinter vier roten Türen, es gibt aber nur einen
		# Knopf – und wer daraufsteht, kann nicht schieben. Lösung: eine Kiste
		# auf einer Tür parken, dann bleiben alle Türen offen, auch wenn der
		# Knopf längst wieder frei ist.
		"name": "lesson-7-12",
		"schritte": 65,
		"boden": [
			"    #######",
			"#####     #",
			"#    h    #",
			"#      ####",
			"###1111#   ",
			"  #HCDS#   ",
			"  ######   ",
		],
		"objekte": [
			"           ",
			"           ",
			"  h c d s  ",
			" @         ",
			"           ",
			"           ",
			"           ",
		],
	},
	{
		# Zwölf Bröckelfelder als 4x3-Block, die vier Farbkisten stehen mittendrin
		# und müssen je zwei Felder hoch. Der Spieler reißt sich beim Manövrieren
		# den Boden unter den Füßen weg – die Reihenfolge entscheidet alles.
		"name": "lesson-a5-10",
		"schritte": 51,
		"boden": [
			"###### ",
			"#    # ",
			"#  # ##",
			"#HCDS #",
			"#%%%% #",
			"#%%%% #",
			"#%%%% #",
			"#     #",
			"#######",
		],
		"objekte": [
			"       ",
			"       ",
			"       ",
			"       ",
			"       ",
			" hcds  ",
			"       ",
			" @     ",
			"       ",
		],
	},
	{
		# Die Schienen bilden eine Spirale. Vier Farbkisten sitzen darauf und
		# können einander nicht überholen: Herz außen, Pik innen – die Herzkiste
		# muss aber ins Zentrum. Also müssen alle anderen erst über das
		# Zentrumsfeld heraus und außen wieder auf die Bahn. Daher 276 Schritte.
		"name": "lesson-a6-12",
		"schritte": 276,
		"boden": [
			" ####      ",
			" #  #######",
			" #        #",
			" # F---7  #",
			" # |F-7| ##",
			"## ||HJ| # ",
			"#   L--J # ",
			"#   CDS  # ",
			"#######  # ",
			"      #### ",
		],
		"objekte": [
			"           ",
			"           ",
			"           ",
			"           ",
			"    c d    ",
			"    h s    ",
			"           ",
			" @      x  ",
			"           ",
			"           ",
		],
	},
	{
		# Die Herzkiste lässt sich nirgends nach oben schieben – überall dort,
		# wo der Spieler dafür stehen müsste, ist Wand oder Loch. Erst die
		# Löcher verfüllen schafft die nötigen Standplätze.
		"name": "lesson-5-3",
		"schritte": 61,
		"boden": [
			" ###### ",
			" #    ##",
			"##     #",
			"#O    H#",
			"#O    ##",
			"#OO#### ",
			"####    ",
		],
		"objekte": [
			"        ",
			"  @     ",
			"  xxxx  ",
			"        ",
			"    h   ",
			"        ",
			"        ",
		],
	},
	{
		# Alle fünf Farben. Jede Kiste muss nur ein Feld weit, abwechselnd hoch
		# und runter – aber der Standplatz dafür ist jedes Mal ein Bröckelfeld.
		# Fünf Bröckelfelder für fünf Schübe: die Reihenfolge ist alles, denn
		# jeder Weg über ein Bröckelfeld verbraucht es.
		"name": "lesson-5-15",
		"schritte": 48,
		"boden": [
			"###########",
			"# %C%S%   #",
			"#         #",
			"# H%D%T ###",
			"#      ##  ",
			"########   ",
		],
		"objekte": [
			"           ",
			"        x  ",
			"  hcdst    ",
			"           ",
			" @         ",
			"           ",
		],
	},
	{
		# Die beiden Schienen sind eine Rutsche: Sie nehmen eine Kiste nur von
		# oben an, führen sie nach rechts und kippen sie unten aufs Karo-Ziel.
		# Die Karokiste kann also nicht direkt hinunter – erst nach links, dann
		# in die Rutsche.
		"name": "lesson-6-10",
		"schritte": 61,
		"boden": [
			" #####",
			" #   #",
			"##   #",
			"#    #",
			"# L7 #",
			"#HCDS#",
			"######",
		],
		"objekte": [
			"      ",
			"  @   ",
			"   cs ",
			"  hd  ",
			"      ",
			"      ",
			"      ",
		],
	},
	{
		# Die Ziele stehen in umgekehrter Reihenfolge zu den Kisten – jede muss an
		# allen anderen vorbei. Unter den beiden linken Wild-Kisten liegt
		# Bröckelboden, im Bild also nicht zu sehen; oben links zwei Löcher.
		"name": "lesson-5-12",
		"schritte": 129,
		"boden": [
			"####        ",
			"#OO#########",
			"#          #",
			"#  % %     #",
			"#  S D C H #",
			"############",
		],
		"objekte": [
			"            ",
			"            ",
			"   h c d s  ",
			"   x x x x  ",
			" @          ",
			"            ",
		],
	},
	{
		# Treppe: die fünf Farbkisten stehen diagonal versetzt, links davon wächst
		# das Bröckelfeld von einer auf vier Kacheln. Die Ziele stehen wieder in
		# umgekehrter Reihenfolge, und mitten im Bröckelfeld steckt eine Wand.
		"name": "lesson-a5-15",
		"schritte": 95,
		"boden": [
			" #####    ",
			" #   ##   ",
			" #    ##  ",
			" #%    #  ",
			"##%%   ###",
			"# %#%    #",
			"# %%%%   #",
			"##TSDCH  #",
			" #########",
		],
		"objekte": [
			"          ",
			"  @       ",
			"  h       ",
			"   c      ",
			"    d     ",
			"     s    ",
			"      tx  ",
			"          ",
			"          ",
		],
	},
	{
		# Eisfeld mit genau einer eisfreien Lücke – dort liegt das Sternziel und
		# nur dort kann eine Kiste stehenbleiben. Die vier Farbkisten links werden
		# quer über das Eis auf ihre Ziele rechts geschoben.
		"name": "lesson-4-14",
		"schritte": 22,
		"boden": [
			"#########",
			"#  ~~~H #",
			"#  ~~~C##",
			"#  ~T~D# ",
			"#  ~~~S# ",
			"######## ",
		],
		"objekte": [
			"         ",
			"  h x    ",
			"  c t    ",
			" @d      ",
			"   s     ",
			"         ",
		],
	},
	{
		# Vertauschungsrätsel: Herzkiste steht auf dem Karo-Ziel, Karokiste auf dem
		# Herz-Ziel – die beiden müssen tauschen. Die Kreuzkiste sitzt schon
		# richtig, steht aber in der Nische genau zwischen ihnen im Weg. Umlaufen
		# geht nur außen herum über die rechte Spalte.
		"name": "lesson-a2-4",
		"schritte": 91,
		"boden": [
			" #####    ",
			"##   #####",
			"#        #",
			"# D#C#H# #",
			"##       #",
			" ###   ###",
			"   #####  ",
		],
		"objekte": [
			"          ",
			"  @       ",
			"          ",
			"  h c d   ",
			"          ",
			"          ",
			"          ",
		],
	},
	{
		# Aus dem Web-Archiv (David W. Skinner, Microban) statt aus den Lektionen.
		# Klassisch, ohne Farben: zwei Kisten, zwei Ziele – aber ein langer,
		# verwinkelter Rückweg, über den der Spieler sich neu ansetzen muss.
		"name": "microban-8",
		"schritte": 97,
		"boden": [
			"  ######",
			"  # .. #",
			"  #    #",
			"  ## ###",
			"   # #  ",
			"   # #  ",
			"#### #  ",
			"#    ## ",
			"# #   # ",
			"#   # # ",
			"###   # ",
			"  ##### ",
		],
		"objekte": [
			"        ",
			"      @ ",
			"    $$  ",
			"        ",
			"        ",
			"        ",
			"        ",
			"        ",
			"        ",
			"        ",
			"        ",
			"        ",
		],
	},
	{
		# Web-Archiv (Microban). Schachbrett aus sechs Kisten und sechs Zielen,
		# verschränkt ineinander – jede Kiste steht neben einem Ziel, aber nie auf
		# dem eigenen. Sehr kompakt: 26 Schritte auf 30 Feldern.
		"name": "microban-7",
		"schritte": 26,
		"boden": [
			"#######",
			"#     #",
			"# . . #",
			"#  .  #",
			"# . . #",
			"#  .  #",
			"#     #",
			"#######",
		],
		"objekte": [
			"       ",
			"       ",
			"   $   ",
			"  $ $  ",
			"   $   ",
			"  $ $  ",
			"   @   ",
			"       ",
		],
	},
	{
		# Web-Archiv (Microban). Vier Kisten oben im verwinkelten Teil, die vier
		# Ziele liegen als Reihe unten links hinter einer Engstelle. Mit 138
		# Schritten das zweitlängste Level der Sammlung.
		"name": "microban-65",
		"schritte": 138,
		"boden": [
			"  ###### ",
			"  #    # ",
			"  #    # ",
			" ####  # ",
			"##     # ",
			"#....# ##",
			"#       #",
			"##  #   #",
			" ########",
		],
		"objekte": [
			"         ",
			"         ",
			"     $   ",
			"     $   ",
			"   $ $   ",
			"         ",
			"      @  ",
			"         ",
			"         ",
		],
	},
]

# Welt → Liste von Level-Namen aus SAMMLUNG. Noch leer: Einsortierung folgt.
# Solange eine Welt hier fehlt/leer ist, zieht die Engine zufällig aus der
# ganzen SAMMLUNG (Staging-Modus, damit alles testbar bleibt).
const WELT_ZUORDNUNG = {}
