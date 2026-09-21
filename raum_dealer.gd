extends "res://raum.gd"

const STATION_POS = Vector2(640, 360)
const REICHWEITE  = 120.0

var dealer_menue_szene = preload("res://dealer_menue.tscn")
var menue: Control = null
var in_reichweite   = false

func _raum_initialisieren():
	# Boden grün einfärben
	var bg = get_node_or_null("ColorRect")
	if bg:
		bg.color = Color(0.10, 0.18, 0.10)

	tueren_oeffnen()

	menue = dealer_menue_szene.instantiate()
	add_child(menue)

	_label_spawnen()

func _label_spawnen():
	var label = Label.new()
	label.text = "D E A L E R"
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", Color(0.3, 0.9, 0.3))
	label.position = Vector2(490, 80)
	add_child(label)

# ── Prozess ───────────────────────────────────────────────────────────────────

func _process(delta):
	super._process(delta)
	if spieler == null or menue == null or menue.visible:
		return
	var nah = spieler.global_position.distance_to(STATION_POS) < REICHWEITE
	if nah != in_reichweite:
		in_reichweite = nah
		queue_redraw()

func _input(event):
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if in_reichweite and event.keycode == KEY_F:
		if menue and not menue.visible:
			menue.oeffnen()

# ── Zeichnen (Station-Visuals) ────────────────────────────────────────────────

func _draw():
	# Station: grüner Kreis mit Rahmen
	draw_circle(STATION_POS, 36, Color(0.10, 0.25, 0.10))
	draw_arc(STATION_POS, 36, 0, TAU, 48, Color(0.3, 0.9, 0.3), 3.0)

	# Pflanzensymbol (drei Blätter)
	var c = STATION_POS
	draw_circle(c + Vector2(0, -18),  11, Color(0.2, 0.7, 0.2))
	draw_circle(c + Vector2(-14, 6),  11, Color(0.2, 0.7, 0.2))
	draw_circle(c + Vector2( 14, 6),  11, Color(0.2, 0.7, 0.2))
	draw_circle(c + Vector2(0, 6),     6, Color(0.15, 0.35, 0.12))  # Stamm-Highlight

	# Tooltip wenn in Reichweite
	if in_reichweite:
		var tx = STATION_POS.x - 90
		var ty = STATION_POS.y + 58
		draw_rect(Rect2(tx - 6, ty - 16, 192, 22), Color(0.05, 0.08, 0.05, 0.88))
		draw_string(ThemeDB.fallback_font, Vector2(tx, ty),
			"[F]  Grow-Box öffnen",
			HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.5, 0.95, 0.5))
