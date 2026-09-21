extends Node

# Türfarbe je Zielraum-Typ (Türen, die zu Spezialräumen führen)
const TUER_TYP_FARBEN = {
	"boss":       Color(0.85, 0.20, 0.15),  # Rot
	"schatz":     Color(0.95, 0.75, 0.15),  # Gold
	"dealer":     Color(0.30, 0.85, 0.30),  # Grün
	"apotheke":   Color(0.25, 0.55, 0.90),  # Blau
	"raetsel":    Color(0.60, 0.35, 0.85),  # Lila
	"perfektion": Color(0.95, 0.95, 0.95),  # Weiß
}

const ALLE_KOMPONENTEN = {
	"papes":  [
		"drucker", "reispapier", "king_size", "blunt",
		"king_size_slim", "ungebleichtes_pape", "king_size_regular", "eins_viertel_size", "single_wide", "flachs_papier",
		"inside_out", "l_pape", "flavored_pape", "menthol_pape", "hanf_wrap", "doppelt_gerollt", "bedrucktes_pape", "bambus_pape",
		"endlos_rolle", "blunt_wrap", "zellulose_pape", "backwoods", "maisblatt", "palmblatt", "vorgerollte_cone",
		"glow_pape", "rosenblatt", "flash_papier", "bananenblatt", "lotusblatt",
		"blattgold_24k", "dollar_note", "bibel_seite",
	],
	"filter": [
		"kein", "slim", "aktivkohle", "karton",
		"holzspitze", "baumwollfilter", "schaumfilter", "gerolltes_papier", "standard_tip",
		"extra_slim", "long_filter", "menthol_filter", "perforiert", "bio_filter", "hanf_filter",
		"dual_filter", "korkspitze", "keramik_tip", "glasspitze", "bambus_filter", "triacetat", "active_plus",
		"gold_tip", "kristall_filter", "elektrostatisch", "nano_filter", "titan_tip", "doppel_aktiv",
		"platinspitze", "diamantfilter",
	],
	"tabak":  [
		"billig", "virginia", "american_spirit", "drum",
		"ernte_23", "losen_blatt", "burley", "maryland_tabak", "schwarzer_kraeutler", "pfeifentabak",
		"camel", "lucky_strike", "gauloises", "bali_shag", "samson", "amber_leaf", "cavendish",
		"dunhill", "winston", "old_holborn", "mac_baren", "latakia", "perique", "gitanes",
		"prince", "captain_black", "skandinavisk", "condor", "toscano", "amphora",
		"beige_pueblo",
	],
	"weed":   [
		"buschgras",
		"harlequin", "ac_dc", "cannatonic", "charlottes_web", "solodiol",
		"finola", "fedora", "santhica", "one_to_one", "fast_eddy",
		"royal_medic", "pennywise", "sour_tsunami", "ringos_gift", "remedium",
		"medihaze", "zen", "compassion", "sierra", "dancehall",
		"tatanka", "joannes_cbd", "royal_highness", "euphoria", "medical_mass",
		"northern_lights", "blue_dream", "white_widow", "ak_47", "jack_herer",
		"skunk_1", "blueberry", "durban_poison", "maui_wowie", "acapulco_gold",
		"panama_red", "hindu_kush", "afghan_kush", "bubble_gum", "master_kush",
		"cheese", "nyc_diesel", "sour_diesel", "strawberry_cough", "super_silver_haze",
		"lemon_haze", "amnesia_haze", "orange_bud", "critical_mass", "power_plant",
		"girl_scout_cookies", "gorilla_glue_4", "og_kush", "wedding_cake", "gelato_33",
		"zkittlez", "runtz", "purple_punch", "blue_cheese", "granddaddy_purple",
		"chemdawg", "green_crack", "bruce_banner", "ghost_train_haze", "trainwreck",
		"alaskan_thunderfuck", "skywalker_og", "bubba_kush", "death_star", "headband",
		"cherry_pie", "g13", "white_rhino", "sensi_star", "kali_mist",
		"godfather_og", "chiquita_banana", "grease_monkey", "irish_cream", "bruce_banner_3",
		"strawberry_banana", "white_tahoe_cookies", "emperor_cookie_dough", "blackberry_moonrocks", "quantum_kush",
		"amnesia_mac_ganja", "permanent_marker", "jealousy", "motorbreath", "kush_mints",
		"wedding_crasher", "apple_fritter", "gmo_cookies", "slurricane", "mimosa",
		"fat_banana", "royal_gorilla", "dr_grinspoon", "shogun", "hulkberry",
	],
}

