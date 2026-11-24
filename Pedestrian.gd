extends CharacterBody3D

var speed: float = 4.0
var direction: Vector3
var time_to_change: float = 0.0

func _ready():
    randomize_direction()

func randomize_direction():
    direction = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
    time_to_change = randf_range(2.0, 5.0)

func _physics_process(delta):
    if not is_on_floor(): velocity.y -= 30.0 * delta
    
    time_to_change -= delta
    if time_to_change <= 0:
        randomize_direction()
        
    velocity.x = direction.x * speed
    velocity.z = direction.z * speed
    move_and_slide()
    
    if get_slide_collision_count() > 0:
        randomize_direction()
