extends Area2D

enum Typ {
	KOLLAGEN, PIZZA, FAHRRAD, PAULANER_SPEZI, GAMBLEMASCHINE,
	OPTIGRILL, KLIMMZUGSTANGE, DIETRICH_SET, RAMEN, PIZZASERVICE_ERLINGEN,
	DOENER, SPACE_COOKIE, BETT, SIGMA, NINJA,
	HASE, SPIELESET, LOTTO_BAYERN_LOS, BOULDERAUSRUESTUNG, JETSKI,
	GRINDER, FAHRRADHELM, ROTER_STABILO, LEDGER
}

const ANZAHL_TYPEN = 24
const REICHWEITE   = 80.0

# Schwächere Relikte – Boss-Drop
const POOL_NORMAL: Array = [
	Typ.KOLLAGEN, Typ.PIZZA, Typ.FAHRRAD, Typ.PAULANER_SPEZI, Typ.GAMBLEMASCHINE,
	Typ.DIETRICH_SET, Typ.RAMEN, Typ.DOENER, Typ.SPACE_COOKIE,
	Typ.HASE, Typ.LOTTO_BAYERN_LOS, Typ.LEDGER,
]
# Stärkere Relikte – Perfektionsraum
const POOL_BESSER: Array = [
	Typ.OPTIGRILL, Typ.KLIMMZUGSTANGE, Typ.PIZZASERVICE_ERLINGEN,
	Typ.BETT, Typ.SIGMA, Typ.NINJA, Typ.SPIELESET,
	Typ.BOULDERAUSRUESTUNG, Typ.JETSKI, Typ.GRINDER, Typ.FAHRRADHELM, Typ.ROTER_STABILO,
]

static func zufaelliger_aus_pool(pool: Array) -> int:
	return pool[randi() % pool.size()]

var typ: int = -1
var spieler = null
var in_reichweite = false
var pool_typ: String = "normal"   # "normal" (Boss) oder "besser" (Perfektion)

func _ready():
	add_to_group("relikt")
	add_to_group("sammelbar")
	z_index        = 100
	z_as_relative  = false
	if typ == -1:
		typ = _zufaelliger_typ()
	spieler = get_tree().get_first_node_in_group("spieler")
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		sprite.visible = false
	queue_redraw()

func _process(_delta):
	if spieler == null:
		return
	var nah = global_position.distance_to(spieler.global_position) < REICHWEITE
	if nah != in_reichweite:
		in_reichweite = nah
		queue_redraw()

func _input(event):
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if in_reichweite and event.keycode == KEY_F:
		anwenden(spieler)
		global_data.besessene_relikte.append({
			"name": _get_name(), "farbe": _get_farbe(), "beschreibung": _get_beschreibung()})
		for r in get_parent().get_children():
			if r != self and r.is_in_group("relikt"):
				r.queue_free()
		queue_free()
	# Zeti – Der Gambler: Relikte rerollen (überall im Raum)
	if event.keycode == KEY_R \
			and global_data.charakter == "zeti" \
			and global_data.zeti_reroll_verfuegbar:
		global_data.zeti_reroll_verfuegbar = false
		_reroll_ausfuehren()

func _reroll_ausfuehren():
	var parent     = get_parent()
	var pool_copy  = pool_typ
	var positionen = []
	for r in parent.get_children():
		if r.is_in_group("relikt"):
			positionen.append(r.position)
			if r != self:
				r.queue_free()
	var pool = POOL_BESSER.duplicate() if pool_copy == "besser" else POOL_NORMAL.duplicate()
	pool.shuffle()
	var relikt_szene = load("res://relikte.tscn")
	for i in min(positionen.size(), pool.size()):
		var r = relikt_szene.instantiate()
		r.typ      = pool[i]
		r.pool_typ = pool_copy
		r.position = positionen[i]
		parent.call_deferred("add_child", r)
	queue_free()

func _zufaelliger_typ() -> int:
	return randi() % ANZAHL_TYPEN

func _get_name() -> String:
	match typ:
		Typ.KOLLAGEN:              return "Kollagen"
		Typ.PIZZA:                 return "Pizza"
		Typ.FAHRRAD:               return "Fahrrad"
		Typ.PAULANER_SPEZI:        return "Paulaner Spezi"
		Typ.GAMBLEMASCHINE:        return "Gamblemaschine"
		Typ.OPTIGRILL:             return "OptiGrill"
		Typ.KLIMMZUGSTANGE:        return "Klimmzugstange"
		Typ.DIETRICH_SET:          return "Dietrich-Set"
		Typ.RAMEN:                 return "Ramen"
		Typ.PIZZASERVICE_ERLINGEN: return "Pizzaservice Erlingen"
		Typ.DOENER:                return "Döner"
		Typ.SPACE_COOKIE:          return "Space Cookie"
		Typ.BETT:                  return "Bett"
		Typ.SIGMA:                 return "Sigma"
		Typ.NINJA:                 return "Ninja"
		Typ.HASE:                  return "Hase"
		Typ.SPIELESET:             return "Spieleset"
		Typ.LOTTO_BAYERN_LOS:      return "Lotto Bayern Los"
		Typ.BOULDERAUSRUESTUNG:    return "Boulderausrüstung"
		Typ.JETSKI:                return "Jetski"
		Typ.GRINDER:               return "Grinder"
		Typ.FAHRRADHELM:           return "Fahrradhelm"
		Typ.ROTER_STABILO:         return "Roter Stabilo"
		Typ.LEDGER:                return "Ledger"
	return ""

