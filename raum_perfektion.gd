extends "res://raum.gd"

var relikt_szene    = preload("res://relikte.tscn")
const RELIKT_SKRIPT = preload("res://relikte.gd")

func _raum_initialisieren():
	tueren_oeffnen()
	_relikte_spawnen()
	_label_spawnen()

func _relikte_spawnen():
	var pool = RELIKT_SKRIPT.POOL_BESSER.duplicate()
	pool.shuffle()
	var positionen = [Vector2(420, 360), Vector2(860, 360)]
	for i in 2:
		var r = relikt_szene.instantiate()
		r.typ      = pool[i]
		r.pool_typ = "besser"
		r.position = positionen[i]
		add_child(r)

func _label_spawnen():
	var label = Label.new()
	label.text = "P E R F E K T I O N"
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", Color(1.0, 0.82, 0.1))
	label.position = Vector2(500, 80)
	add_child(label)
