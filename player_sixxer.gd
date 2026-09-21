extends CharacterBody2D

const UNVERWUNDBAR_DAUER     = 1.0
const SCHUSS_COOLDOWN_BASIS  = 0.3
const JOINT_START = 28.0
const JOINT_LAENGE = 44.0

# ── Figur-Optik je Charakter ──────────────────────────────────────────────────
# "hoehe" = sichtbare Figurhöhe in Pixeln. Die Skalierung wird je Ansicht aus
# dieser Höhe und der jeweiligen Texturhöhe berechnet – die drei Bilder sind
# unterschiedlich groß gezeichnet, ohne diese Normierung würde Domi beim
# Richtungswechsel die Größe ändern. Die Bilder sind randbündig zugeschnitten.
# "mund" = Ansatzpunkt der Joint in TEXTURPIXELN ab Bildmitte, je Ansicht eigens
# gemessen. In Texturpixeln, damit die Werte stimmen bleiben, wenn "hoehe" sich
# ändert. Beim gespiegelten Profil wird die x-Komponente umgedreht.
# "joint_hinten" = Joint hinter die Figur zeichnen (Rückansicht: der Mund liegt
# auf der abgewandten Seite).
# Charaktere ohne Eintrag behalten den Platzhalter aus spieler.tscn.
# Die Bilddateien heißen bewusst "fig_<name>_<ansicht>.png": Windows unterscheidet
# keine Groß-/Kleinschreibung, ein "domi_front.png" würde also das Original
# "Domi_front.png" überschreiben. Das ist mir genau so passiert.
const FIGUR = {
	"domi": {
		"hoehe": 90.0,
		"joint_start": 0.0,
		"ansichten": {
			"front":  {"textur": "res://sprites/fig_domi_front.png",  "mund": Vector2(16.0, 32.0)},
			"profil": {"textur": "res://sprites/fig_domi_profil.png", "mund": Vector2(-79.0, 14.0)},
			"back":   {"textur": "res://sprites/fig_domi_back.png",   "mund": Vector2(0.0, -62.0),
				"joint_hinten": true},
		},
	},
	"sixxer": {
		"hoehe": 90.0,
		"joint_start": 0.0,
		"ansichten": {
			"front":  {"textur": "res://sprites/fig_sixxer_front.png",  "mund": Vector2(3.0, 20.0)},
			"profil": {"textur": "res://sprites/fig_sixxer_profil.png", "mund": Vector2(-66.0, 2.0)},
			"back":   {"textur": "res://sprites/fig_sixxer_back.png",   "mund": Vector2(0.0, -64.0),
				"joint_hinten": true},
		},
	},
	"zeti": {
		"hoehe": 90.0,
		"joint_start": 0.0,
		"ansichten": {
			"front":  {"textur": "res://sprites/fig_zeti_front.png",  "mund": Vector2(3.0, 25.0)},
			"profil": {"textur": "res://sprites/fig_zeti_profil.png", "mund": Vector2(-77.0, 16.0)},
			"back":   {"textur": "res://sprites/fig_zeti_back.png",   "mund": Vector2(-1.0, -69.0),
				"joint_hinten": true},
		},
	},
}

var _sprite: Sprite2D = null
var _figur_daten = null          # Eintrag aus FIGUR, oder null beim Platzhalter
var _ansicht = ""                # aktuell gesetzte Ansicht, verhindert Neuladen je Frame
var _blick = Vector2.DOWN        # Richtung, in die die Figur schaut
# Ansatzpunkt der Joint relativ zum Spielerursprung; wird je Ansicht gesetzt.
# Gilt für die Optik UND für den Abschusspunkt der Projektile.
var joint_ursprung = Vector2.ZERO
var joint_start = JOINT_START

var schuss_cooldown = 0.3
var schuss_timer = 0.0
var bombe_szene        = preload("res://bombe.tscn")
var _projektil_szene   = preload("res://projektil.tscn")
var hp = 6
var max_hp = 6
var unverwundbar = false
var unverwundbar_timer = 0.0
var schaden_bonus = 0
var geschwindigkeit_bonus = 0.0
var projektil_groesse = 1.0
var reichweite = 400
var schuss_tempo = 400
var glueck = 0
var letzte_richtung = Vector2.RIGHT
var bewegung_gesperrt = false   # z.B. für das Eis-Rätsel (Steuerung übernimmt das Rätsel)
var pierce = false
var unverwundbar_dauer_bonus = 0.0

