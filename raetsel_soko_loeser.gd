extends RefCounted

# Sokoban-Löser (farb-fähig): jede Kiste hat eine Farbe, jedes Ziel eine Farbe.
# Gelöst, wenn jedes Ziel von einer FARBGLEICHEN Kiste bedeckt ist.
# Farbcodes: 0 = ungefärbt (klassisch), 1-5 = Farben, 6 = Wild (braucht kein Ziel).
# Breitensuche über Schübe; Zustand = (kanonische Spielerposition + Kistenmenge
# mit Farben).
#
# loesen(waende, kisten0, ziele, spieler0, budget):
#   waende:  Dictionary Vector2i -> true
#   kisten0: Dictionary Vector2i -> farbe(int)
#   ziele:   Dictionary Vector2i -> farbe(int)
#   Rückgabe: { "ok": bool, "schuebe": int, "zustaende": int }

const DIRS = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
# Schienen-Bitmaske, identisch zu raetsel_sokoban.gd: rechts 1, links 2,
# runter 4, hoch 8. Eine Kiste AUF einer Schiene darf nur in deren Richtungen.
const R_BIT = {Vector2i(1, 0): 1, Vector2i(-1, 0): 2, Vector2i(0, 1): 4, Vector2i(0, -1): 8}

static func loesen(waende: Dictionary, kisten0: Dictionary, ziele: Dictionary,
		spieler0: Vector2i, budget: int) -> Dictionary:
	if _erfuellt(kisten0, ziele):
		return {"ok": true, "schuebe": 0, "zustaende": 0}
	var p0 = _norm(spieler0, waende, kisten0)
	var offen = [{"k": kisten0, "p": p0}]
	var gesehen = {_key(p0, kisten0): true}
	var tiefe = 0
	var zust = 0
	while offen.size() > 0:
		var naechste = []
		for zu in offen:
			zust += 1
			if zust > budget:
				return {"ok": false, "schuebe": -1, "zustaende": zust}
			var kisten: Dictionary = zu.k
			var reg = _region(zu.p, waende, kisten)
			for b in kisten:
				var bc = kisten[b]
				for d in DIRS:
					var stand = b - d
					var ziel_z = b + d
					if not reg.has(stand):
						continue
					if waende.has(ziel_z) or kisten.has(ziel_z):
						continue
					if _tot(ziel_z, bc, waende, ziele):
						continue
					var neu = kisten.duplicate()
					neu.erase(b)
					neu[ziel_z] = bc
					if _erfuellt(neu, ziele):
						return {"ok": true, "schuebe": tiefe + 1, "zustaende": zust}
					var np = _norm(b, waende, neu)
					var key = _key(np, neu)
					if gesehen.has(key):
						continue
					gesehen[key] = true
					naechste.append({"k": neu, "p": np})
		offen = naechste
		tiefe += 1
	return {"ok": false, "schuebe": -1, "zustaende": zust}

# ── Zugbasierte Suche für Eislevel ────────────────────────────────────────────
# Auf Eis rutscht der Spieler selbst mit. Damit ist die Regionen-Normalisierung
# des Schub-Lösers ungültig (welche Felder erreichbar sind, hängt vom Weg ab) und
# ein Schub ist keine saubere Einheit mehr. Deshalb hier Breitensuche über
# einzelne Züge; gezählt wird in Schritten (entspricht "steps" auf sokobanonline).
static func loesen_zuege(waende: Dictionary, eis: Dictionary, loecher0: Dictionary,
		broeckel0: Dictionary, tueren: Dictionary, knoepfe: Dictionary,
		schienen: Dictionary, kisten0: Dictionary, ziele: Dictionary,
		spieler0: Vector2i, budget: int) -> Dictionary:
	if _erfuellt(kisten0, ziele):
		return {"ok": true, "zuege": 0, "zustaende": 0}
	var offen = [{"k": kisten0, "p": spieler0, "l": loecher0, "b": broeckel0}]
	var gesehen = {_key_z(spieler0, kisten0, loecher0, broeckel0): true}
	var tiefe = 0
	var zust = 0
	while offen.size() > 0:
		var naechste = []
		for zu in offen:
			zust += 1
			if zust > budget:
				return {"ok": false, "zuege": -1, "zustaende": zust, "tiefe": tiefe}
			for d in DIRS:
				var r = _schritt(zu.p, zu.k, zu.l, zu.b, d, waende, eis, tueren, knoepfe, schienen)
				if r.is_empty():
					continue
				if _erfuellt(r.k, ziele):
					return {"ok": true, "zuege": tiefe + 1, "zustaende": zust}
				var key = _key_z(r.p, r.k, r.l, r.b)
				if gesehen.has(key):
					continue
				gesehen[key] = true
				naechste.append(r)
		offen = naechste
		tiefe += 1
	return {"ok": false, "zuege": -1, "zustaende": zust}

