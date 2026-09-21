extends Control

# ── Größen-Konstanten ────────────────────────────────────────────────────────
const KLEIN_ZELLEN  = 14
const KLEIN_ABSTAND = 3
const KLEIN_GROESSE = 120

const GROSS_ZELLEN  = 18
const GROSS_ABSTAND = 3
const GROSS_GROESSE = 640

var gross = false

var zellen_groesse  = KLEIN_ZELLEN
var abstand         = KLEIN_ABSTAND
var minimap_groesse = KLEIN_GROESSE

var original_position           = Vector2.ZERO
var original_position_gespeichert = false

# ── Farben ───────────────────────────────────────────────────────────────────
var aktuell_farbe     = Color(1, 1, 1)
var rahmen_farbe      = Color(1, 1, 0)
var hintergrund_farbe = Color(0.0, 0.0, 0.0, 0.867)

var farben = {
	"start":       Color(0.5, 0.5, 0.5),
	"normal":      Color(0.5, 0.5, 0.5),
	"schatz":      Color(1.0, 0.8, 0.0),
	"boss":        Color(1.0, 0.2, 0.2),
	"geheim":      Color(0.55, 0.0, 0.8),
	"geheim_wand": Color(0.55, 0.0, 0.8),
	"raetsel":     Color(0.9, 0.55, 0.0),
	"apotheke":    Color(0.1, 0.75, 0.95),
	"perfektion":  Color(1.0, 0.82, 0.1),
	"dealer":      Color(0.3, 0.92, 0.15),
}

# ── Lifecycle ────────────────────────────────────────────────────────────────
func _process(_delta):
	if gross and get_tree().get_nodes_in_group("gegner").size() > 0:
		verkleinern()

func _unhandled_input(event):
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if event.keycode == KEY_M:
		if gross:
			verkleinern()
		elif get_tree().get_nodes_in_group("gegner").size() == 0:
			vergroessern()

# ── Größe umschalten ─────────────────────────────────────────────────────────
func vergroessern():
	# Position erst jetzt speichern – Layout ist zu diesem Zeitpunkt fertig
	if not original_position_gespeichert:
		original_position = position
		original_position_gespeichert = true
	gross           = true
	zellen_groesse  = GROSS_ZELLEN
	abstand         = GROSS_ABSTAND
	minimap_groesse = GROSS_GROESSE
	clip_contents   = false   # Clipping deaktivieren, sonst bleibt Zeichnung auf 120×120 begrenzt
	move_to_front()           # Über andere UI-Elemente legen
	call_deferred("_zentrieren")
	queue_redraw()

func _zentrieren():
	const RAND = 20.0   # gleicher Abstand von rechtem und unterem Rand
	position = Vector2(
		1280.0 - GROSS_GROESSE - RAND,
		720.0  - GROSS_GROESSE - RAND
	)

func verkleinern():
	gross           = false
	zellen_groesse  = KLEIN_ZELLEN
	abstand         = KLEIN_ABSTAND
	minimap_groesse = KLEIN_GROESSE
	clip_contents   = true    # Clipping wieder aktivieren
	call_deferred("_zuruecksetzen")
	queue_redraw()

func _zuruecksetzen():
	position = original_position

func aktualisieren():
	queue_redraw()

