extends Control

const SLOT_NAMEN  = ["papes", "filter", "tabak", "weed"]
const SLOT_LABELS = ["Papes", "Filter", "Tabak", "Weed"]

const BESCHREIBUNG = {
	# Papes
	"drucker":           "Standard Druckerpapier",
	"reispapier":        "Dünnes Reispapier",
	"king_size":         "Größere Kapazität",
	"blunt":             "Dicker Blunt Wrapper",
	"king_size_slim":    "Schmal & Lang",
	"ungebleichtes_pape": "Braunes Naturpapier",
	"king_size_regular": "Standard King Size, breit",
	"eins_viertel_size": "Medium Größe",
	"single_wide":       "Kurzes Einzelpapier",
	"flachs_papier":     "Naturfaserpapier",
	"inside_out":        "Holländische Rollung",
	"l_pape":            "L-förmige Verlängerung",
	"flavored_pape":     "Geschmacktes Papier",
	"menthol_pape":      "Mentholfrisches Papier",
	"hanf_wrap":         "Hanffaser-Umhüllung",
	"doppelt_gerollt":   "Doppelwandig gerollt",
	"bedrucktes_pape":   "Individuell bedruckt",
	"bambus_pape":       "Ökologisches Bambuspapier",
	"endlos_rolle":      "Endlose Papierrolle",
	"blunt_wrap":        "Breiter Blunt-Wrapper",
	"zellulose_pape":    "Transparente Cellulosefolie",
	"backwoods":         "Rustikales Tabakblatt",
	"maisblatt":         "Natürliches Maisblatt",
	"palmblatt":         "Exotisches Palmblatt",
	"vorgerollte_cone":  "Fertig geformte Hülse",
	"glow_pape":         "Leuchtet im Dunkeln",
	"rosenblatt":        "Getrocknetes Rosenblatt",
	"flash_papier":      "Verbrennt explosionsartig",
	"bananenblatt":      "Tropisches Bananenblatt",
	"lotusblatt":        "Spirituelles Lotusblatt",
	"blattgold_24k":     "Echtes 24-Karat Blattgold",
	"dollar_note":       "Echter US-Dollar",
	"bibel_seite":       "Heilige Bibelseite",
	# Filter
	"kein":              "Kein Filter",
	"holzspitze":        "Einfache Holzspitze",
	"baumwollfilter":    "Weicher Baumwollfilter",
	"schaumfilter":      "Leichter Schaumfilter",
	"gerolltes_papier":  "Selbstgerollte Spitze",
	"standard_tip":      "Standard Filteraufsatz",
	"slim":              "Slim Filter",
	"extra_slim":        "Besonders schmaler Filter",
	"long_filter":       "Verlängerter Filter",
	"menthol_filter":    "Mentholfrischer Filter",
	"perforiert":        "Perforierter Luftfilter",
	"bio_filter":        "Biologisch abbaubar",
	"hanf_filter":       "Natürlicher Hanffilter",
	"aktivkohle":        "Reinere Rauchkugeln",
	"dual_filter":       "Doppelte Filterwirkung",
	"korkspitze":        "Klassische Korkspitze",
	"keramik_tip":       "Hitzebeständige Keramik",
	"glasspitze":        "Elegante Glasspitze",
	"bambus_filter":     "Ökologischer Bambusfilter",
	"triacetat":         "Synthetischer Feinfilter",
	"active_plus":       "Verstärkte Aktivkohle",
	"karton":            "Karton-Tip",
	"gold_tip":          "Vergoldete Filterkappe",
	"kristall_filter":   "Kristallklare Filterung",
	"elektrostatisch":   "Elektrostatische Abscheidung",
	"nano_filter":       "Nano-Partikelfiltration",
	"titan_tip":         "Titangehärtete Spitze",
	"doppel_aktiv":      "Doppelte Aktivkohlefilterung",
	"platinspitze":      "Platinbeschichtete Spitze",
	"diamantfilter":     "Diamantgestäubte Reinfilterung",
	# Tabak
	"billig":              "Billiger Tabak",
	"ernte_23":            "DDR-Klassiker, trocken",
	"losen_blatt":         "Loser Schnitt, leicht",
	"burley":              "Würziger Burley-Tabak",
	"maryland_tabak":      "Milder Maryland-Tabak",
	"schwarzer_kraeutler": "Schwerer Kräutertabak",
	"pfeifentabak":        "Aromatischer Pfeifentabak",
	"virginia":            "Mittlerer Tabak",
	"camel":               "Würzig-runder Blend",
	"lucky_strike":        "Klassischer US-Tabak",
	"gauloises":           "Kräftiger Franzose",
	"bali_shag":           "Leichter Shag-Tabak",
	"samson":              "Holländischer Rolltabak",
	"amber_leaf":          "Goldener Burley-Mix",
	"cavendish":           "Süßlich dampfender Blend",
	"american_spirit":     "Naturbelassener Tabak",
	"dunhill":             "Edler englischer Blend",
	"winston":             "Vollmundiger US-Tabak",
	"old_holborn":         "Schwerer Rolltabak",
	"mac_baren":           "Dänischer Premium-Shag",
	"latakia":             "Rauchig-orientalischer Tabak",
	"perique":             "Einzigartiger Würztabak",
	"gitanes":             "Starker französischer Tabak",
	"drum":                "Drum Rolltabak",
	"prince":              "Dänischer Pfeifentabak",
	"captain_black":       "Süßer amerikanischer Blend",
	"skandinavisk":        "Skandinavischer Aromatabak",
	"condor":              "Schwerer britischer Shag",
	"toscano":             "Rustikale italienische Zigarre",
	"amphora":             "Holländischer Luxusblend",
	"beige_pueblo":        "Das Beste vom Besten",
	# Weed (100 Sorten – Typ | Schaden | Feuerrate | Schussgeschw.)
	"buschgras": "Billiges Straßenweed – keine Boni",
	"harlequin": "Hybrid | DMG:2 FR:2 SS:2",
	"ac_dc": "Sativa | DMG:1 FR:3 SS:2",
	"cannatonic": "Hybrid | DMG:2 FR:2 SS:2",
	"charlottes_web": "Indica | DMG:3 FR:1 SS:1",
	"solodiol": "Sativa | DMG:1 FR:2 SS:3",
	"finola": "Hybrid | DMG:2 FR:1 SS:2",
	"fedora": "Sativa | DMG:1 FR:3 SS:2",
	"santhica": "Hybrid | DMG:2 FR:2 SS:1",
	"one_to_one": "Hybrid | DMG:2 FR:2 SS:2",
	"fast_eddy": "Sativa | DMG:1 FR:4 SS:1",
	"royal_medic": "Sativa | DMG:1 FR:3 SS:3",
	"pennywise": "Indica | DMG:3 FR:2 SS:1",
	"sour_tsunami": "Sativa | DMG:2 FR:3 SS:1",
	"ringos_gift": "Hybrid | DMG:2 FR:2 SS:2",
	"remedium": "Indica | DMG:3 FR:1 SS:1",
	"medihaze": "Sativa | DMG:1 FR:3 SS:3",
	"zen": "Hybrid | DMG:2 FR:2 SS:2",
	"compassion": "Indica | DMG:3 FR:1 SS:2",
	"sierra": "Sativa | DMG:1 FR:2 SS:4",
	"dancehall": "Sativa | DMG:2 FR:4 SS:1",
	"tatanka": "Indica | DMG:4 FR:1 SS:1",
	"joannes_cbd": "Hybrid | DMG:2 FR:2 SS:2",
	"royal_highness": "Sativa | DMG:1 FR:3 SS:3",
	"euphoria": "Indica | DMG:3 FR:2 SS:1",
	"medical_mass": "Hybrid | DMG:2 FR:3 SS:1",
	"northern_lights": "Indica | DMG:5 FR:2 SS:2",
	"blue_dream": "Sativa | DMG:2 FR:5 SS:4",
	"white_widow": "Hybrid | DMG:4 FR:4 SS:3",
	"ak_47": "Sativa | DMG:3 FR:6 SS:3",
	"jack_herer": "Sativa | DMG:2 FR:5 SS:5",
	"skunk_1": "Hybrid | DMG:4 FR:3 SS:4",
	"blueberry": "Indica | DMG:6 FR:1 SS:2",
	"durban_poison": "Sativa | DMG:1 FR:6 SS:5",
	"maui_wowie": "Sativa | DMG:2 FR:5 SS:5",
	"acapulco_gold": "Sativa | DMG:3 FR:4 SS:5",
	"panama_red": "Sativa | DMG:2 FR:6 SS:4",
	"hindu_kush": "Indica | DMG:6 FR:2 SS:1",
	"afghan_kush": "Indica | DMG:6 FR:1 SS:2",
	"bubble_gum": "Hybrid | DMG:4 FR:4 SS:3",
	"master_kush": "Indica | DMG:5 FR:3 SS:2",
	"cheese": "Hybrid | DMG:4 FR:3 SS:4",
	"nyc_diesel": "Sativa | DMG:3 FR:5 SS:4",
	"sour_diesel": "Sativa | DMG:2 FR:6 SS:4",
	"strawberry_cough": "Sativa | DMG:3 FR:5 SS:4",
	"super_silver_haze": "Sativa | DMG:2 FR:5 SS:6",
	"lemon_haze": "Sativa | DMG:1 FR:6 SS:6",
	"amnesia_haze": "Sativa | DMG:2 FR:6 SS:5",
	"orange_bud": "Hybrid | DMG:4 FR:4 SS:3",
	"critical_mass": "Indica | DMG:5 FR:3 SS:2",
	"power_plant": "Sativa | DMG:3 FR:5 SS:4",
	"girl_scout_cookies": "Hybrid | DMG:6 FR:5 SS:6",
	"gorilla_glue_4": "Hybrid | DMG:7 FR:5 SS:5",
	"og_kush": "Indica | DMG:8 FR:3 SS:4",
	"wedding_cake": "Hybrid | DMG:6 FR:6 SS:5",
	"gelato_33": "Hybrid | DMG:5 FR:7 SS:5",
	"zkittlez": "Indica | DMG:7 FR:4 SS:4",
	"runtz": "Hybrid | DMG:6 FR:6 SS:6",
	"purple_punch": "Indica | DMG:8 FR:2 SS:4",
	"blue_cheese": "Indica | DMG:7 FR:4 SS:3",
	"granddaddy_purple": "Indica | DMG:8 FR:3 SS:3",
	"chemdawg": "Hybrid | DMG:6 FR:6 SS:5",
	"green_crack": "Sativa | DMG:3 FR:8 SS:7",
	"bruce_banner": "Hybrid | DMG:7 FR:6 SS:5",
	"ghost_train_haze": "Sativa | DMG:4 FR:8 SS:7",
	"trainwreck": "Hybrid | DMG:6 FR:5 SS:6",
	"alaskan_thunderfuck": "Sativa | DMG:3 FR:7 SS:8",
	"skywalker_og": "Indica | DMG:8 FR:4 SS:3",
	"bubba_kush": "Indica | DMG:8 FR:3 SS:3",
	"death_star": "Indica | DMG:9 FR:2 SS:3",
	"headband": "Hybrid | DMG:6 FR:6 SS:5",
	"cherry_pie": "Indica | DMG:7 FR:4 SS:4",
	"g13": "Indica | DMG:8 FR:3 SS:3",
	"white_rhino": "Indica | DMG:7 FR:4 SS:4",
	"sensi_star": "Indica | DMG:8 FR:3 SS:3",
	"kali_mist": "Sativa | DMG:3 FR:8 SS:7",
	"godfather_og": "Indica | DMG:10 FR:4 SS:4",
	"chiquita_banana": "Hybrid | DMG:8 FR:8 SS:7",
	"grease_monkey": "Indica | DMG:9 FR:5 SS:5",
	"irish_cream": "Indica | DMG:10 FR:3 SS:4",
	"bruce_banner_3": "Hybrid | DMG:8 FR:8 SS:8",
	"strawberry_banana": "Hybrid | DMG:7 FR:9 SS:7",
	"white_tahoe_cookies": "Indica | DMG:9 FR:5 SS:5",
	"emperor_cookie_dough": "Hybrid | DMG:8 FR:8 SS:8",
	"blackberry_moonrocks": "Indica | DMG:10 FR:4 SS:4",
	"quantum_kush": "Sativa | DMG:5 FR:10 SS:9",
	"amnesia_mac_ganja": "Sativa | DMG:4 FR:10 SS:10",
	"permanent_marker": "Hybrid | DMG:8 FR:9 SS:7",
	"jealousy": "Hybrid | DMG:8 FR:8 SS:8",
	"motorbreath": "Indica | DMG:10 FR:4 SS:4",
	"kush_mints": "Indica | DMG:9 FR:6 SS:4",
	"wedding_crasher": "Sativa | DMG:5 FR:9 SS:9",
	"apple_fritter": "Hybrid | DMG:8 FR:8 SS:8",
	"gmo_cookies": "Indica | DMG:10 FR:3 SS:5",
	"slurricane": "Indica | DMG:9 FR:5 SS:5",
	"mimosa": "Sativa | DMG:4 FR:9 SS:10",
	"fat_banana": "Indica | DMG:10 FR:4 SS:4",
	"royal_gorilla": "Hybrid | DMG:8 FR:8 SS:8",
	"dr_grinspoon": "Sativa | DMG:4 FR:10 SS:10",
	"shogun": "Sativa | DMG:5 FR:10 SS:9",
	"hulkberry": "Sativa | DMG:5 FR:9 SS:10",
}

