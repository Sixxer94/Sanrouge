extends Area2D

var typ = "voll"   # "voll" = +2 HP, "halb" = +1 HP

func _ready():
	add_to_group("herz")
	add_to_group("sammelbar")
	z_index = 100
	z_as_relative = false
	var shape = CircleShape2D.new()
	shape.radius = 14.0
	var col = CollisionShape2D.new()
	col.shape = shape
	add_child(col)
	body_entered.connect(_on_body_entered)
	queue_redraw()

func _on_body_entered(body):
	if not body.is_in_group("spieler"):
		return
	if body.hp >= body.max_hp:
		return
	var heilung = 2 if typ == "voll" else 1
	body.hp = min(body.hp + heilung, body.max_hp)
	queue_free()

func _draw():
	var rot   = Color(0.95, 0.10, 0.15)
	var grau  = Color(0.30, 0.30, 0.30)
	var weiss = Color(1.0, 1.0, 1.0, 0.9)

	# Weißer Umriss (1 px größer)
	_herz_form(Vector2.ZERO, weiss, 2)

	if typ == "voll":
		_herz_form(Vector2.ZERO, rot)
	else:
		# Halbherz: linke Hälfte rot, rechte grau
		_herz_form(Vector2.ZERO, grau)
		draw_circle(Vector2(-6, -4), 8, rot)
		var l = PackedVector2Array([Vector2(-13, 0), Vector2(0, 0), Vector2(0, 13)])
		draw_colored_polygon(l, rot)

func _herz_form(pos: Vector2, farbe: Color, extra: int = 0):
	draw_circle(pos + Vector2(-6, -4), 8 + extra, farbe)
	draw_circle(pos + Vector2( 6, -4), 8 + extra, farbe)
	var e = float(extra)
	var pts = PackedVector2Array([
		pos + Vector2(-13 - e,  0 - e),
		pos + Vector2( 13 + e,  0 - e),
		pos + Vector2(  0,     13 + e)
	])
	draw_colored_polygon(pts, farbe)
