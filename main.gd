extends Node2D

var raum_szene           = preload("res://raum.tscn")
var raum_schatz_szene    = preload("res://raum_schatz.tscn")
var raum_boss_szene      = preload("res://raum_boss.tscn")
var raum_geheim_szene    = preload("res://raum_geheim.tscn")
var raum_raetsel_szene   = preload("res://raum_raetsel.tscn")
var raum_apotheke_szene  = preload("res://raum_apotheke.tscn")
var raum_perfektion_szene = preload("res://raum_perfektion.tscn")
var raum_dealer_szene    = preload("res://raum_dealer.tscn")
var raum_multi_szene      = preload("res://raum_multi.tscn")
const KOMP_PICKUP_SKRIPT = preload("res://komponenten_pickup.gd")
var gegner_szene     = preload("res://gegner.tscn")
var boss_szene       = preload("res://gegner_boss.tscn")

# Monster-Pools nach Welt-Tier
const MONSTER_TIER1 = [
	"ortsbuergermeister", "ratsbote", "beiratsvorsitzender", "ortsvorsteher",
	"sachkundiger_buerger", "ehrenamtler", "schoeffe", "vereinsvorstand",
	"parteimitglied", "wahlkaempfer", "fluegelkaempfer", "basisaktivist",
]
const MONSTER_TIER2 = [
	"landesminister", "behoerdenleiter", "ministerialrat", "staatsrat",
	"landrat", "oberbuergermeister", "kreisdirektor", "stadtoberhaupt",
	"stadtrat", "kreistagsabgeordneter", "fraktionssprecher", "ausschussvorsitzender",
]
var relikt_szene      = preload("res://relikte.tscn")
const RELIKT_SKRIPT   = preload("res://relikte.gd")
var verbrauch_szene  = preload("res://verbrauchsgegenstand.tscn")
var herz_szene       = preload("res://herz.tscn")
var truhe_szene      = preload("res://truhe.tscn")
var stein_szene      = preload("res://stein.tscn")
var portal_skript    = preload("res://portal.gd")
var pausemenue_skript = preload("res://pausemenue.gd")
var schaden_overlay_skript = preload("res://schaden_overlay.gd")
var relikt_anzeige_skript = preload("res://relikt_anzeige.gd")

var generierte_karte = {}
var pausemenue = null
var aktueller_raum   = null
var spieler          = null
var raum_position    = Vector2(0, 0)
var besuchte_raeume  = {}
var raum_instanzen   = {}
var geheim_positionen   = {}
var perfektion_position = null
var perfektion_eingang  = ""   # Richtung zurück zum Boss-Raum
var _eintritts_richtung = ""   # Richtung mit der der Spieler den letzten Raum betreten hat
var welt             = 1
var schatz_geoeffnet = {}      # bereits mit Schlüssel geöffnete Schatzräume (Pos → true)
var _leichen_gegner_countdown = 0   # im n-ten betretenen Kampfraum wird ein Gegner markiert (ab Welt 5)
var _hinweis_label: Label = null

const RICHTUNG_OFFSET = {
	"oben":   Vector2(0, -1), "unten":  Vector2(0,  1),
	"links":  Vector2(-1, 0), "rechts": Vector2(1,  0),
}
const GEGENRICHTUNG = {
	"oben": "unten", "unten": "oben", "links": "rechts", "rechts": "links",
}

