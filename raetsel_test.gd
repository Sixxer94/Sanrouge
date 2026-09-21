extends Node2D

# Test-Zugang zu den Rätseln (aus der Base, obere Tür).
# Auswahl-Menü: Rätsel-Typ + Welt (Schwierigkeit). Nach dem Lösen/ESC zurück ins Menü.

const SPIELER_SZENE = preload("res://spieler.tscn")
const RAETSEL_SZENE = preload("res://raum_raetsel.tscn")

const SKR_SCHIEBEN = preload("res://raetsel_schieben.gd")
const SKR_LIGHTS   = preload("res://raetsel_lights.gd")
const SKR_EIS      = preload("res://raetsel_eis.gd")
const SKR_SPIEGEL  = preload("res://raetsel_spiegel.gd")
const SKR_SOKOBAN  = preload("res://raetsel_sokoban.gd")

const TYPEN = [
	{"name": "Sokoban (klassisch)",         "skript": SKR_SOKOBAN,  "variante": ""},
	{"name": "Schieben – Druckplatten",     "skript": SKR_SCHIEBEN, "variante": "platten"},
	{"name": "Schieben – Grube überbrücken","skript": SKR_SCHIEBEN, "variante": "grube"},
	{"name": "Lights Out",                  "skript": SKR_LIGHTS,   "variante": ""},
	{"name": "Eis-Rutschen",                "skript": SKR_EIS,      "variante": ""},
	{"name": "Spiegel-Laser",               "skript": SKR_SPIEGEL,  "variante": ""},
	{"name": "Zufällig",                    "skript": null,         "variante": ""},
]

var spieler = null
var raum = null

var _im_menue = true
var _zeile = 0          # 0 = Typ, 1 = Welt
var _typ_idx = 0
var _welt = 1

var _cl: CanvasLayer = null
var _bg: ColorRect = null
var _lbl_titel: Label = null
var _lbl_typ: Label = null
var _lbl_welt: Label = null
var _lbl_hinweis: Label = null

func _ready():
	spieler = SPIELER_SZENE.instantiate()
	spieler.global_position = Vector2(200, 360)
	add_child(spieler)
	if spieler.has_method("kamera_grenzen_setzen"):
		spieler.kamera_grenzen_setzen(1280, 720)
	spieler.visible = false
	spieler.bewegung_gesperrt = true

	_menue_bauen()
	_menue_aktualisieren()

# ── Menü-Aufbau ───────────────────────────────────────────────────────────────
func _menue_bauen():
	_cl = CanvasLayer.new()
	add_child(_cl)

	_bg = ColorRect.new()
	_bg.position = Vector2.ZERO
	_bg.size = Vector2(1280, 720)
	_bg.color = Color(0.06, 0.07, 0.10, 0.97)
	_cl.add_child(_bg)

	_lbl_titel   = _label(140, 34, Color(0.9, 0.95, 1.0))
	_lbl_titel.text = "Rätsel-Test"
	_lbl_typ     = _label(320, 24, Color(1, 1, 1))
	_lbl_welt    = _label(378, 24, Color(1, 1, 1))
	_lbl_hinweis = _label(620, 15, Color(0.6, 0.65, 0.75))
	_lbl_hinweis.text = "W/S: Zeile    A/D: Ändern    Enter: Start    ESC: zurück zur Base"

func _label(y: float, groesse: int, farbe: Color) -> Label:
	var l = Label.new()
	l.position = Vector2(0, y)
	l.size = Vector2(1280, 40)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", groesse)
	l.add_theme_color_override("font_color", farbe)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	l.add_theme_constant_override("outline_size", 4)
	_cl.add_child(l)
	return l

func _menue_aktualisieren():
	var gelb = Color(1.0, 0.85, 0.2)
	var weiss = Color(0.85, 0.85, 0.9)
	var pfeil_t = "▶  " if _zeile == 0 else "     "
	var pfeil_w = "▶  " if _zeile == 1 else "     "
	_lbl_typ.text  = pfeil_t + "Rätsel:  ◀ " + TYPEN[_typ_idx].name + " ▶"
	_lbl_welt.text = pfeil_w + "Welt:  ◀ " + str(_welt) + " ▶"
	_lbl_typ.add_theme_color_override("font_color",  gelb if _zeile == 0 else weiss)
	_lbl_welt.add_theme_color_override("font_color", gelb if _zeile == 1 else weiss)

func _menue_sichtbar(an: bool):
	_cl.visible = an

# ── Steuerung ─────────────────────────────────────────────────────────────────
func _unhandled_input(event):
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if _im_menue:
		match event.keycode:
			KEY_W, KEY_UP:    _zeile = (_zeile - 1 + 2) % 2; _menue_aktualisieren()
			KEY_S, KEY_DOWN:  _zeile = (_zeile + 1) % 2; _menue_aktualisieren()
			KEY_A, KEY_LEFT:  _wert_aendern(-1)
			KEY_D, KEY_RIGHT: _wert_aendern(1)
			KEY_ENTER, KEY_KP_ENTER: _puzzle_starten()
			KEY_ESCAPE: get_tree().change_scene_to_file("res://base.tscn")
	else:
		if event.keycode == KEY_ESCAPE:
			_puzzle_beenden()

func _wert_aendern(d: int):
	if _zeile == 0:
		_typ_idx = (_typ_idx + d + TYPEN.size()) % TYPEN.size()
	else:
		_welt = clampi(_welt + d, 1, 8)
	_menue_aktualisieren()

# ── Rätsel starten / beenden ──────────────────────────────────────────────────
func _puzzle_starten():
	global_data.aktuelle_welt = _welt
	# Test-Leiche: ab Welt 5 braucht die Druckplatten-Variante eine Leiche
	global_data.leichen = 1 if _welt >= 5 else 0
	spieler.global_position = Vector2(200, 360)
	spieler.visible = true
	spieler.bewegung_gesperrt = false

	raum = RAETSEL_SZENE.instantiate()
	var t = TYPEN[_typ_idx]
	raum.erzwinge_skript = t.skript
	raum.erzwinge_variante = t.variante
	# Wie im echten Spiel: Raum hat nicht alle 4 Türen (gibt dem Stollen Platz)
	raum.wand_richtungen = [["oben", "links"], ["unten", "rechts"],
		["oben", "rechts"], ["unten", "links"]][randi() % 4]
	add_child(raum)
	raum.tuer_betreten.connect(_puzzle_beenden)

	_im_menue = false
	_menue_sichtbar(false)

func _puzzle_beenden(_richtung = null):
	if raum and is_instance_valid(raum):
		raum.queue_free()
	raum = null
	spieler.visible = false
	spieler.bewegung_gesperrt = true
	_im_menue = true
	_menue_sichtbar(true)
