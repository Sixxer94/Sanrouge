extends Control

# ── Daten ─────────────────────────────────────────────────────────────────────
const CHARAKTERE = ["sixxer", "zeti", "domi"]
const FORMEN     = ["normal", "kreuz", "lform"]

const CHARAKTER_INFO = {
	"sixxer": {"rasse": "Der Schwabe",   "faehigkeit": "Shopkosten −20%"},
	"zeti":   {"rasse": "Der Gambler",   "faehigkeit": "Kann Relikte rerollen [R]"},
	"domi":   {"rasse": "Die Maschine",  "faehigkeit": "Startet mit erhöhten Grundstats"},
}

# ── Zustand ────────────────────────────────────────────────────────────────────
var char_index  = 0
var form_index  = 0
var aktive_zeile = 0    # 0 = Charaktere  1 = Formen  2 = Bestätigen

var gewaehlter_charakter: String
var gewaehlte_form: String

# ── Lifecycle ──────────────────────────────────────────────────────────────────
func _ready():
	# Werte aus global_data vorbelegen (falls schon gewählt)
	var gi = CHARAKTERE.find(global_data.charakter)
	char_index = gi if gi >= 0 else 0
	var fi = FORMEN.find(global_data.joint_form)
	form_index = fi if fi >= 0 else 0

	gewaehlter_charakter = CHARAKTERE[char_index]
	gewaehlte_form       = FORMEN[form_index]

	# Maus-Klicks weiterhin unterstützen
	$VBoxContainer/CharButtons/Sixxer.pressed.connect(func(): _char_waehlen(0))
	$VBoxContainer/CharButtons/Zeti.pressed.connect(func():   _char_waehlen(1))
	$VBoxContainer/CharButtons/Domi.pressed.connect(func():   _char_waehlen(2))
	$VBoxContainer/FormButtons/Normal.pressed.connect(func(): _form_waehlen(0))
	$VBoxContainer/FormButtons/Kreuz.pressed.connect(func():  _form_waehlen(1))
	$VBoxContainer/FormButtons/LForm.pressed.connect(func():  _form_waehlen(2))
	$VBoxContainer/Bestaetigen.pressed.connect(_on_bestaetigen)

	# Steuerungs-Hinweis unten anhängen
	var hint = Label.new()
	hint.text = "W/S: Zeile wechseln   A/D: Auswahl   ENTER: Bestätigen"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	hint.add_theme_font_size_override("font_size", 13)
	$VBoxContainer.add_child(hint)

	_aktualisieren()

# ── Tastatur-Navigation ────────────────────────────────────────────────────────
func _unhandled_input(event):
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	match event.keycode:
		KEY_W:
			aktive_zeile = (aktive_zeile - 1 + 3) % 3
			_aktualisieren()
		KEY_S:
			aktive_zeile = (aktive_zeile + 1) % 3
			_aktualisieren()
		KEY_A:
			if aktive_zeile == 0:
				char_index = (char_index - 1 + CHARAKTERE.size()) % CHARAKTERE.size()
				gewaehlter_charakter = CHARAKTERE[char_index]
			elif aktive_zeile == 1:
				form_index = (form_index - 1 + FORMEN.size()) % FORMEN.size()
				gewaehlte_form = FORMEN[form_index]
			_aktualisieren()
		KEY_D:
			if aktive_zeile == 0:
				char_index = (char_index + 1) % CHARAKTERE.size()
				gewaehlter_charakter = CHARAKTERE[char_index]
			elif aktive_zeile == 1:
				form_index = (form_index + 1) % FORMEN.size()
				gewaehlte_form = FORMEN[form_index]
			_aktualisieren()
		KEY_ENTER, KEY_KP_ENTER, KEY_F:
			_on_bestaetigen()
		KEY_ESCAPE:
			get_tree().change_scene_to_file("res://base.tscn")

# ── Auswahl-Helfer ─────────────────────────────────────────────────────────────
func _char_waehlen(idx: int):
	char_index = idx
	gewaehlter_charakter = CHARAKTERE[idx]
	aktive_zeile = 0
	_aktualisieren()

func _form_waehlen(idx: int):
	form_index = idx
	gewaehlte_form = FORMEN[idx]
	aktive_zeile = 1
	_aktualisieren()

func _on_bestaetigen():
	global_data.charakter  = gewaehlter_charakter
	global_data.joint_form = gewaehlte_form
	get_tree().change_scene_to_file("res://base.tscn")

# ── Visuelle Aktualisierung ────────────────────────────────────────────────────
func _aktualisieren():
	var gelb   = Color(1.0, 0.85, 0.1, 1.0)    # Ausgewählte Option
	var hell   = Color(1.0, 1.0,  1.0, 1.0)    # Normale Option in aktiver Zeile
	var dunkel = Color(0.5, 0.5,  0.5, 1.0)    # Inaktive Zeile

	# ── Charakter-Buttons ──
	var char_farbe = func(i): return gelb if i == char_index else (hell if aktive_zeile == 0 else dunkel)
	$VBoxContainer/CharButtons/Sixxer.modulate = char_farbe.call(0)
	$VBoxContainer/CharButtons/Zeti.modulate   = char_farbe.call(1)
	$VBoxContainer/CharButtons/Domi.modulate   = char_farbe.call(2)

	# ── Form-Buttons ──
	var form_farbe = func(i): return gelb if i == form_index else (hell if aktive_zeile == 1 else dunkel)
	$VBoxContainer/FormButtons/Normal.modulate = form_farbe.call(0)
	$VBoxContainer/FormButtons/Kreuz.modulate  = form_farbe.call(1)
	$VBoxContainer/FormButtons/LForm.modulate  = form_farbe.call(2)

	# ── Bestätigen-Button ──
	$VBoxContainer/Bestaetigen.modulate = gelb if aktive_zeile == 2 else dunkel

	# ── Zeilenpfeile in Labels ──
	$VBoxContainer/LabelChar.text = ("▶  " if aktive_zeile == 0 else "    ") + "Wähle deinen Charakter"
	$VBoxContainer/LabelForm.text = ("▶  " if aktive_zeile == 1 else "    ") + "Wähle deine Jointform"

	# ── Charakter-Info ──
	var info = CHARAKTER_INFO[gewaehlter_charakter]
	$VBoxContainer/LabelRasse.text      = info["rasse"]
	$VBoxContainer/LabelFaehigkeit.text = "Fähigkeit: " + info["faehigkeit"]
