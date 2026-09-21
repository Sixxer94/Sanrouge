extends Control

# Roter Rand-Blitz (Vignette), wenn der Spieler Schaden nimmt.

const FADE_DAUER = 0.4      # Sekunden bis vollständig ausgeblendet
const TIEFE      = 160.0    # wie weit die Vignette nach innen reicht
const MAX_ALPHA  = 0.5      # maximale Deckkraft am Rand

var staerke = 0.0           # 1.0 = frisch getroffen, 0.0 = unsichtbar

func _ready():
	add_to_group("schaden_overlay")
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	position = Vector2.ZERO
	size = get_viewport_rect().size

func blitzen():
	staerke = 1.0
	queue_redraw()

func _process(delta):
	if staerke > 0.0:
		staerke = max(0.0, staerke - delta / FADE_DAUER)
		queue_redraw()

func _draw():
	if staerke <= 0.0:
		return
	var schritte = 48
	var breite   = TIEFE / schritte + 2.0
	for i in schritte:
		var t = float(i) / float(schritte)      # 0 = außen, 1 = innen
		var a = (1.0 - t) * (1.0 - t)            # quadratisch → weicher Verlauf
		var inset = t * TIEFE
		var col = Color(0.85, 0.03, 0.03, a * MAX_ALPHA * staerke)
		draw_rect(Rect2(inset, inset, size.x - 2.0 * inset, size.y - 2.0 * inset),
				col, false, breite)
