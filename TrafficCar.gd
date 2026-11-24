extends VehicleBody3D
var target_speed: float = 600.0
var time: float = 0.0
var ray: RayCast3D
var health: float = 100.0

func _ready():
    add_to_group("vehicles")
    ray = RayCast3D.new()
    ray.target_position = Vector3(0, 0, -6)
    add_child(ray)

func _physics_process(delta):
    if health <= 0: return
    
    if ray.is_colliding():
        brake = 10.0
        engine_force = 0
    else:
        brake = 0
        engine_force = target_speed
        
    time += delta
    if time > randf_range(5.0, 10.0):
        time = 0
        steering = randf_range(-0.3, 0.3)

func take_damage(amount: float):
    health -= amount
    if health <= 0:
        queue_free()
