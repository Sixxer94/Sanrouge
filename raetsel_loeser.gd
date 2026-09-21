extends RefCounted

# Sokoban-Löser für die Kammer-Rätsel: Breitensuche über Zustände
# (Steinpositionen + kanonische Spielerregion), geschichtet nach Schüben.
# Regeln wie im Spiel: normal = 1 Feld, "gleit" rutscht bis zum Anschlag,
# "riss" verträgt einen Schub und wird danach "fest" (unbeweglich).
#
# Rückgabe von min_schuebe():
#   n < max_tiefe  → minimale Schubzahl bis zum Ziel ist n
#   max_tiefe      → keine Lösung mit weniger als max_tiefe Schüben gefunden
#                    (oder Budget erschöpft) → "mindestens so schwer"

const DIRS = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]

static func min_schuebe(waende: Dictionary, steine0: Dictionary, start: Vector2i,
		ziel: Vector2i, cols: int, rows: int, max_tiefe: int, budget: int) -> int:
	var offen = [{"s": steine0, "p": start}]
	var gesehen = {}
	var tiefe = 0
	while offen.size() > 0 and tiefe < max_tiefe:
		var naechste = []
		for zustand in offen:
			budget -= 1
			if budget <= 0:
				return max_tiefe
			var st: Dictionary = zustand.s
			var reg = _flut(zustand.p, waende, st, cols, rows)
			if reg.has(ziel):
				return tiefe
			# Kanonischer Schlüssel: kleinste erreichbare Zelle + Steinliste
			var minc: Vector2i = zustand.p
			for rc in reg:
				if rc < minc:
					minc = rc
			var cells = st.keys()
			cells.sort()
			var key = str(minc)
			for sc in cells:
				key += "|" + str(sc) + st[sc]
			if gesehen.has(key):
				continue
			gesehen[key] = true
			# Alle möglichen Schübe
			for sc in cells:
				var typ = st[sc]
				if typ == "fest":
					continue
				for d in DIRS:
					if not reg.has(sc - d):
						continue
					var vor: Vector2i = sc + d
					if not _in(vor, cols, rows) or waende.has(vor) or st.has(vor):
						continue
					var neu = st.duplicate()
					neu.erase(sc)
					if typ == "gleit":
						var z = vor
						while _in(z + d, cols, rows) and not waende.has(z + d) and not neu.has(z + d):
							z += d
						neu[z] = "gleit"
					elif typ == "riss":
						neu[vor] = "fest"
					else:
						neu[vor] = "normal"
					naechste.append({"s": neu, "p": sc})
		offen = naechste
		tiefe += 1
	return max_tiefe

static func _flut(start: Vector2i, waende: Dictionary, steine: Dictionary,
		cols: int, rows: int) -> Dictionary:
	var reg = {start: true}
	var q = [start]
	while q.size() > 0:
		var c = q.pop_back()
		for d in DIRS:
			var n = c + d
			if not _in(n, cols, rows):
				continue
			if waende.has(n) or steine.has(n) or reg.has(n):
				continue
			reg[n] = true
			q.append(n)
	return reg

static func _in(c: Vector2i, cols: int, rows: int) -> bool:
	return c.x >= 0 and c.x < cols and c.y >= 0 and c.y < rows
