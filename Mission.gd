extends Area3D
var main: Node

func _ready():
    add_to_group("missions")
    body_entered.connect(_on_body_entered)
    set_process(true)

func _process(delta):
    rotate_y(delta * 2.0)

func _on_body_entered(body):
    if body.name == "Player":
        if main: main.complete_mission()
        queue_free()
