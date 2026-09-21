extends RefCounted
class_name KartenGenerator

# Gibt zurück: {Vector2: {"typ": String, "tueren": {oben,unten,links,rechts: bool}}}
# typ "geheim_wand" = noch nicht entdeckter Geheimraum (nur durch Bombe zugänglich)
static func generieren(anzahl: int, geheim_anzahl: int = 0, welt: int = 1) -> Dictionary:
	var karte = {}
	var queue = [Vector2(0, 0)]
	karte[Vector2(0, 0)] = {"typ": "start", "tueren": {}}

	while karte.size() < anzahl and not queue.is_empty():
		var idx = randi() % queue.size()
		var pos = queue[idx]
		var erweitert = false

		var dirs = _richtungen()
		dirs.shuffle()

		for dir in dirs:
			var neue_pos = pos + dir
			if karte.has(neue_pos):
				continue
			if _nachbarn_zaehlen(karte, neue_pos) > 1:
				continue
			karte[neue_pos] = {"typ": "normal", "tueren": {}}
			queue.append(neue_pos)
			erweitert = true
			break

		if not erweitert:
			queue.remove_at(idx)

	_typen_zuweisen(karte, welt)
	_geheim_raeume_platzieren(karte, geheim_anzahl)
	_tueren_berechnen(karte)
	_multi_raeume_einfuegen(karte)
	return karte

static func _richtungen() -> Array:
	return [Vector2(0, -1), Vector2(0, 1), Vector2(-1, 0), Vector2(1, 0)]

static func _nachbarn_zaehlen(karte: Dictionary, pos: Vector2) -> int:
	var n = 0
	for dir in _richtungen():
		if karte.has(pos + dir):
			n += 1
	return n

# True, wenn pos an einen Schatzraum grenzt – solche Felder bleiben frei,
# damit der Schatzraum garantiert eine Sackgasse bleibt (verschließbar).
static func _grenzt_an_schatz(karte: Dictionary, pos: Vector2) -> bool:
	for dir in _richtungen():
		var adj = pos + dir
		if karte.has(adj) and karte[adj].get("typ", "") == "schatz":
			return true
	return false

static func _typen_zuweisen(karte: Dictionary, welt: int):
	# Alle Sackgassen finden (genau 1 Nachbar), Start ausschließen
	var sackgassen = []
	for pos in karte:
		if pos == Vector2(0, 0):
			continue
		if _nachbarn_zaehlen(karte, pos) == 1:
			sackgassen.append(pos)

	if sackgassen.is_empty():
		return

	# Absteigend nach Distanz vom Start sortieren
	sackgassen.sort_custom(func(a, b):
		return a.distance_squared_to(Vector2.ZERO) > b.distance_squared_to(Vector2.ZERO))

	# Boss = weiteste Sackgasse (immer)
	karte[sackgassen[0]]["typ"] = "boss"

	# Welche Spezialräume sind verfügbar?
	# Welt 1-2: Schatz fix + zufällig Rätsel oder Dealer
	# Welt 3:   Schatz, Rätsel, Dealer, Growbox
	# Welt 4:   Schatz, Rätsel, Dealer
	# Welt 5:   Schatz, Rätsel, Dealer, Growbox
	# Welt 6:   Schatz, Rätsel, Dealer
	# Welt 7+:  Schatz, Rätsel, Dealer, Growbox
	var spezial: Array
	match welt:
		1, 2:
			var wahl = ["raetsel", "apotheke"]
			wahl.shuffle()
			spezial = ["schatz", wahl[0]]
		4, 6:
			spezial = ["schatz", "raetsel", "apotheke"]
		_:  # 3, 5, 7, 8, ...
			spezial = ["schatz", "raetsel", "apotheke", "dealer"]

	if "schatz" in spezial and sackgassen.size() >= 2:
		karte[sackgassen[sackgassen.size() - 1]]["typ"] = "schatz"

	if "raetsel" in spezial and sackgassen.size() >= 3:
		karte[sackgassen[sackgassen.size() >> 1]]["typ"] = "raetsel"

	if "apotheke" in spezial and sackgassen.size() >= 4:
		karte[sackgassen[sackgassen.size() - 2]]["typ"] = "apotheke"

	if "dealer" in spezial and sackgassen.size() >= 5:
		karte[sackgassen[1]]["typ"] = "dealer"

