extends CharacterBody2D

# ── Boss-Datentabelle: welt → Werte & Angriffs-Skill ──────────────────────────
# muster:  "gezielt" | "faecher3" | "faecher5" | "ring8" | "spirale"
#          | "ring_gezielt" | "soeder"
# adds:    ""  | "periodisch" | "phasenwechsel"
const BOSS_DATEN = {
	1: {"name": "Staatssekretäre",                        "hp": 45,  "tempo": 45, "kontakt": 2, "proj": 1, "cooldown": 2.6, "muster": "gezielt",      "dash": false, "adds": ""},
	2: {"name": "Bundesminister & Abgeordnete",           "hp": 60,  "tempo": 55, "kontakt": 2, "proj": 1, "cooldown": 2.4, "muster": "faecher3",     "dash": false, "adds": ""},
	3: {"name": "Präsident des Bundesverfassungsgerichts","hp": 80,  "tempo": 60, "kontakt": 3, "proj": 1, "cooldown": 2.6, "muster": "ring8",        "dash": false, "adds": ""},
	4: {"name": "Bundesratspräsident",                    "hp": 100, "tempo": 65, "kontakt": 3, "proj": 2, "cooldown": 0.35,"muster": "spirale",      "dash": false, "adds": ""},
	5: {"name": "Bundeskanzler",                          "hp": 125, "tempo": 70, "kontakt": 4, "proj": 2, "cooldown": 1.6, "muster": "faecher3",     "dash": true,  "adds": ""},
	6: {"name": "Präsident des Bundestages",              "hp": 155, "tempo": 70, "kontakt": 4, "proj": 2, "cooldown": 1.8, "muster": "faecher5",     "dash": false, "adds": "periodisch"},
	7: {"name": "Bundespräsident",                        "hp": 190, "tempo": 75, "kontakt": 5, "proj": 2, "cooldown": 1.6, "muster": "ring_gezielt", "dash": false, "adds": "phasenwechsel"},
	8: {"name": "Markus Söder",                           "hp": 240, "tempo": 80, "kontakt": 6, "proj": 3, "cooldown": 1.4, "muster": "soeder",       "dash": true,  "adds": "phasenwechsel"},
}

const MAX_ADDS         = 4
const SUMMON_INTERVALL = 7.0
const DASH_TEMPO       = 420.0
const DASH_DAUER       = 0.30
const DASH_INTERVALL   = 4.0

var projektil_szene = preload("res://projektil.tscn")
var gegner_szene    = preload("res://gegner.tscn")

# Add-Monster nach Welt-Tier
const ADD_IDS_FRUEH = ["ratsbote", "wahlkaempfer"]
const ADD_IDS_SPAET = ["landrat", "stadtrat"]

# ── Von main.gd gesetzt ──
var welt = 0

# ── Aus Datentabelle abgeleitet ──
var boss_name       = "Boss"
var max_hp          = 50
var hp              = 50
var basis_tempo     = 60.0
var kontakt_schaden = 6
var proj_schaden    = 1
var basis_cooldown  = 2.0
var muster          = "gezielt"
var config_dash     = false
var adds_modus      = ""

# ── Laufzeit ──
var spieler       = null
var schuss_timer  = 1.5
var phase         = 1
var spiral_winkel = 0.0
var dash_cooldown = DASH_INTERVALL
var dash_aktiv    = 0.0
var dash_richtung = Vector2.ZERO
var summon_timer  = SUMMON_INTERVALL
var meine_adds: Array = []

func _ready():
	if welt <= 0:
		welt = global_data.aktuelle_welt
	_werte_laden()
	spieler = get_tree().get_first_node_in_group("spieler")
	var hp_bar = get_tree().get_root().find_child("BossHPBar", true, false)
	if hp_bar:
		hp_bar.boss_setzen(self)

func _werte_laden():
	var stufe = clampi(welt, 1, 8)
	var d = BOSS_DATEN[stufe]
	var extra = maxi(0, welt - 8)                # Skalierung falls über Welt 8 hinaus
	var faktor = 1.0 + 0.4 * extra
	boss_name       = d["name"]
	max_hp          = int(d["hp"] * faktor)
	hp              = max_hp
	basis_tempo     = d["tempo"]
	kontakt_schaden = d["kontakt"] + extra
	proj_schaden    = d["proj"]
	basis_cooldown  = d["cooldown"]
	muster          = d["muster"]
	config_dash     = d["dash"]
	adds_modus      = d["adds"]

