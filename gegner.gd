extends CharacterBody2D

# ── Generischer, datengetriebener Gegner ──────────────────────────────────────
# tier:       1 = Welt 1-4,  2 = Welt 5-8
# verhalten:  "verfolger" | "schwarm" | "tank" | "schuetze" | "stuermer"
#             | "zickzack" | "sprenger" | "teiler" | "beschwoerer" | "schild"
#             | "umkreiser" | "heiler"
const MONSTER_DATEN = {
	# ── WELT 1-4 ──────────────────────────────────────────────────────────────
	# Ortsbürgermeister & lokale Beiräte (moosgrün)
	"ortsbuergermeister":   {"name": "Ortsbürgermeister",   "tier": 1, "farbe": Color(0.35, 0.50, 0.20), "groesse": 16, "hp": 4,  "tempo": 85,  "kontakt": 2, "verhalten": "verfolger"},
	"ratsbote":             {"name": "Ratsbote",            "tier": 1, "farbe": Color(0.50, 0.70, 0.30), "groesse": 12, "hp": 2,  "tempo": 150, "kontakt": 2, "verhalten": "schwarm"},
	"beiratsvorsitzender":  {"name": "Beiratsvorsitzender", "tier": 1, "farbe": Color(0.25, 0.40, 0.18), "groesse": 26, "hp": 14, "tempo": 45,  "kontakt": 4, "verhalten": "tank"},
	"ortsvorsteher":        {"name": "Ortsvorsteher",       "tier": 1, "farbe": Color(0.42, 0.46, 0.15), "groesse": 18, "hp": 6,  "tempo": 70,  "kontakt": 3, "verhalten": "stuermer"},
	# Sachkundige Bürger & Ehrenamtliche (türkis)
	"sachkundiger_buerger": {"name": "Sachkundiger Bürger", "tier": 1, "farbe": Color(0.15, 0.55, 0.55), "groesse": 16, "hp": 4,  "tempo": 80,  "kontakt": 2, "verhalten": "schuetze",   "schiesst": true, "proj_schaden": 1, "schuss_cd": 2.0},
	"ehrenamtler":          {"name": "Ehrenamtler",         "tier": 1, "farbe": Color(0.20, 0.60, 0.60), "groesse": 15, "hp": 4,  "tempo": 90,  "kontakt": 2, "verhalten": "zickzack"},
	"schoeffe":             {"name": "Schöffe",             "tier": 1, "farbe": Color(0.10, 0.50, 0.62), "groesse": 18, "hp": 6,  "tempo": 65,  "kontakt": 2, "verhalten": "schild",     "schutz_dauer": 1.5, "verwundbar_dauer": 2.5},
	"vereinsvorstand":      {"name": "Vereinsvorstand",     "tier": 1, "farbe": Color(0.15, 0.60, 0.50), "groesse": 18, "hp": 6,  "tempo": 60,  "kontakt": 2, "verhalten": "beschwoerer", "summon_id": "ratsbote", "summon_cd": 6.0},
	# Parteimitglieder (rot)
	"parteimitglied":       {"name": "Parteimitglied",      "tier": 1, "farbe": Color(0.70, 0.20, 0.15), "groesse": 16, "hp": 4,  "tempo": 95,  "kontakt": 2, "verhalten": "verfolger"},
	"wahlkaempfer":         {"name": "Wahlkämpfer",         "tier": 1, "farbe": Color(0.85, 0.30, 0.20), "groesse": 12, "hp": 2,  "tempo": 160, "kontakt": 2, "verhalten": "schwarm"},
	"fluegelkaempfer":      {"name": "Flügelkämpfer",       "tier": 1, "farbe": Color(0.75, 0.15, 0.25), "groesse": 20, "hp": 8,  "tempo": 70,  "kontakt": 3, "verhalten": "teiler"},
	"basisaktivist":        {"name": "Basisaktivist",       "tier": 1, "farbe": Color(0.80, 0.25, 0.10), "groesse": 17, "hp": 5,  "tempo": 85,  "kontakt": 2, "verhalten": "sprenger",   "proj_schaden": 1},

	# ── WELT 5-8 ──────────────────────────────────────────────────────────────
	# Landesminister & Behördenleiter (gold/violett)
	"landesminister":       {"name": "Landesminister",      "tier": 2, "farbe": Color(0.55, 0.40, 0.15), "groesse": 20, "hp": 14, "tempo": 70,  "kontakt": 4, "verhalten": "schuetze",   "schiesst": true, "proj_schaden": 2, "schuss_cd": 1.6},
	"behoerdenleiter":      {"name": "Behördenleiter",      "tier": 2, "farbe": Color(0.45, 0.30, 0.50), "groesse": 22, "hp": 16, "tempo": 55,  "kontakt": 4, "verhalten": "beschwoerer", "summon_id": "landrat", "summon_cd": 7.0},
	"ministerialrat":       {"name": "Ministerialrat",      "tier": 2, "farbe": Color(0.50, 0.35, 0.50), "groesse": 18, "hp": 12, "tempo": 120, "kontakt": 3, "verhalten": "umkreiser",  "schiesst": true, "proj_schaden": 2, "schuss_cd": 1.4},
	"staatsrat":            {"name": "Staatsrat",           "tier": 2, "farbe": Color(0.50, 0.45, 0.20), "groesse": 22, "hp": 16, "tempo": 60,  "kontakt": 4, "verhalten": "schild",     "schutz_dauer": 2.5, "verwundbar_dauer": 2.0},
	# Landräte & Oberbürgermeister (stahlblau)
	"landrat":              {"name": "Landrat",             "tier": 2, "farbe": Color(0.30, 0.45, 0.60), "groesse": 20, "hp": 14, "tempo": 95,  "kontakt": 4, "verhalten": "verfolger"},
	"oberbuergermeister":   {"name": "Oberbürgermeister",   "tier": 2, "farbe": Color(0.25, 0.40, 0.60), "groesse": 24, "hp": 18, "tempo": 65,  "kontakt": 5, "verhalten": "stuermer"},
	"kreisdirektor":        {"name": "Kreisdirektor",       "tier": 2, "farbe": Color(0.30, 0.50, 0.65), "groesse": 20, "hp": 12, "tempo": 70,  "kontakt": 3, "verhalten": "heiler",     "heil_cd": 3.0, "heil_menge": 3},
	"stadtoberhaupt":       {"name": "Stadtoberhaupt",      "tier": 2, "farbe": Color(0.20, 0.35, 0.55), "groesse": 22, "hp": 16, "tempo": 75,  "kontakt": 4, "verhalten": "sprenger",   "proj_schaden": 2},
	# Kommunale Abgeordnete (bordeaux)
	"stadtrat":             {"name": "Stadtrat",            "tier": 2, "farbe": Color(0.50, 0.12, 0.20), "groesse": 18, "hp": 12, "tempo": 80,  "kontakt": 4, "verhalten": "schuetze",   "schiesst": true, "proj_schaden": 2, "schuss_cd": 1.2},
	"kreistagsabgeordneter":{"name": "Kreistagsabgeordneter","tier": 2,"farbe": Color(0.55, 0.15, 0.25), "groesse": 18, "hp": 12, "tempo": 100, "kontakt": 4, "verhalten": "zickzack",   "schiesst": true, "proj_schaden": 2, "schuss_cd": 2.2},
	"fraktionssprecher":    {"name": "Fraktionssprecher",   "tier": 2, "farbe": Color(0.60, 0.10, 0.30), "groesse": 20, "hp": 14, "tempo": 55,  "kontakt": 4, "verhalten": "beschwoerer", "summon_id": "kreistagsabgeordneter", "summon_cd": 7.0},
	"ausschussvorsitzender":{"name": "Ausschussvorsitzender","tier": 2,"farbe": Color(0.50, 0.10, 0.25), "groesse": 22, "hp": 18, "tempo": 70,  "kontakt": 4, "verhalten": "teiler"},
}