func _ready():
	# ── Kompletter Run-Reset ──────────────────────────────────────────────────
	global_data.bitcoins   = 0
	global_data.bomben     = 5  # TODO (Test): vor Release auf 0 setzen
	global_data.schluessel = 0
	global_data.leichen    = 0
	global_data.besessene_relikte = []
	schatz_geoeffnet = {}
	global_data.schaden_in_aktueller_welt = false
	global_data.aktuelle_welt = welt
	# joint_form wird aus der Charakterauswahl übernommen – nicht zurücksetzen
	global_data.joint_komponenten = {
		"papes": "drucker", "filter": "kein",
		"tabak": "billig",  "weed":   "buschgras",
	}
	global_data.inventar = {
		"papes":  ["drucker"],
		"filter": ["kein"],
		"tabak":  ["billig"],
		"weed":   ["buschgras"],
	}
	global_data.komponenten_bonus = {
		"schaden": 0, "geschwindigkeit": 0.0, "reichweite": 0,
		"schuss_tempo": 0, "projektil_groesse": 0.0, "glueck": 0,
		"max_hp": 0, "unverwundbar_dauer": 0.0,
		"pierce": false, "feuerrate_mult": 1.0,
	}
	# ─────────────────────────────────────────────────────────────────────────
	spieler = get_tree().get_first_node_in_group("spieler")

	generierte_karte = KartenGenerator.generieren(_karten_groesse(), _geheim_anzahl(), welt)
	_leichen_gegner_countdown = randi_range(2, 4)

	aktueller_raum = $Raum
	_raum_verbinden(aktueller_raum)
	besuchte_raeume[raum_position] = "start"
	raum_instanzen[raum_position]  = aktueller_raum
	global_data.aktueller_raum     = aktueller_raum

	# Start-Raum: Wände setzen (bereits in Szene, _ready schon gelaufen)
	aktueller_raum.wand_richtungen = _wand_richtungen_fuer(raum_position)
	aktueller_raum.geheimwand_richtungen = _geheimwand_richtungen_fuer(raum_position)
	aktueller_raum.tueren_oeffnen()

	$CanvasLayer/MiniMap.aktualisieren()
	$CanvasLayer/WeltUebergang.uebergang_fertig.connect(_neue_welt_aufbauen)

	# Pausemenü einrichten
	pausemenue = Control.new()
	pausemenue.set_script(pausemenue_skript)
	pausemenue.fortfahren_gedrueckt.connect(_pausemenue_fortfahren)
	pausemenue.beenden_gedrueckt.connect(_pausemenue_beenden)
	$CanvasLayer.add_child(pausemenue)

	# Schaden-Feedback (roter Rand-Blitz)
	var schaden_overlay = Control.new()
	schaden_overlay.set_script(schaden_overlay_skript)
	$CanvasLayer.add_child(schaden_overlay)

	# Relikt-Anzeige (unten links)
	var relikt_anzeige = Control.new()
	relikt_anzeige.set_script(relikt_anzeige_skript)
	$CanvasLayer.add_child(relikt_anzeige)

	# Hinweis-Label (z. B. „Schlüssel benötigt")
	_hinweis_label = Label.new()
	_hinweis_label.position = Vector2(340, 600)
	_hinweis_label.size     = Vector2(600, 40)
	_hinweis_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hinweis_label.add_theme_font_size_override("font_size", 26)
	_hinweis_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	_hinweis_label.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	_hinweis_label.add_theme_constant_override("outline_size", 6)
	_hinweis_label.visible = false
	$CanvasLayer.add_child(_hinweis_label)

# Verbindet alle Signale eines Raums
func _raum_verbinden(raum):
	if raum.has_signal("tuer_betreten_ziel"):
		raum.tuer_betreten_ziel.connect(_on_tuer_betreten_ziel)
	else:
		raum.tuer_betreten.connect(_on_tuer_betreten)
	if raum.has_signal("geheimwand_gesprengt"):
		raum.geheimwand_gesprengt.connect(_on_geheimwand_gesprengt)
	if raum.has_signal("alle_gegner_besiegt"):
		raum.alle_gegner_besiegt.connect(_on_alle_gegner_besiegt.bind(raum))

func _karten_groesse() -> int:
	match welt:
		1: return randi_range(8,  10)
		2: return randi_range(12, 13)
		3: return randi_range(12, 16)
		4: return randi_range(15, 16)
		5: return randi_range(17, 19)
		6: return 19
		7: return randi_range(18, 22)
		8: return randi_range(18, 22)
		_: return 22

func _geheim_anzahl() -> int:
	match welt:
		1: return 1
		2: return 1
		3: return 2
		4: return 2
		5: return 2
		6: return 2
		7: return 3
		8: return 3
		_: return 3

func _wand_richtungen_fuer(pos: Vector2) -> Array:
	if not generierte_karte.has(pos):
		return []
	var tueren = generierte_karte[pos]["tueren"]
	var waende = []
	for richtung in tueren:
		if not tueren[richtung]:
			waende.append(richtung)
		else:
			# Richtung zeigt auf einen Geheimraum → gilt als Wand, solange noch nicht besucht
			var adj = pos + RICHTUNG_OFFSET[richtung]
			if generierte_karte.get(adj, {}).get("typ", "") == "geheim_wand":
				if besuchte_raeume.get(adj, "") != "geheim":
					waende.append(richtung)
	return waende

# Gibt alle Richtungen zurück in denen ein Geheimraum an pos angrenzt
func _geheimwand_richtungen_fuer(pos: Vector2) -> Array:
	var richtungen = []
	for richtung in RICHTUNG_OFFSET:
		var adj = pos + RICHTUNG_OFFSET[richtung]
		if generierte_karte.get(adj, {}).get("typ", "") == "geheim_wand":
			richtungen.append(richtung)
	return richtungen

# ── Spawner ──────────────────────────────────────────────────────────────────

func gegner_spawnen(raum):
	var pool = MONSTER_TIER2 if welt >= 5 else MONSTER_TIER1
	var anzahl = randi_range(2, 4)
	var neue = []
	for i in anzahl:
		var g = gegner_szene.instantiate()
		g.monster_id = pool[randi() % pool.size()]
		g.welt = welt
		g.global_position = _sicherer_spawn(raum)
		raum.add_child(g)
		raum.gegner_registrieren(g)
		neue.append(g)
	# Leichen-Träger: ab Welt 5 trägt im 2.–4. betretenen Kampfraum ein Gegner die Markierung
	if welt >= 5 and _leichen_gegner_countdown > 0 and neue.size() > 0:
		_leichen_gegner_countdown -= 1
		if _leichen_gegner_countdown == 0:
			neue[randi() % neue.size()].leichen_traeger = true

