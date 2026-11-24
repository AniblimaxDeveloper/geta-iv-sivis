extends CharacterBody3D
var speed: float = 14.0
var target: Node3D
var health: int = 100
var shoot_cooldown: float = 2.0

func _ready():
    target = get_node_or_null("../../Player")
    if not target: target = get_node_or_null("../Player")

func _physics_process(delta):
    if not is_on_floor(): velocity.y -= 30.0 * delta
    shoot_cooldown -= delta
    
    if target and health > 0:
        var dir = (target.global_position - global_position)
        dir.y = 0
        var dist = dir.length()
        
        if dist > 15.0:
            dir = dir.normalized()
            velocity.x = dir.x * speed
            velocity.z = dir.z * speed
            rotation.y = atan2(-dir.x, -dir.z)
        else:
            velocity.x = 0
            velocity.z = 0
            if shoot_cooldown <= 0:
                shoot_cooldown = 2.0
                var main = get_node_or_null("../../Main")
                if main: main.player_take_damage(10)
    move_and_slide()

func take_damage(amount: int):
    health -= amount
    if health <= 0:
        queue_free()