const ABKUERZUNG = {
	"drucker": "DRK", "king_size": "KS",  "reispapier": "REI", "blunt":   "BLT",
	"kein":    "–",   "aktivkohle": "AK", "slim":       "SLM", "karton":  "KRT",
	"holzspitze": "HLZ", "baumwollfilter": "BAW", "schaumfilter": "SCH", "gerolltes_papier": "GP",
	"standard_tip": "STD", "extra_slim": "XSL", "long_filter": "LNG", "menthol_filter": "MNF",
	"perforiert": "PRF", "bio_filter": "BIO", "hanf_filter": "HNF",
	"dual_filter": "DUF", "korkspitze": "KRK", "keramik_tip": "KRM", "glasspitze": "GLS",
	"bambus_filter": "BAF", "triacetat": "TRI", "active_plus": "ACP",
	"gold_tip": "GLD", "kristall_filter": "KRF", "elektrostatisch": "ELS",
	"nano_filter": "NNF", "titan_tip": "TTN", "doppel_aktiv": "DAK",
	"platinspitze": "PLT", "diamantfilter": "DMF",
	"billig":  "BIL", "virginia":  "VIR", "american_spirit": "AMS", "drum": "DRM",
	"ernte_23": "E23", "losen_blatt": "LB", "burley": "BUR", "maryland_tabak": "MRY",
	"schwarzer_kraeutler": "SKR", "pfeifentabak": "PFE",
	"camel": "CAM", "lucky_strike": "LS", "gauloises": "GAU", "bali_shag": "BSH",
	"samson": "SAM", "amber_leaf": "ABL", "cavendish": "CAV",
	"dunhill": "DUN", "winston": "WIN", "old_holborn": "OLH", "mac_baren": "MCB",
	"latakia": "LAT", "perique": "PER", "gitanes": "GIT",
	"prince": "PRI", "captain_black": "CPB", "skandinavisk": "SKN",
	"condor": "CON", "toscano": "TOS", "amphora": "AMP",
	"beige_pueblo": "BPU",
	"king_size_slim": "KSS", "ungebleichtes_pape": "UBL", "king_size_regular": "KSR",
	"eins_viertel_size": "1¼", "single_wide": "SW",  "flachs_papier": "FLX",
	"inside_out": "IO",  "l_pape": "L",   "flavored_pape": "FLV", "menthol_pape": "MNT",
	"hanf_wrap": "HW",  "doppelt_gerollt": "DG", "bedrucktes_pape": "BDP", "bambus_pape": "BAM",
	"endlos_rolle": "ENR", "blunt_wrap": "BW", "zellulose_pape": "ZEL", "backwoods": "BKW",
	"maisblatt": "MBL", "palmblatt": "PBL", "vorgerollte_cone": "VGC",
	"glow_pape": "GLW", "rosenblatt": "RSB", "flash_papier": "FLP", "bananenblatt": "BNB", "lotusblatt": "LTB",
	"blattgold_24k": "24K", "dollar_note": "USD", "bibel_seite": "BIB",
}

