extends Control

var spieler = null

func _ready():
	spieler = get_tree().get_first_node_in_group("spieler")
	custom_minimum_size = Vector2(700, 72)

func _process(_delta):
	if spieler and is_instance_valid(spieler):
		queue_redraw()

func _draw():
	if not spieler or not is_instance_valid(spieler):
		return
	var total = int(ceil(spieler.max_hp / 2.0))
	for i in total:
		var x = i * 76.0
		var hp_rest = spieler.hp - i * 2
		_draw_herz(Vector2(x + 32, 32), hp_rest)

func _draw_herz(pos: Vector2, hp_rest: int):
	var rot  = Color(0.95, 0.10, 0.15)
	var grau = Color(0.25, 0.25, 0.25)

	# Leerer Container (immer grau im Hintergrund)
	_herz_form(pos, grau)

	if hp_rest >= 2:
		# Volles Herz
		_herz_form(pos, rot)
	elif hp_rest == 1:
		# Halbherz: linke Hälfte rot
		draw_circle(pos + Vector2(-12, -8), 16, rot)
		var l = PackedVector2Array([
			pos + Vector2(-26,  0),
			pos + Vector2(  0,  0),
			pos + Vector2(  0, 26)
		])
		draw_colored_polygon(l, rot)

func _herz_form(pos: Vector2, farbe: Color):
	draw_circle(pos + Vector2(-12, -8), 16, farbe)
	draw_circle(pos + Vector2( 12, -8), 16, farbe)
	var pts = PackedVector2Array([
		pos + Vector2(-26,  0),
		pos + Vector2( 26,  0),
		pos + Vector2(  0, 26)
	])
	draw_colored_polygon(pts, farbe)