# Ein Zug in Richtung d. Leeres Dictionary = Zug nicht möglich.
# Kopiert Kisten/Löcher/Bröckelboden nur, wenn sich daran wirklich etwas ändert.
static func _schritt(p: Vector2i, kisten: Dictionary, loecher: Dictionary,
		broeckel: Dictionary, d: Vector2i, waende: Dictionary,
		eis: Dictionary, tueren: Dictionary, knoepfe: Dictionary,
		schienen: Dictionary) -> Dictionary:
	var zu = _gesperrte_tueren(tueren, knoepfe, kisten, p)   # Zustand VOR dem Zug
	var ziel = p + d
	if waende.has(ziel) or loecher.has(ziel) or zu.has(ziel):
		return {}
	var nk = kisten
	var nl = loecher
	var nb = broeckel
	var l_kopie = false
	var b_kopie = false
	var geschoben = false
	if kisten.has(ziel):
		geschoben = true
		# Kiste auf einer Schiene: nur entlang der Schiene schiebbar
		if schienen.has(ziel) and (schienen[ziel] & R_BIT[d]) == 0:
			return {}
		var dahinter = ziel + d
		# ... und in eine Schiene nur durch ein Ende, das zur Herkunft zeigt.
		if schienen.has(dahinter) and (schienen[dahinter] & R_BIT[-d]) == 0:
			return {}
		if waende.has(dahinter) or kisten.has(dahinter) or zu.has(dahinter):
			return {}
		nk = kisten.duplicate()
		var farbe = nk[ziel]
		nk.erase(ziel)
		# Erst die Kiste verbuchen, dann den Spieler: sie bremst ihn ggf. aus.
		var ende = _gleiten_kiste(dahinter, d, waende, nk, eis, loecher, zu, schienen)
		if loecher.has(ende):
			nl = loecher.duplicate()
			l_kopie = true
			nl.erase(ende)          # Kiste füllt das Loch auf und ist verbraucht
		else:
			nk[ende] = farbe
	# Wer schiebt, rutscht nicht: nach einem Schub genau ein Feld nachrücken.
	var np = ziel if geschoben else _gleiten(ziel, d, waende, nk, eis, nl, zu)
	# Bröckelboden bricht hinter dem Spieler ein; das Zielfeld hält noch.
	var c = p
	var schutz = 0
	while c != np and schutz < 500:
		if nb.has(c):
			if not l_kopie:
				nl = nl.duplicate()
				l_kopie = true
			if not b_kopie:
				nb = nb.duplicate()
				b_kopie = true
			nb.erase(c)
			nl[c] = true
		c += d
		schutz += 1
	return {"k": nk, "p": np, "l": nl, "b": nb}

# Spieler: weiterrutschen, solange er auf Eis steht. Er schiebt dabei nichts an
# und betritt kein Loch – er bleibt davor stehen.
static func _gleiten(start: Vector2i, d: Vector2i, waende: Dictionary,
		kisten: Dictionary, eis: Dictionary, loecher: Dictionary,
		zu: Dictionary) -> Vector2i:
	var p = start
	var schutz = 0
	while eis.has(p):
		var n = p + d
		if waende.has(n) or kisten.has(n) or loecher.has(n) or zu.has(n):
			break
		p = n
		schutz += 1
		if schutz > 500:
			break
	return p

# Kiste: wie oben, aber ein Loch stoppt sie nicht davor – sie gleitet hinein.
static func _gleiten_kiste(start: Vector2i, d: Vector2i, waende: Dictionary,
		kisten: Dictionary, eis: Dictionary, loecher: Dictionary,
		zu: Dictionary, schienen: Dictionary) -> Vector2i:
	var p = start
	var schutz = 0
	while eis.has(p):
		var n = p + d
		if waende.has(n) or kisten.has(n) or zu.has(n):
			break
		if schienen.has(n) and (schienen[n] & R_BIT[-d]) == 0:
			break   # Schiene nimmt die Kiste von dieser Seite nicht auf
		p = n
		if loecher.has(p):
			break
		schutz += 1
		if schutz > 500:
			break
	return p

