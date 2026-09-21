extends Node2D

signal portal_betreten(ziel_raum_pos)

var ziel_raum_pos: Vector2 = Vector2.ZERO
var spieler = null
var timer = 0.0
var benutzt = false
var aktivierungs_delay = 1.2

func _ready():
	spieler = get_tree().get_first_node_in_group("spieler")

func _process(delta):
	timer += delta
	queue_redraw()
	if benutzt or spieler == null or timer < aktivierungs_delay:
		return
	if spieler.global_position.distance_to(global_position) < 32:
		benutzt = true
		portal_betreten.emit(ziel_raum_pos)

func _draw():
	var pulse = (sin(timer * 3.5) + 1.0) * 0.5
	var r = 20.0 + pulse * 5.0
	draw_circle(Vector2.ZERO, r + 8, Color(0.3, 0.0, 0.55, 0.4))
	draw_circle(Vector2.ZERO, r,     Color(0.5, 0.1, 0.85, 0.75))
	draw_circle(Vector2.ZERO, r * 0.5, Color(0.8, 0.5, 1.0, 0.9))
	draw_circle(Vector2.ZERO, r * 0.2, Color(1.0, 0.9, 1.0, 1.0))
	draw_arc(Vector2.ZERO, r + 10, timer * 1.5, timer * 1.5 + TAU * 0.75,
		32, Color(0.7, 0.3, 1.0, 0.5 + pulse * 0.3), 2.0)
