extends Node2D

const REICHWEITE = 80.0

# Feste Füllfarbe je Slot
const SLOT_FARBE = {
	"papes":  Color(0.92, 0.88, 0.75),  # Creme/Papier
	"filter": Color(0.75, 0.60, 0.40),  # Beige/Kork
	"tabak":  Color(0.50, 0.30, 0.10),  # Braun/Tabak
	"weed":   Color(0.20, 0.65, 0.20),  # Grün
}

# Umrandungsfarbe je Seltenheit (per Komponentenname)
const SELTENHEIT_FARBE = {
	# Papes
	"drucker":           Color(0.55,0.55,0.55),
	"reispapier":        Color(0.2, 0.75,0.2),
	"king_size":         Color(0.2, 0.45,1.0),
	"blunt":             Color(0.65,0.1, 0.9),
	"king_size_slim":    Color(0.55,0.55,0.55),
	"ungebleichtes_pape": Color(0.55,0.55,0.55),
	"king_size_regular": Color(0.55,0.55,0.55),
	"eins_viertel_size": Color(0.55,0.55,0.55),
	"single_wide":       Color(0.55,0.55,0.55),
	"flachs_papier":     Color(0.55,0.55,0.55),
	"inside_out":        Color(0.2, 0.75,0.2),
	"l_pape":            Color(0.2, 0.75,0.2),
	"flavored_pape":     Color(0.2, 0.75,0.2),
	"menthol_pape":      Color(0.2, 0.75,0.2),
	"hanf_wrap":         Color(0.2, 0.75,0.2),
	"doppelt_gerollt":   Color(0.2, 0.75,0.2),
	"bedrucktes_pape":   Color(0.2, 0.75,0.2),
	"bambus_pape":       Color(0.2, 0.75,0.2),
	"endlos_rolle":      Color(0.2, 0.45,1.0),
	"blunt_wrap":        Color(0.2, 0.45,1.0),
	"zellulose_pape":    Color(0.2, 0.45,1.0),
	"backwoods":         Color(0.2, 0.45,1.0),
	"maisblatt":         Color(0.2, 0.45,1.0),
	"palmblatt":         Color(0.2, 0.45,1.0),
	"vorgerollte_cone":  Color(0.2, 0.45,1.0),
	"glow_pape":         Color(0.65,0.1, 0.9),
	"rosenblatt":        Color(0.65,0.1, 0.9),
	"flash_papier":      Color(0.65,0.1, 0.9),
	"bananenblatt":      Color(0.65,0.1, 0.9),
	"lotusblatt":        Color(0.65,0.1, 0.9),
	"blattgold_24k":     Color(1.0, 0.82,0.1),
	"dollar_note":       Color(1.0, 0.82,0.1),
	"bibel_seite":       Color(1.0, 0.82,0.1),
	# Filter
	"kein":              Color(0.55,0.55,0.55),
	"holzspitze":        Color(0.55,0.55,0.55),
	"baumwollfilter":    Color(0.55,0.55,0.55),
	"schaumfilter":      Color(0.55,0.55,0.55),
	"gerolltes_papier":  Color(0.55,0.55,0.55),
	"standard_tip":      Color(0.55,0.55,0.55),
	"slim":              Color(0.2, 0.75,0.2),
	"extra_slim":        Color(0.2, 0.75,0.2),
	"long_filter":       Color(0.2, 0.75,0.2),
	"menthol_filter":    Color(0.2, 0.75,0.2),
	"perforiert":        Color(0.2, 0.75,0.2),
	"bio_filter":        Color(0.2, 0.75,0.2),
	"hanf_filter":       Color(0.2, 0.75,0.2),
	"aktivkohle":        Color(0.2, 0.45,1.0),
	"dual_filter":       Color(0.2, 0.45,1.0),
	"korkspitze":        Color(0.2, 0.45,1.0),
	"keramik_tip":       Color(0.2, 0.45,1.0),
	"glasspitze":        Color(0.2, 0.45,1.0),
	"bambus_filter":     Color(0.2, 0.45,1.0),
	"triacetat":         Color(0.2, 0.45,1.0),
	"active_plus":       Color(0.2, 0.45,1.0),
	"karton":            Color(0.65,0.1, 0.9),
	"gold_tip":          Color(0.65,0.1, 0.9),
	"kristall_filter":   Color(0.65,0.1, 0.9),
	"elektrostatisch":   Color(0.65,0.1, 0.9),
	"nano_filter":       Color(0.65,0.1, 0.9),
	"titan_tip":         Color(0.65,0.1, 0.9),
	"doppel_aktiv":      Color(0.65,0.1, 0.9),
	"platinspitze":      Color(1.0, 0.82,0.1),
	"diamantfilter":     Color(1.0, 0.82,0.1),
	# Tabak
	"billig":            Color(0.55,0.55,0.55),
	"ernte_23":          Color(0.55,0.55,0.55),
	"losen_blatt":       Color(0.55,0.55,0.55),
	"burley":            Color(0.55,0.55,0.55),
	"maryland_tabak":    Color(0.55,0.55,0.55),
	"schwarzer_kraeutler": Color(0.55,0.55,0.55),
	"pfeifentabak":      Color(0.55,0.55,0.55),
	"virginia":          Color(0.2, 0.75,0.2),
	"camel":             Color(0.2, 0.75,0.2),
	"lucky_strike":      Color(0.2, 0.75,0.2),
	"gauloises":         Color(0.2, 0.75,0.2),
	"bali_shag":         Color(0.2, 0.75,0.2),
	"samson":            Color(0.2, 0.75,0.2),
	"amber_leaf":        Color(0.2, 0.75,0.2),
	"cavendish":         Color(0.2, 0.75,0.2),
	"american_spirit":   Color(0.2, 0.45,1.0),
	"dunhill":           Color(0.2, 0.45,1.0),
	"winston":           Color(0.2, 0.45,1.0),
	"old_holborn":       Color(0.2, 0.45,1.0),
	"mac_baren":         Color(0.2, 0.45,1.0),
	"latakia":           Color(0.2, 0.45,1.0),
	"perique":           Color(0.2, 0.45,1.0),
	"gitanes":           Color(0.2, 0.45,1.0),
	"drum":              Color(0.65,0.1, 0.9),
	"prince":            Color(0.65,0.1, 0.9),
	"captain_black":     Color(0.65,0.1, 0.9),
	"skandinavisk":      Color(0.65,0.1, 0.9),
	"condor":            Color(0.65,0.1, 0.9),
	"toscano":           Color(0.65,0.1, 0.9),
	"amphora":           Color(0.65,0.1, 0.9),
	"beige_pueblo":      Color(1.0, 0.82,0.1),
}