static func _geheim_raeume_platzieren(karte: Dictionary, anzahl: int):
	if anzahl <= 0:
		return
	# Bevorzugt: Positionen die an 2+ Räume grenzen (Lücken in der Karte)
	# Fallback:  Positionen die an genau 1 Raum grenzen
	var bevorzugt = []
	var fallback  = []
	var geprueft  = {}
	for pos in karte:
		for dir in _richtungen():
			var adj = pos + dir
			if karte.has(adj) or geprueft.has(adj):
				continue
			geprueft[adj] = true
			if _grenzt_an_schatz(karte, adj):
				continue
			var n = _nachbarn_zaehlen(karte, adj)
			if n >= 2:
				bevorzugt.append(adj)
			elif n == 1:
				fallback.append(adj)
	bevorzugt.shuffle()
	fallback.shuffle()
	var kandidaten = bevorzugt + fallback
	for i in min(anzahl, kandidaten.size()):
		karte[kandidaten[i]] = {"typ": "geheim_wand", "tueren": {}}

static func _multi_raeume_einfuegen(karte: Dictionary):
	var normale = []
	for pos in karte:
		if karte[pos]["typ"] == "normal":
			normale.append(pos)
	normale.shuffle()

	var beansprucht = {}

	for pos in normale:
		if beansprucht.has(pos):
			continue
		var w = randf()
		if w < 0.60:
			continue
		elif w < 0.85:  # 25 % → länglicher Raum
			_probiere_lang(karte, pos, beansprucht)
		elif w < 0.95:  # 10 % → L-Raum
			_probiere_l_raum(karte, pos, beansprucht)
		else:           #  5 % → Großer Raum
			_probiere_gross(karte, pos, beansprucht)

	# Satelliten zählen und gleich viele neue Normalräume hinzufügen,
	# damit ein Multi-Zell-Raum nur als EIN Raum zählt.
	var sat_count = 0
	for pos in karte:
		if karte[pos]["typ"] == "satellit":
			sat_count += 1
	if sat_count > 0:
		_karte_erweitern(karte, sat_count)
		_tueren_berechnen(karte)  # Türen für neue Räume berechnen

static func _karte_erweitern(karte: Dictionary, anzahl: int):
	var hinzugefuegt = 0
	var versuche    = 0
	while hinzugefuegt < anzahl and versuche < anzahl * 50:
		versuche += 1
		# Alle freien Positionen neben Nicht-Satelliten/Nicht-Geheimwand-Räumen sammeln
		var kandidaten = []
		for pos in karte:
			if karte[pos]["typ"] == "satellit":
				continue
			if karte[pos]["typ"] == "geheim_wand":
				continue
			if karte[pos]["typ"] == "boss":
				continue  # Boss-Raum bleibt immer Sackgasse
			for dir in _richtungen():
				var np = pos + dir
				if not karte.has(np) and _nachbarn_zaehlen(karte, np) <= 1 \
						and not _grenzt_an_schatz(karte, np):
					kandidaten.append(np)
		if kandidaten.is_empty():
			break
		kandidaten.shuffle()
		karte[kandidaten[0]] = {"typ": "normal", "tueren": {}}
		hinzugefuegt += 1

static func _freie_normale_nachbarn(karte: Dictionary, pos: Vector2, beansprucht: Dictionary) -> Array:
	var frei = []
	for dir in _richtungen():
		var adj = pos + dir
		if karte.has(adj) and karte[adj]["typ"] == "normal" and not beansprucht.has(adj):
			frei.append(dir)
	return frei

static func _probiere_lang(karte: Dictionary, pos: Vector2, beansprucht: Dictionary):
	# Erlaubt sowohl existierende Normalräume als auch freie Positionen als Satellit
	var dirs = []
	for dir in _richtungen():
		var adj = pos + dir
		if beansprucht.has(adj):
			continue
		if _grenzt_an_schatz(karte, adj):
			continue
		if not karte.has(adj) or karte[adj]["typ"] == "normal":
			dirs.append(dir)
	if dirs.is_empty():
		return
	var dir = dirs[randi() % dirs.size()]
	var sat_pos = pos + dir
	var typ = "lang_h" if dir.x != 0 else "lang_v"
	# pos ist immer Anker; Satellit zuerst anlegen (braucht _merged_tueren)
	karte[sat_pos]          = {"typ": "satellit", "anker": pos, "tueren": {}}
	karte[pos]["typ"]       = typ
	karte[pos]["zellen"]    = [pos, sat_pos]
	karte[pos]["tueren"]    = _merged_tueren(karte, [pos, sat_pos])
	beansprucht[pos]        = true
	beansprucht[sat_pos]    = true