# ── Türen ─────────────────────────────────────────────────────────────────────
# Offen, wenn alle Knöpfe der Farbe besetzt sind ODER mindestens eine Tür der
# Farbe besetzt ist (dann hält sie sich selbst offen). Rein abgeleitet – der
# Türzustand vergrößert den Suchraum also nicht.
static func _tuer_offen(farbe: int, tueren: Dictionary, knoepfe: Dictionary,
		kisten: Dictionary, p: Vector2i) -> bool:
	var hat_knopf = false
	var alle_gedrueckt = true
	for k in knoepfe:
		if knoepfe[k] != farbe:
			continue
		hat_knopf = true
		if not (kisten.has(k) or p == k):
			alle_gedrueckt = false
	if hat_knopf and alle_gedrueckt:
		return true
	for t in tueren:
		if tueren[t] == farbe and (kisten.has(t) or p == t):
			return true
	return false

static func _gesperrte_tueren(tueren: Dictionary, knoepfe: Dictionary,
		kisten: Dictionary, p: Vector2i) -> Dictionary:
	if tueren.is_empty():
		return {}
	var zu = {}
	var zustand = {}
	for t in tueren:
		var f = tueren[t]
		if not zustand.has(f):
			zustand[f] = _tuer_offen(f, tueren, knoepfe, kisten, p)
		if not zustand[f]:
			zu[t] = true
	return zu

# Kompakter Zustandsschlüssel für die Zug-Suche. Positionen als Zeichencodes
# statt "(x, y)"-Strings: bei Suchtiefen wie 63 Zügen ist das spürbar schneller.
static func _key_z(p: Vector2i, kisten: Dictionary, loecher: Dictionary,
		broeckel: Dictionary) -> String:
	var cells = kisten.keys()
	cells.sort()
	var s = char(48 + p.x + p.y * 64)
	for c in cells:
		s += char(48 + c.x + c.y * 64) + char(1000 + kisten[c])
	s += "|"
	var lz = loecher.keys()
	lz.sort()
	for c in lz:
		s += char(48 + c.x + c.y * 64)
	s += "|"
	var bz = broeckel.keys()
	bz.sort()
	for c in bz:
		s += char(48 + c.x + c.y * 64)
	return s

# Gelöst: jedes Ziel von einer farbgleichen Kiste bedeckt.
static func _erfuellt(kisten: Dictionary, ziele: Dictionary) -> bool:
	for g in ziele:
		if not (kisten.has(g) and kisten[g] == ziele[g]):
			return false
	return true

# Eck-Deadlock: Kiste, die ein Ziel braucht (nicht Wild), in einer Ecke, die
# nicht ihr passendes Ziel ist, kann nie mehr ein passendes Ziel erreichen.
static func _tot(c: Vector2i, farbe: int, waende: Dictionary, ziele: Dictionary) -> bool:
	if farbe == 6:
		return false   # Wild-Kiste braucht kein Ziel → nie „tot"
	if ziele.has(c) and ziele[c] == farbe:
		return false   # steht auf passendem Ziel
	var o = waende.has(c + Vector2i(0, -1))
	var u = waende.has(c + Vector2i(0, 1))
	var l = waende.has(c + Vector2i(-1, 0))
	var r = waende.has(c + Vector2i(1, 0))
	return (o and l) or (o and r) or (u and l) or (u and r)

static func _norm(p: Vector2i, waende: Dictionary, kisten: Dictionary) -> Vector2i:
	var reg = _region(p, waende, kisten)
	var minc = p
	for c in reg:
		if c < minc:
			minc = c
	return minc

static func _region(p: Vector2i, waende: Dictionary, kisten: Dictionary) -> Dictionary:
	var reg = {p: true}
	var q = [p]
	while q.size() > 0:
		var c = q.pop_back()
		for d in DIRS:
			var n = c + d
			if waende.has(n) or kisten.has(n) or reg.has(n):
				continue
			reg[n] = true
			q.append(n)
			if reg.size() > 4000:
				return reg
	return reg

static func _key(p: Vector2i, kisten: Dictionary) -> String:
	var cells = kisten.keys()
	cells.sort()
	var s = str(p)
	for c in cells:
		s += "|" + str(c) + ":" + str(kisten[c])
	return s