const KURZNAME = {
	"drucker": "Druckerpapier", "king_size": "King Size", "reispapier": "Reispapier",
	"blunt": "Blunt", "kein": "Kein", "aktivkohle": "Aktivkohle",
	"slim": "Slim", "karton": "Karton", "billig": "Billig",
	"holzspitze": "Holzspitze",          "baumwollfilter": "Baumwollfilter",
	"schaumfilter": "Schaumfilter",       "gerolltes_papier": "Gerolltes Papier",
	"standard_tip": "Standard-Tip",      "extra_slim": "Extra Slim",
	"long_filter": "Long Filter",        "menthol_filter": "Menthol-Filter",
	"perforiert": "Perforiert",           "bio_filter": "Bio-Filter",
	"hanf_filter": "Hanf-Filter",         "dual_filter": "Dual Filter",
	"korkspitze": "Korkspitze",           "keramik_tip": "Keramik-Tip",
	"glasspitze": "Glasspitze",           "bambus_filter": "Bambus-Filter",
	"triacetat": "Triacetat",             "active_plus": "Active Plus",
	"gold_tip": "Gold-Tip",               "kristall_filter": "Kristallfilter",
	"elektrostatisch": "Elektrostatisch", "nano_filter": "Nano-Filter",
	"titan_tip": "Titan-Tip",             "doppel_aktiv": "Doppel-Aktiv",
	"platinspitze": "Platinspitze",       "diamantfilter": "Diamantfilter",
	"virginia": "Virginia", "american_spirit": "Am. Spirit", "drum": "Drum",
	"ernte_23": "Ernte 23",            "losen_blatt": "Losen Blatt",
	"burley": "Burley",                "maryland_tabak": "Maryland",
	"schwarzer_kraeutler": "Schw. Kräutler", "pfeifentabak": "Pfeifentabak",
	"camel": "Camel",                  "lucky_strike": "Lucky Strike",
	"gauloises": "Gauloises",          "bali_shag": "Bali Shag",
	"samson": "Samson",                "amber_leaf": "Amber Leaf",
	"cavendish": "Cavendish",          "dunhill": "Dunhill",
	"winston": "Winston",              "old_holborn": "Old Holborn",
	"mac_baren": "Mac Baren",          "latakia": "Latakia",
	"perique": "Perique",              "gitanes": "Gitanes",
	"prince": "Prince",                "captain_black": "Captain Black",
	"skandinavisk": "Skandinavisk",    "condor": "Condor",
	"toscano": "Toscano",              "amphora": "Amphora",
	"beige_pueblo": "Beige Pueblo",
	"king_size_slim": "KS Slim",       "ungebleichtes_pape": "Ungebleicht",
	"king_size_regular": "KS Regular", "eins_viertel_size": "1¼ Size",
	"single_wide": "Single Wide",      "flachs_papier": "Flachs-Papier",
	"inside_out": "Inside-Out",        "l_pape": "L-Pape",
	"flavored_pape": "Flavored Pape",  "menthol_pape": "Menthol-Pape",
	"hanf_wrap": "Hanf-Wrap",          "doppelt_gerollt": "Doppelt gerollt",
	"bedrucktes_pape": "Bedruckt",     "bambus_pape": "Bambus-Pape",
	"endlos_rolle": "Endlos-Rolle",    "blunt_wrap": "Blunt Wrap",
	"zellulose_pape": "Zellulose",     "backwoods": "Backwoods",
	"maisblatt": "Maisblatt",          "palmblatt": "Palmblatt",
	"vorgerollte_cone": "Cone",        "glow_pape": "Glow-in-Dark",
	"rosenblatt": "Rosenblatt",        "flash_papier": "Flash-Papier",
	"bananenblatt": "Bananenblatt",    "lotusblatt": "Lotusblatt",
	"blattgold_24k": "24k Blattgold",  "dollar_note": "Dollar-Note",
	"bibel_seite": "Bibel-Seite",
	"buschgras": "Buschgras",
	"harlequin": "Harlequin",
	"ac_dc": "AC/DC",
	"cannatonic": "Cannatonic",
	"charlottes_web": "Charlotte's W.",
	"solodiol": "Solodiol",
	"finola": "Finola",
	"fedora": "Fedora",
	"santhica": "Santhica",
	"one_to_one": "One to One",
	"fast_eddy": "Fast Eddy",
	"royal_medic": "Royal Medic",
	"pennywise": "Pennywise",
	"sour_tsunami": "Sour Tsunami",
	"ringos_gift": "Ringo's Gift",
	"remedium": "Remedium",
	"medihaze": "MediHaze",
	"zen": "Zen",
	"compassion": "Compassion",
	"sierra": "Sierra",
	"dancehall": "Dancehall",
	"tatanka": "Tatanka",
	"joannes_cbd": "Joanne's CBD",
	"royal_highness": "Royal Highness",
	"euphoria": "Euphoria",
	"medical_mass": "Medical Mass",
	"northern_lights": "Northern Ligh.",
	"blue_dream": "Blue Dream",
	"white_widow": "White Widow",
	"ak_47": "AK-47",
	"jack_herer": "Jack Herer",
	"skunk_1": "Skunk #1",
	"blueberry": "Blueberry",
	"durban_poison": "Durban Poison",
	"maui_wowie": "Maui Wowie",
	"acapulco_gold": "Acapulco Gold",
	"panama_red": "Panama Red",
	"hindu_kush": "Hindu Kush",
	"afghan_kush": "Afghan Kush",
	"bubble_gum": "Bubble Gum",
	"master_kush": "Master Kush",
	"cheese": "Cheese",
	"nyc_diesel": "NYC Diesel",
	"sour_diesel": "Sour Diesel",
	"strawberry_cough": "Strawberry Co.",
	"super_silver_haze": "Super Silver.",
	"lemon_haze": "Lemon Haze",
	"amnesia_haze": "Amnesia Haze",
	"orange_bud": "Orange Bud",
	"critical_mass": "Critical Mass",
	"power_plant": "Power Plant",
	"girl_scout_cookies": "Girl Scout Co.",
	"gorilla_glue_4": "Gorilla Glue.",
	"og_kush": "OG Kush",
	"wedding_cake": "Wedding Cake",
	"gelato_33": "Gelato #33",
	"zkittlez": "Zkittlez",
	"runtz": "Runtz",
	"purple_punch": "Purple Punch",
	"blue_cheese": "Blue Cheese",
	"granddaddy_purple": "Granddaddy Pu.",
	"chemdawg": "Chemdawg",
	"green_crack": "Green Crack",
	"bruce_banner": "Bruce Banner",
	"ghost_train_haze": "Ghost Train H.",
	"trainwreck": "Trainwreck",
	"alaskan_thunderfuck": "Alaskan Thund.",
	"skywalker_og": "Skywalker OG",
	"bubba_kush": "Bubba Kush",
	"death_star": "Death Star",
	"headband": "Headband",
	"cherry_pie": "Cherry Pie",
	"g13": "G13",
	"white_rhino": "White Rhino",
	"sensi_star": "Sensi Star",
	"kali_mist": "Kali Mist",
	"godfather_og": "Godfather OG",
	"chiquita_banana": "Chiquita Bana.",
	"grease_monkey": "Grease Monkey",
	"irish_cream": "Irish Cream",
	"bruce_banner_3": "Bruce Banner.",
	"strawberry_banana": "Strawberry Ba.",
	"white_tahoe_cookies": "White Tahoe C.",
	"emperor_cookie_dough": "Emperor Cooki.",
	"blackberry_moonrocks": "Blackberry Mo.",
	"quantum_kush": "Quantum Kush",
	"amnesia_mac_ganja": "Amnesia Mac G.",
	"permanent_marker": "Permanent Mar.",
	"jealousy": "Jealousy",
	"motorbreath": "Motorbreath",
	"kush_mints": "Kush Mints",
	"wedding_crasher": "Wedding Crash.",
	"apple_fritter": "Apple Fritter",
	"gmo_cookies": "GMO Cookies",
	"slurricane": "Slurricane",
	"mimosa": "Mimosa",
	"fat_banana": "Fat Banana",
	"royal_gorilla": "Royal Gorilla",
	"dr_grinspoon": "Dr. Grinspoon",
	"shogun": "Shogun",
	"hulkberry": "Hulkberry",
}

