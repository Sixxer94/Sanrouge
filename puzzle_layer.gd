extends Node2D

const SLOT_POS = [
	Vector2(413, 530), Vector2(487, 530),
	Vector2(603, 530), Vector2(677, 530),
	Vector2(793, 530), Vector2(867, 530)
]
const BLOCK_GROESSE = 36.0
const SLOT_GROESSE = 40.0

func _draw():
	var raum = get_parent()
	if not raum.aktiv:
		return

	var font = ThemeDB.fallback_font
	var spos = raum.spieler.global_position if raum.spieler else Vector2(640, 360)

	# Hinweis-Text oben
	draw_string(font, Vector2(640, 48), "Bilde sinnvolle Paerchen",
			HORIZONTAL_ALIGNMENT_CENTER, -1, 13, Color(0.85, 0.75, 1.0, 0.85))

	if raum.geloest:
		draw_string(font, Vector2(640, 88), "Geloest!",
				HORIZONTAL_ALIGNMENT_CENTER, -1, 15, Color(0.3, 1.0, 0.4, 1.0))

	# Trennlinien zwischen Paar-Gruppen
	for tx in [545.0, 735.0]:
		draw_line(Vector2(tx, 505), Vector2(tx, 565), Color(0.45, 0.3, 0.65, 0.5), 1.5)

	# Aufnahmen (Slots)
	for i in 6:
		var sp = SLOT_POS[i]
		var r = Rect2(sp.x - SLOT_GROESSE / 2, sp.y - SLOT_GROESSE / 2, SLOT_GROESSE, SLOT_GROESSE)
		draw_rect(r, Color(0.12, 0.1, 0.2, 0.95))
		if raum.slot_inhalt[i] != "":
			draw_rect(r, Color(0.28, 0.18, 0.45, 1.0))
			draw_string(font, Vector2(sp.x, sp.y + 7), raum.slot_inhalt[i],
					HORIZONTAL_ALIGNMENT_CENTER, -1, 20, Color(1.0, 0.95, 1.0))
		draw_rect(r, Color(0.65, 0.45, 0.9, 0.85), false, 2.0)

	# Blöcke auf dem Boden
	for b in raum.bloecke:
		var r = Rect2(b.pos.x - BLOCK_GROESSE / 2, b.pos.y - BLOCK_GROESSE / 2, BLOCK_GROESSE, BLOCK_GROESSE)
		draw_rect(r, Color(0.18, 0.14, 0.3, 1.0))
		draw_rect(r, Color(0.7, 0.5, 1.0, 0.9), false, 2.0)
		draw_string(font, Vector2(b.pos.x, b.pos.y + 7), b.buchstabe,
				HORIZONTAL_ALIGNMENT_CENTER, -1, 20, Color(1.0, 0.9, 1.0))

	# Gehaltener Block über Spieler
	if raum.gehaltener_buchstabe != "":
		var hpos = Vector2(spos.x, spos.y - 38)
		var r = Rect2(hpos.x - BLOCK_GROESSE / 2, hpos.y - BLOCK_GROESSE / 2, BLOCK_GROESSE, BLOCK_GROESSE)
		draw_rect(r, Color(0.3, 0.2, 0.5, 1.0))
		draw_rect(r, Color(1.0, 0.8, 0.2, 1.0), false, 2.5)
		draw_string(font, Vector2(hpos.x, hpos.y + 7), raum.gehaltener_buchstabe,
				HORIZONTAL_ALIGNMENT_CENTER, -1, 20, Color(1.0, 1.0, 0.5))

	# Interaktions-Hinweis
	var hinweis = raum._get_hinweis(spos)
	if hinweis != "":
		draw_string(font, Vector2(spos.x, spos.y - 52), hinweis,
				HORIZONTAL_ALIGNMENT_CENTER, -1, 11, Color(0.5, 0.9, 0.5, 1.0))
