extends Control

@onready var main_ui = $MainUI
@onready var settings_ui = $SettingsUI
@onready var char_ui = $CharSelectUI

func _ready():
    main_ui.visible = true
    settings_ui.visible = false
    char_ui.visible = false

func _on_new_game_pressed():
    get_tree().change_scene_to_file("res://Main.tscn")

func _on_settings_pressed():
    main_ui.visible = false
    settings_ui.visible = true

func _on_char_select_pressed():
    main_ui.visible = false
    char_ui.visible = true

func _on_back_pressed():
    main_ui.visible = true
    settings_ui.visible = false
    char_ui.visible = false

func _on_exit_pressed():
    get_tree().quit()

func _on_char_chosen(index: int):
    Global.selected_char = index
    $CharSelectUI/StatusLabel.text = "Karakter " + str(index + 1) + " Dipilih"
