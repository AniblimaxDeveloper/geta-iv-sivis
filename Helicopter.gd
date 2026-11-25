extends CharacterBody3D
var speed: float = 25.0
var target: Node3D
var time: float = 0.0

func _ready():
    target = get_node_or_null("../../Player")
    if not target: target = get_node_or_null("../Player")

func _physics_process(delta):
    if target:
        time += delta
        var dir = (target.global_position - global_position).normalized()
        velocity.x = dir.x * speed
        velocity.z = dir.z * speed
        velocity.y = sin(time * 2.0) * 5.0 # Naik turun perlahan
        move_and_slide()
        # Helikopter selalu menghadap pemain
        look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z), Vector3.UP)