func _ready():
	_figur_setzen()
	var b = global_data.komponenten_bonus
	schaden_bonus         += b["schaden"]
	geschwindigkeit_bonus += b["geschwindigkeit"]
	reichweite            += b["reichweite"]
	schuss_tempo          += b["schuss_tempo"]
	projektil_groesse     += b["projektil_groesse"]
	glueck                += b["glueck"]
	max_hp                += b["max_hp"] * 2
	hp                     = min(hp + b["max_hp"] * 2, max_hp)
	pierce                 = b["pierce"]
	unverwundbar_dauer_bonus = b["unverwundbar_dauer"]
	schuss_cooldown        = SCHUSS_COOLDOWN_BASIS * b["feuerrate_mult"]
	# ── Charakter-Fähigkeiten ────────────────────────────────────────────────
	if global_data.charakter == "domi":
		schaden_bonus         += 2
		max_hp                += 4
		hp                     = min(hp + 4, max_hp)
		geschwindigkeit_bonus += 30
		reichweite            += 50

# Setzt die Figur des gewählten Charakters auf. Fehlt ein Eintrag oder ein Bild,
# bleibt der Platzhalter stehen – das Spiel läuft dann unverändert weiter.
func _figur_setzen():
	_sprite = get_node_or_null("Sprite2D")
	if _sprite == null:
		return
	_figur_daten = FIGUR.get(global_data.charakter, null)
	if _figur_daten == null:
		return
	joint_start = float(_figur_daten.get("joint_start", JOINT_START))
	_ansicht_setzen(_blick)

# Wählt Bild, Skalierung, Spiegelung und Joint-Ansatz zur Blickrichtung.
# Waagerecht hat Vorrang: bei diagonaler Bewegung wirkt das Profil besser als
# die Vorder-/Rückansicht.
func _ansicht_setzen(richtung: Vector2):
	if _figur_daten == null or _sprite == null:
		return
	var name_neu = "profil"
	var spiegeln = false
	if absf(richtung.x) >= absf(richtung.y):
		spiegeln = richtung.x > 0.0      # Profilbild schaut nach links
	else:
		name_neu = "front" if richtung.y > 0.0 else "back"
	if name_neu == _ansicht and spiegeln == _sprite.flip_h:
		return
	var a = _figur_daten["ansichten"].get(name_neu, null)
	if a == null:
		return
	var tex = load(a["textur"])
	if tex == null:
		push_warning("Figurbild fehlt: " + str(a["textur"]))
		return
	_ansicht = name_neu
	_sprite.texture = tex
	_sprite.flip_h  = spiegeln
	var s = float(_figur_daten["hoehe"]) / tex.get_height()
	_sprite.scale = Vector2(s, s)
	# Mund mitskalieren; beim gespiegelten Profil auf die andere Seite legen
	var mund: Vector2 = a.get("mund", Vector2.ZERO)
	if spiegeln:
		mund.x = -mund.x
	joint_ursprung = mund * s
	var jv = get_node_or_null("JointVisual")
	if jv != null:
		jv.position = joint_ursprung
		# Rückansicht: der Mund liegt hinten, also Joint hinter die Figur
		jv.z_index = -1 if a.get("joint_hinten", false) else 1