const PROJEKTIL_SZENE = preload("res://projektil.tscn")
const MAX_ADDS = 3

# ── Von main.gd / Spawner gesetzt ──
var monster_id  = "ortsbuergermeister"
var welt        = 1
var geteilt     = false   # true = aus Teilung entstanden (halbe Werte, teilt nicht weiter)
var kann_teilen = true
var leichen_traeger = false   # markierter Gegner: hinterlässt beim Tod eine aufsammelbare Leiche

# ── Aus Daten abgeleitet ──
var anzeige_name = "Gegner"
var tier          = 1
var farbe         = Color(0.5, 0.5, 0.5)
var groesse       = 16.0
var hp            = 4
var max_hp        = 4
var tempo         = 80.0
var kontakt       = 2
var verhalten     = "verfolger"
var schiesst      = false
var proj_schaden  = 1
var schuss_cd     = 2.0
var summon_id     = ""
var summon_cd     = 6.0
var schutz_dauer      = 1.5
var verwundbar_dauer  = 2.5
var heil_cd       = 3.0
var heil_menge    = 3

# ── Laufzeit ──
var spieler = null
var bereit_timer        = 0.5
var getroffen_timer     = 0.0
var kontakt_pause_timer = 0.0
var knockback_velocity  = Vector2.ZERO
var schuss_timer  = 0.0
var summon_timer  = 0.0
var heil_timer    = 0.0
var zick_zeit     = 0.0
var geschuetzt    = false
var schild_timer  = 0.0
var schild_flash  = 0.0
var lade_flash    = 0.0
var sturm_phase   = "annaehern"
var sturm_timer   = 0.0
var sturm_richtung = Vector2.ZERO
var meine_adds: Array = []

