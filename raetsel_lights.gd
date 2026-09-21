extends Node2D

# Lights Out: Stell dich auf ein Feld und drücke F – das Feld und seine
# 4 Nachbarn schalten um. Ziel: alle Felder leuchten.
# Verwürfelt vom gelösten Zustand aus → immer lösbar.

signal geloest

var welt = 1
var variante = ""
var belohnung_welt_pos = Vector2(640, 200)
var spieler = null

var _fertig = false
var N = 3
var T = 130.0
var _origin = Vector2.ZERO
var zustand := []   # zustand[row][col] : bool

const NACHBARN = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]

func _ready():
	spieler = get_tree().get_first_node_in_group("spieler")
	z_index = 0          # Brett bleibt unter dem Spieler (z_index 1)
	_generieren()
	queue_redraw()

func _generieren():
	N = clampi(3 + welt / 3, 3, 5)
	T = clampf(520.0 / N, 90.0, 150.0)
	_origin = Vector2(640.0 - N * T / 2.0, 360.0 - N * T / 2.0)
	zustand = []
	for r in N:
		var row = []
		for c in N:
			row.append(true)
		zustand.append(row)
	var drucke = 4 + welt * 2
	for i in drucke:
		_umschalten(randi() % N, randi() % N)
	var schutz = 0
	while _alle_an() and schutz < 40:
		schutz += 1
		_umschalten(randi() % N, randi() % N)

func _umschalten(c: int, r: int):
	for d in NACHBARN:
		var cc = c + d.x
		var rr = r + d.y
		if cc >= 0 and cc < N and rr >= 0 and rr < N:
			zustand[rr][cc] = not zustand[rr][cc]

func _alle_an() -> bool:
	for r in N:
		for c in N:
			if not zustand[r][c]:
				return false
	return true

func _spieler_feld() -> Vector2i:
	if spieler == null:
		return Vector2i(-1, -1)
	var p = spieler.global_position
	return Vector2i(int(floor((p.x - _origin.x) / T)), int(floor((p.y - _origin.y) / T)))

func _input(event):
	if _fertig:
		return
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if event.keycode != KEY_F:
		return
	var f = _spieler_feld()
	if f.x < 0 or f.x >= N or f.y < 0 or f.y >= N:
		return
	_umschalten(f.x, f.y)
	queue_redraw()
	if _alle_an():
		_fertig = true
		geloest.emit()

func _process(_delta):
	if not _fertig:
		queue_redraw()

func aufloesen():
	_fertig = true
	queue_redraw()

func _draw():
	var f_hell = _spieler_feld()
	for r in N:
		for c in N:
			var pos = _origin + Vector2(c * T, r * T)
			var rect = Rect2(pos + Vector2(4, 4), Vector2(T - 8, T - 8))
			if zustand[r][c]:
				draw_rect(rect, Color(1.0, 0.82, 0.28))
				draw_rect(rect.grow(-6), Color(1.0, 0.92, 0.55))
			else:
				draw_rect(rect, Color(0.16, 0.16, 0.24))
			draw_rect(rect, Color(0.05, 0.05, 0.08), false, 2.0)
			if not _fertig and c == f_hell.x and r == f_hell.y:
				draw_rect(rect, Color(0.4, 0.9, 1.0), false, 3.0)

	if not _fertig:
		draw_string(ThemeDB.fallback_font, Vector2(340, 706),
			"Stell dich auf ein Feld und drücke F – alle Felder zum Leuchten bringen",
			HORIZONTAL_ALIGNMENT_CENTER, 600, 18, Color(0.85, 0.85, 0.9, 0.9))
