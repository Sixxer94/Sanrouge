extends Control

# Zeigt unten links für jedes aufgenommene Relikt einen Platzhalter (Farbe + Kürzel).
# Beim Hovern erscheint ein Tooltip mit Name & Wirkung.
# Später werden die Kästchen durch echte Item-Icons ersetzt.

const ICON      = 36.0
const GAP       = 6.0
const START_X   = 14.0
const UNTEN_Y   = 706.0   # untere Kante der untersten Reihe
const PRO_REIHE = 14

var _letzte_anzahl = -1
var _hover_index   = -1

func _ready():
	position = Vector2.ZERO
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(_delta):
	var relikte = global_data.besessene_relikte
	var maus = get_viewport().get_mouse_position()
	var neu_hover = -1
	for i in relikte.size():
		if _icon_rect(i).has_point(maus):
			neu_hover = i
			break
	# Nur neu zeichnen, wenn sich Anzahl oder Hover geändert hat
	if relikte.size() != _letzte_anzahl or neu_hover != _hover_index:
		_letzte_anzahl = relikte.size()
		_hover_index   = neu_hover
		queue_redraw()

func _draw():
	var relikte = global_data.besessene_relikte
	for i in relikte.size():
		_icon_zeichnen(_icon_rect(i).position, relikte[i])
	if _hover_index >= 0 and _hover_index < relikte.size():
		_tooltip_zeichnen(_hover_index, relikte[_hover_index])

func _icon_rect(i: int) -> Rect2:
	var spalte = i % PRO_REIHE
	var reihe  = i / PRO_REIHE
	var x = START_X + spalte * (ICON + GAP)
	var y = UNTEN_Y - ICON - reihe * (ICON + GAP)
	return Rect2(Vector2(x, y), Vector2(ICON, ICON))

func _icon_zeichnen(pos: Vector2, eintrag: Dictionary):
	var farbe = eintrag.get("farbe", Color(0.5, 0.5, 0.5))
	var titel = str(eintrag.get("name", "?"))
	var rect  = Rect2(pos, Vector2(ICON, ICON))

	# Abgerundetes Kästchen mit Rahmen
	var sb = StyleBoxFlat.new()
	sb.bg_color = farbe
	sb.set_corner_radius_all(7)
	sb.border_color = farbe.lightened(0.45)
	sb.set_border_width_all(2)
	draw_style_box(sb, rect)

	# Kürzel – Textfarbe je nach Helligkeit lesbar
	var text_farbe = Color(0.1, 0.1, 0.1) if farbe.get_luminance() > 0.6 else Color(1, 1, 1)
	draw_string(ThemeDB.fallback_font, pos + Vector2(0, ICON * 0.7),
			_kuerzel(titel), HORIZONTAL_ALIGNMENT_CENTER, ICON, 16, text_farbe)

func _tooltip_zeichnen(i: int, eintrag: Dictionary):
	var font  = ThemeDB.fallback_font
	var titel = str(eintrag.get("name", "?"))
	var farbe = eintrag.get("farbe", Color(0.5, 0.5, 0.5))
	var besch = str(eintrag.get("beschreibung", ""))
	var zeilen = besch.split("  ", false) if besch != "" else PackedStringArray()

	var titel_size = 14
	var text_size  = 12
	var pad        = 8.0
	var titel_h    = 24.0
	var zeile_h    = 16.0

	# Breite anhand des längsten Textes
	var breite = font.get_string_size(titel, HORIZONTAL_ALIGNMENT_LEFT, -1, titel_size).x
	for z in zeilen:
		breite = maxf(breite, font.get_string_size(z, HORIZONTAL_ALIGNMENT_LEFT, -1, text_size).x)
	breite = maxf(breite + pad * 2.0, 120.0)

	var hoehe = titel_h + zeilen.size() * zeile_h + pad
	var rect  = _icon_rect(i)
	var x = rect.position.x
	var y = rect.position.y - 6.0 - hoehe           # oberhalb des Icons
	x = clampf(x, 6.0, 1280.0 - breite - 6.0)
	y = maxf(y, 6.0)

	# Hintergrund, Titelbalken, Rahmen
	draw_rect(Rect2(x, y, breite, hoehe), Color(0.08, 0.08, 0.08, 0.95))
	draw_rect(Rect2(x, y, breite, titel_h), farbe)
	draw_rect(Rect2(x, y, breite, hoehe), farbe.lightened(0.3), false, 2.0)

	var titel_farbe = Color(0.08, 0.08, 0.08) if farbe.get_luminance() > 0.6 else Color(1, 1, 1)
	draw_string(font, Vector2(x + pad, y + 17.0), titel,
			HORIZONTAL_ALIGNMENT_LEFT, -1, titel_size, titel_farbe)
	for j in zeilen.size():
		draw_string(font, Vector2(x + pad, y + titel_h + 12.0 + j * zeile_h), zeilen[j],
				HORIZONTAL_ALIGNMENT_LEFT, -1, text_size, Color(0.88, 0.88, 0.88))

func _kuerzel(n: String) -> String:
	var teile = n.split(" ", false)
	if teile.size() >= 2:
		return (teile[0].substr(0, 1) + teile[1].substr(0, 1)).to_upper()
	return n.substr(0, 2).capitalize()