# ── Zeichnen ─────────────────────────────────────────────────────────────────
func _draw():
	var main      = get_parent().get_parent()
	var generiert = main.generierte_karte
	var besucht   = main.besuchte_raeume
	var aktuell   = main.raum_position

	var bg = Color(0.0, 0.0, 0.0, 0.93) if gross else hintergrund_farbe
	draw_rect(Rect2(0, 0, minimap_groesse, minimap_groesse), bg)

	# Kleine Map: auf den Spieler zentriert. Große Map: ganze Karte einpassen.
	var zentrum = Vector2(aktuell)
	if gross:
		zentrum = _grosse_map_anpassen(generiert, besucht)

	var mitte = Vector2(minimap_groesse / 2.0, minimap_groesse / 2.0)

	# Alle generierten Räume zeichnen
	for pos in generiert:
		var typ    = generiert[pos]["typ"]
		# Satelliten werden als Teil des Ankers dargestellt – eigene Zelle überspringen
		if typ == "satellit":
			continue
		var offset = pos - zentrum
		var draw_x = mitte.x + offset.x * (zellen_groesse + abstand) - zellen_groesse / 2.0
		var draw_y = mitte.y + offset.y * (zellen_groesse + abstand) - zellen_groesse / 2.0

		if draw_x + zellen_groesse < 0 or draw_x > minimap_groesse:
			continue
		if draw_y + zellen_groesse < 0 or draw_y > minimap_groesse:
			continue

		var basis_farbe = farben.get(typ, farben["normal"])

		# Zellen-Offsets: aus "zellen"-Array lesen (Anker ist bereits enthalten)
		var zellen_offsets: Array
		if generiert[pos].has("zellen"):
			zellen_offsets = []
			for z in generiert[pos]["zellen"]:
				zellen_offsets.append(z - pos)
		else:
			zellen_offsets = [Vector2.ZERO]

		# Aktuell / besucht für den gesamten Raum
		var ist_aktuell_raum = (pos == aktuell) or \
			(generiert.get(aktuell, {}).get("typ","") == "satellit" and \
			 generiert.get(aktuell, {}).get("anker", Vector2(-9999,-9999)) == pos)
		var ist_besucht_raum = besucht.has(pos)

		if zellen_offsets.size() > 1:
			# Multi-Zell-Raum: einheitliche Füllung – kein Per-Zell-Rahmen
			var offset_set = {}
			for zo in zellen_offsets:
				offset_set[zo] = true

			var fill: Color
			if ist_aktuell_raum:
				fill = aktuell_farbe
			elif ist_besucht_raum:
				fill = basis_farbe
			else:
				fill = basis_farbe * 0.25

			for zo in zellen_offsets:
				var cx = draw_x + zo.x * (zellen_groesse + abstand)
				var cy = draw_y + zo.y * (zellen_groesse + abstand)
				draw_rect(Rect2(cx, cy, zellen_groesse, zellen_groesse), fill)
				for conn_dir in [Vector2(1, 0), Vector2(0, 1)]:
					if not offset_set.has(zo + conn_dir):
						continue
					var conn_rect: Rect2
					if conn_dir.x > 0:
						conn_rect = Rect2(cx + zellen_groesse, cy, abstand, zellen_groesse)
					else:
						conn_rect = Rect2(cx, cy + zellen_groesse, zellen_groesse, abstand)
					draw_rect(conn_rect, fill)

			# Äußere Kontur – gleiche Logik wie Einzelzelle, folgt echter Form
			var kontur_farbe: Color
			var kontur_breite: float
			if ist_aktuell_raum:
				kontur_farbe  = rahmen_farbe
				kontur_breite = 2.0
			elif not ist_besucht_raum:
				kontur_farbe  = basis_farbe * 0.5
				kontur_breite = 1.0
			else:
				kontur_farbe  = Color.TRANSPARENT
				kontur_breite = 0.0

			if kontur_breite > 0.0:
				for zo in zellen_offsets:
					var cx = draw_x + zo.x * (zellen_groesse + abstand)
					var cy = draw_y + zo.y * (zellen_groesse + abstand)
					# Äußere Zell-Kanten
					if not offset_set.has(zo + Vector2(0, -1)):
						draw_line(Vector2(cx, cy), Vector2(cx + zellen_groesse, cy), kontur_farbe, kontur_breite)
					if not offset_set.has(zo + Vector2(0, 1)):
						draw_line(Vector2(cx, cy + zellen_groesse), Vector2(cx + zellen_groesse, cy + zellen_groesse), kontur_farbe, kontur_breite)
					if not offset_set.has(zo + Vector2(-1, 0)):
						draw_line(Vector2(cx, cy), Vector2(cx, cy + zellen_groesse), kontur_farbe, kontur_breite)
					if not offset_set.has(zo + Vector2(1, 0)):
						draw_line(Vector2(cx + zellen_groesse, cy), Vector2(cx + zellen_groesse, cy + zellen_groesse), kontur_farbe, kontur_breite)
					# Äußere Verbinder-Kanten (nur falls Nachbar in Gruppe)
					if offset_set.has(zo + Vector2(1, 0)):
						var vx = cx + zellen_groesse
						if not (offset_set.has(zo + Vector2(0, -1)) and offset_set.has(zo + Vector2(1, -1))):
							draw_line(Vector2(vx, cy), Vector2(vx + abstand, cy), kontur_farbe, kontur_breite)
						if not (offset_set.has(zo + Vector2(0, 1)) and offset_set.has(zo + Vector2(1, 1))):
							draw_line(Vector2(vx, cy + zellen_groesse), Vector2(vx + abstand, cy + zellen_groesse), kontur_farbe, kontur_breite)
					if offset_set.has(zo + Vector2(0, 1)):
						var vy = cy + zellen_groesse
						if not (offset_set.has(zo + Vector2(-1, 0)) and offset_set.has(zo + Vector2(-1, 1))):
							draw_line(Vector2(cx, vy), Vector2(cx, vy + abstand), kontur_farbe, kontur_breite)
						if not (offset_set.has(zo + Vector2(1, 0)) and offset_set.has(zo + Vector2(1, 1))):
							draw_line(Vector2(cx + zellen_groesse, vy), Vector2(cx + zellen_groesse, vy + abstand), kontur_farbe, kontur_breite)

			if ist_besucht_raum:
				_buchstabe_zeichnen(typ, draw_x, draw_y)
				if not ist_aktuell_raum and _raum_hat_item(main, pos):
					_item_icon_zeichnen(draw_x, draw_y)
		else:
			# Einzelzelle
			var rect = Rect2(draw_x, draw_y, zellen_groesse, zellen_groesse)
			if ist_aktuell_raum:
				draw_rect(rect, aktuell_farbe)
				draw_rect(rect, rahmen_farbe, false, 2.0)
			elif ist_besucht_raum:
				draw_rect(rect, basis_farbe)
				_buchstabe_zeichnen(typ, draw_x, draw_y)
				if _raum_hat_item(main, pos):
					_item_icon_zeichnen(draw_x, draw_y)
			else:
				draw_rect(rect, basis_farbe * 0.25)
				draw_rect(rect, basis_farbe * 0.5, false, 1.0)

	# Geheim-Räume
	for pos in besucht:
		if generiert.has(pos):
			continue
		var offset = pos - zentrum
		var draw_x = mitte.x + offset.x * (zellen_groesse + abstand) - zellen_groesse / 2.0
		var draw_y = mitte.y + offset.y * (zellen_groesse + abstand) - zellen_groesse / 2.0
		if draw_x + zellen_groesse < 0 or draw_x > minimap_groesse:
			continue
		if draw_y + zellen_groesse < 0 or draw_y > minimap_groesse:
			continue
		draw_rect(Rect2(draw_x, draw_y, zellen_groesse, zellen_groesse), farben["geheim"])
		var gfs = int(clampf(zellen_groesse * 0.72, 8, 15)) if gross else 10
		var goy = (zellen_groesse * 0.72) if gross else 11.0
		draw_string(ThemeDB.fallback_font, Vector2(draw_x + 2, draw_y + goy), "G",
			HORIZONTAL_ALIGNMENT_LEFT, -1, gfs, Color(1, 1, 1))
		if pos != aktuell and _raum_hat_item(main, pos):
			_item_icon_zeichnen(draw_x, draw_y)

	# Hinweis bei großer Map
	if gross:
		var hint_w = 120.0
		var hint_x = (minimap_groesse - hint_w) / 2.0
		var hint_y = minimap_groesse - 16
		draw_rect(Rect2(hint_x - 4, hint_y - 13, hint_w + 8, 18), Color(0.0, 0.0, 0.0, 0.75))
		draw_string(ThemeDB.fallback_font, Vector2(hint_x, hint_y), "[M] Schließen",
			HORIZONTAL_ALIGNMENT_CENTER, hint_w, 12, Color(0.85, 0.85, 0.85, 1.0))

