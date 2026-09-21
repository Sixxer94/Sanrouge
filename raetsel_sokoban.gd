extends Node2D

# Sokoban: schiebe alle Kisten auf alle Ziele. Unterstützt farbige Kisten/Ziele
# (jede farbige Kiste muss auf ihr FARBGLEICHES Ziel) und Wild-Kisten (brauchen
# kein Ziel). Diskreter eigener Avatar (Pfeiltasten/WASD); die Spielfigur wird
# während des Rätsels versteckt/gesperrt und beim Lösen/Aufgeben wiederhergestellt.
# Rein logisch (keine Physik-Körper). Reset unbegrenzt (Taste 0), Aufgeben ESC.
#
# Level bestehen aus zwei Rastern gleicher Größe (siehe raetsel_sokoban_daten.gd):
#   boden:   # Wand, Leerzeichen Boden, ~ Eis, O Loch, % Bröckelboden,
#            . Ziel, H C D S T Farbziele, h c d s t Farbknöpfe,
#            1 2 3 4 5 Farbtüren (Ziffer = Farbcode),
#            - | F 7 L J Schienen (Rohrlabyrinth-Schreibweise)
#   objekte: Leerzeichen nichts, @ Spieler, $ Kiste, x Wild, h c d s t Farbkisten
#
# Eis: Wer auf ein Eisfeld gerät, rutscht in derselben Richtung weiter, bis er
# ein Feld ohne Eis erreicht oder vor Wand/Kiste stoppt. Das gilt für Kisten UND
# für den Spieler. Ein rutschender Spieler schiebt nichts an – er bleibt stehen.
# Umgekehrt gilt: WER SCHIEBT, RUTSCHT NICHT. Nach einem Schub rückt der Spieler
# genau ein Feld auf den freigewordenen Platz und bleibt dort, auch auf Eis. Nur
# beim freien Laufen rutscht er.
#
# Loch: für den Spieler nicht betretbar (der Zug ist schlicht nicht möglich).
# Wird eine Kiste hineingeschoben, ist die Kiste verbraucht und das Feld wird zu
# ganz normalem Boden – begehbar und für weitere Kisten passierbar.
#
# Bröckelboden: begehbar, bricht aber ein, sobald der Spieler ihn WIEDER VERLÄSST
# (draufstehen ist erlaubt) – danach ist es ein Loch. Kisten lassen ihn unberührt,
# ob im Vorbeischieben oder im Draufstehen. Rutscht der Spieler über mehrere
# hinweg, brechen alle durchquerten ein; nur das Feld, auf dem er stehenbleibt,
# hält noch.
#
# Tür/Knopf: Eine Tür der Farbe X ist offen, wenn ALLE Knöpfe der Farbe X besetzt
# sind (Spieler oder Kiste) ODER MINDESTENS EINE Tür der Farbe X besetzt ist. Man
# kann Türen also offen halten, indem man eine Kiste darauf parkt – auch wenn der
# Knopf längst wieder frei ist. Geschlossene Türen sperren Spieler und Kisten wie
# Wände. Geprüft wird der Zustand VOR dem Zug, sonst sperrte man sich jede Tür
# durch das eigene Betreten selbst auf. Der Türzustand ist rein abgeleitet und
# damit kein eigener Suchzustand.
#
# Schiene: Eine Kiste, die AUF einer Schiene steht, lässt sich nur in deren
# Richtungen schieben – UND in eine Schiene hinein nur durch ein Ende, das zur
# Herkunftsseite zeigt. Seitlich auf eine Schiene schieben geht also nicht; ein
# Feld neben der Bahn hat oft nur einen einzigen möglichen Einstieg. Der Spieler
# läuft frei über Schienen hinweg.

signal geloest
signal verlassen

const DATEN = preload("res://raetsel_sokoban_daten.gd")

const RICHTUNG = {
	KEY_W: Vector2i(0, -1), KEY_UP: Vector2i(0, -1),
	KEY_S: Vector2i(0, 1),  KEY_DOWN: Vector2i(0, 1),
	KEY_A: Vector2i(-1, 0), KEY_LEFT: Vector2i(-1, 0),
	KEY_D: Vector2i(1, 0),  KEY_RIGHT: Vector2i(1, 0),
}
const DIRS = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]

