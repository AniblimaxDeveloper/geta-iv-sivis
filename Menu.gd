extends Control

@onready var main_buttons = $MainButtons
@onready var char_select = $CharacterSelect
@onready var popup = $PopupPanel

func _ready():
    char_select.visible = false
    popup.visible = false

func _on_new_game_pressed():
    get_tree().change_scene_to_file("res://Main.tscn")

func _on_character_select_pressed():
    main_buttons.visible = false
    char_select.visible = true

func _on_back_pressed():
    main_buttons.visible = true
    char_select.visible = false

func _on_char_selected(index: int):
    Global.selected_char = index
    popup.dialog_text = "Karakter " + str(index + 1) + " Dipilih!"
    popup.popup_centered()

func _on_online_pressed():
    popup.dialog_text = "Fitur ONLINE akan hadir di update selanjutnya."
    popup.popup_centered()

func _on_exit_pressed():
    get_tree().quit()
