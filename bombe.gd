extends Node2D

const EXPLOSION_RADIUS = 200.0
const ZUND_DAUER = 2.0

var timer          = 0.0
var explosion_timer = 0.0
var explodiert     = false
var _blink_an      = false

func _process(delta):
	if explodiert:
		explosion_timer += delta
		queue_redraw()          # Explosion animiert → jeden Frame
		if explosion_timer >= 0.4:
			queue_free()
	else:
		timer += delta
		if timer >= ZUND_DAUER:
			explodieren()
			return
		# Blink-Zustand prüfen – nur bei Wechsel neu zeichnen
		var t          = timer / ZUND_DAUER
		var blink_freq = 6.0 + t * 16.0
		var blink_jetzt = sin(timer * blink_freq) > 0
		if blink_jetzt != _blink_an:
			_blink_an = blink_jetzt
			queue_redraw()

func explodieren():
	explodiert = true
	queue_redraw()
	# Nur Entitäten des aktiven Raums treffen – andere (unsichtbare) Räume
	# teilen sich denselben Koordinatenursprung und dürfen nicht getroffen werden.
	var raum = global_data.aktueller_raum
	for gegner in get_tree().get_nodes_in_group("gegner"):
		if raum and not raum.is_ancestor_of(gegner):
			continue
		if global_position.distance_to(gegner.global_position) <= EXPLOSION_RADIUS:
			if gegner.has_method("treffer"):
				gegner.treffer(5)
	for stein in get_tree().get_nodes_in_group("stein"):
		if raum and not raum.is_ancestor_of(stein):
			continue
		if global_position.distance_to(stein.global_position) <= EXPLOSION_RADIUS:
			stein.zerstoeren()
	if raum and raum.has_method("bombe_bei"):
		raum.bombe_bei(global_position, EXPLOSION_RADIUS)

func _draw():
	if explodiert:
		var alpha = 1.0 - (explosion_timer / 0.4)
		draw_circle(Vector2.ZERO, EXPLOSION_RADIUS,        Color(1.0, 0.35, 0.05, 0.45 * alpha))
		draw_circle(Vector2.ZERO, EXPLOSION_RADIUS * 0.55, Color(1.0, 0.75, 0.1,  0.65 * alpha))
		draw_circle(Vector2.ZERO, 22,                      Color(1.0, 1.0,  1.0,  alpha))
		return

	draw_circle(Vector2.ZERO, 14, Color(0.15, 0.15, 0.15))
	draw_arc(Vector2.ZERO, 14, 0, TAU, 32, Color(0.45, 0.45, 0.45), 2.0)

	if _blink_an:
		draw_circle(Vector2.ZERO, 7, Color(1.0, 0.3, 0.05))
