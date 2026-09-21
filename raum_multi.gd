extends Node2D

signal tuer_betreten_ziel(neue_pos: Vector2, eintritts_pos: Vector2)
signal geheimwand_gesprengt(richtung: String)
signal alle_gegner_besiegt

const WAND_FARBE  = Color(0.194, 0.194, 0.194)
const TUER_FARBE  = Color(0.146, 0.495, 0.512)
const BODEN_FARBE = Color(0.241, 0.241, 0.153)
const WAND_D  = 80    # Wanddicke
const TUER_B  = 160   # Türöffnung
const Z_B     = 1280  # Zelle Breite (Basis)
const Z_H     = 720   # Zelle Höhe  (Basis)

const FAKTOR_2X1  = 0.7   # Stauchung der langen Achse bei 2×1
const FAKTOR_QUAD = 0.8   # Stauchung beider Achsen bei 2×2 / L

# Wird von main.gd vor add_child() gesetzt:
var anker_pos   : Vector2 = Vector2.ZERO
var layout_typ  : String  = "lang_h"
# [{offset: Vector2, tueren: {oben,unten,links,rechts: bool}}]
var zellen_info : Array   = []
# [{zell_offset: Vector2, richtung: String}]
var geheim_infos: Array   = []
# Positionen gesperrter Schatzräume (Schloss-Optik an der jeweiligen Tür):
var verschlossene_ziele: Array = []
# Ziel-Raumposition → Zielraum-Typ (für Türfarbe):
var tuer_typen_ziel: Dictionary = {}

# Laufzeit:
var spieler       = null
var aktiv         = false
var timer         = 0.0
var tueren_offen  = true
var loot_gedroppt = false
var wand_richtungen = []  # Kompat. mit main.gd
var gegner_anzahl : int = 0

var _bbox_breite  : int
var _bbox_hoehe   : int
var _pixel_breite : float
var _pixel_hoehe  : float
var _bbox_orig    : Vector2

var ZB : int = Z_B   # tatsächliche Zellbreite (evtl. gestaucht)
var ZH : int = Z_H   # tatsächliche Zellhöhe  (evtl. gestaucht)

var _wall_rects   : Array
var _door_rects   : Array
var _door_ziele   : Array   # parallel zu _door_rects: Ziel-Raumposition je Tür
var _sperre_rects : Array
var _sperre_nodes : Array
var _ausgaenge    : Array

# Geheim-Wand-System (parallel zu geheim_infos):
var _geheim_block_nodes : Array  # StaticBody2D der Blockierung
var _geheim_door_rects  : Array  # Rect2 der Türöffnung
var _geheim_geoeffnet   : Array  # bool, ob gesprengt

# ── Lifecycle ─────────────────────────────────────────────────────────────────

func _ready():
	spieler = get_tree().get_first_node_in_group("spieler")
	timer   = 0.5
	_wall_rects   = []
	_door_rects   = []
	_door_ziele   = []
	_sperre_rects = []
	_sperre_nodes = []
	_ausgaenge    = []
	# Geheim-Arrays parallel zu geheim_infos initialisieren
	_geheim_block_nodes = []
	_geheim_door_rects  = []
	_geheim_geoeffnet   = []
	for _i in geheim_infos.size():
		_geheim_block_nodes.append(null)
		_geheim_door_rects.append(Rect2())
		_geheim_geoeffnet.append(false)
	_zellgroesse_berechnen()
	_berechne_bbox()
	_baue_kollision()
	_ausgaenge_berechnen()
	queue_redraw()

func _zellgroesse_berechnen():
	var fx = 1.0
	var fy = 1.0
	match layout_typ:
		"lang_h": fx = FAKTOR_2X1
		"lang_v": fy = FAKTOR_2X1
		"gross":
			fx = FAKTOR_QUAD
			fy = FAKTOR_QUAD
		_:
			if layout_typ.begins_with("l_"):
				fx = FAKTOR_QUAD
				fy = FAKTOR_QUAD
	ZB = int(round(Z_B * fx))
	ZH = int(round(Z_H * fy))

