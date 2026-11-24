extends CharacterBody3D

@export var speed: float = 15.0
@export var jump_force: float = 12.0
@export var gravity: float = 30.0

var money: int = 0
var input_dir: Vector2 = Vector2.ZERO
var is_dead: bool = false

@onready var camera = $SpringArm3D/Camera3D

func _physics_process(delta):
    if is_dead:
        return
        
    if not is_on_floor():
        velocity.y -= gravity * delta

    var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    
    if direction:
        velocity.x = direction.x * speed
        velocity.z = direction.z * speed
        var target_angle = atan2(-direction.x, -direction.z)
        rotation.y = lerp_angle(rotation.y, target_angle, 0.2)
    else:
        velocity.x = move_toward(velocity.x, 0, speed)
        velocity.z = move_toward(velocity.z, 0, speed)

    move_and_slide()

func jump():
    if is_on_floor():
        velocity.y = jump_force

func shoot():
    # Membuat garis tembakan dari tengah kamera
    var space_state = get_world_3d().direct_space_state
    var screen_center = get_viewport().get_visible_rect().size / 2
    var origin = camera.project_ray_origin(screen_center)
    var end = origin + camera.project_ray_normal(screen_center) * 100
    
    var query = PhysicsRayQueryParameters3D.create(origin, end)
    query.exclude = [self.get_rid()]
    
    var result = space_state.intersect_ray(query)
    
    if result and result.collider.has_method("take_damage"):
        result.collider.take_damage(50) # Damage 50

func add_money(amount: int):
    money += amount

func take_damage(amount: int):
    pass # Bisa ditambahkan sistem Health nanti
