extends CharacterBody3D

var health: int = 100
var speed: float = 5.0
var target: Node3D
@export var gravity: float = 30.0

func _ready():
    # Mencari node Player
    target = get_node_or_null("../../Player")
    if not target:
        target = get_node_or_null("../Player")

func _physics_process(delta):
    if not is_on_floor():
        velocity.y -= gravity * delta
        
    if target and health > 0:
        var dir = (target.global_position - global_position).normalized()
        velocity.x = dir.x * speed
        velocity.z = dir.z * speed
        
        # Menghadap ke pemain
        var target_angle = atan2(-dir.x, -dir.z)
        rotation.y = lerp_angle(rotation.y, target_angle, 0.1)
        
    move_and_slide()

func take_damage(amount: int):
    health -= amount
    # Berkedip merah saat kena tembak
    $MeshInstance3D.material_override.albedo_color = Color(1, 0, 0)
    await get_tree().create_timer(0.1).timeout
    if health > 0:
        $MeshInstance3D.material_override.albedo_color = Color(1, 0.2, 0.2)
    
    if health <= 0:
        queue_free()
