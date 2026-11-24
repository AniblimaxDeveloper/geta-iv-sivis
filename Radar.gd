extends Control
@onready var player = get_node_or_null("../../Player")

func _draw():
    var center = Vector2(100, 100)
    draw_circle(center, 90, Color(0, 0, 0, 0.7))
    draw_arc(center, 90, 0, TAU, 64, Color(0.5, 0.5, 0.5, 1), 3.0)
    if not player: return
    draw_circle(center, 5, Color(0.2, 0.6, 1)) # Player
    
    for p in get_tree().get_nodes_in_group("police"):
        var offset = (p.global_position - player.global_position) * 0.5
        if offset.length() < 90: draw_circle(center + Vector2(offset.x, offset.z), 4, Color(1, 0, 0))