const SLOT_LABEL = {
	"papes": "Papes", "filter": "Filter", "tabak": "Tabak", "weed": "Weed",
}

const EFFEKT = {
	# Papes
	"drucker":           "Keine Boni",
	"reispapier":        "Feuerrate +10%",
	"king_size":         "+100 Reichweite",
	"blunt":             "+1 Schaden  +0.3 Größe",
	"king_size_slim":    "+50 Reichweite",
	"ungebleichtes_pape": "+1 Glück",
	"king_size_regular": "+75 Reichweite",
	"eins_viertel_size": "Feuerrate +5%",
	"single_wide":       "+20 Schusstempo",
	"flachs_papier":     "+20 Geschwindigkeit",
	"inside_out":        "Pierce",
	"l_pape":            "+150 Reichweite",
	"flavored_pape":     "+2 Glück",
	"menthol_pape":      "+50 Schusstempo",
	"hanf_wrap":         "+1 Schaden",
	"doppelt_gerollt":   "+1 Schaden  +0.2 Größe",
	"bedrucktes_pape":   "+2 Glück",
	"bambus_pape":       "Feuerrate +12%",
	"endlos_rolle":      "Feuerrate +18%  +80 Reichweite",
	"blunt_wrap":        "+2 Schaden  +0.2 Größe",
	"zellulose_pape":    "Pierce  +30 Schusstempo",
	"backwoods":         "+2 Schaden  +0.4 Größe",
	"maisblatt":         "+3 Glück  +30 Geschwindigkeit",
	"palmblatt":         "+200 Reichweite",
	"vorgerollte_cone":  "Feuerrate +20%",
	"glow_pape":         "+4 Glück  +60 Schusstempo",
	"rosenblatt":        "+100 Schusstempo  Feuerrate +15%",
	"flash_papier":      "Feuerrate +30%",
	"bananenblatt":      "+3 Schaden  +0.5 Größe",
	"lotusblatt":        "+2 Schaden  +50 Geschwindigkeit  +2 Glück",
	"blattgold_24k":     "+4 Schaden  +4 Glück  +0.5 Größe",
	"dollar_note":       "+3 Schaden  +200 Reichweite  +80 Schusstempo",
	"bibel_seite":       "+5 Schaden  +1 Max-HP  +5 Glück",
	# Filter
	"kein":              "Keine Boni",
	"holzspitze":        "+1 Glück",
	"baumwollfilter":    "Feuerrate +3%",
	"schaumfilter":      "+15 Schusstempo",
	"gerolltes_papier":  "+30 Reichweite",
	"standard_tip":      "+10 Geschwindigkeit",
	"slim":              "+1 Glück",
	"extra_slim":        "+2 Glück",
	"long_filter":       "+80 Reichweite",
	"menthol_filter":    "+40 Schusstempo  +20 Geschwindigkeit",
	"perforiert":        "Feuerrate +8%",
	"bio_filter":        "+2 Glück",
	"hanf_filter":       "+1 Schaden  +1 Glück",
	"aktivkohle":        "Pierce",
	"dual_filter":       "Pierce  Feuerrate +5%",
	"korkspitze":        "+2 Schaden  +60 Reichweite",
	"keramik_tip":       "+60 Schusstempo  +0.2 Größe",
	"glasspitze":        "Pierce  +30 Schusstempo",
	"bambus_filter":     "+3 Glück  +30 Geschwindigkeit",
	"triacetat":         "Feuerrate +15%  +80 Reichweite",
	"active_plus":       "+2 Schaden  +2 Glück",
	"karton":            "+50 Schusstempo",
	"gold_tip":          "+4 Glück  +2 Schaden",
	"kristall_filter":   "Pierce  +3 Schaden  +0.3 Größe",
	"elektrostatisch":   "Feuerrate +25%  +50 Schusstempo",
	"nano_filter":       "+80 Schusstempo  +40 Geschwindigkeit",
	"titan_tip":         "+4 Schaden  +0.4 Größe",
	"doppel_aktiv":      "Pierce  +3 Glück  Feuerrate +18%",
	"platinspitze":      "+4 Schaden  +5 Glück  +150 Reichweite",
	"diamantfilter":     "Pierce  +5 Schaden  +0.6 Größe  +4 Glück",
	# Tabak
	"billig":            "Keine Boni",
	"ernte_23":          "+15 Geschwindigkeit",
	"losen_blatt":       "+15 Schusstempo",
	"burley":            "+1 Schaden",
	"maryland_tabak":    "Feuerrate +3%",
	"schwarzer_kraeutler": "+1 Glück",
	"pfeifentabak":      "+40 Reichweite",
	"virginia":          "+40 Geschwindigkeit",
	"camel":             "+1 Schaden  +20 Schusstempo",
	"lucky_strike":      "Feuerrate +7%  +25 Schusstempo",
	"gauloises":         "+2 Schaden  −15 Geschwindigkeit",
	"bali_shag":         "Feuerrate +8%",
	"samson":            "+50 Geschwindigkeit",
	"amber_leaf":        "+2 Glück  +50 Reichweite",
	"cavendish":         "+40 Schusstempo  +0.15 Größe",
	"american_spirit":   "+50 Geschwindigkeit  +50 Reichweite",
	"dunhill":           "+2 Schaden  +75 Reichweite",
	"winston":           "+2 Schaden  +40 Schusstempo",
	"old_holborn":       "Feuerrate +15%  +2 Schaden",
	"mac_baren":         "+60 Geschwindigkeit  +2 Glück",
	"latakia":           "+3 Schaden  +0.3 Größe  −20 Geschwindigkeit",
	"perique":           "+3 Glück  Feuerrate +12%",
	"gitanes":           "+2 Schaden  Feuerrate +13%",
	"drum":              "+2 Schaden  −30 Geschwindigkeit",
	"prince":            "+3 Schaden  +100 Reichweite  +50 Schusstempo",
	"captain_black":     "+3 Schaden  +0.4 Größe  +2 Glück",
	"skandinavisk":      "Feuerrate +22%  +3 Schaden",
	"condor":            "+4 Schaden  −20 Geschwindigkeit  +0.3 Größe",
	"toscano":           "+4 Schaden  +1 Max-HP  −10 Geschwindigkeit",
	"amphora":           "+80 Schusstempo  +3 Glück  +100 Reichweite",
	"beige_pueblo":      "+5 Schaden  +60 Geschwindigkeit  +4 Glück  +150 Reichweite",
	# Weed Basis
	"buschgras":         "Keine Boni",
}

