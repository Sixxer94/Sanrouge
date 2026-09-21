extends Node2D

# Schiebe-Rätsel-Familie (Sokoban-Engine, gemeinsame Schiebe-Mechanik):
#   "platten" – Gewicht auf alle Druckplatten (Steine + Spieler + Leiche ab Welt 5)
#   "stollen" – Kammer-Sokoban auf feinem Raster: eine handgebaute, per Löser
#               vermessene Vorlage (raetsel_kammern_daten.gd) wird zur Welt
#               passend gewählt und vertikal gespiegelt. Garantiert lösbar,
#               Schwierigkeit (min. Schubzahl) exakt kalibriert.
#   "grube"   – Stein in die Grube schieben (Brücke), dann hinüber zur Belohnung
# Gleitstein rutscht bis zum Anschlag, Rissstein ist nach einem Schub fest.

signal geloest

# Rastergröße: Standard 80 px (platten/grube); die Kammern nutzen ein feineres
# 60-px-Raster im selben Raum (wird in _ready je Variante gesetzt).
var zelle    := 80.0
var cols     := 14
var rows     := 7
var ursprung := Vector2(120, 120)
const DIRS = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]

var welt = 1
var variante = ""                       # leer → zufällig
var belohnung_welt_pos = Vector2(640, 200)
var spieler = null

var _fertig = false
var _cooldown = 0.0
var steine := {}        # Vector2i -> StaticBody2D (schiebbar)
var platten := []       # Array[Vector2i]         (Variante "platten")
var _waende := {}       # Vector2i -> StaticBody2D (interne Wände)
var _gruben := {}       # Vector2i -> {node, gefuellt}
var _ziel := Vector2i(-999, -999)       # Zielzelle (Varianten "weg"/"grube")
var _sperr_zone := {}

# Variante "platten": Spieler + Leiche zählen als Gewicht
const KEINE_ZELLE = Vector2i(-999, -999)
var braucht_leiche = false              # ab Welt 5: eine Platte ist für die Leiche reserviert
var _leiche_zelle := KEINE_ZELLE
var _leiche_node: StaticBody2D = null
var _blick := Vector2i(1, 0)            # letzte Bewegungsrichtung (für E-Ablegen)

# Spezialsteine / Stollen
var _stein_typ := {}      # Vector2i -> "gleit" | "riss"  ("normal" wird nicht gespeichert)
var _riss_fest := {}      # Vector2i -> true (festgesetzte Risssteine, Körper liegt in _waende)
var _fels_zellen := []    # Array[Vector2i] Fels-Deko (Körper liegt in _waende)

# Snapshot für Reset
var _start_steine := []   # Array[{zelle, typ}]
var _spieler_start := Vector2(200, 360)

func _ready():
	spieler = get_tree().get_first_node_in_group("spieler")
	z_index = 0          # Brett bleibt unter dem Spieler (z_index 1)
	if variante == "":
		variante = ["platten", "grube"][randi() % 2]   # "stollen" ersetzt durch raetsel_sokoban.gd
	if variante == "stollen" or variante == "weg":
		zelle = 60.0
		cols = 18
		rows = 9
		ursprung = Vector2(130, 120)
	_generieren()
	_start_steine = []
	for c in steine:
		_start_steine.append({"zelle": c, "typ": _stein_typ.get(c, "normal")})
	if spieler:
		_spieler_start = spieler.global_position
	queue_redraw()

# ── Raster ────────────────────────────────────────────────────────────────────
func _cell_to_world(c: Vector2i) -> Vector2:
	return ursprung + Vector2(c.x, c.y) * zelle

func _world_to_cell(p: Vector2) -> Vector2i:
	return Vector2i(roundi((p.x - ursprung.x) / zelle), roundi((p.y - ursprung.y) / zelle))

func _in_grid(c: Vector2i) -> bool:
	return c.x >= 0 and c.x < cols and c.y >= 0 and c.y < rows

