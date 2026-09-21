extends Control

const CRAFTING = preload("res://crafting_menue.gd")

const SLOT_NAMEN  = ["papes", "filter", "tabak", "weed"]
const SLOT_LABELS = ["Papes", "Filter", "Tabak", "Weed"]

const SELTENHEIT_NAMEN = ["Gewöhnlich", "Ungewöhnlich", "Selten", "Episch", "Legendär"]
const SELTENHEIT_FARBEN = [
	Color(0.55, 0.55, 0.55),  # 0 Gewöhnlich
	Color(0.2,  0.75, 0.2),   # 1 Ungewöhnlich
	Color(0.2,  0.45, 1.0),   # 2 Selten
	Color(0.65, 0.1,  0.9),   # 3 Episch
	Color(1.0,  0.82, 0.1),   # 4 Legendär
]

var ausgewaehlter_slot  = 0
var komponenten_cursor  = 0
var eingang             = ["", ""]
var ergebnis            = ""
var ergebnis_stufe      = -1
var in_komponenten_modus = false

# ── Lifecycle ────────────────────────────────────────────────────────────────

func _ready():
	visible      = false
	process_mode = Node.PROCESS_MODE_ALWAYS

func oeffnen():
	ausgewaehlter_slot   = 0
	komponenten_cursor   = 0
	eingang              = ["", ""]
	ergebnis             = ""
	ergebnis_stufe       = -1
	in_komponenten_modus = false
	_cursor_eingrenzen()
	_hud_sichtbarkeit(false)
	_spieler_sichtbarkeit(false)
	visible           = true
	get_tree().paused = true
	queue_redraw()

func _schliessen():
	visible           = false
	get_tree().paused = false
	_hud_sichtbarkeit(true)
	_spieler_sichtbarkeit(true)

func _spieler_sichtbarkeit(sichtbar: bool):
	var spieler = get_tree().get_first_node_in_group("spieler")
	if spieler:
		spieler.visible = sichtbar

func _hud_sichtbarkeit(sichtbar: bool):
	# HUD-Elemente im CanvasLayer
	var node = get_parent()
	while node and not node.get_node_or_null("CanvasLayer"):
		node = node.get_parent()
	if node:
		var cl = node.get_node("CanvasLayer")
		for hud_name in ["Lebensanzeige", "Verbrauchsanzeige", "StatsAnzeige", "MiniMap"]:
			var n = cl.get_node_or_null(hud_name)
			if n:
				n.visible = sichtbar
	# Raum-Label ausblenden (z.B. "D E A L E R" im Raum)
	for sibling in get_parent().get_children():
		if sibling is Label:
			sibling.visible = sichtbar

# ── Eingabe ──────────────────────────────────────────────────────────────────

func _unhandled_input(event):
	if not visible:
		return
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	match event.keycode:
		KEY_ESCAPE, KEY_TAB:
			_schliessen()
		KEY_W:
			if in_komponenten_modus:
				var inv = _inventar()
				if inv.size() > 0:
					komponenten_cursor = (komponenten_cursor - 1 + inv.size()) % inv.size()
					queue_redraw()
			else:
				ausgewaehlter_slot = (ausgewaehlter_slot - 1 + SLOT_NAMEN.size()) % SLOT_NAMEN.size()
				_slot_gewechselt()
		KEY_S:
			if in_komponenten_modus:
				var inv = _inventar()
				if inv.size() > 0:
					komponenten_cursor = (komponenten_cursor + 1) % inv.size()
					queue_redraw()
			else:
				ausgewaehlter_slot = (ausgewaehlter_slot + 1) % SLOT_NAMEN.size()
				_slot_gewechselt()
		KEY_A:
			if in_komponenten_modus:
				in_komponenten_modus = false
				queue_redraw()
		KEY_D:
			if not in_komponenten_modus:
				in_komponenten_modus = true
				queue_redraw()
		KEY_ENTER, KEY_KP_ENTER:
			if in_komponenten_modus:
				if eingang[0] != "" and eingang[1] != "" and ergebnis != "":
					_kombinieren()
				else:
					_eingang_hinzufuegen()
		KEY_BACKSPACE:
			if in_komponenten_modus:
				_eingang_entfernen()