var slot: String = ""
var komponente: String = ""
var spieler = null
var in_reichweite = false
var ist_schatz_wahl: bool = false

func _ready():
	z_index        = 100
	z_as_relative  = false
	add_to_group("sammelbar")
	spieler = get_tree().get_first_node_in_group("spieler")
	queue_redraw()

func _process(_delta):
	if spieler == null:
		return
	var nah = global_position.distance_to(spieler.global_position) < REICHWEITE
	if nah != in_reichweite:
		in_reichweite = nah
		queue_redraw()

func _input(event):
	if in_reichweite and event is InputEventKey \
			and event.keycode == KEY_F and event.pressed and not event.echo:
		_aufnehmen()

func _aufnehmen():
	if not global_data.inventar[slot].has(komponente):
		global_data.inventar[slot].append(komponente)
	if ist_schatz_wahl:
		for andere in get_tree().get_nodes_in_group("schatz_pickup"):
			if andere != self:
				andere.queue_free()
	queue_free()

func _get_farbe() -> Color:
	if slot == "weed":
		var wd = global_data.WEED_DATEN.get(komponente, {})
		match wd.get("seltenheit", ""):
			"Gewöhnlich":   return Color(0.55, 0.55, 0.55)
			"Ungewöhnlich": return Color(0.2,  0.75, 0.2)
			"Selten":       return Color(0.2,  0.45, 1.0)
			"Episch":       return Color(0.65, 0.1,  0.9)
			"Legendar":     return Color(1.0,  0.82, 0.1)
		return Color(0.55, 0.55, 0.55)
	return SELTENHEIT_FARBE.get(komponente, Color(0.55, 0.55, 0.55))

