extends Control

func _ready():
	$Button.pressed.connect(_on_neu_starten)
	$Button2.pressed.connect(_on_hauptmenue)

func _on_neu_starten():
	get_tree().change_scene_to_file("res://base.tscn")

func _on_hauptmenue():
	get_tree().change_scene_to_file("res://hauptmenue.tscn")
