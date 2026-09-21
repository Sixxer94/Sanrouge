extends Node2D

# ── Schild-Klasse (eigener z_index → immer vor Spieler) ───────────────────────
class Schild extends Node2D:
	const B = 140.0   # Breite
	const H = 88.0    # Höhe
	var hervorgehoben := false

	func _draw():
		var font = ThemeDB.fallback_font
		var rand = Color(0.45, 0.90, 0.45) if hervorgehoben else Color(0.25, 0.50, 0.25)
		var text = Color(0.55, 1.00, 0.55) if hervorgehoben else Color(0.30, 0.65, 0.30)

		# Ständer
		draw_rect(Rect2(-4, H / 2.0, 8, 38), Color(0.35, 0.25, 0.10))
		# Fläche
		draw_rect(Rect2(-B / 2.0, -H / 2.0, B, H), Color(0.08, 0.13, 0.08))
		draw_rect(Rect2(-B / 2.0, -H / 2.0, B, H), rand, false, 2.0)
		# Text (zentriert über definierte Breite)
		draw_string(font, Vector2(-B / 2.0, -10), "CHARAKTER",
			HORIZONTAL_ALIGNMENT_CENTER, B, 13, text)
		draw_string(font, Vector2(-B / 2.0, 10), "& JOINT",
			HORIZONTAL_ALIGNMENT_CENTER, B, 13, text)
		if hervorgehoben:
			draw_string(font, Vector2(-B / 2.0 - 20, 58), "F: Auswahl öffnen",
				HORIZONTAL_ALIGNMENT_CENTER, B + 40, 11, Color(0.5, 0.9, 0.5))

# ── Raumlayout ─────────────────────────────────────────────────────────────────
const WAND_DICKE   = 96.0
const TUER_OBEN_X  = 576.0   # Türöffnung oben: x=576 bis x=704 (128px)
const TUER_OBEN_B  = 128.0
const TUER_SEITE_Y = 280.0   # Türöffnung links/rechts: y=280 bis y=440 (160px)
const TUER_SEITE_H = 160.0

# ── Farben ─────────────────────────────────────────────────────────────────────
const BODEN_FARBE  = Color(0.09, 0.12, 0.09)
const WAND_FARBE   = Color(0.15, 0.18, 0.14)
const TUER_BODEN   = Color(0.12, 0.20, 0.12)
const TUER_LINIE   = Color(0.28, 0.48, 0.28)

# ── Interaktion ────────────────────────────────────────────────────────────────
const SCHILD_POS    = Vector2(640, 340)
const SCHILD_RADIUS = 110.0

var spieler       = null
var hinweis_label = null
var aktive_zone   = ""
var _schild_node  = null

# ── Initialisierung ────────────────────────────────────────────────────────────
func _ready():
	spieler       = get_tree().get_first_node_in_group("spieler")
	hinweis_label = $CanvasLayer/Hinweis

	if spieler and spieler.has_method("kamera_grenzen_setzen"):
		spieler.kamera_grenzen_setzen(1280, 720)

	_waende_erstellen()

	# Schild als eigener Node mit hohem z_index → vor Spieler
	_schild_node = Schild.new()
	_schild_node.position = SCHILD_POS
	_schild_node.z_index = 10
	_schild_node.z_as_relative = false
	add_child(_schild_node)

func _waende_erstellen():
	# Oben links
	_wand(Vector2(288, 48),    Vector2(576, WAND_DICKE))
	# Oben rechts
	_wand(Vector2(992, 48),    Vector2(576, WAND_DICKE))
	# Unten (komplett)
	_wand(Vector2(640, 672),   Vector2(1280, WAND_DICKE))
	# Links oben
	_wand(Vector2(48, 140),    Vector2(WAND_DICKE, 280))
	# Links unten
	_wand(Vector2(48, 580),    Vector2(WAND_DICKE, 280))
	# Rechts oben
	_wand(Vector2(1232, 140),  Vector2(WAND_DICKE, 280))
	# Rechts unten
	_wand(Vector2(1232, 580),  Vector2(WAND_DICKE, 280))

func _wand(center: Vector2, groesse: Vector2):
	var body  = StaticBody2D.new()
	body.position = center
	var shape = CollisionShape2D.new()
	var rect  = RectangleShape2D.new()
	rect.size = groesse
	shape.shape = rect
	body.add_child(shape)
	add_child(body)

# ── Prozess ────────────────────────────────────────────────────────────────────
func _process(_delta):
	if spieler == null or not is_instance_valid(spieler):
		return

	var pos = spieler.global_position

	# Auto-Übergang: Spieler läuft durch rechte Tür → Spiel starten
	if pos.x > 1230 and pos.y > TUER_SEITE_Y and pos.y < TUER_SEITE_Y + TUER_SEITE_H:
		get_tree().change_scene_to_file("res://main.tscn")
		return

	# Auto-Übergang: Spieler läuft durch obere Tür → Test-Rätselraum
	if pos.y < 40 and pos.x > TUER_OBEN_X and pos.x < TUER_OBEN_X + TUER_OBEN_B:
		get_tree().change_scene_to_file("res://raetsel_test.tscn")
		return

	# Zonen-Erkennung
	var letzte = aktive_zone
	aktive_zone = ""

	if pos.distance_to(SCHILD_POS) < SCHILD_RADIUS:
		aktive_zone = "schild"
	elif pos.x > 1100 and pos.y > TUER_SEITE_Y and pos.y < TUER_SEITE_Y + TUER_SEITE_H:
		aktive_zone = "rechts"
	elif pos.y < 180 and pos.x > TUER_OBEN_X and pos.x < TUER_OBEN_X + TUER_OBEN_B:
		aktive_zone = "oben"
	elif pos.x < 180 and pos.y > TUER_SEITE_Y and pos.y < TUER_SEITE_Y + TUER_SEITE_H:
		aktive_zone = "links"

	if aktive_zone != letzte:
		_hinweis_aktualisieren()
		if _schild_node:
			_schild_node.hervorgehoben = (aktive_zone == "schild")
			_schild_node.queue_redraw()
		queue_redraw()

