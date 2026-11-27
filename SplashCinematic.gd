extends Node3D

@onready var camera = $Camera3D
@onready var title = $UI/TitleLabel
@onready var skip_btn = $UI/SkipButton

func _ready():
    # Animasi Kamera: Bergerak dari jauh ke dekat gedung selama 20 detik
    var tween = create_tween()
    tween.tween_property(camera, "position", Vector3(0, 15, -60), 20.0).from(Vector3(0, 50, -150))
    tween.parallel().tween_property(camera, "rotation_degrees:x", -10.0, 20.0).from(-30.0)
    
    # Animasi Teks Muncul
    title.modulate.a = 0.0
    var t_text = create_tween()
    t_text.tween_property(title, "modulate:a", 1.0, 2.0).set_delay(2.0)
    
    # Tunggu 20 detik, lalu pindah ke Menu
    await get_tree().create_timer(20.0).timeout
    get_tree().change_scene_to_file("res://Menu.tscn")

func _on_skip_pressed():
    get_tree().change_scene_to_file("res://Menu.tscn")
