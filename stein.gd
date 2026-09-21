extends StaticBody2D

signal geheimgang_gefunden(pos)

var ist_geheimstein = false

func _ready():
	add_to_group("stein")
	queue_redraw()

func zerstoeren():
	if ist_geheimstein:
		geheimgang_gefunden.emit(global_position)
	elif randf() < 0.20:
		var v = load("res://verbrauchsgegenstand.tscn").instantiate()
		var typen = ["bitcoin", "bombe", "schluessel"]
		v.typ = typen[randi() % typen.size()]
		v.global_position = global_position
		get_parent().add_child(v)
	queue_free()

func _draw():
	var punkte = PackedVector2Array()
	var seiten = 8
	var radius = 32.0
	var unregelmaessig = [1.0, 0.88, 1.0, 0.92, 0.85, 1.0, 0.93, 0.88]
	for i in seiten:
		var winkel = (i / float(seiten)) * TAU - PI / 8.0
		var r = radius * unregelmaessig[i]
		punkte.append(Vector2(cos(winkel) * r, sin(winkel) * r))

	draw_polygon(punkte, [Color(0.44, 0.41, 0.37)])
	draw_polyline(punkte + PackedVector2Array([punkte[0]]), Color(0.58, 0.55, 0.50), 2.5)

	draw_circle(Vector2(-9, -10), 7, Color(0.52, 0.49, 0.45))
	draw_circle(Vector2(8,   6),  5, Color(0.38, 0.35, 0.31))

	# TODO (Test): Geheimstein-Markierung – vor Release entfernen
	if ist_geheimstein:
		draw_circle(Vector2.ZERO, 6, Color(1.0, 0.2, 0.9, 0.85))
