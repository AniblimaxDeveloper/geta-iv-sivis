extends Control
@onready var logo = $LogoLabel
@onready var loading_bar = $LoadingBar

func _ready():
    logo.modulate.a = 0.0
    loading_bar.modulate.a = 0.0
    
    var tween = create_tween()
    tween.tween_property(logo, "modulate:a", 1.0, 1.5)
    tween.tween_property(loading_bar, "modulate:a", 1.0, 0.5)
    
    await get_tree().create_timer(1.0).timeout
    loading_bar.value = 50
    await get_tree().create_timer(1.0).timeout
    loading_bar.value = 100
    await get_tree().create_timer(0.5).timeout
    
    get_tree().change_scene_to_file("res://Menu.tscn")