func _get_beschreibung() -> String:
	match typ:
		Typ.KOLLAGEN:              return "+1 Schaden"
		Typ.PIZZA:                 return "+1 Herzcontainer  +1 leerer Container"
		Typ.FAHRRAD:               return "+50 Geschwindigkeit"
		Typ.PAULANER_SPEZI:        return "+0.5 Projektilgröße"
		Typ.GAMBLEMASCHINE:        return "Zufällig:  ±Schaden/HP/Geschw./Größe"
		Typ.OPTIGRILL:             return "+2 Schaden"
		Typ.KLIMMZUGSTANGE:        return "+1 Schaden  +40 Geschwindigkeit"
		Typ.DIETRICH_SET:          return "+2 Schlüssel"
		Typ.RAMEN:                 return "+2 leere Herzcontainer"
		Typ.PIZZASERVICE_ERLINGEN: return "+2 Herzcontainer  Vollheilung  +20 Geschwindigkeit"
		Typ.DOENER:                return "+1 Herzcontainer  Vollheilung  −25 Geschwindigkeit"
		Typ.SPACE_COOKIE:          return "+3 Glück"
		Typ.BETT:                  return "+0.5s Unverwundbarkeit"
		Typ.SIGMA:                 return "+1 Schaden  +30 Geschw.  +50 Reichweite"
		Typ.NINJA:                 return "+60 Geschwindigkeit  Pierce"
		Typ.HASE:                  return "+80 Geschwindigkeit"
		Typ.SPIELESET:             return "Zufällig positiv:  Schaden/HP/Geschw./Größe"
		Typ.LOTTO_BAYERN_LOS:      return "+5 Glück"
		Typ.BOULDERAUSRUESTUNG:    return "+2 Schaden"
		Typ.JETSKI:                return "+100 Geschwindigkeit"
		Typ.GRINDER:               return "Feuerrate ×1.25"
		Typ.FAHRRADHELM:           return "+1 Herzcontainer  +0.3s Unverwundbarkeit"
		Typ.ROTER_STABILO:         return "+150 Reichweite"
		Typ.LEDGER:                return "+8 Bitcoins"
	return ""

func _get_farbe() -> Color:
	match typ:
		Typ.KOLLAGEN:              return Color(0.75, 0.35, 0.15)
		Typ.PIZZA:                 return Color(0.85, 0.20, 0.10)
		Typ.FAHRRAD:               return Color(0.10, 0.45, 0.85)
		Typ.PAULANER_SPEZI:        return Color(0.85, 0.65, 0.00)
		Typ.GAMBLEMASCHINE:        return Color(0.55, 0.10, 0.75)
		Typ.OPTIGRILL:             return Color(0.90, 0.45, 0.10)
		Typ.KLIMMZUGSTANGE:        return Color(0.40, 0.55, 0.70)
		Typ.DIETRICH_SET:          return Color(0.60, 0.50, 0.20)
		Typ.RAMEN:                 return Color(0.90, 0.60, 0.15)
		Typ.PIZZASERVICE_ERLINGEN: return Color(0.80, 0.15, 0.15)
		Typ.DOENER:                return Color(0.65, 0.38, 0.12)
		Typ.SPACE_COOKIE:          return Color(0.30, 0.15, 0.70)
		Typ.BETT:                  return Color(0.50, 0.70, 0.90)
		Typ.SIGMA:                 return Color(0.80, 0.80, 0.85)
		Typ.NINJA:                 return Color(0.15, 0.15, 0.20)
		Typ.HASE:                  return Color(0.90, 0.85, 0.80)
		Typ.SPIELESET:             return Color(0.10, 0.70, 0.35)
		Typ.LOTTO_BAYERN_LOS:      return Color(0.10, 0.30, 0.75)
		Typ.BOULDERAUSRUESTUNG:    return Color(0.50, 0.45, 0.38)
		Typ.JETSKI:                return Color(0.05, 0.75, 0.85)
		Typ.GRINDER:               return Color(0.15, 0.55, 0.20)
		Typ.FAHRRADHELM:           return Color(0.90, 0.50, 0.05)
		Typ.ROTER_STABILO:         return Color(0.90, 0.10, 0.10)
		Typ.LEDGER:                return Color(0.85, 0.75, 0.20)
	return Color(0.5, 0.5, 0.5)

