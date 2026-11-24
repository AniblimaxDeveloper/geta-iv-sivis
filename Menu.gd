extends Control

@onready var main_buttons = $MainButtons
@onready var char_select = $CharacterSelect
@onready var popup = $PopupPanel
@onready var popup_label = $PopupPanel/Label

func _ready():
    # Sembunyikan menu sekunder saat mulai
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
    show_popup("Karakter " + str(index + 1) + " Dipilih!")

func _on_online_pressed():
    show_popup("Fitur ONLINE akan hadir di update selanjutnya.")

func _on_exit_pressed():
    get_tree().quit()

func show_popup(text: String):
    popup_label.text = text
    popup.visible = true
    await get_tree().create_timer(2.0).timeout
    popup.visible = false