func nicht_besessene_komponenten() -> Array:
	var liste = []
	for slot in ALLE_KOMPONENTEN:
		for komp in ALLE_KOMPONENTEN[slot]:
			if not inventar[slot].has(komp):
				liste.append({"slot": slot, "komponente": komp})
	return liste

# ── Welt-basierte Komponenten-Seltenheit ──────────────────────────────────────

var aktuelle_welt: int = 1

# Wahrscheinlichkeitstabelle [Gewöhnlich, Ungewöhnlich, Selten, Episch, Legendär]
const WELT_SELTENHEIT_TABELLE = [
	[0.70, 0.25, 0.05, 0.00, 0.00],  # Welt 1
	[0.50, 0.35, 0.15, 0.00, 0.00],  # Welt 2
	[0.30, 0.35, 0.25, 0.10, 0.00],  # Welt 3
	[0.15, 0.30, 0.30, 0.20, 0.05],  # Welt 4
	[0.05, 0.20, 0.30, 0.30, 0.15],  # Welt 5
	[0.00, 0.15, 0.25, 0.35, 0.25],  # Welt 6
	[0.00, 0.05, 0.20, 0.35, 0.40],  # Welt 7
	[0.00, 0.00, 0.10, 0.35, 0.55],  # Welt 8
]
const SELTENHEIT_NAMEN = ["Gewöhnlich", "Ungewöhnlich", "Selten", "Episch", "Legendär"]

# Seltenheit je Komponentenname (abgeleitet aus SELTENHEIT_FARBE in komponenten_pickup.gd)
const KOMPONENTEN_SELTENHEIT = {
	# Papes – Gewöhnlich
	"drucker": "Gewöhnlich", "king_size_slim": "Gewöhnlich", "ungebleichtes_pape": "Gewöhnlich",
	"king_size_regular": "Gewöhnlich", "eins_viertel_size": "Gewöhnlich",
	"single_wide": "Gewöhnlich", "flachs_papier": "Gewöhnlich",
	# Papes – Ungewöhnlich
	"reispapier": "Ungewöhnlich", "inside_out": "Ungewöhnlich", "l_pape": "Ungewöhnlich",
	"flavored_pape": "Ungewöhnlich", "menthol_pape": "Ungewöhnlich", "hanf_wrap": "Ungewöhnlich",
	"doppelt_gerollt": "Ungewöhnlich", "bedrucktes_pape": "Ungewöhnlich", "bambus_pape": "Ungewöhnlich",
	# Papes – Selten
	"king_size": "Selten", "endlos_rolle": "Selten", "blunt_wrap": "Selten",
	"zellulose_pape": "Selten", "backwoods": "Selten", "maisblatt": "Selten",
	"palmblatt": "Selten", "vorgerollte_cone": "Selten",
	# Papes – Episch
	"blunt": "Episch", "glow_pape": "Episch", "rosenblatt": "Episch",
	"flash_papier": "Episch", "bananenblatt": "Episch", "lotusblatt": "Episch",
	# Papes – Legendär
	"blattgold_24k": "Legendär", "dollar_note": "Legendär", "bibel_seite": "Legendär",
	# Filter – Gewöhnlich
	"kein": "Gewöhnlich", "holzspitze": "Gewöhnlich", "baumwollfilter": "Gewöhnlich",
	"schaumfilter": "Gewöhnlich", "gerolltes_papier": "Gewöhnlich", "standard_tip": "Gewöhnlich",
	# Filter – Ungewöhnlich
	"slim": "Ungewöhnlich", "extra_slim": "Ungewöhnlich", "long_filter": "Ungewöhnlich",
	"menthol_filter": "Ungewöhnlich", "perforiert": "Ungewöhnlich",
	"bio_filter": "Ungewöhnlich", "hanf_filter": "Ungewöhnlich",
	# Filter – Selten
	"aktivkohle": "Selten", "dual_filter": "Selten", "korkspitze": "Selten",
	"keramik_tip": "Selten", "glasspitze": "Selten", "bambus_filter": "Selten",
	"triacetat": "Selten", "active_plus": "Selten",
	# Filter – Episch
	"karton": "Episch", "gold_tip": "Episch", "kristall_filter": "Episch",
	"elektrostatisch": "Episch", "nano_filter": "Episch", "titan_tip": "Episch",
	"doppel_aktiv": "Episch",
	# Filter – Legendär
	"platinspitze": "Legendär", "diamantfilter": "Legendär",
	# Tabak – Gewöhnlich
	"billig": "Gewöhnlich", "ernte_23": "Gewöhnlich", "losen_blatt": "Gewöhnlich",
	"burley": "Gewöhnlich", "maryland_tabak": "Gewöhnlich",
	"schwarzer_kraeutler": "Gewöhnlich", "pfeifentabak": "Gewöhnlich",
	# Tabak – Ungewöhnlich
	"virginia": "Ungewöhnlich", "camel": "Ungewöhnlich", "lucky_strike": "Ungewöhnlich",
	"gauloises": "Ungewöhnlich", "bali_shag": "Ungewöhnlich", "samson": "Ungewöhnlich",
	"amber_leaf": "Ungewöhnlich", "cavendish": "Ungewöhnlich",
	# Tabak – Selten
	"american_spirit": "Selten", "dunhill": "Selten", "winston": "Selten",
	"old_holborn": "Selten", "mac_baren": "Selten", "latakia": "Selten",
	"perique": "Selten", "gitanes": "Selten",
	# Tabak – Episch
	"drum": "Episch", "prince": "Episch", "captain_black": "Episch",
	"skandinavisk": "Episch", "condor": "Episch", "toscano": "Episch", "amphora": "Episch",
	# Tabak – Legendär
	"beige_pueblo": "Legendär",
	# Weed – Seltenheit via WEED_DATEN (Gewöhnlich / Selten / Episch / Legendar)
}