func _physics_process(delta):
	if unverwundbar:
		unverwundbar_timer -= delta
		if unverwundbar_timer <= 0:
			unverwundbar = false

	if not bewegung_gesperrt:
		var richtung = Vector2.ZERO
		if Input.is_key_pressed(KEY_D):
			richtung.x += 1
		if Input.is_key_pressed(KEY_A):
			richtung.x -= 1
		if Input.is_key_pressed(KEY_S):
			richtung.y += 1
		if Input.is_key_pressed(KEY_W):
			richtung.y -= 1
		if richtung.length() > 0:
			richtung = richtung.normalized()
		velocity = richtung * (280.0 + geschwindigkeit_bonus)
		move_and_slide()
		if richtung.length() > 0.01:
			_blick = richtung

	schuss_timer -= delta

	if Input.is_key_pressed(KEY_RIGHT):
		letzte_richtung = Vector2.RIGHT
		if schuss_timer <= 0:
			schiessen(Vector2.RIGHT)
	elif Input.is_key_pressed(KEY_LEFT):
		letzte_richtung = Vector2.LEFT
		if schuss_timer <= 0:
			schiessen(Vector2.LEFT)
	elif Input.is_key_pressed(KEY_DOWN):
		letzte_richtung = Vector2.DOWN
		if schuss_timer <= 0:
			schiessen(Vector2.DOWN)
	elif Input.is_key_pressed(KEY_UP):
		letzte_richtung = Vector2.UP
		if schuss_timer <= 0:
			schiessen(Vector2.UP)

	# Beim Zielen schaut die Figur in die Zielrichtung – sonst säße die Joint in
	# einem Mund, der gar nicht in diese Richtung zeigt. Ohne Zielen gilt die
	# Laufrichtung, damit die Figur beim bloßen Laufen nicht starr bleibt.
	if Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_LEFT) \
			or Input.is_key_pressed(KEY_UP) or Input.is_key_pressed(KEY_DOWN):
		_blick = letzte_richtung
	_ansicht_setzen(_blick)

func _get_feuerrate():
	return snapped(1.0 / schuss_cooldown, 0.1)

func _joint_tip_offset(richtung):
	match global_data.joint_form:
		"lform":
			var halb = JOINT_LAENGE / 2.0
			return richtung * (joint_start + halb) + richtung.rotated(PI / 4) * halb
		_:
			return richtung * (joint_start + JOINT_LAENGE)

func _kreuz_positionen(richtung):
	# † Form: Querbalken bei 70% der Armlänge (nahe der Spitze)
	var quer  = joint_start + JOINT_LAENGE * 0.65
	var arm   = JOINT_LAENGE * 0.4
	return [
		richtung * (joint_start + JOINT_LAENGE),
		richtung * quer + richtung.rotated(-PI / 2.0) * arm,
		richtung * quer + richtung.rotated( PI / 2.0) * arm,
	]

func schiessen(richtung):
	schuss_timer = schuss_cooldown
	match global_data.joint_form:
		"normal":
			_projektil_abfeuern(richtung, _joint_tip_offset(richtung))
		"kreuz":
			var pos = _kreuz_positionen(richtung)
			_projektil_abfeuern(richtung,                    pos[0])
			_projektil_abfeuern(richtung.rotated(-PI / 2.0), pos[1])
			_projektil_abfeuern(richtung.rotated( PI / 2.0), pos[2])
		"lform":
			_projektil_abfeuern(richtung.rotated(PI / 4.0), _joint_tip_offset(richtung))

func _projektil_abfeuern(richtung, spawn_offset):
	var p = _projektil_szene.instantiate()
	p.global_position = global_position + joint_ursprung + spawn_offset
	p.richtung        = richtung
	p.schaden         = 1 + schaden_bonus
	p.von_spieler     = true
	p.pierce          = pierce
	p.geschwindigkeit = float(schuss_tempo)
	p.max_distanz     = float(reichweite)
	p.scale           = Vector2(projektil_groesse, projektil_groesse)
	get_tree().current_scene.add_child(p)

func _input(event):
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if event.keycode == KEY_F1:  # TODO (Test): vor Release entfernen
		for g in get_tree().get_nodes_in_group("gegner"):
			if g.has_method("treffer"):
				g.treffer(9999)
			else:
				g.queue_free()
	if event.keycode == KEY_E:
		_bombe_platzieren()

func _bombe_platzieren():
	if global_data.bomben <= 0:
		return
	global_data.bomben -= 1
	var b = bombe_szene.instantiate()
	b.global_position = global_position
	get_parent().add_child(b)

func kamera_grenzen_setzen(rechts: int, unten: int):
	$Camera2D.limit_right  = rechts
	$Camera2D.limit_bottom = unten

func treffer(menge):
	schaden(menge)

func schaden(menge):
	if unverwundbar:
		return
	hp -= menge
	global_data.schaden_in_aktueller_welt = true
	var overlay = get_tree().get_first_node_in_group("schaden_overlay")
	if overlay:
		overlay.blitzen()
	unverwundbar = true
	unverwundbar_timer = UNVERWUNDBAR_DAUER + unverwundbar_dauer_bonus
	if hp <= 0:
		get_tree().call_deferred("change_scene_to_file", "res://base.tscn")