func _sicherer_spawn(raum) -> Vector2:
	# Für Multi-Zell-Räume: Zufällige gültige Zelle wählen,
	# damit Gegner nie im fehlenden Eck spawnen (z. B. l_2).
	if not "zellen_info" in raum or raum.zellen_info.is_empty():
		return Vector2(randf_range(160, 1120), randf_range(160, 540))
	var bbox_orig = Vector2.ZERO
	for zi in raum.zellen_info:
		bbox_orig.x = min(bbox_orig.x, zi.offset.x)
		bbox_orig.y = min(bbox_orig.y, zi.offset.y)
	var cell = Vector2(float(Z_B_CONST), float(Z_H_CONST))
	if raum.has_method("zell_groesse"):
		cell = raum.zell_groesse()
	var zi = raum.zellen_info[randi() % raum.zellen_info.size()]
	var px = (zi.offset - bbox_orig) * cell
	return Vector2(px.x + randf_range(160, cell.x - 160), px.y + randf_range(160, cell.y - 180))

func boss_spawnen(raum):
	var b = boss_szene.instantiate()
	b.welt = welt
	b.global_position = Vector2(640, 360)
	raum.add_child(b)
	raum.gegner_registrieren(b)

func boss_relikt_spawnen(raum):
	var r = relikt_szene.instantiate()
	r.typ      = RELIKT_SKRIPT.zufaelliger_aus_pool(RELIKT_SKRIPT.POOL_NORMAL)
	r.pool_typ = "normal"
	r.position = Vector2(640, 450)
	raum.add_child.call_deferred(r)

func steine_spawnen(raum):
	if randf() < 0.30:
		return
	var muster = _zufaelliges_muster()

	var cs = Vector2(1280, 720)
	if raum.has_method("zell_groesse"):
		cs = raum.zell_groesse()
	var mitte = cs / 2.0

	# Türmitten der Zelle freihalten, damit man nie in Steinen spawnt / hängen bleibt
	var eingaenge = [
		Vector2(cs.x / 2.0, 140), Vector2(cs.x / 2.0, cs.y - 140),
		Vector2(140, cs.y / 2.0), Vector2(cs.x - 140, cs.y / 2.0)]
	const FREI_RADIUS = 85.0

	var positionen = []
	for m in muster:
		var pos = mitte + m
		var frei = true
		for e in eingaenge:
			if pos.distance_to(e) < FREI_RADIUS:
				frei = false
				break
		if frei:
			positionen.append(pos)
	if positionen.is_empty():
		return

	var geheimstein_idx = -1
	if randf() < 0.20:
		geheimstein_idx = randi() % positionen.size()
	for i in positionen.size():
		var s = stein_szene.instantiate()
		s.position = positionen[i]
		if i == geheimstein_idx:
			s.ist_geheimstein = true
			s.geheimgang_gefunden.connect(_on_geheimstein_zerstoert.bind(raum))
		raum.add_child(s)

func _zufaelliges_muster() -> Array:
	var muster = [
		null, null,
		[Vector2(0,0), Vector2(0,-160), Vector2(0,160), Vector2(-220,0), Vector2(220,0)],
		[Vector2(-200,-130), Vector2(200,-130), Vector2(0,0), Vector2(-200,130), Vector2(200,130)],
		[Vector2(-240,0), Vector2(-120,0), Vector2(0,0), Vector2(120,0), Vector2(240,0)],
		[Vector2(0,-150), Vector2(0,-75), Vector2(0,0), Vector2(0,75), Vector2(0,150)],
		[Vector2(-240,-100), Vector2(-120,-50), Vector2(0,0), Vector2(120,50), Vector2(240,100)],
		[Vector2(0,-150), Vector2(-200,100), Vector2(200,100)],
		[Vector2(-200,-100), Vector2(-200,0), Vector2(-200,100), Vector2(-100,100), Vector2(0,100)],
		[Vector2(-220,0), Vector2(220,0)],
	]
	var wahl = muster[randi() % muster.size()]
	return wahl if wahl != null else _scatter_muster()

func _scatter_muster() -> Array:
	var gitter = [
		Vector2(-368,-120), Vector2(-184,-120), Vector2(0,-120), Vector2(184,-120), Vector2(368,-120),
		Vector2(-368,   0), Vector2(-184,   0), Vector2(0,   0), Vector2(184,   0), Vector2(368,   0),
		Vector2(-368, 120), Vector2(-184, 120), Vector2(0, 120), Vector2(184, 120), Vector2(368, 120),
	]
	gitter.shuffle()
	var anzahl  = randi_range(3, 8)
	var ergebnis = []
	for i in min(anzahl, gitter.size()):
		ergebnis.append(gitter[i] + Vector2(randf_range(-45, 45), randf_range(-30, 30)))
	return ergebnis

