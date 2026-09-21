extends Node2D

# Leiche des markierten Gegners: bleibt am Boden liegen, Drüberlaufen sammelt sie ein.
# Wird im Rätselraum (Druckplatten, ab Welt 5) mit E auf eine Druckplatte gelegt.
# Verfällt beim Weltwechsel (global_data.leichen wird dort auf 0 gesetzt).

const AUFHEB_RADIUS = 34.0

var spieler = null

func _ready():
	add_to_group("sammelbar")
	spieler = get_tree().get_first_node_in_group("spieler")
	queue_redraw()

func _process(_delta):
	if spieler == null:
		return
	if global_position.distance_to(spieler.global_position) < AUFHEB_RADIUS:
		global_data.leichen += 1
		queue_free()

func _draw():
	var gold   = Color(1.0, 0.85, 0.25)
	var dunkel = Color(0.2, 0.2, 0.15)
	draw_circle(Vector2(3, 5), 16.0, Color(0, 0, 0, 0.25))
	# Goldener Markierungsring (gleiches Gold wie die Aura des Trägers)
	draw_arc(Vector2.ZERO, 24.0, 0, TAU, 28, Color(gold.r, gold.g, gold.b, 0.8), 2.0)
	# Liegender Körper + Kopf
	draw_circle(Vector2(5, 4), 12.0, Color(0.55, 0.58, 0.5))
	draw_circle(Vector2(-9, -2), 8.0, Color(0.72, 0.68, 0.58))
	# X-Augen
	draw_line(Vector2(-12, -5), Vector2(-8, -1), dunkel, 1.5)
	draw_line(Vector2(-8, -5), Vector2(-12, -1), dunkel, 1.5)