func zell_groesse() -> Vector2:
	return Vector2(ZB, ZH)

func gesamt_groesse() -> Vector2:
	return Vector2(_pixel_breite, _pixel_hoehe)

func _berechne_bbox():
	var min_x = 0; var min_y = 0; var max_x = 0; var max_y = 0
	for zi in zellen_info:
		min_x = min(min_x, zi.offset.x)
		min_y = min(min_y, zi.offset.y)
		max_x = max(max_x, zi.offset.x)
		max_y = max(max_y, zi.offset.y)
	_bbox_orig   = Vector2(min_x, min_y)
	_bbox_breite = int(max_x - min_x + 1)
	_bbox_hoehe  = int(max_y - min_y + 1)
	_pixel_breite = _bbox_breite * ZB
	_pixel_hoehe  = _bbox_hoehe  * ZH

func _zell_pixel(offset: Vector2) -> Vector2:
	return (offset - _bbox_orig) * Vector2(ZB, ZH)

# ── Kollision aufbauen ────────────────────────────────────────────────────────

func _baue_kollision():
	var gruppe = {}
	for zi in zellen_info:
		gruppe[zi.offset] = zi

	for zi in zellen_info:
		var px = _zell_pixel(zi.offset)
		for richtung in ["oben", "unten", "links", "rechts"]:
			var adj = zi.offset + _dir_v(richtung)
			if gruppe.has(adj):
				continue  # interne Kante → offen
			var ist_tuer = zi.tueren.get(richtung, false)
			var geheim_idx = _geheim_idx(zi.offset, richtung)
			_kante_bauen(px, richtung, ist_tuer, geheim_idx, zi.offset)

	# Fehlende Zellen (z. B. das leere Eck eines L-Raums) vollständig blockieren.
	# Visuell sind sie bereits als Wand gezeichnet – hier kommt die Kollision dazu.
	for bx in _bbox_breite:
		for by in _bbox_hoehe:
			var gitter_pos = Vector2(bx, by) + _bbox_orig
			if not gruppe.has(gitter_pos):
				_phys_box(float(bx * ZB), float(by * ZH), float(ZB), float(ZH))

func _geheim_idx(zell_offset: Vector2, richtung: String) -> int:
	for i in geheim_infos.size():
		if geheim_infos[i]["zell_offset"] == zell_offset and geheim_infos[i]["richtung"] == richtung:
			return i
	return -1