func _slot_gewechselt():
	komponenten_cursor   = 0
	eingang              = ["", ""]
	ergebnis             = ""
	ergebnis_stufe       = -1
	in_komponenten_modus = false
	_cursor_eingrenzen()
	queue_redraw()

func _inventar() -> Array:
	var slot = SLOT_NAMEN[ausgewaehlter_slot]
	var inv  = global_data.inventar.get(slot, []).duplicate()
	inv.sort_custom(func(a, b):
		return _seltenheit_stufe(slot, a) < _seltenheit_stufe(slot, b))
	return inv

func _cursor_eingrenzen():
	var inv = _inventar()
	if not inv.is_empty():
		komponenten_cursor = clamp(komponenten_cursor, 0, inv.size() - 1)

# ── Eingabe-Slots ────────────────────────────────────────────────────────────

func _eingang_hinzufuegen():
	var inv = _inventar()
	if inv.is_empty():
		return
	var komp = inv[komponenten_cursor % inv.size()]
	if komp == eingang[0] or komp == eingang[1]:
		return
	if eingang[0] == "":
		eingang[0] = komp
		_ergebnis_berechnen()
	elif eingang[1] == "":
		eingang[1] = komp
		_ergebnis_berechnen()
	queue_redraw()

func _eingang_entfernen():
	if eingang[1] != "":
		eingang[1]     = ""
		ergebnis       = ""
		ergebnis_stufe = -1
	elif eingang[0] != "":
		eingang[0]     = ""
		ergebnis       = ""
		ergebnis_stufe = -1
	queue_redraw()

# ── Seltenheits-Logik ────────────────────────────────────────────────────────

func _seltenheit_stufe(slot: String, komp: String) -> int:
	if slot == "weed":
		match global_data.WEED_DATEN.get(komp, {}).get("seltenheit", ""):
			"Gewöhnlich":   return 0
			"Ungewöhnlich": return 1
			"Selten":       return 2
			"Episch":       return 3
			"Legendar":     return 4
		return -1
	var c = CRAFTING.SELTENHEIT_FARBE.get(komp, Color(0.55, 0.55, 0.55))
	if c.is_equal_approx(Color(0.2,  0.75, 0.2)):  return 1
	if c.is_equal_approx(Color(0.2,  0.45, 1.0)):  return 2
	if c.is_equal_approx(Color(0.65, 0.1,  0.9)):  return 3
	if c.is_equal_approx(Color(1.0,  0.82, 0.1)):  return 4
	return 0

func _ziel_stufe(s_a: int, s_b: int, _slot: String) -> int:
	if s_a < 0 or s_b < 0:
		return -1
	if s_a == s_b:
		var next = s_a + 1
		return -1 if next > 4 else next
	return max(s_a, s_b)

func _seltenheit_farbe(slot: String, komp: String) -> Color:
	var stufe = _seltenheit_stufe(slot, komp)
	if stufe < 0 or stufe >= SELTENHEIT_FARBEN.size():
		return Color(0.55, 0.55, 0.55)
	return SELTENHEIT_FARBEN[stufe]

# ── Kombinations-Berechnung ──────────────────────────────────────────────────

func _ergebnis_berechnen():
	ergebnis       = ""
	ergebnis_stufe = -1
	if eingang[0] == "" or eingang[1] == "":
		return
	var slot       = SLOT_NAMEN[ausgewaehlter_slot]
	var s_a        = _seltenheit_stufe(slot, eingang[0])
	var s_b        = _seltenheit_stufe(slot, eingang[1])
	ergebnis_stufe = _ziel_stufe(s_a, s_b, slot)
	if ergebnis_stufe < 0:
		return
	ergebnis = _zufaellige_komponente(slot, ergebnis_stufe, [eingang[0], eingang[1]])

func _zufaellige_komponente(slot: String, ziel: int, ausschliessen: Array) -> String:
	var kandidaten = []
	for komp in global_data.ALLE_KOMPONENTEN.get(slot, []):
		if komp in ausschliessen:
			continue
		if _seltenheit_stufe(slot, komp) == ziel:
			kandidaten.append(komp)
	if kandidaten.is_empty():
		# Fallback: auch Eingaben erlauben
		for komp in global_data.ALLE_KOMPONENTEN.get(slot, []):
			if _seltenheit_stufe(slot, komp) == ziel:
				kandidaten.append(komp)
	if kandidaten.is_empty():
		return ""
	kandidaten.shuffle()
	return kandidaten[0]