func _ready():
	_werte_laden()
	var shape = CircleShape2D.new()
	shape.radius = groesse
	$CollisionShape2D.shape = shape
	spieler = get_tree().get_first_node_in_group("spieler")
	queue_redraw()

func _werte_laden():
	var d = MONSTER_DATEN.get(monster_id, MONSTER_DATEN["ortsbuergermeister"])
	anzeige_name     = d["name"]
	tier             = d["tier"]
	farbe            = d["farbe"]
	groesse          = float(d["groesse"])
	tempo            = float(d["tempo"])
	kontakt          = d["kontakt"]
	verhalten        = d["verhalten"]
	schiesst         = d.get("schiesst", false)
	proj_schaden     = d.get("proj_schaden", 1)
	schuss_cd        = d.get("schuss_cd", 2.0)
	summon_id        = d.get("summon_id", "")
	summon_cd        = d.get("summon_cd", 6.0)
	schutz_dauer     = d.get("schutz_dauer", 1.5)
	verwundbar_dauer = d.get("verwundbar_dauer", 2.5)
	heil_cd          = d.get("heil_cd", 3.0)
	heil_menge       = d.get("heil_menge", 3)

	# Welt-Skalierung innerhalb des Tiers
	var start = 1 if tier == 1 else 5
	var stufe = clampi(welt - start, 0, 10)
	var faktor = 1.0 + 0.12 * stufe
	hp = int(round(d["hp"] * faktor))
	if stufe >= 3:
		kontakt += 1

	if geteilt:
		hp      = maxi(1, int(hp / 2))
		groesse *= 0.7
		kontakt  = maxi(1, kontakt - 1)

	max_hp       = hp
	schild_timer = verwundbar_dauer
	schuss_timer = randf() * schuss_cd
	summon_timer = summon_cd
	heil_timer   = heil_cd

