extends Area3D
var main_node: Node

func _ready():
    body_entered.connect(_on_body_entered)
    # Putar terus agar terlihat keren
    set_process(true)

func _process(delta):
    rotate_y(delta * 2.0)

func _on_body_entered(body):
    if body.name == "Player":
        if main_node:
            main_node.complete_mission()
        queue_free()
