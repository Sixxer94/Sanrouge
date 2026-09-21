extends Node2D

const REICHWEITE = 80.0

var geoeffnet = false
var in_reichweite = false
var kein_schluessel_timer = 0.0
var spieler = null

func _ready():
	add_to_group("sammelbar")
	spieler = get_tree().get_first_node_in_group("spieler")
	queue_redraw()

func _process(delta):
	if spieler == null or geoeffnet:
		return
	var nah = global_position.distance_to(spieler.global_position) < REICHWEITE
	if nah != in_reichweite:
		in_reichweite = nah
		queue_redraw()
	if kein_schluessel_timer > 0:
		kein_schluessel_timer -= delta
		queue_redraw()

func _input(event):
	if geoeffnet or not in_reichweite:
		return
	if event is InputEventKey and event.keycode == KEY_F and event.pressed and not event.echo:
		if global_data.schluessel > 0:
			global_data.schluessel -= 1
			_oeffnen()
		else:
			kein_schluessel_timer = 1.5
			queue_redraw()

func _oeffnen():
	geoeffnet = true
	remove_from_group("sammelbar")   # geöffnete Truhe zählt nicht mehr als „Item im Raum"
	var zufall = randf()
	if zufall < 0.6:
		var kandidaten = global_data.nicht_besessene_komponenten_fuer_welt(global_data.aktuelle_welt)
		if kandidaten.size() > 0:
			var k = kandidaten[0]
			var p = Node2D.new()
			p.set_script(load("res://komponenten_pickup.gd"))
			p.slot = k["slot"]
			p.komponente = k["komponente"]
			p.global_position = global_position + Vector2(0, -60)
			get_parent().add_child(p)
	elif randf() < 0.25:
		var h = load("res://herz.tscn").instantiate()
		h.typ = "voll" if randf() < 0.6 else "halb"
		h.global_position = global_position
		get_parent().add_child(h)
	else:
		var v = load("res://verbrauchsgegenstand.tscn").instantiate()
		var typen = ["bitcoin", "bombe", "schluessel"]
		v.typ = typen[randi() % typen.size()]
		v.global_position = global_position
		get_parent().add_child(v)
	queue_redraw()

func _draw():
	var font = ThemeDB.fallback_font

	if geoeffnet:
		draw_rect(Rect2(-22, -4, 44, 22), Color(0.35, 0.2, 0.05))
		draw_rect(Rect2(-22, -4, 44, 22), Color(0.6, 0.4, 0.1), false, 2.0)
		draw_rect(Rect2(-22, -18, 44, 16), Color(0.28, 0.15, 0.03))
		draw_rect(Rect2(-22, -18, 44, 16), Color(0.6, 0.4, 0.1), false, 2.0)
		return

	draw_rect(Rect2(-22, -18, 44, 36), Color(0.35, 0.2, 0.05))
	draw_rect(Rect2(-22, -18, 44, 36), Color(1.0, 0.75, 0.1), false, 2.0)
	draw_rect(Rect2(-22, -3,  44, 3),  Color(1.0, 0.75, 0.1))
	draw_circle(Vector2(0, 0), 5, Color(1.0, 0.75, 0.1))
	draw_circle(Vector2(0, 0), 3, Color(0.15, 0.1, 0.02))

	if not in_reichweite:
		return

	if kein_schluessel_timer > 0:
		draw_string(font, Vector2(-55, -38), "Schlüssel benötigt!",
			HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.95, 0.3, 0.3))
	else:
		var text = "F: Öffnen  [Schlüssel: " + str(global_data.schluessel) + "]"
		draw_string(font, Vector2(-65, -38), text,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.5, 0.9, 0.5))