func seltenheit_von(slot: String, komp: String) -> String:
	var s: String
	if slot == "weed":
		s = WEED_DATEN.get(komp, {}).get("seltenheit", "Gewöhnlich")
	else:
		s = KOMPONENTEN_SELTENHEIT.get(komp, "Gewöhnlich")
	# Normalisierung: WEED_DATEN nutzt "Legendar" (ohne Umlaut)
	return "Legendär" if s == "Legendar" else s

func _seltenheit_ziehen(welt: int) -> String:
	var w = clamp(welt - 1, 0, WELT_SELTENHEIT_TABELLE.size() - 1)
	var probs = WELT_SELTENHEIT_TABELLE[w]
	var roll = randf()
	var kumuliert = 0.0
	for i in probs.size():
		kumuliert += probs[i]
		if roll < kumuliert:
			return SELTENHEIT_NAMEN[i]
	return SELTENHEIT_NAMEN.back()

func nicht_besessene_komponenten_fuer_welt(welt: int) -> Array:
	var alle = nicht_besessene_komponenten()
	if alle.is_empty():
		return alle
	var ziel = _seltenheit_ziehen(welt)
	var gefiltert = alle.filter(func(k): return seltenheit_von(k["slot"], k["komponente"]) == ziel)
	# Fallback: falls keine Komponente der Ziel-Seltenheit verfügbar
	if gefiltert.is_empty():
		gefiltert = alle
	gefiltert.shuffle()
	return gefiltert

var charakter = "sixxer"

