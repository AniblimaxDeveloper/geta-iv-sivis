extends Control

func _ready():
    # Mengatur ukuran layar UI agar responsif
    set_anchors_preset(Control.PRESET_FULL_RECT)

func _on_new_game_pressed():
    get_tree().change_scene_to_file("res://Main.tscn")

func _on_quit_pressed():
    get_tree().quit()