const KURZNAME = {
	"drucker": "Druckerpapier", "king_size": "King Size",    "reispapier": "Reispapier",
	"blunt":   "Blunt",       "kein":      "Kein",          "aktivkohle": "Aktivkohle",
	"slim":    "Slim",        "karton":    "Karton",         "billig":     "Billig",
	# Filter – neu
	"holzspitze":        "Holzspitze",
	"baumwollfilter":    "Baumwollfilter",
	"schaumfilter":      "Schaumfilter",
	"gerolltes_papier":  "Gerolltes Papier",
	"standard_tip":      "Standard-Tip",
	"extra_slim":        "Extra Slim",
	"long_filter":       "Long Filter",
	"menthol_filter":    "Menthol-Filter",
	"perforiert":        "Perforiert",
	"bio_filter":        "Bio-Filter",
	"hanf_filter":       "Hanf-Filter",
	"dual_filter":       "Dual Filter",
	"korkspitze":        "Korkspitze",
	"keramik_tip":       "Keramik-Tip",
	"glasspitze":        "Glasspitze",
	"bambus_filter":     "Bambus-Filter",
	"triacetat":         "Triacetat",
	"active_plus":       "Active Plus",
	"gold_tip":          "Gold-Tip",
	"kristall_filter":   "Kristallfilter",
	"elektrostatisch":   "Elektrostatisch",
	"nano_filter":       "Nano-Filter",
	"titan_tip":         "Titan-Tip",
	"doppel_aktiv":      "Doppel-Aktiv",
	"platinspitze":      "Platinspitze",
	"diamantfilter":     "Diamantfilter",
	"virginia": "Virginia",   "american_spirit": "Am. Spirit", "drum":    "Drum",
	# Tabak – neu
	"ernte_23":            "Ernte 23",
	"losen_blatt":         "Losen Blatt",
	"burley":              "Burley",
	"maryland_tabak":      "Maryland",
	"schwarzer_kraeutler": "Schwarzer Kräutler",
	"pfeifentabak":        "Pfeifentabak",
	"camel":               "Camel",
	"lucky_strike":        "Lucky Strike",
	"gauloises":           "Gauloises",
	"bali_shag":           "Bali Shag",
	"samson":              "Samson",
	"amber_leaf":          "Amber Leaf",
	"cavendish":           "Cavendish",
	"dunhill":             "Dunhill",
	"winston":             "Winston",
	"old_holborn":         "Old Holborn",
	"mac_baren":           "Mac Baren",
	"latakia":             "Latakia",
	"perique":             "Perique",
	"gitanes":             "Gitanes",
	"prince":              "Prince",
	"captain_black":       "Captain Black",
	"skandinavisk":        "Skandinavisk",
	"condor":              "Condor",
	"toscano":             "Toscano",
	"amphora":             "Amphora",
	"beige_pueblo":        "Beige Pueblo",
	# Papes – neu
	"king_size_slim":    "KS Slim",
	"ungebleichtes_pape": "Ungebleicht",
	"king_size_regular": "KS Regular",
	"eins_viertel_size": "1¼ Size",
	"single_wide":       "Single Wide",
	"flachs_papier":     "Flachs-Papier",
	"inside_out":        "Inside-Out",
	"l_pape":            "L-Pape",
	"flavored_pape":     "Flavored Pape",
	"menthol_pape":      "Menthol-Pape",
	"hanf_wrap":         "Hanf-Wrap",
	"doppelt_gerollt":   "Doppelt gerollt",
	"bedrucktes_pape":   "Bedrucktes Pape",
	"bambus_pape":       "Bambus-Pape",
	"endlos_rolle":      "Endlos-Rolle",
	"blunt_wrap":        "Blunt Wrap",
	"zellulose_pape":    "Zellulose-Pape",
	"backwoods":         "Backwoods",
	"maisblatt":         "Maisblatt",
	"palmblatt":         "Palmblatt",
	"vorgerollte_cone":  "Vorgerollte Cone",
	"glow_pape":         "Glow-in-Dark",
	"rosenblatt":        "Rosenblatt",
	"flash_papier":      "Flash-Papier",
	"bananenblatt":      "Bananenblatt",
	"lotusblatt":        "Lotusblatt",
	"blattgold_24k":     "24k Blattgold",
	"dollar_note":       "Dollar-Note",
	"bibel_seite":       "Bibel-Seite",
	# Weed – generiert aus WEED_DATEN (Kurzname via global_data.WEED_DATEN)
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

# Farbe je Seltenheit
const SELTENHEIT_FARBE = {
	# Papes
	"drucker":           Color(0.55, 0.55, 0.55),  # grau  – gewöhnlich
	"reispapier":        Color(0.2,  0.75, 0.2),   # grün  – ungewöhnlich
	"king_size":         Color(0.2,  0.45, 1.0),   # blau  – selten
	"blunt":             Color(0.65, 0.1,  0.9),   # lila  – episch
	"king_size_slim":    Color(0.55, 0.55, 0.55),
	"ungebleichtes_pape": Color(0.55, 0.55, 0.55),
	"king_size_regular": Color(0.55, 0.55, 0.55),
	"eins_viertel_size": Color(0.55, 0.55, 0.55),
	"single_wide":       Color(0.55, 0.55, 0.55),
	"flachs_papier":     Color(0.55, 0.55, 0.55),
	"inside_out":        Color(0.2,  0.75, 0.2),
	"l_pape":            Color(0.2,  0.75, 0.2),
	"flavored_pape":     Color(0.2,  0.75, 0.2),
	"menthol_pape":      Color(0.2,  0.75, 0.2),
	"hanf_wrap":         Color(0.2,  0.75, 0.2),
	"doppelt_gerollt":   Color(0.2,  0.75, 0.2),
	"bedrucktes_pape":   Color(0.2,  0.75, 0.2),
	"bambus_pape":       Color(0.2,  0.75, 0.2),
	"endlos_rolle":      Color(0.2,  0.45, 1.0),
	"blunt_wrap":        Color(0.2,  0.45, 1.0),
	"zellulose_pape":    Color(0.2,  0.45, 1.0),
	"backwoods":         Color(0.2,  0.45, 1.0),
	"maisblatt":         Color(0.2,  0.45, 1.0),
	"palmblatt":         Color(0.2,  0.45, 1.0),
	"vorgerollte_cone":  Color(0.2,  0.45, 1.0),
	"glow_pape":         Color(0.65, 0.1,  0.9),
	"rosenblatt":        Color(0.65, 0.1,  0.9),
	"flash_papier":      Color(0.65, 0.1,  0.9),
	"bananenblatt":      Color(0.65, 0.1,  0.9),
	"lotusblatt":        Color(0.65, 0.1,  0.9),
	"blattgold_24k":     Color(1.0,  0.82, 0.1),
	"dollar_note":       Color(1.0,  0.82, 0.1),
	"bibel_seite":       Color(1.0,  0.82, 0.1),
	# Filter
	"kein":              Color(0.55, 0.55, 0.55),
	"holzspitze":        Color(0.55, 0.55, 0.55),
	"baumwollfilter":    Color(0.55, 0.55, 0.55),
	"schaumfilter":      Color(0.55, 0.55, 0.55),
	"gerolltes_papier":  Color(0.55, 0.55, 0.55),
	"standard_tip":      Color(0.55, 0.55, 0.55),
	"slim":              Color(0.2,  0.75, 0.2),
	"extra_slim":        Color(0.2,  0.75, 0.2),
	"long_filter":       Color(0.2,  0.75, 0.2),
	"menthol_filter":    Color(0.2,  0.75, 0.2),
	"perforiert":        Color(0.2,  0.75, 0.2),
	"bio_filter":        Color(0.2,  0.75, 0.2),
	"hanf_filter":       Color(0.2,  0.75, 0.2),
	"aktivkohle":        Color(0.2,  0.45, 1.0),
	"dual_filter":       Color(0.2,  0.45, 1.0),
	"korkspitze":        Color(0.2,  0.45, 1.0),
	"keramik_tip":       Color(0.2,  0.45, 1.0),
	"glasspitze":        Color(0.2,  0.45, 1.0),
	"bambus_filter":     Color(0.2,  0.45, 1.0),
	"triacetat":         Color(0.2,  0.45, 1.0),
	"active_plus":       Color(0.2,  0.45, 1.0),
	"karton":            Color(0.65, 0.1,  0.9),
	"gold_tip":          Color(0.65, 0.1,  0.9),
	"kristall_filter":   Color(0.65, 0.1,  0.9),
	"elektrostatisch":   Color(0.65, 0.1,  0.9),
	"nano_filter":       Color(0.65, 0.1,  0.9),
	"titan_tip":         Color(0.65, 0.1,  0.9),
	"doppel_aktiv":      Color(0.65, 0.1,  0.9),
	"platinspitze":      Color(1.0,  0.82, 0.1),
	"diamantfilter":     Color(1.0,  0.82, 0.1),
	# Tabak
	"billig":            Color(0.55, 0.55, 0.55),
	"ernte_23":          Color(0.55, 0.55, 0.55),
	"losen_blatt":       Color(0.55, 0.55, 0.55),
	"burley":            Color(0.55, 0.55, 0.55),
	"maryland_tabak":    Color(0.55, 0.55, 0.55),
	"schwarzer_kraeutler": Color(0.55, 0.55, 0.55),
	"pfeifentabak":      Color(0.55, 0.55, 0.55),
	"virginia":          Color(0.2,  0.75, 0.2),
	"camel":             Color(0.2,  0.75, 0.2),
	"lucky_strike":      Color(0.2,  0.75, 0.2),
	"gauloises":         Color(0.2,  0.75, 0.2),
	"bali_shag":         Color(0.2,  0.75, 0.2),
	"samson":            Color(0.2,  0.75, 0.2),
	"amber_leaf":        Color(0.2,  0.75, 0.2),
	"cavendish":         Color(0.2,  0.75, 0.2),
	"american_spirit":   Color(0.2,  0.45, 1.0),
	"dunhill":           Color(0.2,  0.45, 1.0),
	"winston":           Color(0.2,  0.45, 1.0),
	"old_holborn":       Color(0.2,  0.45, 1.0),
	"mac_baren":         Color(0.2,  0.45, 1.0),
	"latakia":           Color(0.2,  0.45, 1.0),
	"perique":           Color(0.2,  0.45, 1.0),
	"gitanes":           Color(0.2,  0.45, 1.0),
	"drum":              Color(0.65, 0.1,  0.9),
	"prince":            Color(0.65, 0.1,  0.9),
	"captain_black":     Color(0.65, 0.1,  0.9),
	"skandinavisk":      Color(0.65, 0.1,  0.9),
	"condor":            Color(0.65, 0.1,  0.9),
	"toscano":           Color(0.65, 0.1,  0.9),
	"amphora":           Color(0.65, 0.1,  0.9),
	"beige_pueblo":      Color(1.0,  0.82, 0.1),
	# Weed – Gewöhnlich
	"buschgras": Color(0.55, 0.55, 0.55),
	"harlequin": Color(0.55, 0.55, 0.55), "ac_dc": Color(0.55, 0.55, 0.55),
	"cannatonic": Color(0.55, 0.55, 0.55), "charlottes_web": Color(0.55, 0.55, 0.55),
	"solodiol": Color(0.55, 0.55, 0.55), "finola": Color(0.55, 0.55, 0.55),
	"fedora": Color(0.55, 0.55, 0.55), "santhica": Color(0.55, 0.55, 0.55),
	"one_to_one": Color(0.55, 0.55, 0.55), "fast_eddy": Color(0.55, 0.55, 0.55),
	"royal_medic": Color(0.55, 0.55, 0.55), "pennywise": Color(0.55, 0.55, 0.55),
	"sour_tsunami": Color(0.55, 0.55, 0.55), "ringos_gift": Color(0.55, 0.55, 0.55),
	"remedium": Color(0.55, 0.55, 0.55), "medihaze": Color(0.55, 0.55, 0.55),
	"zen": Color(0.55, 0.55, 0.55), "compassion": Color(0.55, 0.55, 0.55),
	"sierra": Color(0.55, 0.55, 0.55), "dancehall": Color(0.55, 0.55, 0.55),
	"tatanka": Color(0.55, 0.55, 0.55), "joannes_cbd": Color(0.55, 0.55, 0.55),
	"royal_highness": Color(0.55, 0.55, 0.55), "euphoria": Color(0.55, 0.55, 0.55),
	"medical_mass": Color(0.55, 0.55, 0.55),
	"northern_lights": Color(0.55, 0.55, 0.55), "blue_dream": Color(0.55, 0.55, 0.55),
	"white_widow": Color(0.55, 0.55, 0.55), "ak_47": Color(0.55, 0.55, 0.55),
	"jack_herer": Color(0.55, 0.55, 0.55),
	# Weed – Ungewöhnlich
	"skunk_1": Color(0.2, 0.75, 0.2), "blueberry": Color(0.2, 0.75, 0.2),
	"durban_poison": Color(0.2, 0.75, 0.2), "maui_wowie": Color(0.2, 0.75, 0.2),
	"acapulco_gold": Color(0.2, 0.75, 0.2), "panama_red": Color(0.2, 0.75, 0.2),
	"hindu_kush": Color(0.2, 0.75, 0.2), "afghan_kush": Color(0.2, 0.75, 0.2),
	"bubble_gum": Color(0.2, 0.75, 0.2), "master_kush": Color(0.2, 0.75, 0.2),
	"cheese": Color(0.2, 0.75, 0.2), "nyc_diesel": Color(0.2, 0.75, 0.2),
	"sour_diesel": Color(0.2, 0.75, 0.2), "strawberry_cough": Color(0.2, 0.75, 0.2),
	"super_silver_haze": Color(0.2, 0.75, 0.2), "lemon_haze": Color(0.2, 0.75, 0.2),
	"amnesia_haze": Color(0.2, 0.75, 0.2), "orange_bud": Color(0.2, 0.75, 0.2),
	"critical_mass": Color(0.2, 0.75, 0.2), "power_plant": Color(0.2, 0.75, 0.2),
	"girl_scout_cookies": Color(0.2, 0.75, 0.2), "gorilla_glue_4": Color(0.2, 0.75, 0.2),
	"og_kush": Color(0.2, 0.75, 0.2), "wedding_cake": Color(0.2, 0.75, 0.2),
	"gelato_33": Color(0.2, 0.75, 0.2),
	# Weed – Selten
	"zkittlez": Color(0.2, 0.45, 1.0), "runtz": Color(0.2, 0.45, 1.0),
	"purple_punch": Color(0.2, 0.45, 1.0), "blue_cheese": Color(0.2, 0.45, 1.0),
	"granddaddy_purple": Color(0.2, 0.45, 1.0), "chemdawg": Color(0.2, 0.45, 1.0),
	"green_crack": Color(0.2, 0.45, 1.0), "bruce_banner": Color(0.2, 0.45, 1.0),
	"ghost_train_haze": Color(0.2, 0.45, 1.0), "trainwreck": Color(0.2, 0.45, 1.0),
	"alaskan_thunderfuck": Color(0.2, 0.45, 1.0), "skywalker_og": Color(0.2, 0.45, 1.0),
	"bubba_kush": Color(0.2, 0.45, 1.0), "death_star": Color(0.2, 0.45, 1.0),
	"headband": Color(0.2, 0.45, 1.0), "cherry_pie": Color(0.2, 0.45, 1.0),
	"g13": Color(0.2, 0.45, 1.0), "white_rhino": Color(0.2, 0.45, 1.0),
	"sensi_star": Color(0.2, 0.45, 1.0), "kali_mist": Color(0.2, 0.45, 1.0),
	# Weed – Episch
	"godfather_og": Color(0.65, 0.1, 0.9), "chiquita_banana": Color(0.65, 0.1, 0.9),
	"grease_monkey": Color(0.65, 0.1, 0.9), "irish_cream": Color(0.65, 0.1, 0.9),
	"bruce_banner_3": Color(0.65, 0.1, 0.9), "strawberry_banana": Color(0.65, 0.1, 0.9),
	"white_tahoe_cookies": Color(0.65, 0.1, 0.9), "emperor_cookie_dough": Color(0.65, 0.1, 0.9),
	"blackberry_moonrocks": Color(0.65, 0.1, 0.9), "quantum_kush": Color(0.65, 0.1, 0.9),
	"amnesia_mac_ganja": Color(0.65, 0.1, 0.9), "permanent_marker": Color(0.65, 0.1, 0.9),
	"jealousy": Color(0.65, 0.1, 0.9), "motorbreath": Color(0.65, 0.1, 0.9),
	"kush_mints": Color(0.65, 0.1, 0.9),
	# Weed – Legendär
	"wedding_crasher": Color(1.0, 0.82, 0.1), "apple_fritter": Color(1.0, 0.82, 0.1),
	"gmo_cookies": Color(1.0, 0.82, 0.1), "slurricane": Color(1.0, 0.82, 0.1),
	"mimosa": Color(1.0, 0.82, 0.1), "fat_banana": Color(1.0, 0.82, 0.1),
	"royal_gorilla": Color(1.0, 0.82, 0.1), "dr_grinspoon": Color(1.0, 0.82, 0.1),
	"shogun": Color(1.0, 0.82, 0.1), "hulkberry": Color(1.0, 0.82, 0.1),
}

var ausgewaehlter_slot = 0
var spieler = null
var letztes_delta = {}
var bonus_bei_oeffnen = {}

func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("crafting_menue")

func _unhandled_input(event):
	if not (event is InputEventKey and event.pressed):
		return
	if not visible:
		if event.keycode == KEY_TAB:
			_oeffnen()
		return
	match event.keycode:
		KEY_TAB:
			_schliessen()
		KEY_W:
			ausgewaehlter_slot = (ausgewaehlter_slot - 1 + SLOT_NAMEN.size()) % SLOT_NAMEN.size()
			queue_redraw()
		KEY_S:
			ausgewaehlter_slot = (ausgewaehlter_slot + 1) % SLOT_NAMEN.size()
			queue_redraw()
		KEY_A:
			_komponente_wechseln(-1)
		KEY_D:
			_komponente_wechseln(1)

func _oeffnen():
	if get_tree().get_nodes_in_group("gegner").size() > 0:
		return
	spieler = get_tree().get_first_node_in_group("spieler")
	letztes_delta = {}
	bonus_bei_oeffnen = global_data.komponenten_bonus.duplicate()
	visible = true
	get_tree().paused = true
	queue_redraw()

func _schliessen():
	_effekte_anwenden()
	visible = false
	get_tree().paused = false

func _komponente_wechseln(richtung):
	var slot = SLOT_NAMEN[ausgewaehlter_slot]
	var inv = global_data.inventar.get(slot, [])
	if inv.size() <= 1:
		return
	var aktuell = global_data.joint_komponenten[slot]
	var idx = inv.find(aktuell)
	idx = (idx + richtung + inv.size()) % inv.size()
	global_data.joint_komponenten[slot] = inv[idx]
	_delta_berechnen()
	queue_redraw()

func _berechne_bonus() -> Dictionary:
	var b = {
		"schaden": 0, "geschwindigkeit": 0.0, "reichweite": 0,
		"schuss_tempo": 0, "projektil_groesse": 0.0, "glueck": 0,
		"max_hp": 0, "unverwundbar_dauer": 0.0,
		"pierce": false, "feuerrate_mult": 1.0,
	}
	match global_data.joint_komponenten.get("papes", "drucker"):
		"reispapier":        b["feuerrate_mult"] *= 0.9
		"king_size":         b["reichweite"] += 100
		"blunt":             b["schaden"] += 1; b["projektil_groesse"] += 0.3
		# Gewöhnlich
		"king_size_slim":    b["reichweite"] += 50
		"ungebleichtes_pape": b["glueck"] += 1
		"king_size_regular": b["reichweite"] += 75
		"eins_viertel_size": b["feuerrate_mult"] *= 0.95
		"single_wide":       b["schuss_tempo"] += 20
		"flachs_papier":     b["geschwindigkeit"] += 20.0
		# Ungewöhnlich
		"inside_out":        b["pierce"] = true
		"l_pape":            b["reichweite"] += 150
		"flavored_pape":     b["glueck"] += 2
		"menthol_pape":      b["schuss_tempo"] += 50
		"hanf_wrap":         b["schaden"] += 1
		"doppelt_gerollt":   b["projektil_groesse"] += 0.2; b["schaden"] += 1
		"bedrucktes_pape":   b["glueck"] += 2
		"bambus_pape":       b["feuerrate_mult"] *= 0.88
		# Selten
		"endlos_rolle":      b["feuerrate_mult"] *= 0.82; b["reichweite"] += 80
		"blunt_wrap":        b["schaden"] += 2; b["projektil_groesse"] += 0.2
		"zellulose_pape":    b["pierce"] = true; b["schuss_tempo"] += 30
		"backwoods":         b["schaden"] += 2; b["projektil_groesse"] += 0.4
		"maisblatt":         b["glueck"] += 3; b["geschwindigkeit"] += 30.0
		"palmblatt":         b["reichweite"] += 200
		"vorgerollte_cone":  b["feuerrate_mult"] *= 0.80
		# Episch
		"glow_pape":         b["glueck"] += 4; b["schuss_tempo"] += 60
		"rosenblatt":        b["schuss_tempo"] += 100; b["feuerrate_mult"] *= 0.85
		"flash_papier":      b["feuerrate_mult"] *= 0.70
		"bananenblatt":      b["schaden"] += 3; b["projektil_groesse"] += 0.5
		"lotusblatt":        b["schaden"] += 2; b["geschwindigkeit"] += 50.0; b["glueck"] += 2
		# Legendär
		"blattgold_24k":     b["schaden"] += 4; b["glueck"] += 4; b["projektil_groesse"] += 0.5
		"dollar_note":       b["schaden"] += 3; b["reichweite"] += 200; b["schuss_tempo"] += 80
		"bibel_seite":       b["schaden"] += 5; b["max_hp"] += 1; b["glueck"] += 5
	match global_data.joint_komponenten.get("filter", "kein"):
		# Gewöhnlich
		"holzspitze":        b["glueck"] += 1
		"baumwollfilter":    b["feuerrate_mult"] *= 0.97
		"schaumfilter":      b["schuss_tempo"] += 15
		"gerolltes_papier":  b["reichweite"] += 30
		"standard_tip":      b["geschwindigkeit"] += 10.0
		# Ungewöhnlich
		"slim":              b["glueck"] += 1
		"extra_slim":        b["glueck"] += 2
		"long_filter":       b["reichweite"] += 80
		"menthol_filter":    b["schuss_tempo"] += 40; b["geschwindigkeit"] += 20.0
		"perforiert":        b["feuerrate_mult"] *= 0.92
		"bio_filter":        b["glueck"] += 2
		"hanf_filter":       b["schaden"] += 1; b["glueck"] += 1
		# Selten
		"aktivkohle":        b["pierce"] = true
		"dual_filter":       b["pierce"] = true; b["feuerrate_mult"] *= 0.95
		"korkspitze":        b["schaden"] += 2; b["reichweite"] += 60
		"keramik_tip":       b["schuss_tempo"] += 60; b["projektil_groesse"] += 0.2
		"glasspitze":        b["pierce"] = true; b["schuss_tempo"] += 30
		"bambus_filter":     b["glueck"] += 3; b["geschwindigkeit"] += 30.0
		"triacetat":         b["feuerrate_mult"] *= 0.85; b["reichweite"] += 80
		"active_plus":       b["schaden"] += 2; b["glueck"] += 2
		# Episch
		"karton":            b["schuss_tempo"] += 50
		"gold_tip":          b["glueck"] += 4; b["schaden"] += 2
		"kristall_filter":   b["pierce"] = true; b["schaden"] += 3; b["projektil_groesse"] += 0.3
		"elektrostatisch":   b["feuerrate_mult"] *= 0.75; b["schuss_tempo"] += 50
		"nano_filter":       b["schuss_tempo"] += 80; b["geschwindigkeit"] += 40.0
		"titan_tip":         b["schaden"] += 4; b["projektil_groesse"] += 0.4
		"doppel_aktiv":      b["pierce"] = true; b["glueck"] += 3; b["feuerrate_mult"] *= 0.82
		# Legendär
		"platinspitze":      b["schaden"] += 4; b["glueck"] += 5; b["reichweite"] += 150; b["schuss_tempo"] += 60
		"diamantfilter":     b["pierce"] = true; b["schaden"] += 5; b["projektil_groesse"] += 0.6; b["glueck"] += 4
	match global_data.joint_komponenten.get("tabak", "billig"):
		# Gewöhnlich
		"ernte_23":            b["geschwindigkeit"] += 15.0
		"losen_blatt":         b["schuss_tempo"] += 15
		"burley":              b["schaden"] += 1
		"maryland_tabak":      b["feuerrate_mult"] *= 0.97
		"schwarzer_kraeutler": b["glueck"] += 1
		"pfeifentabak":        b["reichweite"] += 40
		# Ungewöhnlich
		"virginia":            b["geschwindigkeit"] += 40.0
		"camel":               b["schaden"] += 1; b["schuss_tempo"] += 20
		"lucky_strike":        b["feuerrate_mult"] *= 0.93; b["schuss_tempo"] += 25
		"gauloises":           b["schaden"] += 2; b["geschwindigkeit"] -= 15.0
		"bali_shag":           b["feuerrate_mult"] *= 0.92
		"samson":              b["geschwindigkeit"] += 50.0
		"amber_leaf":          b["glueck"] += 2; b["reichweite"] += 50
		"cavendish":           b["schuss_tempo"] += 40; b["projektil_groesse"] += 0.15
		# Selten
		"american_spirit":     b["geschwindigkeit"] += 50.0; b["reichweite"] += 50
		"dunhill":             b["schaden"] += 2; b["reichweite"] += 75
		"winston":             b["schaden"] += 2; b["schuss_tempo"] += 40
		"old_holborn":         b["feuerrate_mult"] *= 0.85; b["schaden"] += 2
		"mac_baren":           b["geschwindigkeit"] += 60.0; b["glueck"] += 2
		"latakia":             b["schaden"] += 3; b["projektil_groesse"] += 0.3; b["geschwindigkeit"] -= 20.0
		"perique":             b["glueck"] += 3; b["feuerrate_mult"] *= 0.88
		"gitanes":             b["schaden"] += 2; b["feuerrate_mult"] *= 0.87
		# Episch
		"drum":                b["schaden"] += 2; b["geschwindigkeit"] -= 30.0
		"prince":              b["schaden"] += 3; b["reichweite"] += 100; b["schuss_tempo"] += 50
		"captain_black":       b["schaden"] += 3; b["projektil_groesse"] += 0.4; b["glueck"] += 2
		"skandinavisk":        b["feuerrate_mult"] *= 0.78; b["schaden"] += 3
		"condor":              b["schaden"] += 4; b["geschwindigkeit"] -= 20.0; b["projektil_groesse"] += 0.3
		"toscano":             b["schaden"] += 4; b["max_hp"] += 1; b["geschwindigkeit"] -= 10.0
		"amphora":             b["schuss_tempo"] += 80; b["glueck"] += 3; b["reichweite"] += 100
		# Legendär
		"beige_pueblo":        b["schaden"] += 5; b["geschwindigkeit"] += 60.0; b["glueck"] += 4; b["reichweite"] += 150
	var _weed = global_data.joint_komponenten.get("weed", "harlequin")
	var _wd   = global_data.WEED_DATEN.get(_weed, {})
	if not _wd.is_empty():
		b["schaden"]        += _wd["damage"] - 1
		b["feuerrate_mult"] *= 1.0 - (_wd["fire_rate"] - 1) * 0.03
		b["schuss_tempo"]   += (_wd["shot_speed"] - 1) * 15
	return b

func _delta_berechnen():
	var neu = _berechne_bonus()
	var basis = bonus_bei_oeffnen
	letztes_delta = {
		"schaden":           neu["schaden"]           - basis.get("schaden", 0),
		"geschwindigkeit":   neu["geschwindigkeit"]   - basis.get("geschwindigkeit", 0.0),
		"reichweite":        neu["reichweite"]        - basis.get("reichweite", 0),
		"schuss_tempo":      neu["schuss_tempo"]      - basis.get("schuss_tempo", 0),
		"projektil_groesse": neu["projektil_groesse"] - basis.get("projektil_groesse", 0.0),
		"glueck":            neu["glueck"]            - basis.get("glueck", 0),
		"max_hp":            neu["max_hp"]            - basis.get("max_hp", 0),
		"feuerrate_mult":    neu["feuerrate_mult"]    - basis.get("feuerrate_mult", 1.0),
	}

func _effekte_anwenden():
	if not spieler:
		return
	var alt = global_data.komponenten_bonus
	var neu = _berechne_bonus()

	# Alte Boni abziehen
	spieler.schaden_bonus         -= alt["schaden"]
	spieler.geschwindigkeit_bonus -= alt["geschwindigkeit"]
	spieler.reichweite            -= alt["reichweite"]
	spieler.schuss_tempo          -= alt["schuss_tempo"]
	spieler.projektil_groesse     -= alt["projektil_groesse"]
	spieler.glueck                -= alt["glueck"]

	# Neue Boni hinzufügen
	spieler.schaden_bonus         += neu["schaden"]
	spieler.geschwindigkeit_bonus += neu["geschwindigkeit"]
	spieler.reichweite            += neu["reichweite"]
	spieler.schuss_tempo          += neu["schuss_tempo"]
	spieler.projektil_groesse     += neu["projektil_groesse"]
	spieler.glueck                += neu["glueck"]

	# Max HP: Differenz anwenden
	var hp_diff = neu["max_hp"] - alt["max_hp"]
	spieler.max_hp += hp_diff
	if hp_diff > 0:
		spieler.hp = min(spieler.hp + hp_diff, spieler.max_hp)
	else:
		spieler.hp = min(spieler.hp, spieler.max_hp)

	# Pierce & Feuerrate & Unverwundbarkeit
	spieler.pierce = neu["pierce"]
	spieler.unverwundbar_dauer_bonus = neu["unverwundbar_dauer"]
	spieler.schuss_cooldown = spieler.SCHUSS_COOLDOWN_BASIS * neu["feuerrate_mult"]

	global_data.komponenten_bonus = neu

# ── Zeichnen ──────────────────────────────────────────────────────────────────

func _draw():
	var font = ThemeDB.fallback_font

	draw_rect(Rect2(0, 0, 1280, 720), Color(0.08, 0.08, 0.1, 1.0))

	draw_line(Vector2(450, 80), Vector2(450, 660), Color(0.3, 0.3, 0.3), 1)
	draw_line(Vector2(830, 80), Vector2(830, 660), Color(0.3, 0.3, 0.3), 1)

	draw_string(font, Vector2(0, 50), "BAUBOX",
		HORIZONTAL_ALIGNMENT_CENTER, 1280, 32, Color(1.0, 0.82, 0.1))

	_draw_komponenten(font)
	_draw_vorschau(font)
	_draw_effekte(font)

	draw_string(font, Vector2(0, 690), "[TAB] Schließen    [W/S] Slot wählen    [A/D] Wechseln",
		HORIZONTAL_ALIGNMENT_CENTER, 1280, 14, Color(0.45, 0.45, 0.45))

func _draw_komponenten(font):
	draw_string(font, Vector2(60, 100), "KOMPONENTEN",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(0.6, 0.6, 0.6))

	# ── Kompakte Slot-Liste ──
	for i in SLOT_NAMEN.size():
		var slot  = SLOT_NAMEN[i]
		var wert  = global_data.joint_komponenten.get(slot, "-")
		var y_mid = 155 + i * 82

		var ausgewaehlt = (i == ausgewaehlter_slot)
		if ausgewaehlt:
			draw_rect(Rect2(55, y_mid - 26, 380, 52), Color(0.2, 0.2, 0.25, 1.0))
			draw_rect(Rect2(55, y_mid - 26, 380, 52), Color(1.0, 0.82, 0.1, 0.8), false, 1.5)

		var label_farbe = Color(1.0, 0.82, 0.1) if ausgewaehlt else Color(0.7, 0.7, 0.7)
		draw_string(font, Vector2(75, y_mid - 8), SLOT_LABELS[i] + ":",
			HORIZONTAL_ALIGNMENT_LEFT, -1, 14, label_farbe)

		var sel_farbe = SELTENHEIT_FARBE.get(wert, Color(0.55, 0.55, 0.55))
		draw_string(font, Vector2(75, y_mid + 16), KURZNAME.get(wert, wert),
			HORIZONTAL_ALIGNMENT_LEFT, -1, 16,
			Color(1.0, 1.0, 1.0) if ausgewaehlt else sel_farbe)

	# ── Trennlinie ──
	const TRENN_Y = 500.0
	draw_line(Vector2(55, TRENN_Y), Vector2(435, TRENN_Y), Color(0.25, 0.25, 0.25), 1)
	draw_string(font, Vector2(60, TRENN_Y - 9), "VERFÜGBAR",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.5, 0.5, 0.5))

	_draw_slot_icons(font)