func _get_slot_farbe() -> Color:
	return SLOT_FARBE.get(slot, Color(0.5, 0.5, 0.5))

func _get_effekt_text() -> String:
	if slot == "weed":
		var wd = global_data.WEED_DATEN.get(komponente, {})
		if wd.is_empty():
			return "Keine Boni"
		var parts = []
		var dmg = wd["damage"] - 1
		var fr  = wd["fire_rate"] - 1
		var ss  = wd["shot_speed"] - 1
		if dmg != 0: parts.append("%+d Schaden" % dmg)
		if fr  != 0: parts.append("Feuerrate +%d%%" % (fr * 3))
		if ss  != 0: parts.append("%+d Schusstempo" % (ss * 15))
		return "  ".join(parts) if not parts.is_empty() else "Keine Boni"
	return EFFEKT.get(komponente, "")

func _draw():
	var font        = ThemeDB.fallback_font
	var fill_farbe  = _get_slot_farbe()   # fix pro Slot
	var rand_farbe  = _get_farbe()        # Seltenheit als Umrandung

	draw_circle(Vector2.ZERO, 21, rand_farbe)   # Umrandung (Seltenheit)
	draw_circle(Vector2.ZERO, 16, fill_farbe)   # Füllung (Slot)

	# Slot-Label unter dem Icon
	draw_string(font, Vector2(-22, 33), SLOT_LABEL.get(slot, ""),
		HORIZONTAL_ALIGNMENT_CENTER, 44, 10, Color(0.7, 0.7, 0.7))

	if not in_reichweite:
		return

	var effekt_zeilen = _get_effekt_text().split("  ")
	var n = effekt_zeilen.size()
	var w = 190.0
	var h = 72.0 + n * 16.0
	var x = -w / 2.0
	var y = -h - 28.0

	draw_rect(Rect2(x, y, w, h),     Color(0.08, 0.08, 0.08, 0.93))
	draw_rect(Rect2(x, y, w, 26),    fill_farbe)
	draw_rect(Rect2(x, y, w, h),     rand_farbe, false, 2.0)
	draw_string(font, Vector2(x + 6, y + 19), KURZNAME.get(komponente, komponente),
		HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(0.05, 0.05, 0.05))
	draw_string(font, Vector2(x + 6, y + 40), SLOT_LABEL.get(slot, "") + "-Komponente",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.65, 0.65, 0.65))
	for i in n:
		draw_string(font, Vector2(x + 6, y + 56 + i * 16), effekt_zeilen[i],
			HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.9, 0.5))
	draw_string(font, Vector2(x + 6, y + 56 + n * 16), "F: Aufnehmen",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.5, 0.9, 0.5))
