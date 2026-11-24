extends VehicleBody3D
var target_speed: float = 600.0
var time: float = 0.0
var ray: RayCast3D

func _ready():
    add_to_group("vehicles")
    ray = RayCast3D.new()
    ray.target_position = Vector3(0, 0, -8)
    add_child(ray)

func _physics_process(delta):
    if ray.is_colliding():
        brake = 15.0
        engine_force = 0
    else:
        brake = 0
        engine_force = target_speed
        
    time += delta
    if time > randf_range(4.0, 8.0):
        time = 0
        steering = randf_range(-0.4, 0.4)