static func _probiere_l_raum(karte: Dictionary, pos: Vector2, beansprucht: Dictionary):
	# Erlaubt sowohl existierende Normalräume als auch freie Positionen als Satellit
	var dirs = []
	for dir in _richtungen():
		var adj = pos + dir
		if beansprucht.has(adj):
			continue
		if _grenzt_an_schatz(karte, adj):
			continue
		if not karte.has(adj) or karte[adj]["typ"] == "normal":
			dirs.append(dir)
	if dirs.size() < 2:
		return
	# Senkrechte Richtungspaare suchen
	var paare = []
	for i in dirs.size():
		for j in range(i + 1, dirs.size()):
			if dirs[i].dot(dirs[j]) == 0:
				paare.append([dirs[i], dirs[j]])
	if paare.is_empty():
		return
	var paar = paare[randi() % paare.size()]
	var sat1 = pos + paar[0]
	var sat2 = pos + paar[1]
	var orient = _l_orientierung(paar[0], paar[1])
	# Satelliten zuerst anlegen, dann tueren berechnen
	karte[sat1]          = {"typ": "satellit", "anker": pos, "tueren": {}}
	karte[sat2]          = {"typ": "satellit", "anker": pos, "tueren": {}}
	karte[pos]["typ"]    = "l_" + str(orient)
	karte[pos]["zellen"] = [pos, sat1, sat2]
	karte[pos]["tueren"] = _merged_tueren(karte, [pos, sat1, sat2])
	beansprucht[pos]  = true
	beansprucht[sat1] = true
	beansprucht[sat2] = true

static func _l_orientierung(d1: Vector2, d2: Vector2) -> int:
	var r = Vector2(1, 0); var u = Vector2(0, 1)
	var l = Vector2(-1, 0); var o = Vector2(0, -1)
	if   (d1 == r or d2 == r) and (d1 == u or d2 == u): return 0
	elif (d1 == l or d2 == l) and (d1 == u or d2 == u): return 1
	elif (d1 == l or d2 == l) and (d1 == o or d2 == o): return 2
	else: return 3  # rechts + oben

static func _probiere_gross(karte: Dictionary, pos: Vector2, beansprucht: Dictionary):
	# 2×2-Block: rechts, unten, diagonal – darf leer oder normaler Raum sein
	var r = pos + Vector2(1, 0)
	var u = pos + Vector2(0, 1)
	var d = pos + Vector2(1, 1)
	for adj in [r, u, d]:
		if _grenzt_an_schatz(karte, adj):
			return
		if karte.has(adj):
			if karte[adj]["typ"] != "normal" or beansprucht.has(adj):
				return
	var zellen = [pos, r, u, d]
	# Satelliten zuerst anlegen, dann tueren berechnen
	for sat in [r, u, d]:
		karte[sat]       = {"typ": "satellit", "anker": pos, "tueren": {}}
		beansprucht[sat] = true
	karte[pos]["typ"]    = "gross"
	karte[pos]["zellen"] = zellen
	karte[pos]["tueren"] = _merged_tueren(karte, zellen)
	beansprucht[pos]     = true

static func _merged_tueren(karte: Dictionary, zellen: Array) -> Dictionary:
	var gruppe = {}
	for z in zellen:
		gruppe[z] = true
	var namen = {
		Vector2(0,-1): "oben", Vector2(0,1): "unten",
		Vector2(-1,0): "links", Vector2(1,0): "rechts"
	}
	var tueren = {"oben": false, "unten": false, "links": false, "rechts": false}
	for z in zellen:
		for dir in namen:
			var adj = z + dir
			if not gruppe.has(adj) and karte.has(adj):
				var t = karte[adj]["typ"]
				if t != "geheim_wand":
					tueren[namen[dir]] = true
	return tueren

static func _tueren_berechnen(karte: Dictionary):
	var namen = {
		Vector2(0, -1): "oben", Vector2(0, 1): "unten",
		Vector2(-1, 0): "links", Vector2(1, 0): "rechts"
	}
	for pos in karte:
		var tueren = {}
		for dir in _richtungen():
			tueren[namen[dir]] = karte.has(pos + dir)
		karte[pos]["tueren"] = tueren