# ── Hauptschleife ─────────────────────────────────────────────────────────────
func _physics_process(delta):
	if spieler == null:
		return
	if bereit_timer > 0:
		bereit_timer -= delta
		return

	if getroffen_timer > 0:
		getroffen_timer -= delta
	if schild_flash > 0:
		schild_flash -= delta
	if lade_flash > 0:
		lade_flash -= delta

	knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, delta * 9.0)

	# Kontakt-Pause (nach Treffer am Spieler) oder Knockback dominieren
	if kontakt_pause_timer > 0:
		kontakt_pause_timer -= delta
		velocity = knockback_velocity
		move_and_slide()
		queue_redraw()
		return
	if knockback_velocity.length() > 10.0:
		velocity = knockback_velocity
		move_and_slide()
		queue_redraw()
		return

	var dir     = (spieler.global_position - global_position).normalized()
	var abstand = global_position.distance_to(spieler.global_position)

	match verhalten:
		"verfolger", "schwarm", "tank", "sprenger", "teiler":
			velocity = dir * tempo
		"schuetze":
			velocity = _kiter_velocity(dir, abstand, 160.0, 260.0)
			_schuss_logik(delta, dir, abstand, 380.0)
		"zickzack":
			zick_zeit += delta
			var perp = Vector2(-dir.y, dir.x)
			velocity = dir * tempo + perp * sin(zick_zeit * 6.0) * tempo * 0.8
			if schiesst:
				_schuss_logik(delta, dir, abstand, 400.0)
		"stuermer":
			_stuermer_logik(delta, dir, abstand)
		"beschwoerer":
			velocity = _kiter_velocity(dir, abstand, 220.0, 340.0)
			summon_timer -= delta
			if summon_timer <= 0.0:
				_adds_beschwoeren(2)
				summon_timer = summon_cd
		"schild":
			velocity = dir * tempo
			_schild_logik(delta)
		"umkreiser":
			velocity = _umkreiser_velocity(abstand)
			_schuss_logik(delta, dir, abstand, 420.0)
		"heiler":
			velocity = _kiter_velocity(dir, abstand, 240.0, 360.0)
			heil_timer -= delta
			if heil_timer <= 0.0:
				_heilen()
				heil_timer = heil_cd

	move_and_slide()
	_kontakt_pruefen(abstand)
	queue_redraw()

# ── Bewegungs-Helfer ──────────────────────────────────────────────────────────
func _kiter_velocity(dir: Vector2, abstand: float, nah: float, fern: float) -> Vector2:
	if abstand > fern:
		return dir * tempo
	elif abstand < nah:
		return -dir * tempo
	return Vector2.ZERO

func _umkreiser_velocity(abstand: float) -> Vector2:
	var ziel_radius = 200.0
	var radial_dir = (global_position - spieler.global_position).normalized()
	var tangential = Vector2(-radial_dir.y, radial_dir.x)
	var korrektur = clampf(abstand - ziel_radius, -tempo, tempo)
	return tangential * tempo - radial_dir * korrektur

func _stuermer_logik(delta: float, dir: Vector2, abstand: float):
	match sturm_phase:
		"annaehern":
			velocity = dir * tempo * 0.6
			if abstand < 280.0:
				sturm_phase = "aufladen"
				sturm_timer = 0.6
		"aufladen":
			velocity = Vector2.ZERO
			lade_flash = 0.1
			sturm_timer -= delta
			if sturm_timer <= 0.0:
				sturm_phase   = "sturm"
				sturm_timer   = 0.45
				sturm_richtung = dir
		"sturm":
			velocity = sturm_richtung * tempo * 3.0
			sturm_timer -= delta
			if sturm_timer <= 0.0:
				sturm_phase = "annaehern"

func _schild_logik(delta: float):
	schild_timer -= delta
	if schild_timer <= 0.0:
		geschuetzt = not geschuetzt
		schild_timer = schutz_dauer if geschuetzt else verwundbar_dauer

func _schuss_logik(delta: float, dir: Vector2, abstand: float, reichweite: float):
	if not schiesst:
		return
	schuss_timer -= delta
	if schuss_timer <= 0.0 and abstand < reichweite:
		_projektil_erzeugen(dir)
		schuss_timer = schuss_cd

func _kontakt_pruefen(_abstand: float):
	if global_position.distance_to(spieler.global_position) < groesse + 18.0:
		spieler.schaden(kontakt)
		kontakt_pause_timer = 0.6

# ── Aktionen ──────────────────────────────────────────────────────────────────
func _projektil_erzeugen(richtung: Vector2):
	var p = PROJEKTIL_SZENE.instantiate()
	p.global_position = global_position + richtung.normalized() * (groesse + 8.0)
	p.richtung        = richtung.normalized()
	p.schaden         = proj_schaden
	p.von_spieler     = false
	p.geschwindigkeit = 340.0
	p.max_distanz     = 420.0
	var ziel = get_parent()
	if ziel:
		ziel.add_child.call_deferred(p)

