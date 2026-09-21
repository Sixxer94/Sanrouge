extends Control

var spieler = null
var _cache: Array = []

func _ready():
	spieler = get_tree().get_first_node_in_group("spieler")

func _process(_delta):
	if not spieler:
		spieler = get_tree().get_first_node_in_group("spieler")
		return
	var aktuell = _stat_werte()
	if aktuell != _cache:
		_cache = aktuell
		queue_redraw()

func _stat_werte() -> Array:
	return [
		spieler.schaden_bonus,
		spieler.geschwindigkeit_bonus,
		spieler._get_feuerrate(),
		spieler.reichweite,
		spieler.schuss_tempo,
		spieler.glueck,
	]

func _draw():
	if not spieler:
		return

	var font = ThemeDB.fallback_font
	var gs = 13
	var zh = 19
	var cl = Color(0.65, 0.65, 0.65, 1.0)
	var cw = Color(1.0, 1.0, 1.0, 1.0)

	var stats = [
		["Schaden",      str(1 + spieler.schaden_bonus)],
		["Geschw.",      str(int(280 + spieler.geschwindigkeit_bonus))],
		["Feuerrate",    str(spieler._get_feuerrate()) + "/s"],
		["Reichweite",   str(spieler.reichweite)],
		["Schuss-Tempo", str(spieler.schuss_tempo)],
		["Glück",        str(spieler.glueck)],
	]

	for i in stats.size():
		var y = zh * (i + 1)
		draw_string(font, Vector2(0, y),  stats[i][0] + ":", HORIZONTAL_ALIGNMENT_LEFT, -1, gs, cl)
		draw_string(font, Vector2(100, y), stats[i][1],       HORIZONTAL_ALIGNMENT_LEFT, -1, gs, cw)