# ── Kombination durchführen ───────────────────────────────────────────────────

func _kombinieren():
	var slot = SLOT_NAMEN[ausgewaehlter_slot]
	var inv  = global_data.inventar.get(slot, []).duplicate()

	# Eingaben entfernen; wenn eine davon ausgerüstet war → Ergebnis ausrüsten
	for e in eingang:
		if e == "":
			continue
		inv.erase(e)
		if global_data.joint_komponenten.get(slot, "") == e:
			global_data.joint_komponenten[slot] = ergebnis

	# Ergebnis ins Inventar
	if ergebnis != "" and not (ergebnis in inv):
		inv.append(ergebnis)

	global_data.inventar[slot] = inv

	# Spieler-Stats über Crafting-Menü neu berechnen
	for node in get_tree().get_nodes_in_group("crafting_menue"):
		if node.has_method("_effekte_anwenden"):
			node._effekte_anwenden()
			break

	# Eingaben zurücksetzen – Menü bleibt offen für weitere Kombinationen
	eingang        = ["", ""]
	ergebnis       = ""
	ergebnis_stufe = -1
	_cursor_eingrenzen()
	queue_redraw()

# ── Zeichnen ─────────────────────────────────────────────────────────────────

func _draw():
	var font = ThemeDB.fallback_font

	# Hintergrund
	draw_rect(Rect2(0, 0, 1280, 720), Color(0.05, 0.08, 0.05, 1.0))
	draw_line(Vector2(320, 58), Vector2(320, 685), Color(0.18, 0.28, 0.18), 1)
	draw_line(Vector2(700, 58), Vector2(700, 685), Color(0.18, 0.28, 0.18), 1)

	# Titel
	draw_string(font, Vector2(0, 40), "D E A L E R",
		HORIZONTAL_ALIGNMENT_CENTER, 1280, 26, Color(0.3, 0.9, 0.3))

	_draw_slot_leiste(font)
	_draw_inventar(font)
	_draw_kombination(font)

	# Steuerung
	var steuerung = "[ESC] Schließen   [W/S] Slot   [D] Auswählen" if not in_komponenten_modus \
		else "[A] Zurück   [W/S] Komponente   [ENTER] Hinzufügen/Kombinieren   [BKSP] Entfernen"
	draw_string(font, Vector2(0, 708), steuerung,
		HORIZONTAL_ALIGNMENT_CENTER, 1280, 12, Color(0.3, 0.4, 0.3))

# ── Slot-Leiste (links) ───────────────────────────────────────────────────────

func _draw_slot_leiste(font):
	# Im Komponenten-Modus: Slot-Panel abdunkeln
	if in_komponenten_modus:
		draw_rect(Rect2(0, 58, 320, 630), Color(0.0, 0.0, 0.0, 0.55))

	draw_string(font, Vector2(22, 78), "SLOT",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.4, 0.5, 0.4))

	for i in SLOT_NAMEN.size():
		var y   = 128 + i * 76
		var sel = (i == ausgewaehlter_slot)

		if sel:
			draw_rect(Rect2(12, y - 26, 296, 60), Color(0.08, 0.16, 0.08, 1.0))
			draw_rect(Rect2(12, y - 26, 296, 60), Color(0.3, 0.9, 0.3, 0.75), false, 1.5)

		var farbe = Color(0.3, 0.9, 0.3) if sel else Color(0.45, 0.6, 0.45)
		draw_string(font, Vector2(34, y + 8), SLOT_LABELS[i],
			HORIZONTAL_ALIGNMENT_LEFT, -1, 18, farbe)

		# Aktuell ausgerüstete Komponente klein drunter
		var ekv   = global_data.joint_komponenten.get(SLOT_NAMEN[i], "")
		var ekv_n = CRAFTING.KURZNAME.get(ekv, ekv)
		draw_string(font, Vector2(34, y + 24), ekv_n,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 11,
			Color(0.3, 0.9, 0.3) if sel else Color(0.3, 0.4, 0.3))

# ── Inventar (Mitte) ─────────────────────────────────────────────────────────