func _explosion():
	var n = 12 if tier == 2 else 8
	for i in n:
		var a = i * TAU / float(n)
		_projektil_erzeugen(Vector2(cos(a), sin(a)))

func _lebende_adds() -> int:
	meine_adds = meine_adds.filter(func(a): return is_instance_valid(a))
	return meine_adds.size()

func _adds_beschwoeren(anzahl: int):
	if summon_id == "":
		return
	for i in anzahl:
		if _lebende_adds() >= MAX_ADDS:
			break
		var pos = global_position + Vector2(randf_range(-80, 80), randf_range(-80, 80))
		var m = _monster_spawnen(summon_id, pos, false, true)
		if m:
			meine_adds.append(m)

func _teilen():
	for i in 2:
		var pos = global_position + Vector2(randf_range(-30, 30), randf_range(-30, 30))
		_monster_spawnen(monster_id, pos, false, true)

func _monster_spawnen(id: String, pos: Vector2, teilbar: bool, halbieren: bool):
	var raum = get_parent()
	if raum == null:
		return null
	var m = load("res://gegner.tscn").instantiate()
	m.monster_id  = id
	m.welt        = welt
	m.kann_teilen = teilbar
	m.geteilt     = halbieren
	m.global_position = pos
	raum.call_deferred("add_child", m)
	if raum.has_method("gegner_registrieren"):
		raum.call_deferred("gegner_registrieren", m)
	return m

func _heilen():
	for g in get_tree().get_nodes_in_group("gegner"):
		if g == self or not is_instance_valid(g):
			continue
		if global_position.distance_to(g.global_position) > 220.0:
			continue
		if "hp" in g and "max_hp" in g and g.hp < g.max_hp:
			g.hp = mini(g.hp + heil_menge, g.max_hp)
			g.queue_redraw()

# ── Treffer / Tod ─────────────────────────────────────────────────────────────
func knockback(impuls: Vector2):
	var faktor = 0.35 if verhalten == "tank" else 0.8
	knockback_velocity = impuls * faktor

func treffer(schaden):
	if geschuetzt:
		schild_flash = 0.12
		queue_redraw()
		return
	hp -= schaden
	getroffen_timer = 0.12
	queue_redraw()
	if hp <= 0:
		_sterben()

func _sterben():
	if leichen_traeger:
		_leiche_hinterlassen()
	elif verhalten == "sprenger":
		_explosion()
	elif verhalten == "teiler" and kann_teilen:
		_teilen()
	queue_free()

func _leiche_hinterlassen():
	var l = Node2D.new()
	l.set_script(load("res://leiche_pickup.gd"))
	l.position = position
	var elternraum = get_parent()
	if elternraum:
		elternraum.add_child.call_deferred(l)

# ── Darstellung ───────────────────────────────────────────────────────────────
func _draw():
	if leichen_traeger:
		var puls = 0.5 + 0.5 * sin(Time.get_ticks_msec() / 1000.0 * 4.0)
		var gold = Color(1.0, 0.85, 0.25)
		draw_circle(Vector2.ZERO, groesse + 10.0 + puls * 4.0, Color(gold.r, gold.g, gold.b, 0.10 + 0.08 * puls))
		draw_arc(Vector2.ZERO, groesse + 8.0 + puls * 4.0, 0, TAU, 28, Color(gold.r, gold.g, gold.b, 0.7), 2.5)
	if getroffen_timer > 0:
		draw_circle(Vector2.ZERO, groesse, Color(1.0, 1.0, 1.0, 0.85))
		return

	# Lade-Telegraph (Stürmer)
	if verhalten == "stuermer" and sturm_phase == "aufladen":
		draw_circle(Vector2.ZERO, groesse + 8.0, Color(1.0, 0.85, 0.2, 0.35))

	# Schild-Aura
	if geschuetzt:
		var aura = Color(0.5, 0.8, 1.0, 0.9 if schild_flash > 0 else 0.55)
		draw_arc(Vector2.ZERO, groesse + 6.0, 0, TAU, 32, aura, 3.0)

	# Körper
	draw_circle(Vector2.ZERO, groesse, farbe)
	draw_arc(Vector2.ZERO, groesse, 0, TAU, 28, farbe.lightened(0.35), 2.5)

	_marker_zeichnen()

	# Augen
	var ar = groesse * 0.3
	draw_circle(Vector2(-ar, -ar * 0.6), groesse * 0.18, Color(1, 1, 1))
	draw_circle(Vector2( ar, -ar * 0.6), groesse * 0.18, Color(1, 1, 1))
	draw_circle(Vector2(-ar, -ar * 0.6), groesse * 0.09, Color(0.05, 0.05, 0.08))
	draw_circle(Vector2( ar, -ar * 0.6), groesse * 0.09, Color(0.05, 0.05, 0.08))

	# HP-Leiste
	if hp < max_hp:
		var bar_w = groesse * 2.0
		var ratio = float(hp) / float(max_hp)
		var oben = -groesse - 12.0
		draw_rect(Rect2(-bar_w / 2, oben, bar_w,         5), Color(0.15, 0.15, 0.15))
		draw_rect(Rect2(-bar_w / 2, oben, bar_w * ratio, 5), Color(0.1, 0.85, 0.1))

