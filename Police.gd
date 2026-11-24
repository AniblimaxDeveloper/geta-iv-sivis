extends CharacterBody3D
var speed: float = 16.0
var target: Node3D
var health: int = 100
var shoot_cd: float = 1.5

func _ready():
    target = get_node_or_null("../../Player")
    if not target: target = get_node_or_null("../Player")

func _physics_process(delta):
    if not is_on_floor(): velocity.y -= 30.0 * delta
    shoot_cd -= delta
    
    if target and health > 0:
        var dir = (target.global_position - global_position)
        dir.y = 0
        if dir.length() > 20.0:
            dir = dir.normalized()
            velocity.x = dir.x * speed
            velocity.z = dir.z * speed
            rotation.y = atan2(-dir.x, -dir.z)
        else:
            velocity.x = 0
            velocity.z = 0
            if shoot_cd <= 0:
                shoot_cd = 1.5
                if target.has_method("take_damage"): target.take_damage(15)
    move_and_slide()

func take_damage(amount: int):
    health -= amount
    if health <= 0: queue_free()
