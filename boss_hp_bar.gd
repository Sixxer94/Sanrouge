extends Control

var boss = null

func boss_setzen(b):
	boss = b
	visible = true

func _process(_delta):
	if boss != null and not is_instance_valid(boss):
		boss = null
		visible = false
	queue_redraw()

func _draw():
	if boss == null:
		return

	var bar_width = 400.0
	var bar_height = 18.0
	var x = 440.0
	var y = 40.0

	draw_rect(Rect2(x - 4, y - 20, bar_width + 8, bar_height + 26), Color(0, 0, 0, 0.82))
	draw_string(ThemeDB.fallback_font, Vector2(x, y - 6), boss.boss_name, HORIZONTAL_ALIGNMENT_CENTER, bar_width, 12, Color(1.0, 0.6, 0.6, 1.0))
	draw_rect(Rect2(x, y, bar_width, bar_height), Color(0.15, 0.0, 0.0, 1.0))

	var ratio = float(boss.hp) / float(boss.max_hp)
	if ratio > 0.0:
		var farbe = Color(0.9, 0.1, 0.1) if ratio > 0.5 else Color(1.0, 0.5, 0.0)
		draw_rect(Rect2(x, y, bar_width * ratio, bar_height), farbe)

	draw_rect(Rect2(x, y, bar_width, bar_height), Color(0.7, 0.3, 0.3, 0.9), false, 1.5)
