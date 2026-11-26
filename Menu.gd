extends Control

func _ready():
    $ProfilePanel/NameLabel.text = Global.player_name
    $ProfilePanel/LevelLabel.text = "LEVEL " + str(Global.player_level)
    $ProfilePanel/MoneyLabel.text = "$" + str(Global.player_money)

func _on_new_game_pressed():
    get_tree().change_scene_to_file("res://Main.tscn")

func _on_quit_pressed():
    get_tree().quit()

func _on_settings_pressed():
    $Popup.visible = true
    await get_tree().create_timer(2.0).timeout
    $Popup.visible = false

func _on_online_pressed():
    $Popup/Label.text = "CONNECTING TO DELTVA ONLINE..."
    $Popup.visible = true
    await get_tree().create_timer(2.0).timeout
    $Popup.visible = false
    $Popup/Label.text = "SERVER OFFLINE"