func _kante_bauen(px: Vector2, richtung: String, ist_tuer: bool, geheim_idx: int, zell_offset: Vector2):
	var dxs = (ZB - TUER_B) / 2.0   # Tür-Start horizontal (zentriert)
	var dys = (ZH - TUER_B) / 2.0   # Tür-Start vertikal   (zentriert)
	var ziel = anker_pos + zell_offset + _dir_v(richtung)
	match richtung:
		"oben":
			var wy = px.y
			if ist_tuer:
				_wand_h(px.x,                   wy, dxs)
				_wand_h(px.x + dxs + TUER_B,    wy, ZB - dxs - TUER_B)
				_door_rect(Rect2(px.x + dxs, wy, TUER_B, WAND_D), ziel)
				_sperre_add(Rect2(px.x + dxs, wy, TUER_B, WAND_D))
			elif geheim_idx >= 0:
				_wand_h(px.x,                   wy, dxs)
				_wand_h(px.x + dxs + TUER_B,    wy, ZB - dxs - TUER_B)
				_geheim_block_add(Rect2(px.x + dxs, wy, TUER_B, WAND_D), geheim_idx)
			else:
				_wand_h(px.x, wy, float(ZB))
		"unten":
			var wy = px.y + ZH - WAND_D
			if ist_tuer:
				_wand_h(px.x,                   wy, dxs)
				_wand_h(px.x + dxs + TUER_B,    wy, ZB - dxs - TUER_B)
				_door_rect(Rect2(px.x + dxs, wy, TUER_B, WAND_D), ziel)
				_sperre_add(Rect2(px.x + dxs, wy, TUER_B, WAND_D))
			elif geheim_idx >= 0:
				_wand_h(px.x,                   wy, dxs)
				_wand_h(px.x + dxs + TUER_B,    wy, ZB - dxs - TUER_B)
				_geheim_block_add(Rect2(px.x + dxs, wy, TUER_B, WAND_D), geheim_idx)
			else:
				_wand_h(px.x, wy, float(ZB))
		"links":
			var wx = px.x
			if ist_tuer:
				_wand_v(wx, px.y,               dys)
				_wand_v(wx, px.y + dys + TUER_B, ZH - dys - TUER_B)
				_door_rect(Rect2(wx, px.y + dys, WAND_D, TUER_B), ziel)
				_sperre_add(Rect2(wx, px.y + dys, WAND_D, TUER_B))
			elif geheim_idx >= 0:
				_wand_v(wx, px.y,               dys)
				_wand_v(wx, px.y + dys + TUER_B, ZH - dys - TUER_B)
				_geheim_block_add(Rect2(wx, px.y + dys, WAND_D, TUER_B), geheim_idx)
			else:
				_wand_v(wx, px.y, float(ZH))
		"rechts":
			var wx = px.x + ZB - WAND_D
			if ist_tuer:
				_wand_v(wx, px.y,               dys)
				_wand_v(wx, px.y + dys + TUER_B, ZH - dys - TUER_B)
				_door_rect(Rect2(wx, px.y + dys, WAND_D, TUER_B), ziel)
				_sperre_add(Rect2(wx, px.y + dys, WAND_D, TUER_B))
			elif geheim_idx >= 0:
				_wand_v(wx, px.y,               dys)
				_wand_v(wx, px.y + dys + TUER_B, ZH - dys - TUER_B)
				_geheim_block_add(Rect2(wx, px.y + dys, WAND_D, TUER_B), geheim_idx)
			else:
				_wand_v(wx, px.y, float(ZH))

func _wand_h(x: float, y: float, breite: float):
	if breite <= 0.0:
		return
	_wall_rects.append(Rect2(x, y, breite, WAND_D))
	_phys_box(x, y, breite, WAND_D)

func _wand_v(x: float, y: float, hoehe: float):
	if hoehe <= 0.0:
		return
	_wall_rects.append(Rect2(x, y, WAND_D, hoehe))
	_phys_box(x, y, WAND_D, hoehe)

func _door_rect(r: Rect2, ziel: Vector2):
	_door_rects.append(r)
	_door_ziele.append(ziel)

# Schatzraum-Tür entsperren (Schloss-Optik entfernen)
func schatz_entsperren_ziel(pos: Vector2):
	verschlossene_ziele.erase(pos)
	queue_redraw()

func _sperre_add(r: Rect2):
	_sperre_rects.append(r)
	var sb = StaticBody2D.new()
	sb.visible = false
	var cs = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = r.size
	cs.position = r.get_center()
	cs.disabled = true
	cs.shape = shape
	sb.add_child(cs)
	add_child(sb)
	_sperre_nodes.append(sb)

func _geheim_block_add(r: Rect2, idx: int):
	_geheim_door_rects[idx] = r
	var sb = StaticBody2D.new()
	var cs = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = r.size
	cs.position = r.get_center()
	cs.shape = shape
	sb.add_child(cs)
	add_child(sb)
	_geheim_block_nodes[idx] = sb

func _phys_box(x: float, y: float, b: float, h: float):
	var sb = StaticBody2D.new()
	var cs = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(b, h)
	cs.position = Vector2(x + b / 2.0, y + h / 2.0)
	cs.shape = shape
	sb.add_child(cs)
	add_child(sb)

