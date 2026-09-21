extends "res://raum.gd"

const PICKUP_SKRIPT = preload("res://komponenten_pickup.gd")

# Rätsel-Pool (wird schrittweise erweitert)
const RAETSEL_POOL = [
	preload("res://raetsel_sokoban.gd"),
	preload("res://raetsel_schieben.gd"),
	preload("res://raetsel_lights.gd"),
	preload("res://raetsel_eis.gd"),
	preload("res://raetsel_spiegel.gd"),
]

var geloest = false
var _puzzle: Node2D = null
var resets_uebrig = 2
var _reset_label: Label = null

# Optional (Test): bestimmtes Rätsel erzwingen statt zufällig
var erzwinge_skript = null
var erzwinge_variante = ""

func _raum_initialisieren():
	# Türen bleiben offen – der Raum darf ungelöst verlassen werden.
	# Der Stand bleibt erhalten, weil Rauminstanzen beim Verlassen nur versteckt werden.
	tueren_offen = true
	tueren_oeffnen()

	var skript = erzwinge_skript if erzwinge_skript != null else RAETSEL_POOL[randi() % RAETSEL_POOL.size()]
	_puzzle = Node2D.new()
	_puzzle.set_script(skript)
	_puzzle.welt = global_data.aktuelle_welt
	if erzwinge_variante != "":
		_puzzle.variante = erzwinge_variante
	add_child(_puzzle)
	_puzzle.geloest.connect(_raetsel_geloest)
	if _puzzle.has_signal("verlassen"):
		_puzzle.verlassen.connect(_raetsel_verlassen)

	if _puzzle.has_method("zuruecksetzen"):
		_reset_label_bauen()

# Sokoban aufgegeben (ESC): keine Belohnung, Raum gilt als erledigt.
func _raetsel_verlassen():
	geloest = true
	if _reset_label:
		_reset_label.visible = false

func _input(event):
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if event.keycode == KEY_F1 and not geloest:   # TODO (Test): vor Release entfernen
		_raetsel_geloest()
	elif (event.keycode == KEY_0 or event.keycode == KEY_KP_0) and not geloest \
			and resets_uebrig > 0 and _puzzle and _puzzle.has_method("zuruecksetzen"):
		resets_uebrig -= 1
		_puzzle.zuruecksetzen()
		_reset_label_aktualisieren()

func _reset_label_bauen():
	_reset_label = Label.new()
	_reset_label.position = Vector2(95, 688)
	_reset_label.add_theme_font_size_override("font_size", 14)
	add_child(_reset_label)
	_reset_label_aktualisieren()

func _reset_label_aktualisieren():
	if _reset_label == null:
		return
	_reset_label.text = "0: Zurücksetzen (%d)" % resets_uebrig
	var farbe = Color(0.75, 0.75, 0.8) if resets_uebrig > 0 else Color(0.4, 0.4, 0.45)
	_reset_label.add_theme_color_override("font_color", farbe)

func _raetsel_geloest():
	if geloest:
		return
	geloest = true
	if _reset_label:
		_reset_label.visible = false
	if _puzzle and _puzzle.has_method("aufloesen"):
		_puzzle.aufloesen()
	tueren_offen = true
	tueren_oeffnen()

	var kandidaten = global_data.nicht_besessene_komponenten_fuer_welt(global_data.aktuelle_welt)
	if kandidaten.size() > 0:
		var k = kandidaten[0]
		var p = Node2D.new()
		p.set_script(PICKUP_SKRIPT)
		p.slot = k["slot"]
		p.komponente = k["komponente"]
		p.position = _puzzle.belohnung_welt_pos if _puzzle else Vector2(640, 200)
		add_child(p)
