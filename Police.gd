extends CharacterBody3D

var speed: float = 9.0
var target: Node3D
var health: int = 100

func _ready():
    target = get_node_or_null("../../Player")
    if not target: target = get_node_or_null("../Player")

func _physics_process(delta):
    if not is_on_floor(): velocity.y -= 30.0 * delta

    if target and health > 0:
        var dir = (target.global_position - global_position)
        dir.y = 0
        if dir.length() > 1.5:
            dir = dir.normalized()
            velocity.x = dir.x * speed
            velocity.z = dir.z * speed
            rotation.y = atan2(-dir.x, -dir.z)
        else:
            velocity.x = 0
            velocity.z = 0
            if target.has_method("take_damage"):
                target.take_damage(10)
    move_and_slide()

func take_damage(amount: int):
    health -= amount
    $MeshInstance3D.material_override.albedo_color = Color(1, 1, 1)
    await get_tree().create_timer(0.1).timeout
    if health > 0:
        $MeshInstance3D.material_override.albedo_color = Color(0, 0.2, 1)
    else:
        queue_free()
