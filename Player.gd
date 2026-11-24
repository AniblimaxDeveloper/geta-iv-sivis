extends CharacterBody3D

@export var speed: float = 15.0
@export var jump_force: float = 10.0
@export var gravity: float = 30.0

var money: int = 248750
var health: float = 100.0
var armor: float = 100.0
var stamina: float = 100.0
var input_dir: Vector2 = Vector2.ZERO
var current_vehicle: VehicleBody3D = null
var walk_time: float = 0.0

@onready var mesh_root = $MeshRoot
@onready var left_leg = $MeshRoot/LeftLeg
@onready var right_leg = $MeshRoot/RightLeg
@onready var left_arm = $MeshRoot/LeftArm
@onready var right_arm = $MeshRoot/RightArm

func _physics_process(delta):
    if current_vehicle:
        if input_dir.y > 0:
            current_vehicle.brake = input_dir.y * 15.0
            current_vehicle.engine_force = 0
        else:
            current_vehicle.brake = 0
            current_vehicle.engine_force = -input_dir.y * 2500.0
        current_vehicle.steering = -input_dir.x * 0.6
        global_position = current_vehicle.global_position + Vector3(0, 3.0, 0)
        mesh_root.visible = false
        return

    mesh_root.visible = true
    if not is_on_floor(): velocity.y -= gravity * delta

    var direction = (global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    direction.y = 0
    direction = direction.normalized()

    if direction:
        velocity.x = direction.x * speed
        velocity.z = direction.z * speed
        var target_angle = atan2(-direction.x, -direction.z)
        mesh_root.rotation.y = lerp_angle(mesh_root.rotation.y, target_angle, 0.2)
        
        walk_time += delta * 15.0
        left_leg.rotation.x = sin(walk_time) * 0.7
        right_leg.rotation.x = -sin(walk_time) * 0.7
        left_arm.rotation.x = -sin(walk_time) * 0.5
        right_arm.rotation.x = sin(walk_time) * 0.5
    else:
        velocity.x = move_toward(velocity.x, 0, speed)
        velocity.z = move_toward(velocity.z, 0, speed)
        left_leg.rotation.x = lerp(left_leg.rotation.x, 0.0, 0.2)
        right_leg.rotation.x = lerp(right_leg.rotation.x, 0.0, 0.2)
        left_arm.rotation.x = lerp(left_arm.rotation.x, 0.0, 0.2)
        right_arm.rotation.x = lerp(right_arm.rotation.x, 0.0, 0.2)

    move_and_slide()

func interact():
    if current_vehicle:
        current_vehicle = null
    else:
        var vehicles = get_tree().get_nodes_in_group("vehicles")
        for v in vehicles:
            if global_position.distance_to(v.global_position) < 8.0:
                current_vehicle = v
                break
