extends CharacterBody3D
var speed: float = 4.0
var direction: Vector3
var time_to_change: float = 0.0
var is_panicking: bool = false
@onready var leg_l = $MeshRoot/LegL
@onready var leg_r = $MeshRoot/LegR
var walk_t: float = 0.0
var target_player: Node3D

func _ready(): 
    randomize_dir()
    target_player = get_node_or_null("../../Player")

func randomize_dir():
    direction = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
    time_to_change = randf_range(3.0, 6.0)

func panic():
    if not is_panicking:
        is_panicking = true
        speed = 10.0 # Lari kencang
        time_to_change = 5.0

func _physics_process(delta):
    if not is_on_floor(): velocity.y -= 30.0 * delta
    time_to_change -= delta
    
    if is_panicking and target_player:
        # Lari menjauh dari pemain
        direction = (global_position - target_player.global_position).normalized()
        direction.y = 0
        if time_to_change <= 0:
            is_panicking = false
            speed = 4.0
            randomize_dir()
    elif time_to_change <= 0: 
        randomize_dir()
    
    velocity.x = direction.x * speed
    velocity.z = direction.z * speed
    move_and_slide()
    
    walk_t += delta * (20.0 if is_panicking else 10.0)
    if leg_l and leg_r:
        leg_l.rotation.x = sin(walk_t) * 0.5
        leg_r.rotation.x = -sin(walk_t) * 0.5
        
    if get_slide_collision_count() > 0 and not is_panicking: randomize_dir()