func truhe_spawnen(raum):
	var t = truhe_szene.instantiate()
	t.position = Vector2(randf_range(200, 1080), randf_range(200, 500))
	raum.add_child(t)

func verbrauch_spawnen(raum):
	var v = verbrauch_szene.instantiate()
	v.typ = ["bitcoin", "bombe", "schluessel"][randi() % 3]
	v.position = Vector2(randf_range(200, 1080), randf_range(200, 500))
	raum.add_child(v)

func geheim_komponente_spawnen(raum):
	var kandidaten = global_data.nicht_besessene_komponenten_fuer_welt(welt)
	if kandidaten.is_empty():
		return
	var k = kandidaten[0]
	var p = Node2D.new()
	p.set_script(KOMP_PICKUP_SKRIPT)
	p.slot = k["slot"]
	p.komponente = k["komponente"]
	p.position = Vector2(640, 360)
	raum.add_child(p)

func komponenten_spawnen(raum, anzahl: int):
	var kandidaten = global_data.nicht_besessene_komponenten_fuer_welt(welt)
	var pos_liste = [Vector2(420, 360), Vector2(860, 360)]
	for i in min(anzahl, kandidaten.size()):
		var k = kandidaten[i]
		var p = Node2D.new()
		p.set_script(KOMP_PICKUP_SKRIPT)
		p.slot = k["slot"]
		p.komponente = k["komponente"]
		p.position = pos_liste[i]
		p.ist_schatz_wahl = true
		raum.add_child(p)
		p.add_to_group("schatz_pickup")

# ── Raumerstellung ────────────────────────────────────────────────────────────

func naechsten_raum_erstellen() -> Node:
	var neuer_raum

	var karten_typ = generierte_karte.get(raum_position, {}).get("typ", "")

	# Perfektionsraum: Bonus-Raum nach schadensfreier Welt
	if perfektion_position != null and raum_position == perfektion_position:
		besuchte_raeume[raum_position] = "perfektion"
		neuer_raum = raum_perfektion_szene.instantiate()
		# Alle Richtungen sind Wände, außer dem Eingang zurück zum Boss-Raum
		var alle = ["oben", "unten", "links", "rechts"]
		alle.erase(perfektion_eingang)
		neuer_raum.wand_richtungen = alle
		add_child(neuer_raum)
		_raum_verbinden(neuer_raum)
		raum_instanzen[raum_position] = neuer_raum
		return neuer_raum

	# Geheimraum: entweder durch Bombenöffnung (geheim_wand) oder Stein-Portal (geheim_positionen)
	if karten_typ == "geheim_wand" or geheim_positionen.has(raum_position):
		besuchte_raeume[raum_position] = "geheim"
		neuer_raum = raum_geheim_szene.instantiate()
		# Alle Wände sperren außer der Eingangsrichtung – andere Wände müssen gesprengt werden
		var alle = ["oben", "unten", "links", "rechts"]
		if _eintritts_richtung != "":
			alle.erase(GEGENRICHTUNG[_eintritts_richtung])
		neuer_raum.wand_richtungen = alle
		# Angrenzende reguläre Räume als Geheimwände markieren (bombierbar)
		if karten_typ == "geheim_wand" and _eintritts_richtung != "":
			var eingang = GEGENRICHTUNG[_eintritts_richtung]
			for r in ["oben", "unten", "links", "rechts"]:
				if r == eingang:
					continue
				var adj = raum_position + RICHTUNG_OFFSET[r]
				if generierte_karte.get(adj, {}).get("typ", "") not in ["", "geheim_wand", "satellit"]:
					neuer_raum.geheimwand_richtungen.append(r)
		add_child(neuer_raum)
		_raum_verbinden(neuer_raum)
		raum_instanzen[raum_position] = neuer_raum
		geheim_komponente_spawnen(neuer_raum)
		if geheim_positionen.has(raum_position):
			_portal_in_geheimraum_spawnen(neuer_raum)
		return neuer_raum

	var typ = karten_typ if karten_typ != "" else "normal"
	besuchte_raeume[raum_position] = typ

	if typ in ["lang_h", "lang_v", "l_0", "l_1", "l_2", "l_3", "gross"]:
		neuer_raum = raum_multi_szene.instantiate()
		neuer_raum.anker_pos   = raum_position
		neuer_raum.layout_typ  = typ
		neuer_raum.zellen_info = _multi_zellen_info(raum_position)
		neuer_raum.geheim_infos = _multi_geheim_infos(raum_position)
		neuer_raum.verschlossene_ziele = _verschlossene_ziele_fuer(raum_position)
		neuer_raum.tuer_typen_ziel = _tuer_typen_ziel_fuer(raum_position)
		add_child(neuer_raum)
		_raum_verbinden(neuer_raum)
		raum_instanzen[raum_position] = neuer_raum
		# Satelliten-Positionen ebenfalls eintragen
		for zi in neuer_raum.zellen_info:
			if zi.offset != Vector2.ZERO:
				raum_instanzen[raum_position + zi.offset] = neuer_raum
		gegner_spawnen(neuer_raum)
		steine_spawnen(neuer_raum)
		return neuer_raum

	match typ:
		"boss":    neuer_raum = raum_boss_szene.instantiate()
		"schatz":  neuer_raum = raum_schatz_szene.instantiate()
		"raetsel": neuer_raum = raum_raetsel_szene.instantiate()
		"apotheke": neuer_raum = raum_apotheke_szene.instantiate()
		"dealer":   neuer_raum = raum_dealer_szene.instantiate()
		_:         neuer_raum = raum_szene.instantiate()

	neuer_raum.wand_richtungen = _wand_richtungen_fuer(raum_position)

	# Geheimwand aus der Karte lesen (kein Zufall mehr)
	if neuer_raum.has_method("bombe_bei"):
		neuer_raum.geheimwand_richtungen = _geheimwand_richtungen_fuer(raum_position)

	if "verschlossene_tueren" in neuer_raum:
		neuer_raum.verschlossene_tueren = _verschlossene_tueren_fuer(raum_position)
		neuer_raum.tuer_typen = _tuer_typen_fuer(raum_position)

	add_child(neuer_raum)
	_raum_verbinden(neuer_raum)
	raum_instanzen[raum_position] = neuer_raum

	match typ:
		"normal":
			gegner_spawnen(neuer_raum)
			steine_spawnen(neuer_raum)
			pass  # Kein fester Truhen-Spawn – nur via Raum-Clear-Loot
		"boss":   boss_spawnen(neuer_raum)
		"schatz": komponenten_spawnen(neuer_raum, 2)
		"apotheke": pass  # raum_apotheke.gd spawnt Angebote selbst in _raum_initialisieren()
		"dealer":   pass  # raum_dealer.gd baut alles selbst auf

	return neuer_raum