func _draw_slot_icons(font):
	var slot    = SLOT_NAMEN[ausgewaehlter_slot]
	var inv     = global_data.inventar.get(slot, [])
	var aktuell = global_data.joint_komponenten.get(slot, "")

	const ICON_R   = 22.0
	const ICON_ABT = 58.0
	const ICON_Y   = 548.0
	const NAME_Y   = ICON_Y + ICON_R + 18.0
	const PANEL_MX = 245.0   # Mitte des linken Panels (55 + 380/2)

	var start_x = PANEL_MX - (inv.size() - 1) * ICON_ABT / 2.0

	for i in inv.size():
		var komp       = inv[i]
		var cx         = start_x + i * ICON_ABT
		var ausgewaehlt = (komp == aktuell)
		var farbe      = SELTENHEIT_FARBE.get(komp, Color(0.5, 0.5, 0.5))

		# Gefüllter Kreis – abgedunkelt wenn nicht ausgewählt
		draw_circle(Vector2(cx, ICON_Y), ICON_R, farbe * (1.0 if ausgewaehlt else 0.28))

		# Rand
		if ausgewaehlt:
			draw_arc(Vector2(cx, ICON_Y), ICON_R + 4.0, 0, TAU, 32,
				Color(1.0, 0.82, 0.1, 1.0), 2.5)
		else:
			draw_arc(Vector2(cx, ICON_Y), ICON_R, 0, TAU, 32, farbe * 0.75, 1.5)

		# Abkürzung zentriert im Kreis
		var abk = ABKUERZUNG.get(komp, komp.substr(0, 3).to_upper())
		draw_string(font, Vector2(cx - ICON_R, ICON_Y + 5), abk,
			HORIZONTAL_ALIGNMENT_CENTER, ICON_R * 2, 10,
			Color(1.0, 1.0, 1.0) if ausgewaehlt else Color(0.6, 0.6, 0.6))

		# Kurzname nur unter dem ausgewählten Icon
		if ausgewaehlt:
			draw_string(font, Vector2(cx - 40.0, NAME_Y), KURZNAME.get(komp, komp),
				HORIZONTAL_ALIGNMENT_CENTER, 80.0, 10, Color(1.0, 0.82, 0.1))