func _frei(c: Vector2i) -> bool:
	return _in_grid(c) and not steine.has(c) and not _waende.has(c) \
		and not _gruben.has(c) and not _sperr_zone.has(c) and c != _leiche_zelle

# Feld, auf das ein Stein geschoben werden darf (Grube = erlaubt, wird gefüllt)
func _kann_stein_hin(c: Vector2i) -> bool:
	return _in_grid(c) and not steine.has(c) and not _waende.has(c) and c != _leiche_zelle

# ── Generierung ───────────────────────────────────────────────────────────────
func _generieren():
	# Sperr-Zone (Spieler-Umgebung freihalten) nur für die prozeduralen Varianten.
	# Die Kammer-Vorlagen sind fertig vermessen – dort würde ein ausgesparter
	# Wandblock ein Loch reißen und das Rätsel verfälschen.
	if spieler and variante != "stollen" and variante != "weg":
		var pc = _world_to_cell(spieler.global_position)
		for dx in range(-1, 2):
			for dy in range(-1, 2):
				_sperr_zone[pc + Vector2i(dx, dy)] = true
	match variante:
		"weg", "stollen": _gen_stollen()
		"grube": _gen_grube()
		_:       _gen_platten()

# Platten: Wände + weniger Steine. Es gilt: Platten = Steine + 1 (Spieler)
# + 1 (Leiche, ab Welt 5). Aufbau vom gelösten Zustand aus (Steine starten auf
# Platten, Rückzüge verwürfeln) → lösbar. Erreichbarkeit wird zusätzlich geprüft.
func _gen_platten():
	belohnung_welt_pos = Vector2(640, 200)
	braucht_leiche = welt >= 5
	var platten_ziel = clampi(3 + welt / 2, 3, 7)
	var steine_ziel  = maxi(1, platten_ziel - (2 if braucht_leiche else 1))
	var waende_ziel  = clampi(1 + welt, 2, 10)

	var spieler_zelle = Vector2i(1, 3)
	if spieler:
		spieler_zelle = _world_to_cell(spieler.global_position)
		spieler_zelle.x = clampi(spieler_zelle.x, 0, cols - 1)
		spieler_zelle.y = clampi(spieler_zelle.y, 0, rows - 1)

	for versuch in 80:
		_layout_leeren()

		# Wände setzen
		var gesetzt = 0
		var tries = 0
		while gesetzt < waende_ziel and tries < 300:
			tries += 1
			var c = Vector2i(randi() % cols, randi() % rows)
			if not _frei(c) or c == spieler_zelle:
				continue
			_wand_setzen(c)
			gesetzt += 1

		# Genug zusammenhängende freie Fläche?
		var erreichbar = _flutung(spieler_zelle, {})
		if erreichbar.size() < (cols * rows) / 2:
			continue

		# Platten wählen: erreichbar, nicht benachbart, Rückzug möglich
		var kandidaten = erreichbar.keys()
		kandidaten.shuffle()
		for c in kandidaten:
			if platten.size() >= platten_ziel:
				break
			if _sperr_zone.has(c) or c == spieler_zelle:
				continue
			if not _rueckzug_moeglich(c):
				continue
			var zu_nah = false
			for p in platten:
				var d = (p - c).abs()
				if d.x + d.y < 2:
					zu_nah = true
					break
			if not zu_nah:
				platten.append(c)
		if platten.size() < platten_ziel:
			continue

		# Steine auf die ersten Platten (Rest bleibt für Spieler/Leiche frei)
		for i in steine_ziel:
			_stein_setzen(platten[i])

		# Endzustand prüfen: freie Platten müssen erreichbar bleiben,
		# wenn alle Steine auf ihren Platten stehen
		var end_hindernis = {}
		for i in steine_ziel:
			end_hindernis[platten[i]] = true
		var end_erreichbar = _flutung(spieler_zelle, end_hindernis)
		var end_ok = true
		for i in range(steine_ziel, platten_ziel):
			if not end_erreichbar.has(platten[i]):
				end_ok = false
				break
		if not end_ok:
			continue

		# Belohnungsposition: freie erreichbare Zelle nahe der Feldmitte
		var best = spieler_zelle
		var best_d = 1e9
		for c in end_erreichbar:
			var d = Vector2(c - Vector2i(6, 3)).length()
			if d < best_d:
				best_d = d
				best = c
		belohnung_welt_pos = _cell_to_world(best)

		# Verwürfeln (Rückzüge vom gelösten Zustand aus)
		for i in (8 + welt * 4):
			_einen_rueckzug()
		var schutz = 0
		while _alle_steine_belegt() and schutz < 60:
			schutz += 1
			if not _einen_rueckzug():
				break
		return

	# Fallback: ohne Wände (alte, einfache Logik)
	_layout_leeren()
	var versuche = 0
	while platten.size() < platten_ziel and versuche < 500:
		versuche += 1
		var c = Vector2i(randi() % cols, randi() % rows)
		if not _frei(c) or c in platten:
			continue
		platten.append(c)
		if steine.size() < steine_ziel:
			_stein_setzen(c)
	for i in (8 + welt * 3):
		_einen_rueckzug()