# Farbcodes: 0 = ungefärbt, 1-5 = Farben (Herz/Kreuz/Karo/Pik/Stern), 6 = Wild
const KISTE_FARBE = {"$": 0, "x": 6, "h": 1, "c": 2, "d": 3, "s": 4, "t": 5}
const ZIEL_FARBE  = {".": 0, "H": 1, "C": 2, "D": 3, "S": 4, "T": 5}
# Nur im boden-Raster: Knöpfe klein (gleiche Merkhilfe wie die Kisten), Türen als
# Ziffer = Farbcode. Beide Tabellen kollidieren nicht mit ZIEL_FARBE.
const KNOPF_FARBE = {"h": 1, "c": 2, "d": 3, "s": 4, "t": 5}
const TUER_FARBE  = {"1": 1, "2": 2, "3": 3, "4": 4, "5": 5}
# Schienen als Richtungs-Bitmaske: rechts 1, links 2, runter 4, hoch 8.
const R_BIT = {Vector2i(1, 0): 1, Vector2i(-1, 0): 2, Vector2i(0, 1): 4, Vector2i(0, -1): 8}
const BIT_VEK = {1: Vector2(1, 0), 2: Vector2(-1, 0), 4: Vector2(0, 1), 8: Vector2(0, -1)}
const SCHIENE = {
	"-": 3,    # links + rechts
	"|": 12,   # hoch + runter
	"F": 5,    # runter + rechts   (Ecke oben-links)
	"7": 6,    # runter + links    (Ecke oben-rechts)
	"L": 9,    # hoch + rechts     (Ecke unten-links)
	"J": 10,   # hoch + links      (Ecke unten-rechts)
}
const FARB_KORPUS = {
	0: Color(0.70, 0.52, 0.30),   # ungefärbt: braun
	1: Color(0.86, 0.30, 0.34),   # Herz: rot
	2: Color(0.32, 0.70, 0.42),   # Kreuz: grün
	3: Color(0.34, 0.56, 0.92),   # Karo: blau
	4: Color(0.66, 0.44, 0.86),   # Pik: violett
	5: Color(0.92, 0.66, 0.24),   # Stern: orange
	6: Color(0.56, 0.56, 0.62),   # Wild: grau
}

# Interface für raum_raetsel / raetsel_test
var welt = 1
var variante = ""
var belohnung_welt_pos = Vector2(640, 360)
var spieler = null

var _waende := {}
var _ziele := {}
var _eis := {}
var _loecher := {}
var _broeckel := {}
var _tueren := {}
var _knoepfe := {}
var _schienen := {}
var _boden := {}
var _kisten := {}
var _avatar := Vector2i.ZERO
var _blick := Vector2i(0, 1)
var _start_kisten := []
var _start_loecher := {}
var _start_broeckel := {}
var _start_avatar := Vector2i.ZERO
var _cols := 0
var _rows := 0
var _zelle := 48.0
var _ursprung := Vector2.ZERO
var _fertig := false
var _beendet := false

func _ready():
	z_index = 0
	spieler = get_tree().get_first_node_in_group("spieler")
	if spieler:
		spieler.bewegung_gesperrt = true
		spieler.visible = false
		spieler.global_position = Vector2(640, 360)
	_level_laden()
	queue_redraw()

func _level_laden():
	var eintrag = _level_fuer_welt(clampi(welt, 1, 8))
	_parse(eintrag.boden, eintrag.objekte)
	_start_kisten = []
	for c in _kisten:
		_start_kisten.append([c, _kisten[c]])   # [Position, Farbe]
	_start_loecher = _loecher.duplicate()
	_start_broeckel = _broeckel.duplicate()
	_start_avatar = _avatar

# Solange die Welt nicht einsortiert ist (WELT_ZUORDNUNG leer/fehlt), zufällig
# aus der ganzen Sammlung ziehen – so bleibt im Staging alles spielbar.
func _level_fuer_welt(w: int) -> Dictionary:
	var namen = DATEN.WELT_ZUORDNUNG.get(w, [])
	if namen.is_empty():
		return DATEN.SAMMLUNG[randi() % DATEN.SAMMLUNG.size()]
	var gewaehlt = namen[randi() % namen.size()]
	for e in DATEN.SAMMLUNG:
		if e.name == gewaehlt:
			return e
	return DATEN.SAMMLUNG[0]