# ── Geheim-Wand ───────────────────────────────────────────────────────────────

func bombe_bei(explosion_pos: Vector2, radius: float):
	for i in geheim_infos.size():
		if _geheim_geoeffnet[i]:
			continue
		var info = geheim_infos[i]
		var px = _zell_pixel(info["zell_offset"])
		var wand_mitte = to_global(_wand_mitte_lokal(px, info["richtung"]))
		if explosion_pos.distance_to(wand_mitte) <= radius:
			_geheimwand_oeffnen(i)

func _wand_mitte_lokal(px: Vector2, richtung: String) -> Vector2:
	match richtung:
		"oben":   return Vector2(px.x + ZB * 0.5, px.y + WAND_D * 0.5)
		"unten":  return Vector2(px.x + ZB * 0.5, px.y + ZH - WAND_D * 0.5)
		"links":  return Vector2(px.x + WAND_D * 0.5, px.y + ZH * 0.5)
		"rechts": return Vector2(px.x + ZB - WAND_D * 0.5, px.y + ZH * 0.5)
	return Vector2(px.x + ZB * 0.5, px.y + ZH * 0.5)

func _geheimwand_oeffnen(idx: int):
	_geheim_geoeffnet[idx] = true
	var node = _geheim_block_nodes[idx]
	if is_instance_valid(node):
		node.queue_free()

	# Exit-Trigger für den neuen Ausgang hinzufügen
	var info = geheim_infos[idx]
	var px   = _zell_pixel(info["zell_offset"])
	var ziel = anker_pos + info["zell_offset"] + _dir_v(info["richtung"])
	_ausgaenge.append({
		"trigger": _trigger_rect(px, info["richtung"]),
		"ziel":    ziel,
		"spawn":   _gegenueber_spawn(info["richtung"]),
	})

	queue_redraw()
	geheimwand_gesprengt.emit(info["richtung"])

# ── Ausgänge ──────────────────────────────────────────────────────────────────

func _ausgaenge_berechnen():
	_ausgaenge = []
	var gruppe = {}
	for zi in zellen_info:
		gruppe[zi.offset] = zi

	for zi in zellen_info:
		var px = _zell_pixel(zi.offset)
		for richtung in ["oben", "unten", "links", "rechts"]:
			var adj = zi.offset + _dir_v(richtung)
			if gruppe.has(adj):
				continue
			if not zi.tueren.get(richtung, false):
				continue
			var ziel = anker_pos + zi.offset + _dir_v(richtung)
			_ausgaenge.append({
				"trigger": _trigger_rect(px, richtung),
				"ziel":    ziel,
				"spawn":   _gegenueber_spawn(richtung),
			})

func _trigger_rect(px: Vector2, richtung: String) -> Rect2:
	var dxs = (ZB - TUER_B) / 2.0
	var dys = (ZH - TUER_B) / 2.0
	match richtung:
		"oben":   return Rect2(px.x + dxs,       px.y,              TUER_B, WAND_D / 2.0)
		"unten":  return Rect2(px.x + dxs,       px.y + ZH - 40.0,  TUER_B, 40.0)
		"links":  return Rect2(px.x,             px.y + dys,        WAND_D / 2.0, TUER_B)
		"rechts": return Rect2(px.x + ZB - 40.0, px.y + dys,        40.0, TUER_B)
	return Rect2()

func _gegenueber_spawn(richtung: String) -> Vector2:
	match richtung:
		"oben":   return Vector2(640, 580)
		"unten":  return Vector2(640, 140)
		"links":  return Vector2(1120, 360)
		"rechts": return Vector2(160, 360)
	return Vector2(640, 360)

func _dir_v(richtung: String) -> Vector2:
	match richtung:
		"oben":   return Vector2(0, -1)
		"unten":  return Vector2(0,  1)
		"links":  return Vector2(-1, 0)
		"rechts": return Vector2(1,  0)
	return Vector2.ZERO