func _layout_leeren():
	for c in steine:
		steine[c].queue_free()
	steine.clear()
	for c in _waende:
		_waende[c].queue_free()
	_waende.clear()
	platten = []
	_stein_typ.clear()
	_riss_fest.clear()
	_fels_zellen = []

# BFS über freie Zellen (Wände + extra Hindernisse blockieren)
func _flutung(start: Vector2i, extra: Dictionary) -> Dictionary:
	var gesehen = {start: true}
	var queue = [start]
	while not queue.is_empty():
		var c = queue.pop_front()
		for d in DIRS:
			var n = c + d
			if _in_grid(n) and not _waende.has(n) and not extra.has(n) and not gesehen.has(n):
				gesehen[n] = true
				queue.append(n)
	return gesehen

# Kann ein Stein von dieser Zelle weggezogen werden? (nur Wände betrachtet)
func _rueckzug_moeglich(c: Vector2i) -> bool:
	for d in DIRS:
		var ziel   = c + d
		var hinter = c + d * 2
		if _in_grid(ziel) and not _waende.has(ziel) and not _sperr_zone.has(ziel) \
				and _in_grid(hinter) and not _waende.has(hinter) and not _sperr_zone.has(hinter):
			return true
	return false

# ── Kammern (Variante "stollen") ──────────────────────────────────────────────
# Handgebaute, per Löser vermessene Vorlagen (raetsel_kammern_daten.gd). Zur
# Laufzeit wird nur eine zur Welt passende Vorlage gewählt und zufällig
# gespiegelt. Spiegeln erhält Lösbarkeit und Schwierigkeit exakt → sofort da,
# garantiert lösbar, garantiert im Zielbereich der Schwierigkeit.
const KAMMER_DATEN = preload("res://raetsel_kammern_daten.gd")

func _gen_stollen():
	var ziel_m = clampi(2 + welt, 3, 12)   # Welt 1→3 Schübe ... Welt 8→10 Schübe
	# Vorlagen mit der am besten passenden Schubzahl sammeln
	var kandidaten = []
	var beste_diff = 999
	for vorlage in KAMMER_DATEN.VORLAGEN:
		var diff = absi(int(vorlage.m) - ziel_m)
		if diff < beste_diff:
			beste_diff = diff
			kandidaten = [vorlage]
		elif diff == beste_diff:
			kandidaten.append(vorlage)
	if kandidaten.is_empty():
		return
	var gewaehlt = kandidaten[randi() % kandidaten.size()]
	# Nur vertikal spiegeln: Der Spieler betritt den Raum immer von links, die
	# Spiegelachse ist genau seine Startreihe → Schwierigkeit bleibt erhalten.
	# (Horizontal würde den Eingang nach rechts legen und den Raum verfälschen.)
	_vorlage_setzen(gewaehlt.zeilen, false, randi() % 2 == 1)

