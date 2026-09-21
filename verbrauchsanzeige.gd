extends Control

func _process(_delta):
	queue_redraw()

func _draw():
	var font = ThemeDB.fallback_font
	var groesse = 14
	var zeilenhoehe = 20

	draw_string(font, Vector2(0, zeilenhoehe * 1),
		"BTC:       " + str(global_data.bitcoins),
		HORIZONTAL_ALIGNMENT_LEFT, -1, groesse, Color(1.0, 0.82, 0.1, 1.0))

	draw_string(font, Vector2(0, zeilenhoehe * 2),
		"Bomben:  " + str(global_data.bomben),
		HORIZONTAL_ALIGNMENT_LEFT, -1, groesse, Color(1.0, 0.5, 0.15, 1.0))

	draw_string(font, Vector2(0, zeilenhoehe * 3),
		"Schlüssel: " + str(global_data.schluessel),
		HORIZONTAL_ALIGNMENT_LEFT, -1, groesse, Color(0.85, 0.7, 0.25, 1.0))

	if global_data.leichen > 0:
		draw_string(font, Vector2(0, zeilenhoehe * 4),
			"Leiche:    " + str(global_data.leichen),
			HORIZONTAL_ALIGNMENT_LEFT, -1, groesse, Color(0.7, 0.75, 0.6, 1.0))

	# Zeti – Reroll-Indikator (oben rechts, nur wenn Relikt am Boden liegt)
	if global_data.charakter == "zeti":
		var hat_relikt = get_tree().get_nodes_in_group("relikt").size() > 0
		if hat_relikt:
			var verfuegbar = global_data.zeti_reroll_verfuegbar
			var farbe = Color(0.95, 0.65, 0.1, 1.0) if verfuegbar else Color(0.35, 0.35, 0.35, 0.8)
			var text  = "[R]  Reroll" if verfuegbar else "[R]  Reroll"
			# Hintergrund-Box
			var bx = 1050.0
			var by = 8.0
			draw_rect(Rect2(bx - 8, by - 2, 190, 38), Color(0.0, 0.0, 0.0, 0.6))
			draw_rect(Rect2(bx - 8, by - 2, 190, 38), farbe, false, 1.5)
			draw_string(font, Vector2(bx, by + 24), text,
				HORIZONTAL_ALIGNMENT_LEFT, -1, 22, farbe)
			# Verfügbarkeits-Symbol
			var sym_farbe = Color(0.3, 0.95, 0.3) if verfuegbar else Color(0.8, 0.25, 0.25)
			var sym = "●" if verfuegbar else "○"
			draw_string(font, Vector2(bx + 120, by + 24), sym,
				HORIZONTAL_ALIGNMENT_LEFT, -1, 22, sym_farbe)