func _draw():
	draw_circle(Vector2.ZERO, 18, _get_farbe())
	draw_arc(Vector2.ZERO, 18, 0, TAU, 32, Color(1.0, 0.75, 0.1, 0.9), 2.5)

	if not in_reichweite:
		return

	var font = ThemeDB.fallback_font
	var beschreibung = _get_beschreibung()
	var zeilen = beschreibung.split("  ") if beschreibung != "" else PackedStringArray()
	var n = zeilen.size()
	var hat_reroll = global_data.charakter == "zeti" and global_data.zeti_reroll_verfuegbar
	var w = 190.0
	var h = 54.0 + n * 16.0 + (16.0 if hat_reroll else 0.0)
	var x = -w / 2.0
	var y = -h - 28.0

	draw_rect(Rect2(x, y, w, h), Color(0.08, 0.08, 0.08, 0.93))
	draw_rect(Rect2(x, y, w, 26), _get_farbe())
	draw_rect(Rect2(x, y, w, h), Color(1.0, 0.75, 0.1, 0.85), false, 2.0)
	draw_string(font, Vector2(x + 6, y + 19), _get_name(),
			HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(0.05, 0.05, 0.05, 1.0))
	for i in n:
		draw_string(font, Vector2(x + 6, y + 40 + i * 16), zeilen[i],
				HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.85, 0.85, 0.85, 1.0))
	draw_string(font, Vector2(x + 6, y + 40 + n * 16), "F: Aufnehmen",
			HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.5, 0.9, 0.5, 1.0))
	if hat_reroll:
		draw_string(font, Vector2(x + 6, y + 55 + n * 16), "R: Reroll",
				HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.9, 0.6, 0.1, 1.0))

func anwenden(s):
	match typ:
		Typ.KOLLAGEN:
			s.schaden_bonus += 1
		Typ.PIZZA:
			s.max_hp += 4                          # +1 voll (2) + 1 leer (2)
			s.hp = min(s.hp + 2, s.max_hp)         # neuen Container füllen
		Typ.FAHRRAD:
			s.geschwindigkeit_bonus += 50
		Typ.PAULANER_SPEZI:
			s.projektil_groesse += 0.5
		Typ.GAMBLEMASCHINE:
			gamblen(s, false)
		Typ.OPTIGRILL:
			s.schaden_bonus += 2
		Typ.KLIMMZUGSTANGE:
			s.schaden_bonus += 1
			s.geschwindigkeit_bonus += 40
		Typ.DIETRICH_SET:
			global_data.schluessel += 2
		Typ.RAMEN:
			s.max_hp += 4                          # +2 leere Container
		Typ.PIZZASERVICE_ERLINGEN:
			s.max_hp += 4                          # +2 Herzcontainer
			s.hp = s.max_hp                        # Vollheilung
			s.geschwindigkeit_bonus += 20
		Typ.DOENER:
			s.max_hp += 2                          # +1 Herzcontainer
			s.hp = s.max_hp                        # Vollheilung
			s.geschwindigkeit_bonus -= 25
		Typ.SPACE_COOKIE:
			s.glueck += 3
		Typ.BETT:
			s.unverwundbar_dauer_bonus += 0.5
		Typ.SIGMA:
			s.schaden_bonus += 1
			s.geschwindigkeit_bonus += 30
			s.reichweite += 50
		Typ.NINJA:
			s.geschwindigkeit_bonus += 60
			s.pierce = true
		Typ.HASE:
			s.geschwindigkeit_bonus += 80
		Typ.SPIELESET:
			gamblen(s, true)
		Typ.LOTTO_BAYERN_LOS:
			s.glueck += 5
		Typ.BOULDERAUSRUESTUNG:
			s.schaden_bonus += 2
		Typ.JETSKI:
			s.geschwindigkeit_bonus += 100
		Typ.GRINDER:
			s.schuss_cooldown = max(0.08, s.schuss_cooldown * 0.8)
		Typ.FAHRRADHELM:
			s.max_hp += 2                          # +1 Herzcontainer
			s.hp = min(s.hp + 2, s.max_hp)         # neuen Container füllen
			s.unverwundbar_dauer_bonus += 0.3
		Typ.ROTER_STABILO:
			s.reichweite += 150
		Typ.LEDGER:
			global_data.bitcoins += 8

func gamblen(s, nur_positiv: bool):
	var stats = ["schaden", "hp", "geschwindigkeit", "projektil"]
	var stat = stats[randi() % stats.size()]
	var positiv = true if nur_positiv else randf() > 0.4
	match stat:
		"schaden":
			s.schaden_bonus += 2 if positiv else -1
		"hp":
			if positiv:
				# Spieleset (nur_positiv=true) → +1 Herz; Gamblemaschine → +2 Herzen
				var neue = 1 if nur_positiv else 2
				s.max_hp += neue * 2
				s.hp = min(s.hp + neue * 2, s.max_hp)
			else:
				s.hp     -= 4
				s.max_hp -= 4
		"geschwindigkeit":
			s.geschwindigkeit_bonus += 75 if positiv else -50
		"projektil":
			s.projektil_groesse += 0.75 if positiv else -0.3
