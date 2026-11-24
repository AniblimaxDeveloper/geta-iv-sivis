extends Control

@onready var player = get_node("../../Player")

func _draw():
    # Lingkaran Radar
    draw_circle(Vector2(100, 100), 90, Color(0, 0, 0, 0.5))
    draw_arc(Vector2(100, 100), 90, 0, TAU, 64, Color(1, 1, 1, 0.8), 2.0)
    
    # Titik Pemain (Tengah)
    draw_circle(Vector2(100, 100), 5, Color(0.2, 0.6, 1))
    
    # Cari Musuh/Polisi
    if player:
        var enemies = get_tree().get_nodes_in_group("police")
        for e in enemies:
            var offset = (e.global_position - player.global_position) * 0.5
            var dist = offset.length()
            if dist < 90:
                draw_circle(Vector2(100, 100) + Vector2(offset.x, offset.z), 3, Color(1, 0, 0))