func _vorlage_setzen(zeilen: Array, mx: bool, my: bool):
	_layout_leeren()
	for y in zeilen.size():
		var zeile: String = zeilen[y]
		for x in zeile.length():
			var ch = zeile[x]
			if ch == "." or ch == " " or ch == "E":
				continue
			var tx = (cols - 1 - x) if mx else x
			var ty = (rows - 1 - y) if my else y
			var c = Vector2i(tx, ty)
			match ch:
				"#", "X": _wand_setzen(c)
				"S": _stein_setzen(c, "normal")
				"G": _stein_setzen(c, "gleit")
				"R": _stein_setzen(c, "riss")
				"Z":
					_ziel = c
					belohnung_welt_pos = _cell_to_world(c)


func _gen_grube():
	for versuch in 200:
		var aus = DIRS[randi() % DIRS.size()]
		var g = Vector2i(randi() % cols, randi() % rows)
		var pit = g + aus
		var stein_c = g + aus * 2
		var schieber = g + aus * 3
		if not (_frei(g) and _frei(pit) and _frei(stein_c) and _frei(schieber)):
			continue
		_ziel = g
		belohnung_welt_pos = _cell_to_world(g)
		for d in DIRS:
			if d != aus:
				_wand_setzen(g + d)
		_grube_setzen(pit)
		_stein_setzen(stein_c)
		return
	_gen_platten()   # Fallback

func _einen_rueckzug() -> bool:
	var cells = steine.keys()
	cells.shuffle()
	for sc in cells:
		var richtungen = DIRS.duplicate()
		richtungen.shuffle()
		for d in richtungen:
			var ziel = sc - d
			var hinter = sc - d * 2
			if _frei(ziel) and _in_grid(hinter) and not steine.has(hinter) and not _sperr_zone.has(hinter):
				_stein_bewegen(sc, ziel, false)
				return true
	return false

# Gewicht auf jeder Platte? Stein, Leiche oder der Spieler selbst zählen.
func _alle_belegt() -> bool:
	var sz = _spieler_zelle()
	for c in platten:
		if not (steine.has(c) or c == _leiche_zelle or c == sz):
			return false
	return true

# Nur Steine (für die Generierung: Startzustand darf nicht schon fertig sein)
func _alle_steine_belegt() -> bool:
	for c in platten:
		if not steine.has(c):
			return false
	return true

func _spieler_zelle() -> Vector2i:
	if spieler == null:
		return KEINE_ZELLE
	return _world_to_cell(spieler.global_position)

# ── Node-Erzeugung ────────────────────────────────────────────────────────────
func _body_mit_box(c: Vector2i) -> StaticBody2D:
	var sb = StaticBody2D.new()
	var cs = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(zelle - 6, zelle - 6)
	cs.shape = shape
	sb.add_child(cs)
	sb.position = _cell_to_world(c)
	add_child(sb)
	return sb

func _stein_setzen(c: Vector2i, typ: String = "normal"):
	steine[c] = _body_mit_box(c)
	if typ != "normal":
		_stein_typ[c] = typ

func _wand_setzen(c: Vector2i):
	if not _in_grid(c) or _sperr_zone.has(c):
		return
	_waende[c] = _body_mit_box(c)

func _grube_setzen(c: Vector2i):
	if not _in_grid(c):
		return
	_gruben[c] = {"node": _body_mit_box(c), "gefuellt": false}

func _stein_bewegen(von: Vector2i, nach: Vector2i, animiert: bool, dauer := 0.09):
	var sb = steine[von]
	steine.erase(von)
	steine[nach] = sb
	var t = _stein_typ.get(von, "")
	if t != "":
		_stein_typ.erase(von)
		_stein_typ[nach] = t
	if animiert:
		create_tween().tween_property(sb, "position", _cell_to_world(nach), dauer)
	else:
		sb.position = _cell_to_world(nach)

func _grube_fuellen(pit: Vector2i, stein_von: Vector2i):
	steine[stein_von].queue_free()
	steine.erase(stein_von)
	_gruben[pit]["gefuellt"] = true
	_gruben[pit]["node"].get_child(0).set_deferred("disabled", true)   # begehbar

