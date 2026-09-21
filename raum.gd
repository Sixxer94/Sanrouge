extends Node2D

signal tuer_betreten(richtung)
signal geheimwand_gesprengt(richtung)
signal alle_gegner_besiegt

const WAND_FARBE_FALLBACK = Color(0.19434929, 0.19434926, 0.19434926, 1)
const TUER_FARBE_FALLBACK = Color(0.14587978, 0.49514127, 0.5120735, 1)

const WAND_POSITIONEN = {
	"oben":   Vector2(640,  40), "unten":  Vector2(640, 680),
	"links":  Vector2( 40, 360), "rechts": Vector2(1240, 360),
}
const SPERRE_NAMEN = {
	"oben": "Sperre_Oben", "unten": "Sperre_Unten",
	"links": "Sperre_Links", "rechts": "Sperre_Rechts",
}
const TUER_NAMEN = {
	"oben": "Tuer_oben", "unten": "Tuer_unten",
	"links": "Tuer_links", "rechts": "Tuer_rechts",
}

var spieler          = null
var aktiv            = false
var timer            = 0.0
var tueren_offen     = true
var loot_gedroppt    = false
var wand_richtungen  = []
var geheimwand_richtungen: Array = []
var verschlossene_tueren: Array = []   # Richtungen mit verschlossener Tür (Schatzraum)
var tuer_typen: Dictionary = {}        # Richtung → Zielraum-Typ (für Türfarbe)
var _wand_farbe: Color
var _tuer_farbe: Color
var gegner_anzahl: int = 0

# ── Lifecycle ────────────────────────────────────────────────────────────────

func _ready():
	spieler = get_tree().get_first_node_in_group("spieler")
	timer   = 0.5
	var wand_cr = get_node_or_null("Wand oben/ColorRect")
	_wand_farbe = wand_cr.color if wand_cr else WAND_FARBE_FALLBACK
	var tuer_cr = get_node_or_null("Tuer_oben")
	_tuer_farbe = tuer_cr.color if tuer_cr else TUER_FARBE_FALLBACK
	_raum_initialisieren()

# Virtueller Einstiegspunkt – Unterklassen überschreiben dies statt _ready()
func _raum_initialisieren():
	tueren_oeffnen()

func _process(delta):
	if spieler == null:
		return
	if not aktiv:
		timer -= delta
		if timer <= 0:
			aktiv = true
		return
	_tuer_ausgang_pruefen()

# ── Türausgang ────────────────────────────────────────────────────────────────

func _tuer_ausgang_pruefen():
	if not tueren_offen:
		return
	var pos = spieler.global_position
	if "oben" not in wand_richtungen and pos.y < 40 and pos.x > 560 and pos.x < 720:
		tuer_betreten.emit("oben")
	elif "unten" not in wand_richtungen and pos.y > 680 and pos.x > 560 and pos.x < 720:
		tuer_betreten.emit("unten")
	elif "links" not in wand_richtungen and pos.x < 40 and pos.y > 280 and pos.y < 440:
		tuer_betreten.emit("links")
	elif "rechts" not in wand_richtungen and pos.x > 1240 and pos.y > 280 and pos.y < 440:
		tuer_betreten.emit("rechts")

# ── Gegner / Türsperren ───────────────────────────────────────────────────────

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
	for sperre_name in SPERRE_NAMEN.values():
		var sperre = get_node_or_null(sperre_name)
		if sperre:
			sperre.visible = true
			sperre.get_node("CollisionShape2D").disabled = false

func tueren_oeffnen():
	for richtung in SPERRE_NAMEN:
		var ist_wand = richtung in wand_richtungen

		var sperre = get_node_or_null(SPERRE_NAMEN[richtung])
		if sperre:
			sperre.visible = ist_wand
			sperre.get_node("CollisionShape2D").disabled = not ist_wand
			var cr = sperre.get_node_or_null("CollisionShape2D/ColorRect")
			if cr:
				cr.color = _wand_farbe

		var tuer = get_node_or_null(TUER_NAMEN[richtung])
		if tuer:
			if ist_wand:
				tuer.color = _wand_farbe
			else:
				var typ = tuer_typen.get(richtung, "")
				tuer.color = global_data.TUER_TYP_FARBEN.get(typ, _tuer_farbe)
	queue_redraw()

# Schatzraum-Tür entsperren (Schloss-Optik entfernen)
func schatz_entsperren(richtung: String):
	verschlossene_tueren.erase(richtung)
	tueren_oeffnen()

# ── Schloss-Symbol ────────────────────────────────────────────────────────────

func _draw():
	for richtung in verschlossene_tueren:
		if richtung in wand_richtungen:
			continue
		_schloss_zeichnen(WAND_POSITIONEN[richtung])

func _schloss_zeichnen(pos: Vector2):
	var gold    = Color(1.0, 0.82, 0.2)
	var dunkel  = Color(0.15, 0.12, 0.05)
	draw_arc(pos + Vector2(0, -7), 7, PI, TAU, 16, gold, 3.0)          # Bügel
	draw_rect(Rect2(pos.x - 11, pos.y - 4, 22, 17), gold)             # Korpus
	draw_rect(Rect2(pos.x - 11, pos.y - 4, 22, 17), dunkel, false, 2.0)
	draw_circle(pos + Vector2(0, 4), 2.5, dunkel)                     # Schlüsselloch

# ── Geheimwand ────────────────────────────────────────────────────────────────

func bombe_bei(explosion_pos: Vector2, radius: float):
	for richtung in geheimwand_richtungen.duplicate():
		var wand_pos = to_global(WAND_POSITIONEN[richtung])
		if explosion_pos.distance_to(wand_pos) <= radius:
			_geheimwand_oeffnen(richtung)

func _geheimwand_oeffnen(richtung: String):
	geheimwand_richtungen.erase(richtung)
	wand_richtungen.erase(richtung)

	var sperre = get_node_or_null(SPERRE_NAMEN[richtung])
	if sperre:
		sperre.visible = false
		sperre.get_node("CollisionShape2D").disabled = true

	var tuer = get_node_or_null(TUER_NAMEN[richtung])
	if tuer:
		tuer.color = _tuer_farbe

	geheimwand_gesprengt.emit(richtung)

# Öffnet eine Wand als normale Tür (ohne Signal, z.B. für Perfektionsraum-Eingang)
func tuer_aufschliessen(richtung: String):
	if not richtung in wand_richtungen:
		return
	wand_richtungen.erase(richtung)

	var sperre = get_node_or_null(SPERRE_NAMEN[richtung])
	if sperre:
		sperre.visible = false
		sperre.get_node("CollisionShape2D").disabled = true

	var tuer = get_node_or_null(TUER_NAMEN[richtung])
	if tuer:
		tuer.color = _tuer_farbe
