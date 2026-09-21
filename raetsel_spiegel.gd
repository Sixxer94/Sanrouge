extends Node2D

# Spiegel-Laser: Ein Emitter sendet einen Strahl. Schiebe die Spiegel-Steine
# (Sokoban), um den Strahl auf den Ziel-Kristall umzulenken.
# Layout wird über einen Lösungspfad konstruiert und dann verwürfelt → lösbar.

signal geloest

const ZELLE    = 80.0
const COLS     = 14
const ROWS     = 7
const URSPRUNG = Vector2(120, 120)
const DIRS = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]

var welt = 1
var variante = ""
var belohnung_welt_pos = Vector2(640, 200)
var spieler = null

var _fertig = false
var _cooldown = 0.0
var _spiegel := {}      # Vector2i -> {"node": StaticBody2D, "typ": "/" | "\\"}
var _emitter := Vector2i.ZERO
var _emitter_dir := Vector2i(1, 0)
var _ziel := Vector2i.ZERO
var _pfad := []
var _getroffen = false
var _loesung := []      # nur zum Testen/Verifizieren: gelöste Spiegel-Positionen
var _start_spiegel := []   # verwürfelter Startzustand (für R-Reset)

func _ready():
	spieler = get_tree().get_first_node_in_group("spieler")
	z_index = 0          # Brett bleibt unter dem Spieler (z_index 1)
	_generieren()
	queue_redraw()

# ── Raster ────────────────────────────────────────────────────────────────────
func _cell_to_world(c: Vector2i) -> Vector2:
	return URSPRUNG + Vector2(c.x, c.y) * ZELLE

func _world_to_cell(p: Vector2) -> Vector2i:
	return Vector2i(roundi((p.x - URSPRUNG.x) / ZELLE), roundi((p.y - URSPRUNG.y) / ZELLE))

func _in_grid(c: Vector2i) -> bool:
	return c.x >= 0 and c.x < COLS and c.y >= 0 and c.y < ROWS

func _reflect(d: Vector2i, typ: String) -> Vector2i:
	if typ == "/":
		return Vector2i(-d.y, -d.x)
	return Vector2i(d.y, d.x)

# ── Strahl verfolgen ──────────────────────────────────────────────────────────
func _strahl(spiegel_map: Dictionary) -> Dictionary:
	var pfad = [_emitter]
	var c = _emitter
	var d = _emitter_dir
	var getroffen = false
	var k = 0
	while k < 300:
		k += 1
		var n = c + d
		if not _in_grid(n):
			break
		pfad.append(n)
		if n == _ziel:
			getroffen = true
			break
		if spiegel_map.has(n):
			d = _reflect(d, spiegel_map[n])
		c = n
	return {"pfad": pfad, "getroffen": getroffen}

func _aktuelle_map() -> Dictionary:
	var m = {}
	for c in _spiegel:
		m[c] = _spiegel[c]["typ"]
	return m

func _trifft(spiegel_arr: Array) -> bool:
	var m = {}
	for sd in spiegel_arr:
		m[sd.cell] = sd.typ
	var c = _emitter
	var d = _emitter_dir
	var k = 0
	while k < 300:
		k += 1
		var n = c + d
		if not _in_grid(n):
			return false
		if n == _ziel:
			return true
		if m.has(n):
			d = _reflect(d, m[n])
		c = n
	return false

# ── Generierung ───────────────────────────────────────────────────────────────
func _generieren():
	var K = clampi(1 + welt / 3, 1, 3)
	var layout = null
	for versuch in 250:
		layout = _layout_bauen(K)
		if layout != null:
			break
	if layout == null:
		layout = _layout_bauen(1)
	if layout == null:
		# Notfall: trivialer 1-Spiegel-Aufbau
		_emitter = Vector2i(0, 3); _emitter_dir = Vector2i(1, 0); _ziel = Vector2i(6, 0)
		layout = {"emitter": _emitter, "dir": _emitter_dir, "ziel": _ziel,
			"spiegel": [{"cell": Vector2i(6, 3), "typ": "/"}]}

	_emitter = layout.emitter
	_emitter_dir = layout.dir
	_ziel = layout.ziel
	_loesung = []
	for sd in layout.spiegel:
		_loesung.append({"cell": sd.cell, "typ": sd.typ})

	var verwuerfelt = _verwuerfeln(layout)
	for sd in verwuerfelt:
		_spiegel_setzen(sd.cell, sd.typ)
		_start_spiegel.append({"cell": sd.cell, "typ": sd.typ})
	belohnung_welt_pos = _cell_to_world(_ziel)