# ── Schieben ──────────────────────────────────────────────────────────────────
func _process(delta):
	if _fertig or spieler == null:
		return
	if _cooldown > 0.0:
		_cooldown -= delta
	queue_redraw()
	_schieben_pruefen()
	if variante == "platten":
		if _alle_belegt():
			_loesen()
	elif _world_to_cell(spieler.global_position) == _ziel:
		_loesen()

func _schieben_pruefen():
	var ix = (1 if Input.is_key_pressed(KEY_D) else 0) - (1 if Input.is_key_pressed(KEY_A) else 0)
	var iy = (1 if Input.is_key_pressed(KEY_S) else 0) - (1 if Input.is_key_pressed(KEY_W) else 0)
	if (ix != 0) == (iy != 0):
		return
	var pdir = Vector2i(ix, iy)
	_blick = pdir
	if _cooldown > 0.0:
		return
	var pp = spieler.global_position
	var pc = _world_to_cell(pp + Vector2(pdir) * (zelle * 0.55))
	var ist_leiche = (pc == _leiche_zelle)
	if not steine.has(pc) and not ist_leiche:
		return
	var versatz = pp - _cell_to_world(pc)
	var perp = versatz.x if pdir.y != 0 else versatz.y
	if abs(perp) > zelle * 0.35:
		return
	var ziel = pc + pdir
	if not _kann_stein_hin(ziel):
		return
	var typ = "" if ist_leiche else _stein_typ.get(pc, "normal")
	if ist_leiche:
		_leiche_zelle = ziel
		create_tween().tween_property(_leiche_node, "position", _cell_to_world(ziel), 0.09)
	elif typ == "gleit":
		# Gleitstein: rutscht bis zum Anschlag
		var z = ziel
		while _kann_stein_hin(z + pdir):
			z += pdir
		var dist = (z - pc).abs()
		_stein_bewegen(pc, z, true, clampf(0.05 * (dist.x + dist.y), 0.09, 0.4))
	elif typ == "riss":
		# Rissstein: ein einziger Schub, danach sitzt er fest
		var node = steine[pc]
		steine.erase(pc)
		_stein_typ.erase(pc)
		create_tween().tween_property(node, "position", _cell_to_world(ziel), 0.09)
		_waende[ziel] = node
		_riss_fest[ziel] = true
	elif _gruben.has(ziel) and not _gruben[ziel]["gefuellt"]:
		_grube_fuellen(ziel, pc)
	else:
		_stein_bewegen(pc, ziel, true)
	_cooldown = 0.14

# ── Leiche ablegen / aufheben (E) ─────────────────────────────────────────────
func _input(event):
	if _fertig or spieler == null or variante != "platten":
		return
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if event.keycode != KEY_E:
		return
	var pz = _spieler_zelle()
	if global_data.leichen > 0:
		var ziel = pz + _blick
		if _kann_stein_hin(ziel) and ziel != pz:
			global_data.leichen -= 1
			_leiche_setzen(ziel)
	elif _leiche_zelle != KEINE_ZELLE:
		var d = (_leiche_zelle - pz).abs()
		if d.x + d.y == 1:
			_leiche_entfernen()
			global_data.leichen += 1
	queue_redraw()

func _leiche_setzen(c: Vector2i):
	_leiche_node = _body_mit_box(c)
	_leiche_zelle = c

func _leiche_entfernen():
	if _leiche_node and is_instance_valid(_leiche_node):
		_leiche_node.queue_free()
	_leiche_node = null
	_leiche_zelle = KEINE_ZELLE