const WEED_DATEN = {
	"buschgras":  {"damage": 1, "fire_rate": 1, "shot_speed": 1, "seltenheit": "Gewöhnlich", "typ": "Hybrid"},
	"harlequin": {"damage": 2, "fire_rate": 2, "shot_speed": 2, "seltenheit": "Gewöhnlich", "typ": "Hybrid"},
	"ac_dc": {"damage": 1, "fire_rate": 3, "shot_speed": 2, "seltenheit": "Gewöhnlich", "typ": "Sativa"},
	"cannatonic": {"damage": 2, "fire_rate": 2, "shot_speed": 2, "seltenheit": "Gewöhnlich", "typ": "Hybrid"},
	"charlottes_web": {"damage": 3, "fire_rate": 1, "shot_speed": 1, "seltenheit": "Gewöhnlich", "typ": "Indica"},
	"solodiol": {"damage": 1, "fire_rate": 2, "shot_speed": 3, "seltenheit": "Gewöhnlich", "typ": "Sativa"},
	"finola": {"damage": 2, "fire_rate": 1, "shot_speed": 2, "seltenheit": "Gewöhnlich", "typ": "Hybrid"},
	"fedora": {"damage": 1, "fire_rate": 3, "shot_speed": 2, "seltenheit": "Gewöhnlich", "typ": "Sativa"},
	"santhica": {"damage": 2, "fire_rate": 2, "shot_speed": 1, "seltenheit": "Gewöhnlich", "typ": "Hybrid"},
	"one_to_one": {"damage": 2, "fire_rate": 2, "shot_speed": 2, "seltenheit": "Gewöhnlich", "typ": "Hybrid"},
	"fast_eddy": {"damage": 1, "fire_rate": 4, "shot_speed": 1, "seltenheit": "Gewöhnlich", "typ": "Sativa"},
	"royal_medic": {"damage": 1, "fire_rate": 3, "shot_speed": 3, "seltenheit": "Gewöhnlich", "typ": "Sativa"},
	"pennywise": {"damage": 3, "fire_rate": 2, "shot_speed": 1, "seltenheit": "Gewöhnlich", "typ": "Indica"},
	"sour_tsunami": {"damage": 2, "fire_rate": 3, "shot_speed": 1, "seltenheit": "Gewöhnlich", "typ": "Sativa"},
	"ringos_gift": {"damage": 2, "fire_rate": 2, "shot_speed": 2, "seltenheit": "Gewöhnlich", "typ": "Hybrid"},
	"remedium": {"damage": 3, "fire_rate": 1, "shot_speed": 1, "seltenheit": "Gewöhnlich", "typ": "Indica"},
	"medihaze": {"damage": 1, "fire_rate": 3, "shot_speed": 3, "seltenheit": "Gewöhnlich", "typ": "Sativa"},
	"zen": {"damage": 2, "fire_rate": 2, "shot_speed": 2, "seltenheit": "Gewöhnlich", "typ": "Hybrid"},
	"compassion": {"damage": 3, "fire_rate": 1, "shot_speed": 2, "seltenheit": "Gewöhnlich", "typ": "Indica"},
	"sierra": {"damage": 1, "fire_rate": 2, "shot_speed": 4, "seltenheit": "Gewöhnlich", "typ": "Sativa"},
	"dancehall": {"damage": 2, "fire_rate": 4, "shot_speed": 1, "seltenheit": "Gewöhnlich", "typ": "Sativa"},
	"tatanka": {"damage": 4, "fire_rate": 1, "shot_speed": 1, "seltenheit": "Gewöhnlich", "typ": "Indica"},
	"joannes_cbd": {"damage": 2, "fire_rate": 2, "shot_speed": 2, "seltenheit": "Gewöhnlich", "typ": "Hybrid"},
	"royal_highness": {"damage": 1, "fire_rate": 3, "shot_speed": 3, "seltenheit": "Gewöhnlich", "typ": "Sativa"},
	"euphoria": {"damage": 3, "fire_rate": 2, "shot_speed": 1, "seltenheit": "Gewöhnlich", "typ": "Indica"},
	"medical_mass": {"damage": 2, "fire_rate": 3, "shot_speed": 1, "seltenheit": "Gewöhnlich", "typ": "Hybrid"},
	# Gewöhnlich (neu hinzugefügt)
	"northern_lights": {"damage": 5, "fire_rate": 2, "shot_speed": 2, "seltenheit": "Gewöhnlich", "typ": "Indica"},
	"blue_dream": {"damage": 2, "fire_rate": 5, "shot_speed": 4, "seltenheit": "Gewöhnlich", "typ": "Sativa"},
	"white_widow": {"damage": 4, "fire_rate": 4, "shot_speed": 3, "seltenheit": "Gewöhnlich", "typ": "Hybrid"},
	"ak_47": {"damage": 3, "fire_rate": 6, "shot_speed": 3, "seltenheit": "Gewöhnlich", "typ": "Sativa"},
	"jack_herer": {"damage": 2, "fire_rate": 5, "shot_speed": 5, "seltenheit": "Gewöhnlich", "typ": "Sativa"},
	# Ungewöhnlich
	"skunk_1": {"damage": 4, "fire_rate": 3, "shot_speed": 4, "seltenheit": "Ungewöhnlich", "typ": "Hybrid"},
	"blueberry": {"damage": 6, "fire_rate": 1, "shot_speed": 2, "seltenheit": "Ungewöhnlich", "typ": "Indica"},
	"durban_poison": {"damage": 1, "fire_rate": 6, "shot_speed": 5, "seltenheit": "Ungewöhnlich", "typ": "Sativa"},
	"maui_wowie": {"damage": 2, "fire_rate": 5, "shot_speed": 5, "seltenheit": "Ungewöhnlich", "typ": "Sativa"},
	"acapulco_gold": {"damage": 3, "fire_rate": 4, "shot_speed": 5, "seltenheit": "Ungewöhnlich", "typ": "Sativa"},
	"panama_red": {"damage": 2, "fire_rate": 6, "shot_speed": 4, "seltenheit": "Ungewöhnlich", "typ": "Sativa"},
	"hindu_kush": {"damage": 6, "fire_rate": 2, "shot_speed": 1, "seltenheit": "Ungewöhnlich", "typ": "Indica"},
	"afghan_kush": {"damage": 6, "fire_rate": 1, "shot_speed": 2, "seltenheit": "Ungewöhnlich", "typ": "Indica"},
	"bubble_gum": {"damage": 4, "fire_rate": 4, "shot_speed": 3, "seltenheit": "Ungewöhnlich", "typ": "Hybrid"},
	"master_kush": {"damage": 5, "fire_rate": 3, "shot_speed": 2, "seltenheit": "Ungewöhnlich", "typ": "Indica"},
	"cheese": {"damage": 4, "fire_rate": 3, "shot_speed": 4, "seltenheit": "Ungewöhnlich", "typ": "Hybrid"},
	"nyc_diesel": {"damage": 3, "fire_rate": 5, "shot_speed": 4, "seltenheit": "Ungewöhnlich", "typ": "Sativa"},
	"sour_diesel": {"damage": 2, "fire_rate": 6, "shot_speed": 4, "seltenheit": "Ungewöhnlich", "typ": "Sativa"},
	"strawberry_cough": {"damage": 3, "fire_rate": 5, "shot_speed": 4, "seltenheit": "Ungewöhnlich", "typ": "Sativa"},
	"super_silver_haze": {"damage": 2, "fire_rate": 5, "shot_speed": 6, "seltenheit": "Ungewöhnlich", "typ": "Sativa"},
	"lemon_haze": {"damage": 1, "fire_rate": 6, "shot_speed": 6, "seltenheit": "Ungewöhnlich", "typ": "Sativa"},
	"amnesia_haze": {"damage": 2, "fire_rate": 6, "shot_speed": 5, "seltenheit": "Ungewöhnlich", "typ": "Sativa"},
	"orange_bud": {"damage": 4, "fire_rate": 4, "shot_speed": 3, "seltenheit": "Ungewöhnlich", "typ": "Hybrid"},
	"critical_mass": {"damage": 5, "fire_rate": 3, "shot_speed": 2, "seltenheit": "Ungewöhnlich", "typ": "Indica"},
	"power_plant": {"damage": 3, "fire_rate": 5, "shot_speed": 4, "seltenheit": "Ungewöhnlich", "typ": "Sativa"},
	"girl_scout_cookies": {"damage": 6, "fire_rate": 5, "shot_speed": 6, "seltenheit": "Ungewöhnlich", "typ": "Hybrid"},
	"gorilla_glue_4": {"damage": 7, "fire_rate": 5, "shot_speed": 5, "seltenheit": "Ungewöhnlich", "typ": "Hybrid"},
	"og_kush": {"damage": 8, "fire_rate": 3, "shot_speed": 4, "seltenheit": "Ungewöhnlich", "typ": "Indica"},
	"wedding_cake": {"damage": 6, "fire_rate": 6, "shot_speed": 5, "seltenheit": "Ungewöhnlich", "typ": "Hybrid"},
	"gelato_33": {"damage": 5, "fire_rate": 7, "shot_speed": 5, "seltenheit": "Ungewöhnlich", "typ": "Hybrid"},
	# Selten
	"zkittlez": {"damage": 7, "fire_rate": 4, "shot_speed": 4, "seltenheit": "Selten", "typ": "Indica"},
	"runtz": {"damage": 6, "fire_rate": 6, "shot_speed": 6, "seltenheit": "Selten", "typ": "Hybrid"},
	"purple_punch": {"damage": 8, "fire_rate": 2, "shot_speed": 4, "seltenheit": "Selten", "typ": "Indica"},
	"blue_cheese": {"damage": 7, "fire_rate": 4, "shot_speed": 3, "seltenheit": "Selten", "typ": "Indica"},
	"granddaddy_purple": {"damage": 8, "fire_rate": 3, "shot_speed": 3, "seltenheit": "Selten", "typ": "Indica"},
	"chemdawg": {"damage": 6, "fire_rate": 6, "shot_speed": 5, "seltenheit": "Selten", "typ": "Hybrid"},
	"green_crack": {"damage": 3, "fire_rate": 8, "shot_speed": 7, "seltenheit": "Selten", "typ": "Sativa"},
	"bruce_banner": {"damage": 7, "fire_rate": 6, "shot_speed": 5, "seltenheit": "Selten", "typ": "Hybrid"},
	"ghost_train_haze": {"damage": 4, "fire_rate": 8, "shot_speed": 7, "seltenheit": "Selten", "typ": "Sativa"},
	"trainwreck": {"damage": 6, "fire_rate": 5, "shot_speed": 6, "seltenheit": "Selten", "typ": "Hybrid"},
	"alaskan_thunderfuck": {"damage": 3, "fire_rate": 7, "shot_speed": 8, "seltenheit": "Selten", "typ": "Sativa"},
	"skywalker_og": {"damage": 8, "fire_rate": 4, "shot_speed": 3, "seltenheit": "Selten", "typ": "Indica"},
	"bubba_kush": {"damage": 8, "fire_rate": 3, "shot_speed": 3, "seltenheit": "Selten", "typ": "Indica"},
	"death_star": {"damage": 9, "fire_rate": 2, "shot_speed": 3, "seltenheit": "Selten", "typ": "Indica"},
	"headband": {"damage": 6, "fire_rate": 6, "shot_speed": 5, "seltenheit": "Selten", "typ": "Hybrid"},
	"cherry_pie": {"damage": 7, "fire_rate": 4, "shot_speed": 4, "seltenheit": "Selten", "typ": "Indica"},
	"g13": {"damage": 8, "fire_rate": 3, "shot_speed": 3, "seltenheit": "Selten", "typ": "Indica"},
	"white_rhino": {"damage": 7, "fire_rate": 4, "shot_speed": 4, "seltenheit": "Selten", "typ": "Indica"},
	"sensi_star": {"damage": 8, "fire_rate": 3, "shot_speed": 3, "seltenheit": "Selten", "typ": "Indica"},
	"kali_mist": {"damage": 3, "fire_rate": 8, "shot_speed": 7, "seltenheit": "Selten", "typ": "Sativa"},
	# Episch
	"godfather_og": {"damage": 10, "fire_rate": 4, "shot_speed": 4, "seltenheit": "Episch", "typ": "Indica"},
	"chiquita_banana": {"damage": 8, "fire_rate": 8, "shot_speed": 7, "seltenheit": "Episch", "typ": "Hybrid"},
	"grease_monkey": {"damage": 9, "fire_rate": 5, "shot_speed": 5, "seltenheit": "Episch", "typ": "Indica"},
	"irish_cream": {"damage": 10, "fire_rate": 3, "shot_speed": 4, "seltenheit": "Episch", "typ": "Indica"},
	"bruce_banner_3": {"damage": 8, "fire_rate": 8, "shot_speed": 8, "seltenheit": "Episch", "typ": "Hybrid"},
	"strawberry_banana": {"damage": 7, "fire_rate": 9, "shot_speed": 7, "seltenheit": "Episch", "typ": "Hybrid"},
	"white_tahoe_cookies": {"damage": 9, "fire_rate": 5, "shot_speed": 5, "seltenheit": "Episch", "typ": "Indica"},
	"emperor_cookie_dough": {"damage": 8, "fire_rate": 8, "shot_speed": 8, "seltenheit": "Episch", "typ": "Hybrid"},
	"blackberry_moonrocks": {"damage": 10, "fire_rate": 4, "shot_speed": 4, "seltenheit": "Episch", "typ": "Indica"},
	"quantum_kush": {"damage": 5, "fire_rate": 10, "shot_speed": 9, "seltenheit": "Episch", "typ": "Sativa"},
	"amnesia_mac_ganja": {"damage": 4, "fire_rate": 10, "shot_speed": 10, "seltenheit": "Episch", "typ": "Sativa"},
	"permanent_marker": {"damage": 8, "fire_rate": 9, "shot_speed": 7, "seltenheit": "Episch", "typ": "Hybrid"},
	"jealousy": {"damage": 8, "fire_rate": 8, "shot_speed": 8, "seltenheit": "Episch", "typ": "Hybrid"},
	"motorbreath": {"damage": 10, "fire_rate": 4, "shot_speed": 4, "seltenheit": "Episch", "typ": "Indica"},
	"kush_mints": {"damage": 9, "fire_rate": 6, "shot_speed": 4, "seltenheit": "Episch", "typ": "Indica"},
	# Legendär
	"wedding_crasher": {"damage": 5, "fire_rate": 9, "shot_speed": 9, "seltenheit": "Legendar", "typ": "Sativa"},
	"apple_fritter": {"damage": 8, "fire_rate": 8, "shot_speed": 8, "seltenheit": "Legendar", "typ": "Hybrid"},
	"gmo_cookies": {"damage": 10, "fire_rate": 3, "shot_speed": 5, "seltenheit": "Legendar", "typ": "Indica"},
	"slurricane": {"damage": 9, "fire_rate": 5, "shot_speed": 5, "seltenheit": "Legendar", "typ": "Indica"},
	"mimosa": {"damage": 4, "fire_rate": 9, "shot_speed": 10, "seltenheit": "Legendar", "typ": "Sativa"},
	"fat_banana": {"damage": 10, "fire_rate": 4, "shot_speed": 4, "seltenheit": "Legendar", "typ": "Indica"},
	"royal_gorilla": {"damage": 8, "fire_rate": 8, "shot_speed": 8, "seltenheit": "Legendar", "typ": "Hybrid"},
	"dr_grinspoon": {"damage": 4, "fire_rate": 10, "shot_speed": 10, "seltenheit": "Legendar", "typ": "Sativa"},
	"shogun": {"damage": 5, "fire_rate": 10, "shot_speed": 9, "seltenheit": "Legendar", "typ": "Sativa"},
	"hulkberry": {"damage": 5, "fire_rate": 9, "shot_speed": 10, "seltenheit": "Legendar", "typ": "Sativa"},
}
var joint_form = "normal"
var joint_komponenten = {
	"papes": "drucker",
	"filter": "kein",
	"tabak": "billig",
	"weed": "buschgras"
}
var inventar = {
	"papes":  ["drucker"],
	"filter": ["kein"],
	"tabak":  ["billig"],
	"weed":   ["buschgras"],
}

var schaden_in_aktueller_welt = false

var komponenten_bonus = {
	"schaden": 0, "geschwindigkeit": 0.0, "reichweite": 0,
	"schuss_tempo": 0, "projektil_groesse": 0.0, "glueck": 0,
	"max_hp": 0, "unverwundbar_dauer": 0.0,
	"pierce": false, "feuerrate_mult": 1.0,
}

var bitcoins = 0
var bomben = 0
var schluessel = 0
var leichen = 0            # Leiche des markierten Gegners (max 1, verfällt beim Weltwechsel)
var aktueller_raum = null

var zeti_reroll_verfuegbar: bool = true

# Aufgenommene Relikte im aktuellen Run – je Eintrag {"name": String, "farbe": Color}
var besessene_relikte: Array = []