# ── Signalhandler ─────────────────────────────────────────────────────────────

func _projektile_entfernen():
	for p in get_tree().get_nodes_in_group("projektil"):
		p.queue_free()

func _on_tuer_betreten(richtung):
	# Schatzraum-Schloss (ab Welt 2)
	if richtung in RICHTUNG_OFFSET:
		var ziel = raum_position + RICHTUNG_OFFSET[richtung]
		if _schatz_gesperrt(ziel):
			if global_data.schluessel > 0:
				global_data.schluessel -= 1
				schatz_geoeffnet[ziel] = true
				if aktueller_raum.has_method("schatz_entsperren"):
					aktueller_raum.schatz_entsperren(richtung)
			else:
				_schatz_abweisen(richtung)
				return
	_projektile_entfernen()
	global_data.zeti_reroll_verfuegbar = true   # Reroll pro Raum zurücksetzen
	_eintritts_richtung = richtung
	aktueller_raum.visible = false
	aktueller_raum.process_mode = Node.PROCESS_MODE_DISABLED

	match richtung:
		"oben":   raum_position.y -= 1; spieler.global_position = Vector2(640, 580)
		"unten":  raum_position.y += 1; spieler.global_position = Vector2(640, 140)
		"links":  raum_position.x -= 1; spieler.global_position = Vector2(1120, 360)
		"rechts": raum_position.x += 1; spieler.global_position = Vector2(160, 360)
		"geheim":
			var gp = raum_position + Vector2(50, 50)
			geheim_positionen[gp] = true
			raum_position = gp
			spieler.global_position = Vector2(160, 360)

	_raum_wechseln()

# Multi-Zell-Räume senden dieses Signal statt tuer_betreten
func _on_tuer_betreten_ziel(neue_pos: Vector2, eintritts_pos: Vector2):
	# Schatzraum-Schloss (ab Welt 2)
	if _schatz_gesperrt(neue_pos):
		if global_data.schluessel > 0:
			global_data.schluessel -= 1
			schatz_geoeffnet[neue_pos] = true
			if aktueller_raum.has_method("schatz_entsperren_ziel"):
				aktueller_raum.schatz_entsperren_ziel(neue_pos)
		else:
			_schatz_abweisen(_richtung_aus_eintritt(eintritts_pos))
			return
	_projektile_entfernen()
	global_data.zeti_reroll_verfuegbar = true
	# Richtung aus Spawn-Position ableiten (identisch mit normalen Räumen)
	if   eintritts_pos.y > 400:  _eintritts_richtung = "oben"
	elif eintritts_pos.y < 300:  _eintritts_richtung = "unten"
	elif eintritts_pos.x > 640:  _eintritts_richtung = "links"
	else:                         _eintritts_richtung = "rechts"
	aktueller_raum.visible = false
	aktueller_raum.process_mode = Node.PROCESS_MODE_DISABLED
	raum_position = neue_pos
	spieler.global_position = eintritts_pos
	_raum_wechseln()