# ── Reset (R, via raum_raetsel begrenzt) ──────────────────────────────────────
func zuruecksetzen():
	if _fertig:
		return
	for c in steine:
		steine[c].queue_free()
	steine.clear()
	_stein_typ.clear()
	# Festgesetzte Risssteine wieder lösen (liegen als Wand-Körper vor)
	for c in _riss_fest:
		if _waende.has(c):
			_waende[c].queue_free()
			_waende.erase(c)
	_riss_fest.clear()
	if _leiche_zelle != KEINE_ZELLE:
		_leiche_entfernen()
		global_data.leichen += 1
	for s in _start_steine:
		_stein_setzen(s.zelle, s.typ)
	if spieler:
		spieler.global_position = _spieler_start
	_cooldown = 0.3
	queue_redraw()

func _loesen():
	if _fertig:
		return
	_fertig = true
	geloest.emit()

func aufloesen():
	_fertig = true
	for c in steine:
		steine[c].queue_free()
	steine.clear()
	for c in _waende:
		_waende[c].queue_free()
	_waende.clear()
	for c in _gruben:
		_gruben[c]["node"].queue_free()
	_gruben.clear()
	_stein_typ.clear()
	_riss_fest.clear()
	_fels_zellen = []
	if _leiche_zelle != KEINE_ZELLE:
		_leiche_entfernen()
		global_data.leichen += 1
	queue_redraw()

