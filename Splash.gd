extends Control

@onready var logo = $LogoLabel
@onready var subtitle = $SubtitleLabel
@onready var loading_bar = $LoadingBar

func _ready():
    # Mulai dengan transparan (tidak terlihat)
    logo.modulate.a = 0.0
    subtitle.modulate.a = 0.0
    loading_bar.modulate.a = 0.0
    
    # Animasi Fade In
    var tween = create_tween()
    tween.tween_property(logo, "modulate:a", 1.0, 1.5)
    tween.parallel().tween_property(subtitle, "modulate:a", 1.0, 1.5).set_delay(0.5)
    tween.tween_property(loading_bar, "modulate:a", 1.0, 0.5)
    
    # Simulasi Loading
    await get_tree().create_timer(1.0).timeout
    loading_bar.value = 30
    await get_tree().create_timer(0.8).timeout
    loading_bar.value = 70
    await get_tree().create_timer(0.8).timeout
    loading_bar.value = 100
    await get_tree().create_timer(0.8).timeout
    
    # Pindah ke Menu
    get_tree().change_scene_to_file("res://Menu.tscn")