func _draw_inventar(font):
	var slot = SLOT_NAMEN[ausgewaehlter_slot]
	var inv  = _inventar()
	var ekv  = global_data.joint_komponenten.get(slot, "")

	draw_string(font, Vector2(334, 78), "INVENTAR",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.4, 0.5, 0.4))

	if inv.is_empty():
		draw_string(font, Vector2(334, 160), "Keine Komponenten vorhanden",
			HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(0.35, 0.4, 0.35))
		return

	# Scrollfenster: max. 8 Einträge
	const ITEM_H   = 72.0
	const LIST_MAX = 8
	var vis_start = max(0, min(komponenten_cursor - 3, inv.size() - LIST_MAX))
	var vis_end   = min(inv.size(), vis_start + LIST_MAX)

	for i in range(vis_start, vis_end):
		var komp      = inv[i]
		var y         = 98 + (i - vis_start) * ITEM_H
		var selektiert = (i == komponenten_cursor)
		var im_eingang = (komp == eingang[0] or komp == eingang[1])
		var ist_aktiv  = (komp == ekv)

		var kfarbe = CRAFTING.SELTENHEIT_FARBE.get(komp, Color(0.55, 0.55, 0.55))

		# Hintergrund-Box
		if selektiert:
			draw_rect(Rect2(325, y, 362, ITEM_H - 4), Color(0.08, 0.16, 0.08, 1.0))
			if in_komponenten_modus:
				# Im Komponenten-Modus: heller, dicker Rahmen + Pfeil
				draw_rect(Rect2(325, y, 362, ITEM_H - 4), Color(0.3, 0.9, 0.3), false, 2.5)
				draw_string(font, Vector2(325, y + (ITEM_H - 4) / 2.0 + 7),
					"▶", HORIZONTAL_ALIGNMENT_RIGHT, -14, 16, Color(0.3, 0.9, 0.3))
			else:
				draw_rect(Rect2(325, y, 362, ITEM_H - 4), kfarbe * 0.75, false, 1.5)
		elif im_eingang:
			draw_rect(Rect2(325, y, 362, ITEM_H - 4), Color(0.1, 0.2, 0.1, 1.0))
			draw_rect(Rect2(325, y, 362, ITEM_H - 4), kfarbe * 0.45, false, 1.0)

		# Name + Marker
		var name_str = CRAFTING.KURZNAME.get(komp, komp)
		if ist_aktiv:
			name_str += "  [AKTIV]"
		if im_eingang:
			name_str += "  ✓"

		var text_farbe = Color(1.0, 1.0, 1.0) if selektiert else kfarbe
		draw_string(font, Vector2(340, y + 22), name_str,
			HORIZONTAL_ALIGNMENT_LEFT, 340, 15, text_farbe)

		# Seltenheit
		var stufe    = _seltenheit_stufe(slot, komp)
		var sel_name = SELTENHEIT_NAMEN[stufe] if stufe >= 0 else "Keine Seltenheit"
		draw_string(font, Vector2(340, y + 42), sel_name,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 11, kfarbe * (0.9 if selektiert else 0.65))

	# Scrollindikator
	if inv.size() > LIST_MAX:
		var pct = float(komponenten_cursor) / float(inv.size() - 1)
		var bar_h = 8.0 * LIST_MAX
		var bar_y = 98.0 + pct * (bar_h - 12)
		draw_rect(Rect2(689, 98, 4, bar_h), Color(0.2, 0.3, 0.2))
		draw_rect(Rect2(689, bar_y, 4, 12), Color(0.4, 0.9, 0.4))

# ── Kombinations-Panel (rechts) ───────────────────────────────────────────────

func _draw_kombination(font):
	var slot = SLOT_NAMEN[ausgewaehlter_slot]

	draw_string(font, Vector2(710, 78), "TAUSCHEN",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.4, 0.5, 0.4))

	# ── Komponente 1 ──
	_draw_eingang_box(font, eingang[0], slot, 105, 1)

	# ── + ──
	draw_string(font, Vector2(710, 280), "+",
		HORIZONTAL_ALIGNMENT_CENTER, 560, 30, Color(0.35, 0.55, 0.35))

	# ── Komponente 2 ──
	_draw_eingang_box(font, eingang[1], slot, 295, 2)

	# ── Pfeil ──
	draw_string(font, Vector2(710, 462), "↓",
		HORIZONTAL_ALIGNMENT_CENTER, 560, 30, Color(0.28, 0.45, 0.28))

	# ── Ergebnis ──
	_draw_ergebnis_box(font, slot, 488)

	# ── Bestätigen-Hinweis ──
	if eingang[0] != "" and eingang[1] != "" and ergebnis != "":
		draw_string(font, Vector2(710, 672),
			"[ENTER]  Kombinieren  →  Komponenten werden verbraucht",
			HORIZONTAL_ALIGNMENT_CENTER, 560, 13, Color(0.3, 0.9, 0.3))

