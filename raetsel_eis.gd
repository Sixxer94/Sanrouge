extends Node2D

# Eis-Rutschen: Mit WASD antippen → der Spieler rutscht bis zur nächsten Wand
# oder zum nächsten Fels und stoppt erst dort. Ziel: das goldene Feld erreichen.
# Layout wird per Erreichbarkeits-Suche geprüft → immer lösbar.

signal geloest

const ZELLE    = 80.0
const COLS     = 14
const ROWS     = 7
const URSPRUNG = Vector2(120, 120)
const DIRS = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
const RUTSCH_TEMPO = 1100.0

# Tür-Korridore: dort ist die Bewegung frei, damit der Raum ungelöst
# verlassen werden kann. Auf dem Eis selbst bleibt sie gesperrt.
const KORRIDORE = {
	"oben":   Rect2(560, 0, 160, 150),
	"unten":  Rect2(560, 570, 160, 150),
	"links":  Rect2(0, 270, 150, 180),
	"rechts": Rect2(1130, 270, 150, 180),
}
const RICHTUNG_VEC = {
	"oben": Vector2i(0, -1), "unten": Vector2i(0, 1),
	"links": Vector2i(-1, 0), "rechts": Vector2i(1, 0),
}

var welt = 1
var variante = ""
var belohnung_welt_pos = Vector2(640, 200)
var spieler = null

var _fertig = false
var _rutscht = false
var _felsen := {}                       # Vector2i -> true
var _start := Vector2i.ZERO
var _ziel := Vector2i(-999, -999)

func _ready():
	spieler = get_tree().get_first_node_in_group("spieler")
	z_index = 0          # Brett bleibt unter dem Spieler (z_index 1)
	_generieren()
	if spieler:
		spieler.bewegung_gesperrt = true
		spieler.global_position = _cell_to_world(_start)
	queue_redraw()

func _exit_tree():
	if spieler and is_instance_valid(spieler):
		spieler.bewegung_gesperrt = false

# ── Raster ────────────────────────────────────────────────────────────────────
func _cell_to_world(c: Vector2i) -> Vector2:
	return URSPRUNG + Vector2(c.x, c.y) * ZELLE

func _world_to_cell(p: Vector2) -> Vector2i:
	return Vector2i(roundi((p.x - URSPRUNG.x) / ZELLE), roundi((p.y - URSPRUNG.y) / ZELLE))

func _in_grid(c: Vector2i) -> bool:
	return c.x >= 0 and c.x < COLS and c.y >= 0 and c.y < ROWS

func _rutsch_ziel(start: Vector2i, dir: Vector2i) -> Vector2i:
	var c = start
	while true:
		var n = c + dir
		if not _in_grid(n) or _felsen.has(n):
			break
		c = n
	return c

func _erreichbar(start: Vector2i) -> Dictionary:
	var dist = {start: 0}
	var queue = [start]
	while not queue.is_empty():
		var c = queue.pop_front()
		for dir in DIRS:
			var z = _rutsch_ziel(c, dir)
			if z != c and not dist.has(z):
				dist[z] = dist[c] + 1
				queue.append(z)
	return dist

# ── Generierung ───────────────────────────────────────────────────────────────
func _generieren():
	var s = _world_to_cell(spieler.global_position) if spieler else Vector2i(1, 3)
	s.x = clampi(s.x, 0, COLS - 1)
	s.y = clampi(s.y, 0, ROWS - 1)
	_start = s
	# Da der Raum verlassen und durch jede Tür wieder betreten werden kann,
	# muss das Ziel von allen Tür-Eintrittszellen aus erreichbar sein.
	var eintritte = _eintritts_zellen()
	var anzahl = clampi(4 + welt, 5, 18)
	for versuch in 60:
		_felsen = {}
		var gesetzt = 0
		var tries = 0
		while gesetzt < anzahl and tries < 400:
			tries += 1
			var c = Vector2i(randi() % COLS, randi() % ROWS)
			if c == _start or _felsen.has(c) or c in eintritte:
				continue
			_felsen[c] = true
			gesetzt += 1
		var dist = _erreichbar(_start)
		var e_sets = []
		for e in eintritte:
			e_sets.append(_erreichbar(e))
		var best = _start
		var bd = 0
		for c in dist:
			if c in eintritte:
				continue
			var ueberall = true
			for es in e_sets:
				if not es.has(c):
					ueberall = false
					break
			if ueberall and dist[c] > bd:
				bd = dist[c]
				best = c
		if bd >= 2:
			_ziel = best
			belohnung_welt_pos = _cell_to_world(best)
			return
	# Fallback ohne Felsen: Ziel = fernste Ecke (Ecken sind von überall erreichbar)
	_felsen = {}
	var ecken = [Vector2i(0, 0), Vector2i(COLS - 1, 0),
		Vector2i(0, ROWS - 1), Vector2i(COLS - 1, ROWS - 1)]
	var best2 = ecken[0]
	var bd2 = -1
	for e in ecken:
		var d = absi(e.x - _start.x) + absi(e.y - _start.y)
		if d > bd2:
			bd2 = d
			best2 = e
	_ziel = best2
	belohnung_welt_pos = _cell_to_world(best2)