func _on_alle_gegner_besiegt(raum: Node):
	if besuchte_raeume.get(raum_position, "") == "boss":
		boss_relikt_spawnen(raum)
		_welt_portal_spawnen(raum)
		if not global_data.schaden_in_aktueller_welt:
			_perfektion_tuer_oeffnen(raum)

	if besuchte_raeume.get(raum_position, "") == "boss":
		return
	if raum.loot_gedroppt:
		return
	raum.loot_gedroppt = true

	if randf() < 0.65:
		_loot_droppen(raum)

func _loot_droppen(raum: Node):
	var zufall = randf()
	var pos = Vector2(randf_range(420, 860), randf_range(260, 460))
	if zufall < 0.15:
		var t = truhe_szene.instantiate()
		t.position = pos
		raum.add_child.call_deferred(t)
	else:
		var w = randf()
		if w < 0.20:
			# Herz-Drop
			var h = herz_szene.instantiate()
			h.typ = "voll" if randf() < 0.5 else "halb"
			h.position = pos
			raum.add_child.call_deferred(h)
		else:
			var v = verbrauch_szene.instantiate()
			if w < 0.52:
				v.typ = "bitcoin"
			elif w < 0.76:
				v.typ = "bombe"
			else:
				v.typ = "schluessel"
			v.position = pos
			raum.add_child.call_deferred(v)

func _welt_portal_spawnen(raum: Node):
	var p = portal_skript.new()
	p.position = Vector2(640, 200)
	p.aktivierungs_delay = 0.5
	p.portal_betreten.connect(func(_z): _naechste_welt_starten())
	raum.add_child.call_deferred(p)

func _perfektion_tuer_oeffnen(raum: Node):
	# Erste freie Wandrichtung im Boss-Raum suchen – Geheimraum-Positionen überspringen
	var richtung = ""
	for r in ["oben", "links", "rechts", "unten"]:
		if r in raum.wand_richtungen:
			var adj_pos = raum_position + RICHTUNG_OFFSET[r]
			if generierte_karte.get(adj_pos, {}).get("typ", "") == "geheim_wand":
				continue  # Diese Richtung ist ein Geheimraum – überspringen
			richtung = r
			break
	if richtung == "":
		return  # Kein freier Wandplatz
	perfektion_position = raum_position + RICHTUNG_OFFSET[richtung]
	perfektion_eingang  = GEGENRICHTUNG[richtung]
	raum.tuer_aufschliessen(richtung)
	if "tuer_typen" in raum:
		raum.tuer_typen[richtung] = "perfektion"
		raum.tueren_oeffnen()

func _on_geheimwand_gesprengt(_richtung: String):
	pass  # Raum ist bereits als geheim_wand in generierte_karte – kein weiterer Eintrag nötig

func _on_geheimstein_zerstoert(stein_pos: Vector2, raum: Node):
	var geheim_pos = raum_position + Vector2(0, 100)
	geheim_positionen[geheim_pos] = true
	_portal_spawnen(stein_pos, geheim_pos, raum)

func _portal_spawnen(pos: Vector2, ziel: Vector2, raum: Node):
	var p = portal_skript.new()
	p.position = pos
	p.ziel_raum_pos = ziel
	p.portal_betreten.connect(_on_portal_betreten)
	raum.add_child(p)

func _portal_in_geheimraum_spawnen(raum: Node):
	var ursprung = raum_position - Vector2(0, 100)
	_portal_spawnen(Vector2(1180, 100), ursprung, raum)

func _on_portal_betreten(ziel: Vector2):
	_projektile_entfernen()
	_eintritts_richtung = ""   # Portal hat keine Richtung – alle Wände sperren
	aktueller_raum.visible = false
	aktueller_raum.process_mode = Node.PROCESS_MODE_DISABLED
	raum_position = ziel
	spieler.global_position = Vector2(640, 360)
	_raum_wechseln()

# ── Hilfsfunktionen ───────────────────────────────────────────────────────────

