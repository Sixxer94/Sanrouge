extends Node2D

const FORMEN = ["normal", "kreuz", "lform"]
const JOINT_LAENGE_SPRITE = 52.0   # Ziel-Länge der Joint auf dem Bildschirm (tunebar)

var _texturen := {}
var _sprite: Sprite2D = null
var _spieler = null

func _ready():
	_spieler = get_parent()
	_sprite = Sprite2D.new()
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_sprite.visible = false
	add_child(_sprite)
	for form in FORMEN:
		var pfad = "res://sprites/joint_%s.png" % form
		if ResourceLoader.exists(pfad):
			_texturen[form] = load(pfad)

func _process(_delta):
	var form = global_data.joint_form
	var richtung = _spieler.letzte_richtung
	if _texturen.has(form):
		var tex = _texturen[form]
		var w = tex.get_width()
		_sprite.texture  = tex
		_sprite.offset   = Vector2(w / 2.0, 0.0)   # linke Kante (Filter) auf den Node-Ursprung
		_sprite.scale    = Vector2.ONE * (JOINT_LAENGE_SPRITE / float(w))
		_sprite.rotation = richtung.angle()
		_sprite.position = richtung * _spieler.joint_start
		_sprite.visible  = true
	else:
		_sprite.visible = false
	queue_redraw()

func _draw():
	# Fallback: Linien-Joint nur zeichnen, wenn für die aktuelle Form kein Sprite vorliegt
	if _texturen.has(global_data.joint_form):
		return
	var spieler = get_parent()
	var richtung = spieler.letzte_richtung
	var basis = richtung * spieler.joint_start

	match global_data.joint_form:
		"kreuz":
			var positionen = spieler._kreuz_positionen(richtung)
			var quer = richtung * (spieler.joint_start + spieler.JOINT_LAENGE * 0.65)
			draw_line(basis,  quer,          Color(0.55, 0.38, 0.18), 4.0)
			for pos in positionen:
				draw_line(quer, pos, Color(0.55, 0.38, 0.18), 4.0)
				draw_circle(pos, 5.0, Color(1.0, 0.45, 0.05))
				draw_circle(pos, 3.0, Color(1.0, 0.9, 0.3))
		"lform":
			var halb  = spieler.JOINT_LAENGE / 2.0
			var knick = richtung * (spieler.joint_start + halb)
			var tip   = spieler._joint_tip_offset(richtung)
			draw_line(basis, knick, Color(0.55, 0.38, 0.18), 4.0)
			draw_line(knick, tip,   Color(0.55, 0.38, 0.18), 4.0)
			draw_circle(tip, 5.0, Color(1.0, 0.45, 0.05))
			draw_circle(tip, 3.0, Color(1.0, 0.9, 0.3))
		_:
			var tip = spieler._joint_tip_offset(richtung)
			draw_line(basis, tip, Color(0.55, 0.38, 0.18), 4.0)
			draw_circle(tip, 5.0, Color(1.0, 0.45, 0.05))
			draw_circle(tip, 3.0, Color(1.0, 0.9, 0.3))