# Zellen, auf denen der Spieler beim Betreten durch eine Tür aufs Eis tritt
func _eintritts_zellen() -> Array:
	var zellen = []
	if _tuer_vorhanden("oben"):
		zellen += [Vector2i(6, 0), Vector2i(7, 0)]
	if _tuer_vorhanden("unten"):
		zellen += [Vector2i(6, ROWS - 1), Vector2i(7, ROWS - 1)]
	if _tuer_vorhanden("links"):
		zellen += [Vector2i(0, 2), Vector2i(0, 3), Vector2i(0, 4)]
	if _tuer_vorhanden("rechts"):
		zellen += [Vector2i(COLS - 1, 2), Vector2i(COLS - 1, 3), Vector2i(COLS - 1, 4)]
	return zellen

# ── Rutschen ──────────────────────────────────────────────────────────────────
func _input(event):
	if _fertig or _rutscht or spieler == null:
		return
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	var dir := Vector2i.ZERO
	match event.keycode:
		KEY_D: dir = Vector2i(1, 0)
		KEY_A: dir = Vector2i(-1, 0)
		KEY_S: dir = Vector2i(0, 1)
		KEY_W: dir = Vector2i(0, -1)
		_: return
	if not spieler.bewegung_gesperrt:
		return   # Spieler ist im Tür-Korridor unterwegs → kein Rutschen
	var cur = _world_to_cell(spieler.global_position)
	var ziel = _rutsch_ziel(cur, dir)
	if ziel == cur:
		# Am Feldrand Richtung Tür gedrückt → Bewegung freigeben zum Verlassen
		if not _in_grid(cur + dir):
			for r in KORRIDORE:
				if RICHTUNG_VEC[r] == dir and _tuer_vorhanden(r) \
						and KORRIDORE[r].has_point(spieler.global_position):
					spieler.bewegung_gesperrt = false
		return
	_rutscht = true
	var dur = (Vector2(ziel - cur).length() * ZELLE) / RUTSCH_TEMPO
	var tw = create_tween()
	tw.tween_property(spieler, "global_position", _cell_to_world(ziel), dur)
	tw.tween_callback(_rutsch_fertig.bind(ziel))

# Betritt der Spieler das Eis (außerhalb der Tür-Korridore), wird die Bewegung
# wieder gesperrt und er rastet auf der nächsten Zelle ein.
func _process(_delta):
	if _fertig or spieler == null or _rutscht:
		return
	if spieler.bewegung_gesperrt:
		return
	var p = spieler.global_position
	if _im_korridor(p):
		return
	spieler.bewegung_gesperrt = true
	var c = _world_to_cell(p)
	c.x = clampi(c.x, 0, COLS - 1)
	c.y = clampi(c.y, 0, ROWS - 1)
	if _felsen.has(c):
		for d in DIRS:
			var n = c + d
			if _in_grid(n) and not _felsen.has(n):
				c = n
				break
	spieler.global_position = _cell_to_world(c)
	queue_redraw()

func _im_korridor(p: Vector2) -> bool:
	for r in KORRIDORE:
		if _tuer_vorhanden(r) and KORRIDORE[r].has_point(p):
			return true
	return false

func _tuer_vorhanden(richtung: String) -> bool:
	var r = get_parent()
	if r == null or not "wand_richtungen" in r:
		return true
	return not richtung in r.wand_richtungen

func _rutsch_fertig(ziel: Vector2i):
	_rutscht = false
	if ziel == _ziel:
		_fertig = true
		if spieler and is_instance_valid(spieler):
			spieler.bewegung_gesperrt = false
		geloest.emit()

func aufloesen():
	_fertig = true
	if spieler and is_instance_valid(spieler):
		spieler.bewegung_gesperrt = false
	queue_redraw()

# ── Zeichnen ──────────────────────────────────────────────────────────────────
func _draw():
	for cx in COLS:
		for cy in ROWS:
			var w = _cell_to_world(Vector2i(cx, cy))
			var r = Rect2(w - Vector2(ZELLE / 2, ZELLE / 2), Vector2(ZELLE, ZELLE))
			draw_rect(r, Color(0.55, 0.75, 0.92, 0.12))
			draw_rect(r, Color(0.75, 0.88, 1.0, 0.10), false, 1.0)

	if _ziel.x >= 0 and not _fertig:
		var wz = _cell_to_world(_ziel)
		var gold = Color(1.0, 0.85, 0.25)
		draw_circle(wz, ZELLE * 0.30, Color(gold.r, gold.g, gold.b, 0.22))
		draw_arc(wz, ZELLE * 0.30, 0, TAU, 28, gold, 3.0)
		draw_arc(wz, ZELLE * 0.16, 0, TAU, 20, gold, 2.0)

	for c in _felsen:
		var w = _cell_to_world(c)
		var rad = ZELLE * 0.40
		draw_circle(w + Vector2(3, 4), rad, Color(0, 0, 0, 0.25))
		draw_circle(w, rad, Color(0.42, 0.48, 0.58))
		draw_arc(w, rad, 0, TAU, 22, Color(0.62, 0.72, 0.85), 3.0)
		draw_circle(w - Vector2(rad * 0.35, rad * 0.35), rad * 0.22, Color(0.72, 0.82, 0.95))

	if not _fertig:
		draw_string(ThemeDB.fallback_font, Vector2(340, 706),
			"Rutsche übers Eis (WASD antippen) bis zum goldenen Feld",
			HORIZONTAL_ALIGNMENT_CENTER, 600, 18, Color(0.85, 0.9, 1.0, 0.9))
