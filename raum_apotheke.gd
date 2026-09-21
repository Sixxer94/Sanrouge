extends "res://raum.gd"

const ANGEBOT_SKRIPT = preload("res://apotheke_angebot.gd")

func _raum_initialisieren():
	tueren_oeffnen()
	_angebote_spawnen()
	_bezeichnung_zeichnen()

func _angebote_spawnen():
	# 2 zufällige nicht-besessene Komponenten
	var kandidaten = global_data.nicht_besessene_komponenten_fuer_welt(global_data.aktuelle_welt)
	var komp_pos = [Vector2(370, 290), Vector2(910, 290)]
	for i in min(2, kandidaten.size()):
		var a = Node2D.new()
		a.set_script(ANGEBOT_SKRIPT)
		a.angebot_typ = 3
		a.komp_slot   = kandidaten[i]["slot"]
		a.komp_name   = kandidaten[i]["komponente"]
		a.preis       = 3
		a.position    = komp_pos[i]
		add_child(a)

	# Bombe
	var bombe = Node2D.new()
	bombe.set_script(ANGEBOT_SKRIPT)
	bombe.angebot_typ = 1
	bombe.preis       = 2
	bombe.position    = Vector2(500, 470)
	add_child(bombe)

	# Schlüssel
	var schluessel = Node2D.new()
	schluessel.set_script(ANGEBOT_SKRIPT)
	schluessel.angebot_typ = 2
	schluessel.preis       = 3
	schluessel.position    = Vector2(780, 470)
	add_child(schluessel)

func _bezeichnung_zeichnen():
	var label = Label.new()
	label.text = "A P O T H E K E"
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", Color(0.2, 0.85, 0.4))
	label.position = Vector2(540, 80)
	add_child(label)