# ── Vorschau ──────────────────────────────────────────────────────────────────

func _draw_vorschau(font):
	draw_string(font, Vector2(830, 100), "VORSCHAU",
		HORIZONTAL_ALIGNMENT_CENTER, 450, 15, Color(0.6, 0.6, 0.6))

	var form = global_data.joint_form

	var form_text = {"normal": "Normal", "kreuz": "Kreuz", "lform": "L-Form"}.get(form, form)
	draw_string(font, Vector2(830, 630), form_text,
		HORIZONTAL_ALIGNMENT_CENTER, 450, 15, Color(0.5, 0.5, 0.5))

	# Aufgeklappter Joint: fixe Füllfarben + Seltenheits-Umrandung je Lage
	const BASE      = Vector2(1055.0, 570.0)
	const JL        = 340.0
	const DIR       = Vector2.UP
	const FILTER_H  = 60.0
	# Reihenfolge außen → innen: Papes | Tabak | Weed/Filter
	# Ring je 1.5px sichtbar (WR - WF = 3)
	const WR_PAPES  = 69.0
	const WF_PAPES  = 66.0
	const WR_TABAK  = 45.0
	const WF_TABAK  = 42.0
	const WR_WEED   = 23.0
	const WF_WEED   = 20.0

	# Seltenheitsfarben (Umrandung)
	var r_papes  = SELTENHEIT_FARBE.get(global_data.joint_komponenten.get("papes",  "drucker"),   Color(0.55, 0.55, 0.55))
	var r_tabak  = SELTENHEIT_FARBE.get(global_data.joint_komponenten.get("tabak",  "billig"),    Color(0.55, 0.55, 0.55))
	var r_weed   = SELTENHEIT_FARBE.get(global_data.joint_komponenten.get("weed",   "buschgras"), Color(0.55, 0.55, 0.55))
	var r_filter = SELTENHEIT_FARBE.get(global_data.joint_komponenten.get("filter", "kein"),      Color(0.55, 0.55, 0.55))

	# Fixe Füllfarben
	const C_PAPES  = Color(1.00, 1.00, 1.00, 0.90)  # weiß
	const C_TABAK  = Color(0.42, 0.22, 0.06, 1.00)  # dunkelbraun
	const C_WEED   = Color(0.15, 0.62, 0.10, 1.00)  # grün
	const C_FILTER = Color(1.00, 1.00, 1.00, 1.00)  # weiß

	var weed_start = BASE + DIR * FILTER_H

	match form:
		"normal":
			var tip = BASE + DIR * JL
			draw_line(BASE,       tip,        r_papes,  WR_PAPES)
			draw_line(BASE,       tip,        C_PAPES,  WF_PAPES)
			draw_line(weed_start, tip,        r_tabak,  WR_TABAK)
			draw_line(weed_start, tip,        C_TABAK,  WF_TABAK)
			draw_line(weed_start, tip,        r_weed,   WR_WEED)
			draw_line(weed_start, tip,        C_WEED,   WF_WEED)
			draw_line(BASE,       weed_start, r_filter, WR_WEED)
			draw_line(BASE,       weed_start, C_FILTER, WF_WEED)

		"kreuz":
			var tip    = BASE + DIR * JL
			var quer   = BASE + DIR * (JL * 0.65)
			var links  = quer + DIR.rotated(-PI / 2.0) * (JL * 0.4)
			var rechts = quer + DIR.rotated( PI / 2.0) * (JL * 0.4)
			# Papes (ganzer Joint)
			draw_line(BASE,  tip,    r_papes, WR_PAPES)
			draw_line(links, rechts, r_papes, WR_PAPES)
			draw_line(BASE,  tip,    C_PAPES, WF_PAPES)
			draw_line(links, rechts, C_PAPES, WF_PAPES)
			# Tabak (nur ab weed_start)
			draw_line(weed_start, tip,    r_tabak, WR_TABAK)
			draw_line(links,      rechts, r_tabak, WR_TABAK)
			draw_line(weed_start, tip,    C_TABAK, WF_TABAK)
			draw_line(links,      rechts, C_TABAK, WF_TABAK)
			# Weed
			draw_line(weed_start, tip,    r_weed, WR_WEED)
			draw_line(links,      rechts, r_weed, WR_WEED)
			draw_line(weed_start, tip,    C_WEED, WF_WEED)
			draw_line(links,      rechts, C_WEED, WF_WEED)
			# Filter
			draw_line(BASE, weed_start, r_filter, WR_WEED)
			draw_line(BASE, weed_start, C_FILTER, WF_WEED)

		"lform":
			var knick = BASE + DIR * (JL * 0.55)
			var tip   = knick + DIR.rotated(PI / 4.0) * (JL * 0.55)
			# Segment 1: gerade nach oben – Papes ganz, Tabak nur ab weed_start
			draw_line(BASE,       knick, r_papes,  WR_PAPES)
			draw_line(BASE,       knick, C_PAPES,  WF_PAPES)
			draw_line(weed_start, knick, r_tabak,  WR_TABAK)
			draw_line(weed_start, knick, C_TABAK,  WF_TABAK)
			draw_line(weed_start, knick, r_weed,   WR_WEED)
			draw_line(weed_start, knick, C_WEED,   WF_WEED)
			draw_line(BASE, weed_start,  r_filter, WR_WEED)
			draw_line(BASE, weed_start,  C_FILTER, WF_WEED)
			# Segment 2: diagonal
			draw_line(knick, tip, r_papes, WR_PAPES)
			draw_line(knick, tip, C_PAPES, WF_PAPES)
			draw_line(knick, tip, r_tabak, WR_TABAK)
			draw_line(knick, tip, C_TABAK, WF_TABAK)
			draw_line(knick, tip, r_weed,  WR_WEED)
			draw_line(knick, tip, C_WEED,  WF_WEED)
			# Knick-Übergang füllen
			draw_circle(knick, WR_PAPES / 2.0, r_papes)
			draw_circle(knick, WF_PAPES / 2.0, C_PAPES)
			draw_circle(knick, WR_TABAK / 2.0, r_tabak)
			draw_circle(knick, WF_TABAK / 2.0, C_TABAK)
			draw_circle(knick, WR_WEED  / 2.0, r_weed)
			draw_circle(knick, WF_WEED  / 2.0, C_WEED)