func _raum_wechseln():
	# Satellit → Anker umleiten; betretene Zelle merken für Spawn-Korrektur
	var rauminfo = generierte_karte.get(raum_position, {})
	var eintritts_zell_offset = Vector2.ZERO  # Offset der betretenen Zelle vom Anker

	if rauminfo.get("typ", "") == "satellit":
		var anker_pos = rauminfo["anker"]
		eintritts_zell_offset = raum_position - anker_pos
		raum_position = anker_pos
		if not raum_instanzen.has(anker_pos):
			aktueller_raum = naechsten_raum_erstellen()
		else:
			aktueller_raum = raum_instanzen[anker_pos]
	elif raum_instanzen.has(raum_position):
		aktueller_raum = raum_instanzen[raum_position]
		# Falls wir aus einem Geheimraum kommen, die Wand im Zielraum öffnen
		if _eintritts_richtung in GEGENRICHTUNG:
			var eingangs_seite = GEGENRICHTUNG[_eintritts_richtung]
			var herkunfts_pos = raum_position - RICHTUNG_OFFSET[_eintritts_richtung]
			if besuchte_raeume.get(herkunfts_pos, "") == "geheim":
				if eingangs_seite in aktueller_raum.wand_richtungen:
					aktueller_raum.wand_richtungen.erase(eingangs_seite)
					aktueller_raum.tueren_oeffnen()
	else:
		aktueller_raum = naechsten_raum_erstellen()

	# Spawn-Position für Multi-Zell-Räume neu berechnen (gestauchte Zellgröße).
	# Der Anker liegt nicht immer bei Pixel (0,0) – bbox_orig bestimmt den Versatz.
	var anker_data = generierte_karte.get(raum_position, {})
	if anker_data.has("zellen") and aktueller_raum.has_method("zell_groesse"):
		var cell = aktueller_raum.zell_groesse()
		var bbox_orig = Vector2.ZERO
		for z in anker_data["zellen"]:
			var off = z - raum_position
			bbox_orig.x = min(bbox_orig.x, off.x)
			bbox_orig.y = min(bbox_orig.y, off.y)
		var basis = _multi_eintritts_basis(_eintritts_richtung, cell)
		spieler.global_position = basis + (eintritts_zell_offset - bbox_orig) * cell

	aktueller_raum.visible = true
	aktueller_raum.process_mode = Node.PROCESS_MODE_INHERIT
	_kamera_aktualisieren()
	global_data.aktueller_raum = aktueller_raum
	$CanvasLayer/MiniMap.aktualisieren()

const Z_B_CONST = 1280
const Z_H_CONST = 720

func _kamera_aktualisieren():
	var info = generierte_karte.get(raum_position, {})
	if info.get("typ", "") == "satellit":
		info = generierte_karte.get(info["anker"], {})
	var typ = info.get("typ", "")
	if typ in ["lang_h", "lang_v", "l_0", "l_1", "l_2", "l_3", "gross"] \
			and aktueller_raum != null and aktueller_raum.has_method("gesamt_groesse"):
		var g = aktueller_raum.gesamt_groesse()
		spieler.kamera_grenzen_setzen(int(g.x), int(g.y))
	else:
		spieler.kamera_grenzen_setzen(1280, 720)

# Basis-Spawn innerhalb der betretenen Zelle, abhängig von Bewegungsrichtung
func _multi_eintritts_basis(richtung: String, cell: Vector2) -> Vector2:
	match richtung:
		"rechts": return Vector2(160, cell.y / 2.0)          # von links betreten
		"links":  return Vector2(cell.x - 160, cell.y / 2.0) # von rechts betreten
		"unten":  return Vector2(cell.x / 2.0, 140)          # von oben betreten
		"oben":   return Vector2(cell.x / 2.0, cell.y - 140) # von unten betreten
	return Vector2(cell.x / 2.0, cell.y / 2.0)               # Portal o. Ä. → Zellmitte

# ── Schatzraum-Schloss ────────────────────────────────────────────────────────

func _schatz_gesperrt(ziel_pos: Vector2) -> bool:
	var typ = generierte_karte.get(ziel_pos, {}).get("typ", "")
	return typ == "schatz" and welt >= 2 and not schatz_geoeffnet.has(ziel_pos)

# Richtungen eines Einzelraums, deren Tür zu einem gesperrten Schatzraum führt
func _verschlossene_tueren_fuer(pos: Vector2) -> Array:
	var result = []
	if welt < 2:
		return result
	for richtung in RICHTUNG_OFFSET:
		var adj = pos + RICHTUNG_OFFSET[richtung]
		if generierte_karte.get(adj, {}).get("typ", "") == "schatz" and not schatz_geoeffnet.has(adj):
			result.append(richtung)
	return result

# Positionen gesperrter Schatzräume, die an einen Multi-Raum grenzen
func _verschlossene_ziele_fuer(anker_pos: Vector2) -> Array:
	var result = []
	if welt < 2:
		return result
	var zellen = generierte_karte.get(anker_pos, {}).get("zellen", [anker_pos])
	for z in zellen:
		for richtung in RICHTUNG_OFFSET:
			var adj = z + RICHTUNG_OFFSET[richtung]
			if generierte_karte.get(adj, {}).get("typ", "") == "schatz" \
					and not schatz_geoeffnet.has(adj) and adj not in result:
				result.append(adj)
	return result

# Effektiver Raumtyp an einer Position (Satellit → Anker auflösen)
func _ziel_typ(pos: Vector2) -> String:
	var data = generierte_karte.get(pos, {})
	var typ = data.get("typ", "")
	if typ == "satellit":
		typ = generierte_karte.get(data.get("anker", pos), {}).get("typ", "")
	return typ

# Einzelraum: Richtung → Zielraum-Typ (nur Typen mit eigener Türfarbe)
func _tuer_typen_fuer(pos: Vector2) -> Dictionary:
	var result = {}
	for richtung in RICHTUNG_OFFSET:
		var typ = _ziel_typ(pos + RICHTUNG_OFFSET[richtung])
		if typ in global_data.TUER_TYP_FARBEN:
			result[richtung] = typ
	return result

