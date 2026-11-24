extends CharacterBody3D

@export var speed: float = 15.0
@export var jump_velocity: float = 10.0
var money: int = 0
var input_dir: Vector2 = Vector2.ZERO

@onready var camera_arm = $SpringArm3D

func _physics_process(delta):
    # Gravitasi
    if not is_on_floor():
        velocity.y -= 30.0 * delta

    # Arah gerak berdasarkan kamera
    var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    
    if direction:
        velocity.x = direction.x * speed
        velocity.z = direction.z * speed
        # Putar karakter menghadap arah jalan
        var target_angle = atan2(-direction.x, -direction.z)
        rotation.y = lerp_angle(rotation.y, target_angle, 0.2)
    else:
        velocity.x = move_toward(velocity.x, 0, speed)
        velocity.z = move_toward(velocity.z, 0, speed)

    move_and_slide()

func add_money(amount: int):
    money += amount
