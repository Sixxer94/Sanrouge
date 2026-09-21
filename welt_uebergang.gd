extends Control

signal uebergang_fertig

const DAUER   = 3.0
const EINBLEND = 0.5

var timer   = 0.0
var welt_nr = 1

func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

func zeigen(nr: int):
	welt_nr = nr
	timer   = 0.0
	visible = true
	get_tree().paused = true
	queue_redraw()

func _process(delta):
	if not visible:
		return
	timer += delta
	queue_redraw()
	if timer >= DAUER:
		visible = false
		get_tree().paused = false
		uebergang_fertig.emit()

func _draw():
	var alpha = 1.0
	if timer < EINBLEND:
		alpha = timer / EINBLEND
	elif timer > DAUER - EINBLEND:
		alpha = (DAUER - timer) / EINBLEND
	alpha = clamp(alpha, 0.0, 1.0)

	draw_rect(Rect2(0, 0, 1280, 720), Color(0, 0, 0, alpha * 0.9))
	draw_string(ThemeDB.fallback_font, Vector2(0, 320),
		"WELT " + str(welt_nr),
		HORIZONTAL_ALIGNMENT_CENTER, 1280, 52, Color(1.0, 0.82, 0.1, alpha))
	draw_string(ThemeDB.fallback_font, Vector2(0, 400),
		"Viel Erfolg!",
		HORIZONTAL_ALIGNMENT_CENTER, 1280, 24, Color(0.85, 0.85, 0.85, alpha))
