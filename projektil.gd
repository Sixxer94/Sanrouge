extends Area2D

var geschwindigkeit   = 400.0
var richtung          = Vector2.ZERO
var schaden           = 1
var von_spieler       = false
var pierce            = false
var max_distanz       = 400.0
var distanz_gereist   = 0.0

const KNOCKBACK_KRAFT = 260.0

func _ready():
	add_to_group("projektil")

func _physics_process(delta):
	var schritt = richtung * geschwindigkeit * delta
	global_position += schritt
	distanz_gereist += schritt.length()
	if distanz_gereist >= max_distanz:
		queue_free()

func _on_body_entered(body):
	if von_spieler and body.is_in_group("spieler"):
		return
	if not von_spieler and body.is_in_group("gegner"):
		return
	if body.has_method("treffer"):
		body.treffer(schaden)
	if body.has_method("knockback") and von_spieler:
		body.knockback(richtung * KNOCKBACK_KRAFT)
	if pierce and von_spieler and body.is_in_group("gegner"):
		return  # Durchdringen: Gegner treffen aber weiterfliegen
	queue_free()