func _parse(boden: Array, objekte: Array):
	_waende.clear(); _ziele.clear(); _kisten.clear()
	_eis.clear(); _loecher.clear(); _broeckel.clear()
	_tueren.clear(); _knoepfe.clear(); _schienen.clear()
	_cols = 0
	_rows = boden.size()
	for y in boden.size():
		var b: String = boden[y]
		_cols = maxi(_cols, b.length())
		for x in b.length():
			var c = Vector2i(x, y)
			var ch = b[x]
			if ch == "#":
				_waende[c] = true
			elif ch == "~":
				_eis[c] = true
			elif ch == "O":
				_loecher[c] = true
			elif ch == "%":
				_broeckel[c] = true
			elif SCHIENE.has(ch):
				_schienen[c] = SCHIENE[ch]
			elif TUER_FARBE.has(ch):
				_tueren[c] = TUER_FARBE[ch]
			elif KNOPF_FARBE.has(ch):
				_knoepfe[c] = KNOPF_FARBE[ch]
			elif ZIEL_FARBE.has(ch):
				_ziele[c] = ZIEL_FARBE[ch]
			# alles andere (Leerzeichen) = normaler Boden
		var o: String = objekte[y] if y < objekte.size() else ""
		for x in o.length():
			var c2 = Vector2i(x, y)
			var oc = o[x]
			if oc == "@":
				_avatar = c2
			elif KISTE_FARBE.has(oc):
				_kisten[c2] = KISTE_FARBE[oc]
	_boden = _innenboden()
	_zelle = clampf(min(1000.0 / _cols, 520.0 / _rows), 22.0, 60.0)
	_ursprung = Vector2(640.0 - _cols * _zelle / 2.0, 360.0 - _rows * _zelle / 2.0)

# Begehbarer Innenraum = vom Avatar aus erreichbare Nicht-Wand-Zellen
func _innenboden() -> Dictionary:
	var reg = {_avatar: true}
	var q = [_avatar]
	while q.size() > 0:
		var c = q.pop_back()
		for d in DIRS:
			var n = c + d
			if _waende.has(n) or reg.has(n):
				continue
			if n.x < 0 or n.y < 0 or n.x >= _cols or n.y >= _rows:
				continue
			reg[n] = true
			q.append(n)
	return reg

# ── Eingabe / Zug ─────────────────────────────────────────────────────────────
func _input(event):
	if _beendet:
		return
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if event.keycode == KEY_ESCAPE:
		_aufgeben()
		get_viewport().set_input_as_handled()
		return
	if event.keycode == KEY_0 or event.keycode == KEY_KP_0:
		_neu_starten()
		get_viewport().set_input_as_handled()
		return
	if not RICHTUNG.has(event.keycode):
		return
	_blick = RICHTUNG[event.keycode]
	_zug(_blick)
	get_viewport().set_input_as_handled()

# Ist die Tür dieser Farbe offen? Entweder alle Knöpfe der Farbe besetzt, oder
# mindestens eine Tür der Farbe besetzt (dann hält sie sich selbst offen).
func _tuer_offen(farbe: int) -> bool:
	var hat_knopf = false
	var alle_gedrueckt = true
	for k in _knoepfe:
		if _knoepfe[k] != farbe:
			continue
		hat_knopf = true
		if not (_kisten.has(k) or _avatar == k):
			alle_gedrueckt = false
	if hat_knopf and alle_gedrueckt:
		return true
	for t in _tueren:
		if _tueren[t] == farbe and (_kisten.has(t) or _avatar == t):
			return true
	return false

# Menge der aktuell gesperrten Türfelder. Wird einmal vor dem Zug bestimmt und
# dann unverändert benutzt, damit sich der Türzustand nicht mitten im Zug ändert.
func _gesperrte_tueren() -> Dictionary:
	var zu = {}
	var zustand = {}
	for t in _tueren:
		var f = _tueren[t]
		if not zustand.has(f):
			zustand[f] = _tuer_offen(f)
		if not zustand[f]:
			zu[t] = true
	return zu