# ── Zeichnen ──────────────────────────────────────────────────────────────────
func _draw():
	for cx in cols:
		for cy in rows:
			var w = _cell_to_world(Vector2i(cx, cy))
			draw_rect(Rect2(w - Vector2(zelle / 2, zelle / 2), Vector2(zelle, zelle)),
				Color(1, 1, 1, 0.035), false, 1.0)

	for c in _gruben:
		var w = _cell_to_world(c)
		var r = Rect2(w - Vector2(zelle / 2 - 4, zelle / 2 - 4), Vector2(zelle - 8, zelle - 8))
		if _gruben[c]["gefuellt"]:
			draw_rect(r, Color(0.22, 0.20, 0.30))
		else:
			draw_rect(r, Color(0.02, 0.02, 0.05))
			draw_rect(r, Color(0.35, 0.30, 0.15), false, 2.0)

	for c in _waende:
		if _riss_fest.has(c) or c in _fels_zellen:
			continue
		var w = _cell_to_world(c)
		draw_rect(Rect2(w - Vector2(zelle / 2, zelle / 2), Vector2(zelle, zelle)), Color(0.15, 0.12, 0.25))
		draw_rect(Rect2(w - Vector2(zelle / 2, zelle / 2), Vector2(zelle, zelle)), Color(0.25, 0.20, 0.40), false, 2.0)

	# Parkbuchten werden bewusst NICHT markiert – der Spieler soll selbst
	# erkennen, wohin die Steine müssen. Sie sind nur als Lücken im Fels sichtbar.

	# Fels: unbeweglich, blockiert eine Bucht
	for c in _fels_zellen:
		var w = _cell_to_world(c)
		var r = zelle * 0.40
		draw_circle(w + Vector2(3, 4), r, Color(0, 0, 0, 0.3))
		draw_circle(w, r, Color(0.24, 0.22, 0.20))
		draw_arc(w, r, 0, TAU, 8, Color(0.36, 0.33, 0.29), 3.0)

	# Festgesetzte Risssteine
	for c in _riss_fest:
		var w = _cell_to_world(c)
		var r = zelle * 0.40
		var basis = Color(0.40, 0.36, 0.33)
		draw_circle(w + Vector2(3, 4), r, Color(0, 0, 0, 0.25))
		draw_circle(w, r, basis)
		draw_arc(w, r, 0, TAU, 22, basis.lightened(0.25), 3.0)
		_risse_zeichnen(w, r, Color(0.12, 0.10, 0.08))

	var sz = _spieler_zelle()
	for c in platten:
		var w = _cell_to_world(c)
		var belegt = steine.has(c) or c == _leiche_zelle or c == sz
		var f = Color(0.3, 0.9, 0.45) if belegt else Color(0.95, 0.8, 0.2)
		draw_circle(w, zelle * 0.30, Color(f.r, f.g, f.b, 0.20))
		draw_arc(w, zelle * 0.30, 0, TAU, 28, f, 3.0)
		if c == sz and not _fertig:
			# Platte unter dem Spieler leuchtet deutlich auf
			draw_circle(w, zelle * 0.30, Color(0.3, 0.9, 0.45, 0.30))

	if _ziel.x >= 0 and not _fertig:
		var wz = _cell_to_world(_ziel)
		var gold = Color(1.0, 0.85, 0.25)
		draw_circle(wz, zelle * 0.30, Color(gold.r, gold.g, gold.b, 0.22))
		draw_arc(wz, zelle * 0.30, 0, TAU, 28, gold, 3.0)
		draw_arc(wz, zelle * 0.16, 0, TAU, 20, gold, 2.0)

	for c in steine:
		var w = steine[c].position
		var r = zelle * 0.40
		var typ = _stein_typ.get(c, "normal")
		draw_circle(w + Vector2(3, 4), r, Color(0, 0, 0, 0.25))
		if typ == "gleit":
			draw_circle(w, r, Color(0.36, 0.50, 0.64))
			draw_arc(w, r, 0, TAU, 22, Color(0.60, 0.78, 0.95), 3.0)
			draw_arc(w, r * 0.55, PI * 1.1, PI * 1.6, 10, Color(0.85, 0.95, 1.0, 0.9), 2.0)
			draw_arc(w, r * 0.75, PI * 1.15, PI * 1.5, 10, Color(0.85, 0.95, 1.0, 0.5), 2.0)
		elif typ == "riss":
			draw_circle(w, r, Color(0.44, 0.41, 0.37))
			draw_arc(w, r, 0, TAU, 22, Color(0.62, 0.59, 0.53), 3.0)
			_risse_zeichnen(w, r, Color(0.15, 0.12, 0.10))
		else:
			draw_circle(w, r, Color(0.44, 0.41, 0.37))
			draw_arc(w, r, 0, TAU, 22, Color(0.62, 0.59, 0.53), 3.0)
			draw_circle(w - Vector2(r * 0.35, r * 0.35), r * 0.22, Color(0.56, 0.54, 0.49))

	if _leiche_zelle != KEINE_ZELLE and _leiche_node:
		var wl = _leiche_node.position
		var gold = Color(1.0, 0.85, 0.25)
		var dunkel = Color(0.2, 0.2, 0.15)
		draw_circle(wl + Vector2(3, 5), 16.0, Color(0, 0, 0, 0.25))
		draw_arc(wl, zelle * 0.36, 0, TAU, 28, Color(gold.r, gold.g, gold.b, 0.8), 2.0)
		draw_circle(wl + Vector2(5, 4), 12.0, Color(0.55, 0.58, 0.5))
		draw_circle(wl + Vector2(-9, -2), 8.0, Color(0.72, 0.68, 0.58))
		draw_line(wl + Vector2(-12, -5), wl + Vector2(-8, -1), dunkel, 1.5)
		draw_line(wl + Vector2(-8, -5), wl + Vector2(-12, -1), dunkel, 1.5)

	if not _fertig:
		var text = "Schiebe alle Steine auf die Felder"
		if variante == "weg" or variante == "stollen":
			text = "Schiebe die Steine beiseite und bahn dir den Weg zur Belohnung"
		elif variante == "grube":
			text = "Schiebe den Stein in die Grube und geh hinüber"
		draw_string(ThemeDB.fallback_font, Vector2(340, 706), text,
			HORIZONTAL_ALIGNMENT_CENTER, 600, 18, Color(0.85, 0.85, 0.9, 0.9))

func _risse_zeichnen(w: Vector2, r: float, farbe: Color):
	draw_line(w + Vector2(-r * 0.55, -r * 0.15), w + Vector2(-r * 0.1, 0.0), farbe, 2.0)
	draw_line(w + Vector2(-r * 0.1, 0.0), w + Vector2(r * 0.4, -r * 0.45), farbe, 2.0)
	draw_line(w + Vector2(-r * 0.1, 0.0), w + Vector2(r * 0.35, r * 0.4), farbe, 2.0)