func _marker_zeichnen():
	var hell = farbe.lightened(0.4)
	var dunkel = farbe.darkened(0.4)
	match verhalten:
		"schwarm":
			# Fühler
			draw_line(Vector2(-groesse * 0.3, -groesse), Vector2(-groesse * 0.6, -groesse * 1.5), dunkel, 2.0)
			draw_line(Vector2( groesse * 0.3, -groesse), Vector2( groesse * 0.6, -groesse * 1.5), dunkel, 2.0)
		"tank":
			# Risse
			draw_line(Vector2(-groesse * 0.3, -groesse * 0.4), Vector2(-groesse * 0.1, groesse * 0.3), dunkel, 2.5)
			draw_line(Vector2( groesse * 0.25, -groesse * 0.3), Vector2( groesse * 0.05, groesse * 0.35), dunkel, 2.5)
		"schuetze", "landesminister":
			# Hut
			draw_rect(Rect2(-groesse * 0.8, -groesse * 1.5, groesse * 1.6, groesse * 0.5), dunkel)
			draw_rect(Rect2(-groesse * 0.45, -groesse * 2.1, groesse * 0.9, groesse * 0.7), dunkel)
		"stuermer":
			# Vorwärts-Pfeil
			draw_colored_polygon(PackedVector2Array([
				Vector2(0, -groesse * 0.5), Vector2(groesse * 0.7, 0), Vector2(0, groesse * 0.5)]), hell)
		"zickzack":
			# Zickzack-Streifen
			var pts = PackedVector2Array([
				Vector2(-groesse * 0.6, groesse * 0.2), Vector2(-groesse * 0.2, -groesse * 0.2),
				Vector2( groesse * 0.2, groesse * 0.2), Vector2( groesse * 0.6, -groesse * 0.2)])
			for i in pts.size() - 1:
				draw_line(pts[i], pts[i + 1], hell, 2.0)
		"sprenger":
			# Zündfunke
			draw_circle(Vector2(0, -groesse * 1.1), groesse * 0.2, Color(1.0, 0.7, 0.1))
			draw_circle(Vector2(0, -groesse * 1.1), groesse * 0.1, Color(1.0, 1.0, 0.6))
		"teiler":
			# Teilungslinie
			draw_line(Vector2(0, -groesse * 0.8), Vector2(0, groesse * 0.8), dunkel, 2.5)
		"beschwoerer":
			# umkreisende Punkte
			var t = Time.get_ticks_msec() / 400.0
			for i in 3:
				var a = t + i * TAU / 3.0
				draw_circle(Vector2(cos(a), sin(a)) * (groesse * 0.6), groesse * 0.15, hell)
		"heiler":
			# grünes Kreuz
			var gruen = Color(0.4, 1.0, 0.5)
			draw_rect(Rect2(-groesse * 0.5, -groesse * 0.15, groesse, groesse * 0.3), gruen)
			draw_rect(Rect2(-groesse * 0.15, -groesse * 0.5, groesse * 0.3, groesse), gruen)
		"umkreiser":
			draw_arc(Vector2.ZERO, groesse * 0.55, 0, TAU, 20, hell, 2.0)
