extends CharacterBody3D

var speed: float = 10.0
var target: Node3D
var health: int = 100

func _ready():
    target = get_node_or_null("../../Player")
    if not target: target = get_node_or_null("../Player")

func _physics_process(delta):
    if not is_on_floor():
        velocity.y -= 30.0 * delta

    if target and health > 0:
        var dir = (target.global_position - global_position)
        dir.y = 0
        if dir.length() > 0.1:
            dir = dir.normalized()
            velocity.x = dir.x * speed
            velocity.z = dir.z * speed
            var target_angle = atan2(-dir.x, -dir.z)
            rotation.y = lerp_angle(rotation.y, target_angle, 0.1)
    move_and_slide()

func take_damage(amount: int):
    health -= amount
    $MeshInstance3D.material_override.albedo_color = Color(1, 1, 1)
    await get_tree().create_timer(0.1).timeout
    if health > 0:
        $MeshInstance3D.material_override.albedo_color = Color(0, 0.5, 1)
    
    if health <= 0:
        queue_free()
