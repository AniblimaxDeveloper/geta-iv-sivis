extends Control

@onready var player = get_node_or_null("../../Player")

func _process(_delta):
    queue_redraw()

func _draw():
    var center = Vector2(100, 100)
    # Latar Radar
    draw_circle(center, 90, Color(0, 0, 0, 0.6))
    draw_arc(center, 90, 0, TAU, 64, Color(0.2, 0.8, 1, 0.8), 3.0)
    
    if not player: return

    # Titik Pemain (Warna Biru Muda)
    draw_circle(center, 5, Color(0.2, 1, 1))
    
    # Garis Arah Hadap Pemain
    var dir_line = center + Vector2(sin(player.mesh_root.rotation.y), cos(player.mesh_root.rotation.y)) * 15
    draw_line(center, dir_line, Color(0.2, 1, 1), 2.0)

    # Titik Polisi (Warna Merah)
    var police_list = get_tree().get_nodes_in_group("police")
    for p in police_list:
        var offset = (p.global_position - player.global_position) * 0.5
        if offset.length() < 90:
            draw_circle(center + Vector2(offset.x, offset.z), 4, Color(1, 0, 0))

    # Titik Misi (Warna Kuning)
    var missions = get_tree().get_nodes_in_group("missions")
    for m in missions:
        var offset = (m.global_position - player.global_position) * 0.5
        if offset.length() < 90:
            draw_circle(center + Vector2(offset.x, offset.z), 5, Color(1, 1, 0))