# ── Hauptschleife ─────────────────────────────────────────────────────────────
func _physics_process(delta):
	if spieler == null:
		return

	var tempo    = basis_tempo * _phasen_tempo_faktor()
	var cooldown = basis_cooldown * _phasen_cooldown_faktor()
	var richtung_zum_spieler = (spieler.global_position - global_position).normalized()

	# Sturmangriff (Dash)
	if _kann_dashen():
		if dash_aktiv > 0.0:
			dash_aktiv -= delta
		else:
			dash_cooldown -= delta
			if dash_cooldown <= 0.0:
				dash_aktiv    = DASH_DAUER
				dash_richtung = richtung_zum_spieler
				dash_cooldown = DASH_INTERVALL

	if dash_aktiv > 0.0:
		velocity = dash_richtung * DASH_TEMPO
	else:
		velocity = richtung_zum_spieler * tempo
	move_and_slide()

	if global_position.distance_to(spieler.global_position) < 50:
		spieler.schaden(kontakt_schaden)

	# Adds beschwören (periodisch)
	if adds_modus == "periodisch":
		summon_timer -= delta
		if summon_timer <= 0.0:
			_adds_beschwoeren(2)
			summon_timer = SUMMON_INTERVALL

	# Schießen
	schuss_timer -= delta
	if schuss_timer <= 0.0:
		schiessen(richtung_zum_spieler)
		schuss_timer = cooldown

# ── Phasen-Skalierung ─────────────────────────────────────────────────────────
func _phasen_tempo_faktor() -> float:
	match phase:
		3: return 1.7
		2: return 1.4
		_: return 1.0

func _phasen_cooldown_faktor() -> float:
	match phase:
		3: return 0.5
		2: return 0.65
		_: return 1.0

func _kann_dashen() -> bool:
	var ab_phase = 2 if muster == "soeder" else 1
	return config_dash and phase >= ab_phase

# ── Angriffsmuster ────────────────────────────────────────────────────────────
func schiessen(richtung):
	var aktuelles_muster = muster
	if muster == "soeder":
		aktuelles_muster = ["faecher3", "ring8", "spirale"][phase - 1]

	match aktuelles_muster:
		"gezielt":
			_schuss_erstellen(richtung)
		"faecher3":
			for g in [-25, 0, 25]:
				_schuss_erstellen(_gedreht(richtung, g))
		"faecher5":
			for g in [-40, -20, 0, 20, 40]:
				_schuss_erstellen(_gedreht(richtung, g))
		"ring8":
			for i in 8:
				var a = i * TAU / 8.0
				_schuss_erstellen(Vector2(cos(a), sin(a)))
		"spirale":
			for i in 2:
				var a = deg_to_rad(spiral_winkel) + i * PI
				_schuss_erstellen(Vector2(cos(a), sin(a)))
			spiral_winkel += 28.0
		"ring_gezielt":
			for i in 8:
				var a = i * TAU / 8.0
				_schuss_erstellen(Vector2(cos(a), sin(a)))
			for g in [-20, 0, 20]:
				_schuss_erstellen(_gedreht(richtung, g))

func _gedreht(richtung: Vector2, grad) -> Vector2:
	var rad = deg_to_rad(float(grad))
	return Vector2(
		richtung.x * cos(rad) - richtung.y * sin(rad),
		richtung.x * sin(rad) + richtung.y * cos(rad)
	)

func _schuss_erstellen(richtung):
	var p = projektil_szene.instantiate()
	p.richtung = richtung.normalized()
	p.schaden  = proj_schaden
	p.position = global_position + richtung.normalized() * 45
	get_parent().add_child.call_deferred(p)

# ── Adds ──────────────────────────────────────────────────────────────────────
func _lebende_adds() -> int:
	meine_adds = meine_adds.filter(func(a): return is_instance_valid(a))
	return meine_adds.size()

func _add_id() -> String:
	var ids = ADD_IDS_SPAET if welt >= 5 else ADD_IDS_FRUEH
	return ids[randi() % ids.size()]

func _adds_beschwoeren(anzahl: int):
	var raum = get_parent()
	if raum == null:
		return
	for i in anzahl:
		if _lebende_adds() >= MAX_ADDS:
			break
		var m = gegner_szene.instantiate()
		m.monster_id = _add_id()
		m.welt = welt
		m.global_position = global_position + Vector2(randf_range(-90, 90), randf_range(-90, 90))
		raum.call_deferred("add_child", m)
		raum.call_deferred("gegner_registrieren", m)
		meine_adds.append(m)

# ── Treffer / Phasen / Tod ────────────────────────────────────────────────────
func treffer(schaden):
	if hp <= 0:
		return
	hp -= schaden
	_phase_pruefen()
	if hp <= 0:
		sterben()

func _phase_pruefen():
	var anteil = float(hp) / float(max_hp)
	if muster == "soeder":
		if phase == 1 and anteil <= 0.66:
			_phase_wechseln(2)
		elif phase == 2 and anteil <= 0.33:
			_phase_wechseln(3)
	else:
		if phase == 1 and anteil <= 0.5:
			_phase_wechseln(2)

func _phase_wechseln(neu: int):
	phase = neu
	modulate = Color(1.8, 0.2, 0.2, 1) if neu >= 2 else Color(1, 1, 1, 1)
	if adds_modus == "phasenwechsel":
		_adds_beschwoeren(3)

func sterben():
	# Herz-Drop nach Boss-Kill
	var herz = load("res://herz.tscn").instantiate()
	herz.typ = "voll"
	herz.position = global_position + Vector2(60, 0)
	get_parent().call_deferred("add_child", herz)
	call_deferred("queue_free")
