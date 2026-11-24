extends Area3D
var main_node: Node

func _ready():
    add_to_group("missions")
    body_entered.connect(_on_body_entered)

func _process(delta):
    rotate_y(delta * 2.0) # Berputar

func _on_body_entered(body):
    if body.name == "Player":
        if main_node:
            main_node.complete_mission()
        queue_free()