# Große Map: Zellgröße dynamisch so setzen, dass die ganze Karte ins Panel passt.
# Gibt den Karten-Mittelpunkt (Zell-Koordinaten) zurück.
func _grosse_map_anpassen(generiert: Dictionary, besucht: Dictionary) -> Vector2:
	var min_p = Vector2(INF, INF)
	var max_p = Vector2(-INF, -INF)
	for pos in generiert:
		if generiert[pos].get("typ", "") == "satellit":
			continue
		for z in generiert[pos].get("zellen", [pos]):
			min_p.x = minf(min_p.x, z.x); min_p.y = minf(min_p.y, z.y)
			max_p.x = maxf(max_p.x, z.x); max_p.y = maxf(max_p.y, z.y)
	for pos in besucht:
		if generiert.has(pos):
			continue
		min_p.x = minf(min_p.x, pos.x); min_p.y = minf(min_p.y, pos.y)
		max_p.x = maxf(max_p.x, pos.x); max_p.y = maxf(max_p.y, pos.y)
	if min_p.x == INF:
		return Vector2.ZERO
	var cells_w = max_p.x - min_p.x + 1.0
	var cells_h = max_p.y - min_p.y + 1.0
	var verfuegbar = minimap_groesse - 56.0
	var pitch = verfuegbar / maxf(cells_w, cells_h)
	abstand = 2
	zellen_groesse = clampf(pitch - abstand, 6.0, 48.0)
	return (min_p + max_p) * 0.5