# Rutschweg des Spielers: weiter, solange er auf Eis steht. Stoppt, sobald ein
# Feld ohne Eis erreicht ist oder Wand/Kiste/Loch/Tür den Weg versperren.
func _rutschen(start: Vector2i, d: Vector2i, zu: Dictionary) -> Vector2i:
	var p = start
	while _eis.has(p):
		var n = p + d
		if _waende.has(n) or _kisten.has(n) or _loecher.has(n) or zu.has(n):
			break
		p = n
	return p

# Rutschweg einer Kiste: wie oben, aber ein Loch stoppt sie nicht davor – sie
# gleitet hinein und versinkt dort.
func _rutschen_kiste(start: Vector2i, d: Vector2i, zu: Dictionary) -> Vector2i:
	var p = start
	while _eis.has(p):
		var n = p + d
		if _waende.has(n) or _kisten.has(n) or zu.has(n):
			break
		if _schienen.has(n) and (_schienen[n] & R_BIT[-d]) == 0:
			break   # Schiene nimmt die Kiste von dieser Seite nicht auf
		p = n
		if _loecher.has(p):
			break
	return p

# Alle Felder, die der Spieler auf dem Weg von "von" nach "bis" verlässt, brechen
# ein, sofern sie Bröckelboden sind. Das Feld, auf dem er stehenbleibt, hält noch.
func _broeckeln(von: Vector2i, bis: Vector2i, d: Vector2i):
	var c = von
	var schutz = 0
	while c != bis and schutz < 500:
		if _broeckel.has(c):
			_broeckel.erase(c)
			_loecher[c] = true
		c += d
		schutz += 1

func _zug(d: Vector2i):
	var zu = _gesperrte_tueren()      # Türzustand VOR dem Zug
	var ziel = _avatar + d
	if _waende.has(ziel) or _loecher.has(ziel) or zu.has(ziel):
		return
	var start = _avatar
	if _kisten.has(ziel):
		# Kiste auf einer Schiene: nur entlang der Schiene schiebbar
		if _schienen.has(ziel) and (_schienen[ziel] & R_BIT[d]) == 0:
			return
		var dahinter = ziel + d
		# ... und in eine Schiene nur durch ein Ende, das zur Herkunft zeigt.
		# Seitlich auf eine Schiene schieben geht nicht.
		if _schienen.has(dahinter) and (_schienen[dahinter] & R_BIT[-d]) == 0:
			return
		if _waende.has(dahinter) or _kisten.has(dahinter) or zu.has(dahinter):
			return
		var farbe = _kisten[ziel]
		_kisten.erase(ziel)
		# Erst die Kiste verbuchen, dann den Spieler: sie bremst ihn ggf. aus.
		var ende = _rutschen_kiste(dahinter, d, zu)
		if _loecher.has(ende):
			_loecher.erase(ende)    # Kiste füllt das Loch auf und ist verbraucht
		else:
			_kisten[ende] = farbe
		# Wer schiebt, rutscht nicht: der Spieler rückt genau ein Feld nach und
		# bleibt dort stehen, auch auf Eis. Ohne das ist lesson-4-14 unlösbar,
		# weil er über die Felder hinwegrutscht, auf denen er nachsetzen muss.
		_avatar = ziel
	else:
		_avatar = _rutschen(ziel, d, zu)
	_broeckeln(start, _avatar, d)
	queue_redraw()
	if _gewonnen():
		_fertig = true
		_beendet = true
		geloest.emit()

# Gelöst: jedes Ziel von einer farbgleichen Kiste bedeckt.
func _gewonnen() -> bool:
	for z in _ziele:
		if not (_kisten.has(z) and _kisten[z] == _ziele[z]):
			return false
	return true

# ── Reset / Lösen / Aufgeben ──────────────────────────────────────────────────
# Bewusst NICHT "zuruecksetzen" genannt: sonst legt raum_raetsel seine auf 2×
# begrenzte Reset-Logik darauf. Sokoban resettet unbegrenzt selbst (Taste 0).
func _neu_starten():
	if _beendet:
		return
	_kisten.clear()
	for e in _start_kisten:
		_kisten[e[0]] = e[1]   # [Position, Farbe]
	_loecher = _start_loecher.duplicate()
	_broeckel = _start_broeckel.duplicate()
	_avatar = _start_avatar
	queue_redraw()