func _draw_eingang_box(font, komp: String, slot: String, y: float, nummer: int):
	const X = 724.0
	const W = 532.0
	const H = 76.0

	if komp == "":
		draw_rect(Rect2(X, y, W, H), Color(0.05, 0.09, 0.05, 1.0))
		draw_rect(Rect2(X, y, W, H), Color(0.18, 0.28, 0.18, 0.6), false, 1.5)
		draw_string(font, Vector2(X, y + H / 2.0 + 6.0),
			"Komponente %d   –   [W/S] + [ENTER] zum Auswählen" % nummer,
			HORIZONTAL_ALIGNMENT_CENTER, W, 13, Color(0.28, 0.4, 0.28))
	else:
		var kfarbe = CRAFTING.SELTENHEIT_FARBE.get(komp, Color(0.55, 0.55, 0.55))
		draw_rect(Rect2(X, y, W, H), kfarbe * 0.12)
		draw_rect(Rect2(X, y, W, H), kfarbe * 0.75, false, 2.0)
		var stufe    = _seltenheit_stufe(slot, komp)
		var sel_name = SELTENHEIT_NAMEN[stufe] if stufe >= 0 else "?"
		draw_string(font, Vector2(X + 14, y + 26),
			CRAFTING.KURZNAME.get(komp, komp),
			HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(1.0, 1.0, 1.0))
		draw_string(font, Vector2(X + 14, y + 50),
			sel_name,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 13, kfarbe)

func _draw_ergebnis_box(font, slot: String, y: float):
	const X = 724.0
	const W = 532.0
	const H = 82.0

	if eingang[0] == "" or eingang[1] == "":
		draw_rect(Rect2(X, y, W, H), Color(0.04, 0.07, 0.04, 1.0))
		draw_rect(Rect2(X, y, W, H), Color(0.14, 0.22, 0.14, 0.4), false, 1.5)
		draw_string(font, Vector2(X, y + H / 2.0 + 6.0),
			"Wähle zwei Komponenten aus",
			HORIZONTAL_ALIGNMENT_CENTER, W, 14, Color(0.25, 0.35, 0.25))
		return

	# Beide Eingaben gesetzt → Ergebnis berechnet
	if ergebnis == "" or ergebnis_stufe < 0:
		# Ungültig
		draw_rect(Rect2(X, y, W, H), Color(0.1, 0.04, 0.04, 1.0))
		draw_rect(Rect2(X, y, W, H), Color(0.75, 0.2, 0.2, 0.7), false, 2.0)
		var grund: String
		if _seltenheit_stufe(slot, eingang[0]) < 0 or _seltenheit_stufe(slot, eingang[1]) < 0:
			grund = "Buschgras kann nicht kombiniert werden"
		else:
			grund = "Maximale Seltenheit bereits erreicht"
		draw_string(font, Vector2(X, y + H / 2.0 + 6.0), grund,
			HORIZONTAL_ALIGNMENT_CENTER, W, 14, Color(0.9, 0.35, 0.35))
		return

	# Gültiges Ergebnis – Name erst nach Bestätigung sichtbar
	var rfarbe = SELTENHEIT_FARBEN[ergebnis_stufe] if ergebnis_stufe >= 0 else Color(0.55, 0.55, 0.55)
	draw_rect(Rect2(X, y, W, H), rfarbe * 0.16)
	draw_rect(Rect2(X, y, W, H), rfarbe * 0.85, false, 2.5)

	draw_string(font, Vector2(X, y + 32),
		"???",
		HORIZONTAL_ALIGNMENT_CENTER, W, 20, Color(0.6, 0.6, 0.6))
	draw_string(font, Vector2(X, y + 56),
		SELTENHEIT_NAMEN[ergebnis_stufe],
		HORIZONTAL_ALIGNMENT_CENTER, W, 14, rfarbe)