func _draw_gluehende_spitze(pos: Vector2):
	draw_circle(pos, 10.0, Color(1.0, 0.35, 0.0))
	draw_circle(pos,  6.0, Color(1.0, 0.75, 0.1))
	draw_circle(pos,  3.0, Color(1.0, 1.0,  0.8))

# ── Stats & Info ──────────────────────────────────────────────────────────────

func _draw_effekte(font):
	draw_string(font, Vector2(450, 100), "STATS & INFO",
		HORIZONTAL_ALIGNMENT_CENTER, 380, 15, Color(0.6, 0.6, 0.6))

	var slot  = SLOT_NAMEN[ausgewaehlter_slot]
	var wert  = global_data.joint_komponenten.get(slot, "-")
	var farbe = SELTENHEIT_FARBE.get(wert, Color(0.55, 0.55, 0.55))

	draw_string(font, Vector2(475, 160), SLOT_LABELS[ausgewaehlter_slot] + ":",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(1.0, 0.82, 0.1))

	# Weed-Slot: Typ + berechnete Boni aus WEED_DATEN anzeigen
	if slot == "weed":
		var wd  = global_data.WEED_DATEN.get(wert, {})
		var roh = BESCHREIBUNG.get(wert, "")
		if not wd.is_empty():
			var typ_teil  = roh.split(" | ")[0]   # z.B. "Indica"
			var bonusteile = []
			var dmg = wd["damage"]    - 1
			var fr  = wd["fire_rate"] - 1
			var ss  = wd["shot_speed"] - 1
			if dmg != 0: bonusteile.append("+%d Schaden" % dmg)
			if fr  != 0: bonusteile.append("Feuerrate +%d%%" % (fr * 3))
			if ss  != 0: bonusteile.append("+%d Schusstempo" % (ss * 15))
			draw_string(font, Vector2(475, 178), typ_teil,
				HORIZONTAL_ALIGNMENT_LEFT, -1, 13, farbe)
			var bonus_str = ", ".join(bonusteile) if not bonusteile.is_empty() else "Keine Boni"
			draw_string(font, Vector2(475, 196), bonus_str,
				HORIZONTAL_ALIGNMENT_LEFT, -1, 12, farbe)
		else:
			draw_string(font, Vector2(475, 182), roh,
				HORIZONTAL_ALIGNMENT_LEFT, -1, 13, farbe)
	else:
		draw_string(font, Vector2(475, 182), BESCHREIBUNG.get(wert, wert),
			HORIZONTAL_ALIGNMENT_LEFT, -1, 15, farbe)

	draw_line(Vector2(460, 210), Vector2(825, 210), Color(0.25, 0.25, 0.25), 1)

	if not spieler:
		return
	draw_string(font, Vector2(475, 235), "AKTUELLE STATS",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.5, 0.5, 0.5))

	var cl = Color(0.65, 0.65, 0.65)
	var cw = Color(1.0, 1.0, 1.0)
	var c_plus  = Color(0.2, 0.9, 0.2)
	var c_minus = Color(0.95, 0.3, 0.2)

	# [Label, Wert-String, Delta-Schlüssel, Delta-Formatierung]
	var feuerrate_delta = 0.0
	if letztes_delta.has("feuerrate_mult") and letztes_delta["feuerrate_mult"] != 0.0:
		# Negativer mult-Delta = schneller = positiver Effekt für Spieler
		feuerrate_delta = -snapped(letztes_delta["feuerrate_mult"] * (1.0 / 0.3), 0.1)

	var pierce_neu = _berechne_bonus().get("pierce", false)
	var pierce_str = "Ja" if pierce_neu else "Nein"
	var pierce_delta = 0
	if letztes_delta.has("feuerrate_mult"):  # delta wurde schon mal berechnet
		var alt_pierce = bonus_bei_oeffnen.get("pierce", false)
		if pierce_neu != alt_pierce:
			pierce_delta = 1 if pierce_neu else -1

	var stats = [
		["Schaden",       str(1 + spieler.schaden_bonus),                      letztes_delta.get("schaden", 0),            false],
		["Geschw.",       str(int(280 + spieler.geschwindigkeit_bonus)),        letztes_delta.get("geschwindigkeit", 0.0),  false],
		["Feuerrate",     str(spieler._get_feuerrate()) + "/s",                 feuerrate_delta,                            true],
		["Reichweite",    str(spieler.reichweite),                              letztes_delta.get("reichweite", 0),         false],
		["Schuss-Tempo",  str(spieler.schuss_tempo),                            letztes_delta.get("schuss_tempo", 0),       false],
		["Proj.-Größe",   str(snapped(spieler.projektil_groesse, 0.1)),         letztes_delta.get("projektil_groesse", 0.0), true],
		["Max HP",        str(spieler.max_hp),                                  letztes_delta.get("max_hp", 0),             false],
		["Glück",         str(spieler.glueck),                                  letztes_delta.get("glueck", 0),             false],
		["Durchdringen",  pierce_str,                                            pierce_delta,                               false],
	]
	for i in stats.size():
		var y     = 263 + i * 24
		var delta = stats[i][2]
		var ist_float = stats[i][3]
		draw_string(font, Vector2(475, y), stats[i][0] + ":",
			HORIZONTAL_ALIGNMENT_LEFT, -1, 14, cl)
		draw_string(font, Vector2(605, y), stats[i][1],
			HORIZONTAL_ALIGNMENT_LEFT, -1, 14, cw)
		if delta != 0 and delta != 0.0:
			var delta_str: String
			if stats[i][0] == "Durchdringen":
				delta_str = "Ja" if delta > 0 else "Nein"
			else:
				delta_str = ("+" if delta > 0 else "") + (str(snapped(float(delta), 0.1)) if ist_float else str(int(delta)))
			var delta_farbe = c_plus if delta > 0 else c_minus
			draw_string(font, Vector2(700, y), delta_str,
				HORIZONTAL_ALIGNMENT_LEFT, -1, 14, delta_farbe)
