extends Area2D

# "bitcoin", "bombe", "schluessel"
var typ = "bitcoin"
var menge = 1

func _ready():
	add_to_group("sammelbar")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("spieler"):
		match typ:
			"bitcoin":
				global_data.bitcoins += menge
			"bombe":
				global_data.bomben += menge
			"schluessel":
				global_data.schluessel += menge
		queue_free()

func _draw():
	var font = ThemeDB.fallback_font
	var halb = 18.0

	match typ:
		"bitcoin":
			draw_rect(Rect2(-halb, -halb, halb * 2, halb * 2), Color(1.0, 0.75, 0.0, 1.0))
			draw_rect(Rect2(-halb, -halb, halb * 2, halb * 2), Color(0.8, 0.55, 0.0, 1.0), false, 2.0)
			draw_string(font, Vector2(0, 7), "B", HORIZONTAL_ALIGNMENT_CENTER, -1, 18, Color(0.1, 0.05, 0.0))
		"bombe":
			draw_rect(Rect2(-halb, -halb, halb * 2, halb * 2), Color(0.25, 0.25, 0.25, 1.0))
			draw_rect(Rect2(-halb, -halb, halb * 2, halb * 2), Color(0.5, 0.5, 0.5, 1.0), false, 2.0)
			draw_string(font, Vector2(0, 7), "B!", HORIZONTAL_ALIGNMENT_CENTER, -1, 16, Color(1.0, 0.4, 0.1))
		"schluessel":
			draw_rect(Rect2(-halb, -halb, halb * 2, halb * 2), Color(0.65, 0.5, 0.15, 1.0))
			draw_rect(Rect2(-halb, -halb, halb * 2, halb * 2), Color(1.0, 0.85, 0.3, 1.0), false, 2.0)
			draw_string(font, Vector2(0, 7), "K", HORIZONTAL_ALIGNMENT_CENTER, -1, 18, Color(0.1, 0.08, 0.0))
