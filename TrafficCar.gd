extends VehicleBody3D
var speed: float = 600.0
var time: float = 0.0

func _physics_process(delta):
    engine_force = speed
    time += delta
    if time > randf_range(5.0, 10.0):
        time = 0
        steering = randf_range(-0.5, 0.5)
