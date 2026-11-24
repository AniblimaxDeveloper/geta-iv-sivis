extends CharacterBody3D
var speed: float = 5.0
var dir: Vector3
var timer: float = 0.0
var panicking: bool = false
var target: Node3D
@onready var leg_l = $MeshRoot/LegL
@onready var leg_r = $MeshRoot/LegR
var walk_t: float = 0.0

func _ready(): 
    randomize()
    target = get_node_or_null("../../Player")

func randomize():
    dir = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
    timer = randf_range(2.0, 5.0)

func panic():
    panicking = true
    speed = 12.0
    timer = 6.0

func _physics_process(delta):
    if not is_on_floor(): velocity.y -= 30.0 * delta
    timer -= delta
    
    if panicking and target:
        dir = (global_position - target.global_position).normalized()
        if timer <= 0:
            panicking = false
            speed = 5.0
            randomize()
    elif timer <= 0: randomize()
    
    velocity.x = dir.x * speed
    velocity.z = dir.z * speed
    move_and_slide()
    
    walk_t += delta * (25.0 if panicking else 10.0)
    if leg_l and leg_r:
        leg_l.rotation.x = sin(walk_t) * 0.6
        leg_r.rotation.x = -sin(walk_t) * 0.6
        
    if get_slide_collision_count() > 0 and not panicking: randomize()