func _spieler_freigeben():
	if spieler and is_instance_valid(spieler):
		spieler.bewegung_gesperrt = false
		spieler.visible = true
		spieler.global_position = Vector2(160, 360)

# von raum_raetsel bei Lösung aufgerufen
func aufloesen():
	_beendet = true
	_fertig = true
	_spieler_freigeben()
	queue_redraw()

func _aufgeben():
	if _beendet:
		return
	_beendet = true
	_spieler_freigeben()
	queue_redraw()
	verlassen.emit()

# ── Zeichnen ──────────────────────────────────────────────────────────────────
func _cell_to_world(c: Vector2i) -> Vector2:
	return _ursprung + Vector2(c.x + 0.5, c.y + 0.5) * _zelle

func _draw():
	if _beendet:
		return
	var z = _zelle
	# Boden (Eis kühl und mit Schlittenstreifen, damit es sofort auffällt)
	var tuer_zu = _gesperrte_tueren()
	for c in _boden:
		var w = _cell_to_world(c)
		var rb = Rect2(w - Vector2(z, z) / 2.0, Vector2(z, z))
		if _tueren.has(c):
			var tf = FARB_KORPUS[_tueren[c]]
			if tuer_zu.has(c):
				# geschlossen: massive Säule
				draw_rect(rb, tf.darkened(0.30))
				draw_rect(rb, tf.lightened(0.30), false, 2.5)
				draw_line(rb.position + Vector2(z * 0.5, z * 0.16),
					rb.position + Vector2(z * 0.5, z * 0.84), tf.lightened(0.45), 2.0)
			else:
				# offen: versenkt, nur der farbige Rahmen bleibt sichtbar
				draw_rect(rb, Color(0.20, 0.19, 0.24))
				draw_rect(rb, Color(tf.r, tf.g, tf.b, 0.5), false, 2.0)
		elif _knoepfe.has(c):
			var kf = FARB_KORPUS[_knoepfe[c]]
			draw_rect(rb, Color(0.20, 0.19, 0.24))
			draw_rect(rb, Color(0.27, 0.26, 0.32), false, 1.0)
			draw_circle(w, z * 0.27, Color(kf.r, kf.g, kf.b, 0.30))
			draw_arc(w, z * 0.27, 0, TAU, 24, kf, 2.5)
		elif _schienen.has(c):
			draw_rect(rb, Color(0.20, 0.19, 0.24))
			draw_rect(rb, Color(0.27, 0.26, 0.32), false, 1.0)
			var sf = Color(0.66, 0.63, 0.55)
			for bit in [1, 2, 4, 8]:
				if (_schienen[c] & bit) == 0:
					continue
				var dv: Vector2 = BIT_VEK[bit]
				var senk = Vector2(-dv.y, dv.x) * (z * 0.14)
				draw_line(w + senk, w + dv * (z * 0.5) + senk, sf, 2.0)
				draw_line(w - senk, w + dv * (z * 0.5) - senk, sf, 2.0)
		elif _loecher.has(c):
			draw_rect(rb, Color(0.10, 0.09, 0.13))
			draw_rect(rb, Color(0.30, 0.28, 0.36), false, 1.0)
			draw_circle(w, z * 0.30, Color(0.04, 0.04, 0.07))
			draw_arc(w, z * 0.30, 0, TAU, 24, Color(0.26, 0.24, 0.32), 2.0)
		elif _broeckel.has(c):
			draw_rect(rb, Color(0.27, 0.24, 0.21))
			draw_rect(rb, Color(0.42, 0.37, 0.31), false, 1.0)
			var m = z * 0.22
			var riss = Color(0.62, 0.55, 0.45, 0.9)
			draw_line(rb.position + Vector2(m, m), rb.position + Vector2(z - m, z - m), riss, 2.0)
			draw_line(rb.position + Vector2(z - m, m), rb.position + Vector2(m, z - m), riss, 2.0)
		elif _eis.has(c):
			draw_rect(rb, Color(0.20, 0.33, 0.45))
			draw_rect(rb, Color(0.40, 0.60, 0.76), false, 1.0)
			for i in 3:
				var k = z * 0.5 * (i + 1)
				draw_line(rb.position + Vector2(maxf(0.0, k - z), minf(k, z)),
					rb.position + Vector2(minf(k, z), maxf(0.0, k - z)),
					Color(0.58, 0.80, 0.95, 0.5), 1.5)
		else:
			draw_rect(rb, Color(0.20, 0.19, 0.24))
			draw_rect(rb, Color(0.27, 0.26, 0.32), false, 1.0)
	# Wände
	for c in _waende:
		var w = _cell_to_world(c)
		draw_rect(Rect2(w - Vector2(z, z) / 2.0, Vector2(z, z)), Color(0.40, 0.36, 0.46))
		draw_rect(Rect2(w - Vector2(z, z) / 2.0, Vector2(z, z)), Color(0.52, 0.48, 0.60), false, 1.0)
	# Ziele (Farbe je Zielfarbe)
	for c in _ziele:
		var w = _cell_to_world(c)
		var zf = FARB_KORPUS[_ziele[c]]
		var r = z * 0.17
		draw_arc(w, r, 0, TAU, 20, zf, 3.0)
		draw_circle(w, r * 0.45, Color(zf.r, zf.g, zf.b, 0.9))
	# Kisten (Farbe je Kistenfarbe; auf passendem Ziel = heller + heller Rahmen)
	for c in _kisten:
		var w = _cell_to_world(c)
		var kf = _kisten[c]
		var passt = _ziele.has(c) and _ziele[c] == kf
		var korpus = FARB_KORPUS[kf]
		if passt:
			korpus = korpus.lightened(0.22)
		var rahmen = korpus.lightened(0.35)
		var s = z * 0.74
		var r = Rect2(w - Vector2(s, s) / 2.0, Vector2(s, s))
		draw_rect(r, korpus)
		draw_rect(r, rahmen, false, 3.0 if passt else 2.5)
		if kf == 6:
			# Wild-Kiste: „?" statt Kreuz – sie braucht kein Ziel.
			var f = ThemeDB.fallback_font
			var gr = int(z * 0.5)
			var br = f.get_string_size("?", HORIZONTAL_ALIGNMENT_LEFT, -1, gr)
			draw_string(f, w + Vector2(-br.x / 2.0, (f.get_ascent(gr) - f.get_descent(gr)) / 2.0),
				"?", HORIZONTAL_ALIGNMENT_LEFT, -1, gr, rahmen.lightened(0.25))
		else:
			draw_line(r.position, r.position + r.size, rahmen, 2.0)
			draw_line(r.position + Vector2(r.size.x, 0), r.position + Vector2(0, r.size.y), rahmen, 2.0)
	# Avatar
	var wa = _cell_to_world(_avatar)
	draw_circle(wa, z * 0.30, Color(0.30, 0.62, 0.95))
	draw_circle(wa, z * 0.30, Color(0.60, 0.82, 1.0), false, 2.0)
	var aug = z * 0.08
	draw_circle(wa + Vector2(-z * 0.10, -z * 0.04) + Vector2(_blick) * z * 0.06, aug, Color(1, 1, 1))
	draw_circle(wa + Vector2(z * 0.10, -z * 0.04) + Vector2(_blick) * z * 0.06, aug, Color(1, 1, 1))

	# Fortschritt + Hinweis
	var font = ThemeDB.fallback_font
	var erfuellt = 0
	for zc in _ziele:
		if _kisten.has(zc) and _kisten[zc] == _ziele[zc]:
			erfuellt += 1
	draw_string(font, Vector2(340, _ursprung.y - 14.0),
		"Kisten auf Zielen: %d / %d" % [erfuellt, _ziele.size()],
		HORIZONTAL_ALIGNMENT_CENTER, 600, 18, Color(0.9, 0.9, 0.95))
	draw_string(font, Vector2(340, 704),
		"Alle Kisten auf die Ziele schieben   ·   Pfeile/WASD   ·   0: Reset   ·   ESC: aufgeben",
		HORIZONTAL_ALIGNMENT_CENTER, 600, 15, Color(0.7, 0.7, 0.8))