func _buchstabe_zeichnen(typ: String, x: float, y: float):
	var fs = int(clampf(zellen_groesse * 0.72, 8, 15)) if gross else 10
	var oy = (zellen_groesse * 0.72) if gross else 11.0
	match typ:
		"schatz":     draw_string(ThemeDB.fallback_font, Vector2(x+2, y+oy), "S", HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(0,0,0))
		"boss":       draw_string(ThemeDB.fallback_font, Vector2(x+2, y+oy), "B", HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(0,0,0))
		"raetsel":    draw_string(ThemeDB.fallback_font, Vector2(x+2, y+oy), "R", HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(0,0,0))
		"apotheke":   draw_string(ThemeDB.fallback_font, Vector2(x+2, y+oy), "A", HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(0,0,0))
		"perfektion": draw_string(ThemeDB.fallback_font, Vector2(x+2, y+oy), "P", HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(0,0,0))
		"dealer":     draw_string(ThemeDB.fallback_font, Vector2(x+2, y+oy), "D", HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(0,0,0))

# True, wenn im (instanziierten) Raum noch ein aufsammelbares Objekt liegt
func _raum_hat_item(main, pos) -> bool:
	var r = main.raum_instanzen.get(pos, null)
	if r == null or not is_instance_valid(r):
		return false
	for c in r.get_children():
		if c.is_in_group("sammelbar"):
			return true
	return false

# Kleiner Diamant in der oberen rechten Ecke der Raumzelle
func _item_icon_zeichnen(draw_x: float, draw_y: float):
	var s  = zellen_groesse * 0.32
	var cx = draw_x + zellen_groesse - s - 1.0
	var cy = draw_y + s + 1.0
	var pts = PackedVector2Array([
		Vector2(cx, cy - s), Vector2(cx + s, cy),
		Vector2(cx, cy + s), Vector2(cx - s, cy)])
	draw_colored_polygon(pts, Color(0.60, 0.95, 1.0))
	draw_polyline(PackedVector2Array([pts[0], pts[1], pts[2], pts[3], pts[0]]),
		Color(0.05, 0.12, 0.18), 1.0)
