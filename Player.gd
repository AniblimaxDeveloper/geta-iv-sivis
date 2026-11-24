extends CharacterBody3D

@export var speed: float = 15.0
@export var jump_force: float = 10.0
@export var gravity: float = 30.0

var money: int = 0
var health: float = 100.0
var ammo: int = 100
var input_dir: Vector2 = Vector2.ZERO
var current_vehicle: VehicleBody3D = null
var walk_time: float = 0.0

@onready var mesh_root = $MeshRoot
@onready var left_leg = $MeshRoot/LeftLeg
@onready var right_leg = $MeshRoot/RightLeg
@onready var left_arm = $MeshRoot/LeftArm
@onready var right_arm = $MeshRoot/RightArm
@onready var weapon = $MeshRoot/Weapon
@onready var camera_pivot = $CameraPivot
@onready var spring_arm = $CameraPivot/SpringArm3D
@onready var camera = $CameraPivot/SpringArm3D/Camera3D

func _physics_process(delta):
    if current_vehicle:
        current_vehicle.engine_force = -input_dir.y * 2000.0
        current_vehicle.steering = -input_dir.x * 0.6
        global_position = current_vehicle.global_position + Vector3(0, 3.0, 0)
        mesh_root.visible = false
        return

    mesh_root.visible = true
    if not is_on_floor(): velocity.y -= gravity * delta

    var direction = (camera_pivot.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
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

func jump():
    if is_on_floor() and not current_vehicle:
        velocity.y = jump_force

func shoot():
    if current_vehicle or ammo <= 0: return
    ammo -= 1
    
    # Efek visual tembakan
    weapon.visible = true
    await get_tree().create_timer(0.1).timeout
    weapon.visible = false

    var space_state = get_world_3d().direct_space_state
    var screen_center = get_viewport().get_visible_rect().size / 2
    var origin = camera.project_ray_origin(screen_center)
    var end = origin + camera.project_ray_normal(screen_center) * 100
    var query = PhysicsRayQueryParameters3D.create(origin, end)
    query.exclude = [self.get_rid()]
    var result = space_state.intersect_ray(query)
    
    if result and result.collider.has_method("take_damage"):
        result.collider.take_damage(50)
        var main = get_node_or_null("../../Main")
        if main: main.add_wanted_level()

func interact():
    if current_vehicle:
        current_vehicle = null
    else:
        var vehicles = get_tree().get_nodes_in_group("vehicles")
        for v in vehicles:
            if global_position.distance_to(v.global_position) < 8.0:
                current_vehicle = v
                break

func take_damage(amount: float):
    health -= amount
    if health <= 0: get_tree().reload_current_scene()

func add_money(amount: int): money += amount