func _layout_bauen(K: int):
	var emitter: Vector2i
	var dir: Vector2i
	match randi() % 4:
		0: emitter = Vector2i(0, randi() % ROWS); dir = Vector2i(1, 0)
		1: emitter = Vector2i(COLS - 1, randi() % ROWS); dir = Vector2i(-1, 0)
		2: emitter = Vector2i(randi() % COLS, 0); dir = Vector2i(0, 1)
		_: emitter = Vector2i(randi() % COLS, ROWS - 1); dir = Vector2i(0, -1)

	var belegt = {emitter: true}
	var spiegel = []
	var pos = emitter
	var d = dir
	for b in K:
		var schritte = 1 + randi() % 3
		for s in schritte:
			var n = pos + d
			if not _in_grid(n) or belegt.has(n):
				return null
			pos = n
		var perp = [Vector2i(-d.y, -d.x), Vector2i(d.y, d.x)]
		perp.shuffle()
		var gewaehlt = Vector2i.ZERO
		var ok = false
		for od in perp:
			var nn = pos + od
			if _in_grid(nn) and not belegt.has(nn):
				gewaehlt = od; ok = true; break
		if not ok or belegt.has(pos):
			return null
		var typ = "/" if Vector2i(-d.y, -d.x) == gewaehlt else "\\"
		belegt[pos] = true
		spiegel.append({"cell": pos, "typ": typ})
		d = gewaehlt
	# Zum Ziel weiterlaufen
	var tp = pos
	var schritte2 = 1 + randi() % 4
	for s in schritte2:
		var n = tp + d
		if not _in_grid(n) or belegt.has(n):
			break
		tp = n
	if tp == pos or belegt.has(tp):
		return null
	var res = {"emitter": emitter, "dir": dir, "ziel": tp, "spiegel": spiegel}
	# Konstruktion verifizieren
	_emitter = emitter; _emitter_dir = dir; _ziel = tp
	if not _trifft(spiegel):
		return null
	return res

func _verwuerfeln(layout: Dictionary) -> Array:
	var spiegel = []
	for sd in layout.spiegel:
		spiegel.append({"cell": sd.cell, "typ": sd.typ})
	var belegt = {layout.emitter: true, layout.ziel: true}
	for sd in spiegel:
		belegt[sd.cell] = true

	for i in (2 + welt):
		var sd = spiegel[randi() % spiegel.size()]
		var richtungen = DIRS.duplicate(); richtungen.shuffle()
		for dr in richtungen:
			var ziel = sd.cell - dr
			var hinter = sd.cell - dr * 2
			if _in_grid(ziel) and not belegt.has(ziel) and _in_grid(hinter) and not belegt.has(hinter):
				belegt.erase(sd.cell)
				belegt[ziel] = true
				sd.cell = ziel
				break
	# Nicht schon gelöst starten
	var schutz = 0
	while _trifft(spiegel) and schutz < 40:
		schutz += 1
		var sd2 = spiegel[randi() % spiegel.size()]
		for dr in DIRS:
			var ziel = sd2.cell - dr
			var hinter = sd2.cell - dr * 2
			if _in_grid(ziel) and not belegt.has(ziel) and _in_grid(hinter) and not belegt.has(hinter):
				belegt.erase(sd2.cell); belegt[ziel] = true; sd2.cell = ziel
				break
	return spiegel

# ── Spiegel-Nodes / Schieben ──────────────────────────────────────────────────
func _spiegel_setzen(c: Vector2i, typ: String):
	var sb = StaticBody2D.new()
	var cs = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(ZELLE - 6, ZELLE - 6)
	cs.shape = shape
	sb.add_child(cs)
	sb.position = _cell_to_world(c)
	add_child(sb)
	_spiegel[c] = {"node": sb, "typ": typ}

func _kann_stein_hin(c: Vector2i) -> bool:
	return _in_grid(c) and not _spiegel.has(c) and c != _emitter and c != _ziel

func _spiegel_bewegen(von: Vector2i, nach: Vector2i):
	var eintrag = _spiegel[von]
	_spiegel.erase(von)
	_spiegel[nach] = eintrag
	create_tween().tween_property(eintrag["node"], "position", _cell_to_world(nach), 0.09)

func _process(delta):
	if spieler == null:
		return
	if _cooldown > 0.0:
		_cooldown -= delta
	var s = _strahl(_aktuelle_map())
	_pfad = s.pfad
	_getroffen = s.getroffen
	queue_redraw()
	if _getroffen and not _fertig:
		_fertig = true
		geloest.emit()
		return
	if not _fertig:
		_schieben_pruefen()

