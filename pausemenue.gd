extends Control

signal fortfahren_gedrueckt
signal beenden_gedrueckt

const OPTIONEN = ["fortfahren", "beenden"]
var auswahl = 0

var _btn_fortfahren: Button
var _btn_beenden: Button

func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Feste Größe passend zur Viewport-Auflösung
	position = Vector2.ZERO
	size     = Vector2(1280, 720)

	# Halbtransparenter Hintergrund (identisch mit Hauptmenü-Hintergrundgefühl)
	var hintergrund = ColorRect.new()
	hintergrund.position = Vector2.ZERO
	hintergrund.size     = Vector2(1280, 720)
	hintergrund.color    = Color(0.0, 0.0, 0.0, 0.75)
	add_child(hintergrund)

	# Zentrierte VBox
	var vbox = VBoxContainer.new()
	vbox.position = Vector2(490, 260)
	vbox.size     = Vector2(300, 200)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 16)
	add_child(vbox)

	# Titel
	var titel = Label.new()
	titel.text = "PAUSE"
	titel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titel.add_theme_font_size_override("font_size", 32)
	vbox.add_child(titel)

	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	vbox.add_child(spacer)

	# Button: Fortfahren
	_btn_fortfahren = Button.new()
	_btn_fortfahren.text = "Fortfahren"
	_btn_fortfahren.custom_minimum_size = Vector2(300, 55)
	_btn_fortfahren.pressed.connect(_on_fortfahren)
	vbox.add_child(_btn_fortfahren)

	# Button: Beenden
	_btn_beenden = Button.new()
	_btn_beenden.text = "Beenden"
	_btn_beenden.custom_minimum_size = Vector2(300, 55)
	_btn_beenden.pressed.connect(_on_beenden)
	vbox.add_child(_btn_beenden)

	# Steuerungs-Hinweis
	var hint = Label.new()
	hint.text = "W/S: Auswahl   ENTER: Bestätigen"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	hint.add_theme_font_size_override("font_size", 13)
	vbox.add_child(hint)

func _input(event):
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if event.keycode == KEY_ESCAPE:
		if visible:
			_schliessen()
		else:
			_oeffnen()
		return
	if not visible:
		return
	match event.keycode:
		KEY_W, KEY_UP:
			auswahl = (auswahl - 1 + OPTIONEN.size()) % OPTIONEN.size()
			_aktualisieren()
		KEY_S, KEY_DOWN:
			auswahl = (auswahl + 1) % OPTIONEN.size()
			_aktualisieren()
		KEY_ENTER, KEY_KP_ENTER:
			_bestaetigen()

func _bestaetigen():
	match OPTIONEN[auswahl]:
		"fortfahren": _on_fortfahren()
		"beenden":    _on_beenden()

func _oeffnen():
	auswahl = 0
	visible = true
	get_tree().paused = true
	_aktualisieren()

func _schliessen():
	visible = false
	get_tree().paused = false

func _on_fortfahren():
	fortfahren_gedrueckt.emit()
	_schliessen()

func _on_beenden():
	beenden_gedrueckt.emit()

func _aktualisieren():
	if not _btn_fortfahren or not _btn_beenden:
		return
	var gelb   = Color(1.0, 0.85, 0.1, 1.0)
	var normal = Color(1.0, 1.0,  1.0, 1.0)
	_btn_fortfahren.modulate = gelb   if auswahl == 0 else normal
	_btn_beenden.modulate    = gelb   if auswahl == 1 else normal