# ── Prozess ───────────────────────────────────────────────────────────────────

func _process(delta):
	if spieler == null:
		return
	if not aktiv:
		timer -= delta
		if timer <= 0:
			aktiv = true
		return
	if not tueren_offen:
		return
	_tuer_ausgang_pruefen()

func _tuer_ausgang_pruefen():
	var pos = spieler.global_position
	for a in _ausgaenge:
		if a.trigger.has_point(pos):
			tuer_betreten_ziel.emit(a.ziel, a.spawn)
			return

func gegner_registrieren(g: Node):
	gegner_anzahl += 1
	g.tree_exited.connect(_on_gegner_entfernt)
	_gegner_zustand_pruefen()

func _on_gegner_entfernt():
	gegner_anzahl -= 1
	if visible:
		_gegner_zustand_pruefen()

func _gegner_zustand_pruefen():
	if gegner_anzahl > 0:
		if tueren_offen:
			tueren_offen = false
			tueren_sperren()
	else:
		if not tueren_offen:
			tueren_offen = true
			tueren_oeffnen()
			alle_gegner_besiegt.emit()

func tueren_sperren():
	for sb in _sperre_nodes:
		sb.get_child(0).disabled = false
	queue_redraw()

func tueren_oeffnen():
	for sb in _sperre_nodes:
		sb.get_child(0).disabled = true
	queue_redraw()

# ── Zeichnen ──────────────────────────────────────────────────────────────────

func _draw():
	# Boden
	draw_rect(Rect2(0.0, 0.0, _pixel_breite, _pixel_hoehe), BODEN_FARBE)

	# L-Raum: fehlende Ecke mit Wandfarbe überdecken
	if layout_typ.begins_with("l_"):
		var gruppe_bbox = {}
		for zi in zellen_info:
			gruppe_bbox[(zi.offset - _bbox_orig)] = true
		for bx in _bbox_breite:
			for by in _bbox_hoehe:
				if not gruppe_bbox.has(Vector2(bx, by)):
					draw_rect(Rect2(bx * ZB, by * ZH, ZB, ZH), WAND_FARBE)

	# Wände
	for r in _wall_rects:
		draw_rect(r, WAND_FARBE)

	# Geheim-Türen: geschlossen = Wandfarbe, offen = Türfarbe
	for i in _geheim_geoeffnet.size():
		if _geheim_door_rects[i].has_area():
			draw_rect(_geheim_door_rects[i], TUER_FARBE if _geheim_geoeffnet[i] else WAND_FARBE)

	# Türöffnungen: Farbe je Zielraum-Typ, gesperrte Schatzräume zusätzlich mit Schloss
	for i in _door_rects.size():
		var r = _door_rects[i]
		var typ = tuer_typen_ziel.get(_door_ziele[i], "")
		draw_rect(r, global_data.TUER_TYP_FARBEN.get(typ, TUER_FARBE))
		if _door_ziele[i] in verschlossene_ziele:
			_schloss_zeichnen(r.get_center())

	# Sperren bei Kampf
	if not tueren_offen:
		for r in _sperre_rects:
			draw_rect(r, WAND_FARBE)

func _schloss_zeichnen(pos: Vector2):
	var gold   = Color(1.0, 0.82, 0.2)
	var dunkel = Color(0.15, 0.12, 0.05)
	draw_arc(pos + Vector2(0, -7), 7, PI, TAU, 16, gold, 3.0)          # Bügel
	draw_rect(Rect2(pos.x - 11, pos.y - 4, 22, 17), gold)             # Korpus
	draw_rect(Rect2(pos.x - 11, pos.y - 4, 22, 17), dunkel, false, 2.0)
	draw_circle(pos + Vector2(0, 4), 2.5, dunkel)                     # Schlüsselloch