# Multi-Raum: Ziel-Raumposition → Zielraum-Typ
func _tuer_typen_ziel_fuer(anker_pos: Vector2) -> Dictionary:
	var result = {}
	var zellen = generierte_karte.get(anker_pos, {}).get("zellen", [anker_pos])
	var gruppe = {}
	for z in zellen:
		gruppe[z] = true
	for z in zellen:
		for richtung in RICHTUNG_OFFSET:
			var adj = z + RICHTUNG_OFFSET[richtung]
			if gruppe.has(adj):
				continue
			var typ = _ziel_typ(adj)
			if typ in global_data.TUER_TYP_FARBEN:
				result[adj] = typ
	return result

func _richtung_aus_eintritt(eintritts_pos: Vector2) -> String:
	if eintritts_pos.y > 400:   return "oben"
	elif eintritts_pos.y < 300: return "unten"
	elif eintritts_pos.x > 640: return "links"
	return "rechts"

func _schatz_abweisen(richtung: String):
	match richtung:
		"oben":   spieler.global_position += Vector2(0,  90)
		"unten":  spieler.global_position += Vector2(0, -90)
		"links":  spieler.global_position += Vector2( 90, 0)
		"rechts": spieler.global_position += Vector2(-90, 0)
	_hinweis_zeigen("🔒 Schlüssel benötigt")

func _hinweis_zeigen(text: String):
	if _hinweis_label == null:
		return
	_hinweis_label.text    = text
	_hinweis_label.visible = true
	var t = get_tree().create_timer(1.5)
	t.timeout.connect(func():
		if is_instance_valid(_hinweis_label):
			_hinweis_label.visible = false)

func _multi_zellen_info(anker_pos: Vector2) -> Array:
	var anker_data = generierte_karte.get(anker_pos, {})
	var zellen = anker_data.get("zellen", [anker_pos])
	var gruppe = {}
	for z in zellen:
		gruppe[z] = true
	var result = []
	for z in zellen:
		var tueren = {}
		for richtung in RICHTUNG_OFFSET:
			var adj = z + RICHTUNG_OFFSET[richtung]
			var adj_typ = generierte_karte.get(adj, {}).get("typ", "")
			tueren[richtung] = (not gruppe.has(adj)) and generierte_karte.has(adj) \
				and adj_typ != "geheim_wand"
		result.append({"offset": z - anker_pos, "tueren": tueren})
	return result

func _multi_geheim_infos(anker_pos: Vector2) -> Array:
	var anker_data = generierte_karte.get(anker_pos, {})
	var zellen = anker_data.get("zellen", [anker_pos])
	var result = []
	for z in zellen:
		for richtung in RICHTUNG_OFFSET:
			var adj = z + RICHTUNG_OFFSET[richtung]
			if generierte_karte.get(adj, {}).get("typ", "") == "geheim_wand":
				result.append({"zell_offset": z - anker_pos, "richtung": richtung})
	return result

func _naechste_welt_starten():
	welt += 1
	$CanvasLayer/WeltUebergang.zeigen(welt)

func _neue_welt_aufbauen():
	for pos in raum_instanzen:
		var r = raum_instanzen[pos]
		if is_instance_valid(r):
			r.queue_free()

	raum_instanzen.clear()
	besuchte_raeume.clear()
	geheim_positionen.clear()
	perfektion_position = null
	perfektion_eingang  = ""
	schatz_geoeffnet = {}
	global_data.schaden_in_aktueller_welt = false
	global_data.aktuelle_welt = welt
	global_data.leichen = 0            # Leiche verfällt beim Weltwechsel
	raum_position = Vector2(0, 0)

	generierte_karte = KartenGenerator.generieren(_karten_groesse(), _geheim_anzahl(), welt)
	_leichen_gegner_countdown = randi_range(2, 4)

	var start_raum = raum_szene.instantiate()
	start_raum.wand_richtungen = _wand_richtungen_fuer(raum_position)
	start_raum.geheimwand_richtungen = _geheimwand_richtungen_fuer(raum_position)
	start_raum.verschlossene_tueren = _verschlossene_tueren_fuer(raum_position)
	start_raum.tuer_typen = _tuer_typen_fuer(raum_position)
	add_child(start_raum)
	_raum_verbinden(start_raum)
	besuchte_raeume[raum_position] = "start"
	raum_instanzen[raum_position]  = start_raum
	aktueller_raum = start_raum
	global_data.aktueller_raum = aktueller_raum

	spieler.global_position = Vector2(640, 360)
	_kamera_aktualisieren()
	$CanvasLayer/MiniMap.aktualisieren()

# ── Pausemenü-Handler ─────────────────────────────────────────────────────────

func _pausemenue_fortfahren():
	# Pausemenü wird geschlossen und Spiel läuft weiter
	pass

func _pausemenue_beenden():
	# Zurück zum Startmenü
	get_tree().paused = false
	get_tree().change_scene_to_file("res://base.tscn")
