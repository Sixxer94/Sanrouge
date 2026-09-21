extends Control

const OPTIONEN = ["spiel", "beenden"]
var auswahl = 0

func _ready():
	$VBoxContainer/Spiel_starten.pressed.connect(_on_spiel_starten)
	$VBoxContainer/Beenden.pressed.connect(_on_beenden)
	_aktualisieren()

func _unhandled_input(event):
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	match event.keycode:
		KEY_W, KEY_UP:
			auswahl = (auswahl - 1 + OPTIONEN.size()) % OPTIONEN.size()
			_aktualisieren()
		KEY_S, KEY_DOWN:
			auswahl = (auswahl + 1) % OPTIONEN.size()
			_aktualisieren()
		KEY_ENTER, KEY_KP_ENTER, KEY_F:
			_bestaetigen()

func _bestaetigen():
	match OPTIONEN[auswahl]:
		"spiel":    _on_spiel_starten()
		"beenden":  _on_beenden()

func _on_spiel_starten():
	get_tree().change_scene_to_file("res://base.tscn")

func _on_beenden():
	get_tree().quit()

func _aktualisieren():
	var gelb   = Color(1.0, 0.85, 0.1, 1.0)
	var normal = Color(1.0, 1.0,  1.0, 1.0)
	$VBoxContainer/Spiel_starten.modulate = gelb   if auswahl == 0 else normal
	$VBoxContainer/Beenden.modulate       = gelb   if auswahl == 1 else normal