func _schieben_pruefen():
	if _cooldown > 0.0:
		return
	var ix = (1 if Input.is_key_pressed(KEY_D) else 0) - (1 if Input.is_key_pressed(KEY_A) else 0)
	var iy = (1 if Input.is_key_pressed(KEY_S) else 0) - (1 if Input.is_key_pressed(KEY_W) else 0)
	if (ix != 0) == (iy != 0):
		return
	var pdir = Vector2i(ix, iy)
	var pp = spieler.global_position
	var pc = _world_to_cell(pp + Vector2(pdir) * (ZELLE * 0.55))
	if not _spiegel.has(pc):
		return
	var versatz = pp - _cell_to_world(pc)
	var perp = versatz.x if pdir.y != 0 else versatz.y
	if abs(perp) > 28.0:
		return
	var ziel = pc + pdir
	if not _kann_stein_hin(ziel):
		return
	_spiegel_bewegen(pc, ziel)
	_cooldown = 0.14

func aufloesen():
	_fertig = true
	for c in _spiegel:
		_spiegel[c]["node"].queue_free()
	_spiegel.clear()
	queue_redraw()

# R-Reset (via raum_raetsel begrenzt): Spiegel zurück auf den Startzustand
func zuruecksetzen():
	if _fertig:
		return
	for c in _spiegel:
		_spiegel[c]["node"].queue_free()
	_spiegel.clear()
	for sd in _start_spiegel:
		_spiegel_setzen(sd.cell, sd.typ)
	_cooldown = 0.3
	queue_redraw()

# ── Zeichnen ──────────────────────────────────────────────────────────────────
func _draw():
	for cx in COLS:
		for cy in ROWS:
			var w = _cell_to_world(Vector2i(cx, cy))
			draw_rect(Rect2(w - Vector2(ZELLE / 2, ZELLE / 2), Vector2(ZELLE, ZELLE)),
				Color(1, 1, 1, 0.035), false, 1.0)

	# Strahl
	if _pfad.size() >= 2:
		var pts = PackedVector2Array()
		for c in _pfad:
			pts.append(_cell_to_world(c))
		var farbe = Color(0.4, 1.0, 0.5) if _getroffen else Color(0.9, 0.35, 0.3)
		draw_polyline(pts, Color(farbe.r, farbe.g, farbe.b, 0.35), 8.0)
		draw_polyline(pts, farbe, 3.0)

	# Emitter
	var we = _cell_to_world(_emitter)
	draw_circle(we, ZELLE * 0.34, Color(0.3, 0.3, 0.36))
	draw_circle(we, ZELLE * 0.20, Color(0.9, 0.4, 0.3))
	var spitze = we + Vector2(_emitter_dir) * (ZELLE * 0.34)
	draw_circle(spitze, ZELLE * 0.10, Color(1.0, 0.6, 0.4))

	# Ziel-Kristall
	var wz = _cell_to_world(_ziel)
	var zf = Color(0.4, 1.0, 0.5) if _getroffen else Color(0.55, 0.6, 0.7)
	var d = ZELLE * 0.32
	draw_colored_polygon(PackedVector2Array([
		wz + Vector2(0, -d), wz + Vector2(d, 0), wz + Vector2(0, d), wz + Vector2(-d, 0)]),
		Color(zf.r, zf.g, zf.b, 0.85))
	draw_arc(wz, d, 0, TAU, 4, Color(1, 1, 1, 0.5), 2.0)

	# Spiegel
	for c in _spiegel:
		var w = _cell_to_world(c)
		var r = ZELLE * 0.36
		draw_circle(w, r, Color(0.30, 0.33, 0.40))
		var a: Vector2
		var b: Vector2
		if _spiegel[c]["typ"] == "/":
			a = w + Vector2(-r, r); b = w + Vector2(r, -r)
		else:
			a = w + Vector2(-r, -r); b = w + Vector2(r, r)
		draw_line(a, b, Color(0.7, 0.95, 1.0), 5.0)
		draw_line(a, b, Color(1, 1, 1), 2.0)

	if not _fertig:
		draw_string(ThemeDB.fallback_font, Vector2(340, 706),
			"Schiebe die Spiegel, sodass der Strahl den Kristall trifft",
			HORIZONTAL_ALIGNMENT_CENTER, 600, 18, Color(0.85, 0.9, 1.0, 0.9))