func _hinweis_aktualisieren():
	if hinweis_label == null:
		return
	match aktive_zone:
		"schild": hinweis_label.text = "F: Charakter & Joint wählen"
		"rechts":  hinweis_label.text = "→   Spiel starten"
		"oben":    hinweis_label.text = "↑   Rätselraum (Test)"
		"links":   hinweis_label.text = "[Platzhalter]"
		_:         hinweis_label.text = ""

func _input(event):
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if event.keycode == KEY_F and aktive_zone == "schild":
		get_tree().change_scene_to_file("res://charakterauswahl.tscn")

# ── Zeichnen ───────────────────────────────────────────────────────────────────
func _draw():
	var font = ThemeDB.fallback_font

	# Boden (Spielbereich)
	draw_rect(Rect2(WAND_DICKE, WAND_DICKE,
		1280 - WAND_DICKE * 2, 720 - WAND_DICKE * 2), BODEN_FARBE)

	# Türböden (leicht heller)
	draw_rect(Rect2(0, TUER_SEITE_Y, WAND_DICKE, TUER_SEITE_H), TUER_BODEN)
	draw_rect(Rect2(1280 - WAND_DICKE, TUER_SEITE_Y, WAND_DICKE, TUER_SEITE_H), TUER_BODEN)
	draw_rect(Rect2(TUER_OBEN_X, 0, TUER_OBEN_B, WAND_DICKE), TUER_BODEN)

	# Wände
	draw_rect(Rect2(0, 0, TUER_OBEN_X, WAND_DICKE), WAND_FARBE)
	draw_rect(Rect2(TUER_OBEN_X + TUER_OBEN_B, 0,
		1280 - (TUER_OBEN_X + TUER_OBEN_B), WAND_DICKE), WAND_FARBE)
	draw_rect(Rect2(0, 720 - WAND_DICKE, 1280, WAND_DICKE), WAND_FARBE)
	draw_rect(Rect2(0, 0, WAND_DICKE, TUER_SEITE_Y), WAND_FARBE)
	draw_rect(Rect2(0, TUER_SEITE_Y + TUER_SEITE_H,
		WAND_DICKE, 720 - (TUER_SEITE_Y + TUER_SEITE_H)), WAND_FARBE)
	draw_rect(Rect2(1280 - WAND_DICKE, 0, WAND_DICKE, TUER_SEITE_Y), WAND_FARBE)
	draw_rect(Rect2(1280 - WAND_DICKE, TUER_SEITE_Y + TUER_SEITE_H,
		WAND_DICKE, 720 - (TUER_SEITE_Y + TUER_SEITE_H)), WAND_FARBE)

	# Türrahmen-Linien
	draw_line(Vector2(WAND_DICKE, TUER_SEITE_Y), Vector2(0, TUER_SEITE_Y), TUER_LINIE, 2.5)
	draw_line(Vector2(WAND_DICKE, TUER_SEITE_Y + TUER_SEITE_H),
		Vector2(0, TUER_SEITE_Y + TUER_SEITE_H), TUER_LINIE, 2.5)
	draw_line(Vector2(1280 - WAND_DICKE, TUER_SEITE_Y),
		Vector2(1280, TUER_SEITE_Y), TUER_LINIE, 2.5)
	draw_line(Vector2(1280 - WAND_DICKE, TUER_SEITE_Y + TUER_SEITE_H),
		Vector2(1280, TUER_SEITE_Y + TUER_SEITE_H), TUER_LINIE, 2.5)
	draw_line(Vector2(TUER_OBEN_X, WAND_DICKE), Vector2(TUER_OBEN_X, 0), TUER_LINIE, 2.5)
	draw_line(Vector2(TUER_OBEN_X + TUER_OBEN_B, WAND_DICKE),
		Vector2(TUER_OBEN_X + TUER_OBEN_B, 0), TUER_LINIE, 2.5)

	# Tür-Beschriftungen
	var grau = Color(0.40, 0.55, 0.40)
	var aktiv = Color(0.55, 0.95, 0.55)

	draw_string(font, Vector2(1060, 368), "Spiel  →",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 13,
		aktiv if aktive_zone == "rechts" else grau)

	draw_string(font, Vector2(640, 130), "↑   Rätselraum (Test)",
		HORIZONTAL_ALIGNMENT_CENTER, -1, 13,
		aktiv if aktive_zone == "oben" else grau)

	draw_string(font, Vector2(220, 368), "←   [Platzhalter]",
		HORIZONTAL_ALIGNMENT_RIGHT, -1, 13,
		aktiv if aktive_zone == "links" else grau)

